#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "init-firewall.sh must be run as root (use sudo)." >&2
  exit 1
fi

on_error() {
  echo "ERROR: firewall initialization failed; resetting default iptables policies to ACCEPT." >&2
  iptables -P INPUT ACCEPT || true
  iptables -P FORWARD ACCEPT || true
  iptables -P OUTPUT ACCEPT || true
}
trap on_error ERR

if [[ "${FIREWALL_DISABLE:-0}" == "1" ]]; then
  echo "Firewall disabled via FIREWALL_DISABLE=1. Reason: ${FIREWALL_DISABLE_REASON:-not provided}" >&2
  exit 0
fi

: "${FIREWALL_ALLOWLIST_REF:=main}"
: "${FIREWALL_ALLOWLIST_LOCAL:=}"

if [[ -n "${FIREWALL_ALLOWLIST_CACHE_DIR:-}" ]]; then
  echo "NOTE: FIREWALL_ALLOWLIST_CACHE_DIR is deprecated and ignored; the allowlist is fetched fresh on every run." >&2
fi

if [[ -z "${FIREWALL_ALLOWLIST_URL:-}" ]]; then
  echo "WARNING: FIREWALL_ALLOWLIST_URL not set. Falling back to baseline allowlist only." >&2
fi

# Ensure prior DROP policies don't block downloads while we rebuild the ruleset
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

BASELINE_FILE="$(mktemp)"
MERGED_FILE="$(mktemp)"
DOWNLOAD_FILE="$(mktemp)"
trap 'rm -f "$BASELINE_FILE" "$MERGED_FILE" "$DOWNLOAD_FILE"' EXIT

cat <<'BASELINE_EOF' >"$BASELINE_FILE"
api.anthropic.com
claude.ai
marketplace.visualstudio.com
registry.npmjs.org
sentry.io
statsig.anthropic.com
statsig.com
update.code.visualstudio.com
vscode.blob.core.windows.net
BASELINE_EOF

remote_file=""
remote_status="missing"
remote_warning=""

if [[ -n "${FIREWALL_ALLOWLIST_URL:-}" ]]; then
  echo "Fetching shared allowlist from ${FIREWALL_ALLOWLIST_URL}..."
  if curl --fail --retry 3 --retry-delay 1 --silent --show-error "$FIREWALL_ALLOWLIST_URL" -o "$DOWNLOAD_FILE"; then
    remote_file="$DOWNLOAD_FILE"
    remote_status="remote@${FIREWALL_ALLOWLIST_REF}"
  else
    remote_warning="failed to download ${FIREWALL_ALLOWLIST_URL}"
  fi
else
  remote_warning="FIREWALL_ALLOWLIST_URL not set"
fi

local_label="local overrides: none"
local_warning=""

if [[ -n "${FIREWALL_ALLOWLIST_LOCAL:-}" ]]; then
  if [[ -f "$FIREWALL_ALLOWLIST_LOCAL" ]]; then
    local_label="local overrides: ${FIREWALL_ALLOWLIST_LOCAL}"
  else
    local_label="local overrides: ${FIREWALL_ALLOWLIST_LOCAL} (missing)"
    local_warning="specified FIREWALL_ALLOWLIST_LOCAL file not found"
  fi
fi

{
  cat "$BASELINE_FILE"
  if [[ -n "$remote_file" ]]; then cat "$remote_file"; fi
  if [[ -n "${FIREWALL_ALLOWLIST_LOCAL:-}" && -f "$FIREWALL_ALLOWLIST_LOCAL" ]]; then cat "$FIREWALL_ALLOWLIST_LOCAL"; fi
} | sed 's/\r$//' | grep -E '^[^#[:space:]]' | LC_ALL=C sort -u >"$MERGED_FILE"

if [[ ! -s "$MERGED_FILE" ]]; then
  echo "ERROR: computed allowlist is empty. Aborting." >&2
  exit 1
fi

summary_remote=$([[ "$remote_status" == "missing" ]] && echo "remote@${FIREWALL_ALLOWLIST_REF} (unavailable)" || echo "$remote_status")
echo "Allowlist sources: baseline, ${summary_remote}, ${local_label}"
echo "Docs: https://github.com/ocillo/devcontainer-firewall#readme"

if [[ -n "$remote_warning" ]]; then
  fallback_context="baseline only"
  if [[ -n "${FIREWALL_ALLOWLIST_LOCAL:-}" && -f "$FIREWALL_ALLOWLIST_LOCAL" ]]; then
    fallback_context="baseline + local overrides"
  fi
  echo "WARNING: ${remote_warning}. FALLING BACK TO ${fallback_context^^}. New shared allowlist entries are NOT active." >&2
fi

if [[ -n "$local_warning" ]]; then
  echo "WARNING: ${local_warning}." >&2
fi

# Preserve Docker DNS NAT rules
DOCKER_DNS_RULES=$(iptables-save -t nat | grep "127\.0\.0\.11" || true)

# Reset iptables/ipset state
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
ipset destroy allowed-domains 2>/dev/null || true

if [[ -n "$DOCKER_DNS_RULES" ]]; then
  echo "Restoring Docker DNS rules..."
  iptables -t nat -N DOCKER_OUTPUT 2>/dev/null || true
  iptables -t nat -N DOCKER_POSTROUTING 2>/dev/null || true
  echo "$DOCKER_DNS_RULES" | xargs -L 1 iptables -t nat
else
  echo "No Docker DNS rules to restore."
fi

# Allow DNS, SSH, loopback
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

ipset create allowed-domains hash:net || true

echo "Fetching GitHub IP ranges..."
gh_ranges=$(curl -s https://api.github.com/meta || true)
if [[ -n "$gh_ranges" ]] && echo "$gh_ranges" | jq -e '.web and .api and .git' >/dev/null 2>&1; then
  for cidr in $(echo "$gh_ranges" | jq -r '(.web + .api + .git)[]'); do
    if [[ -n "$cidr" ]]; then
      ipset add allowed-domains "$cidr" 2>/dev/null || true
    fi
  done
else
  echo "WARNING: could not fetch GitHub IP ranges; git operations may require manual allowlist entries." >&2
fi

# Helper to resolve hostname to IPv4 and add to ipset (logs when IPv6 is present)
add_hostname_to_ipset() {
  local host="$1"
  local resolved=0

  while read -r ip; do
    if [[ -n "$ip" ]]; then
      ipset add allowed-domains "$ip" 2>/dev/null || true
      resolved=1
    fi
  done < <(dig +time=2 +tries=1 +short "$host" A 2>/dev/null || true)

  if [[ $resolved -eq 0 ]]; then
    echo "WARNING: no IPv4 DNS records found for $host" >&2
  fi

  local ipv6_records
  ipv6_records=$(dig +time=2 +tries=1 +short "$host" AAAA 2>/dev/null || true)
  if [[ -n "$ipv6_records" ]]; then
    echo "NOTE: IPv6 records detected for $host but ignored; firewall currently allows IPv4 destinations only." >&2
  fi
}

HOSTS=0
CIDRS=0

while read -r entry; do
  [[ -z "$entry" ]] && continue
  if [[ "$entry" == *"/"* ]]; then
    ipset add allowed-domains "$entry" 2>/dev/null || true
    CIDRS=$((CIDRS + 1))
  else
    add_hostname_to_ipset "$entry"
    HOSTS=$((HOSTS + 1))
  fi
done <"$MERGED_FILE"

# Detect host network (assumes /24)
HOST_IP=$(ip route | awk '/default/ {print $3; exit}')
if [[ -n "$HOST_IP" ]]; then
  HOST_NETWORK=$(echo "$HOST_IP" | sed 's/\.[0-9]\{1,3\}$/.0\/24/')
  iptables -A INPUT -s "$HOST_NETWORK" -j ACCEPT
  iptables -A OUTPUT -d "$HOST_NETWORK" -j ACCEPT
fi

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m set --match-set allowed-domains dst -j ACCEPT
iptables -A OUTPUT -j REJECT --reject-with icmp-admin-prohibited

echo "Allowlist entries applied: ${HOSTS} hostnames, ${CIDRS} CIDR ranges"
echo "Verifying firewall rules..."

if curl --connect-timeout 5 https://example.com >/dev/null 2>&1; then
  echo "ERROR: firewall verification failed (able to reach https://example.com)" >&2
  exit 1
fi

if ! curl --connect-timeout 5 https://api.github.com/zen >/dev/null 2>&1; then
  echo "ERROR: firewall verification failed (unable to reach https://api.github.com)" >&2
  exit 1
fi

echo "Firewall verification passed."
