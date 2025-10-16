#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${FIREWALL_ALLOWLIST_URL:-}" ]]; then
  echo "ERROR: FIREWALL_ALLOWLIST_URL is not set. Export it to the raw GitHub URL of the shared allowlist." >&2
  exit 1
fi

readonly ref="${FIREWALL_ALLOWLIST_REF:-main}"
readonly url="${FIREWALL_ALLOWLIST_URL}"
readonly cache_dir="${FIREWALL_ALLOWLIST_CACHE_DIR:-$HOME/.claude/firewall-cache}"
readonly init_script="${FIREWALL_INIT_SCRIPT:-/usr/local/bin/init-firewall.sh}"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

mkdir -p "$cache_dir"

echo "Fetching allowlist from ${url}…"
if curl --fail --retry 3 --retry-delay 1 --silent --show-error "$url" -o "$tmp"; then
  mv "$tmp" "${cache_dir}/global.txt"
  chmod 0644 "${cache_dir}/global.txt"
  echo "Allowlist cached at ${cache_dir}/global.txt"
else
  echo "WARNING: download failed; keeping existing cached copy (if any)." >&2
fi

echo "Re-applying firewall rules via ${init_script}"
sudo "$init_script"
