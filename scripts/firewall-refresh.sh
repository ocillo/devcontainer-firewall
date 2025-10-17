#!/usr/bin/env bash
set -euo pipefail

readonly doc_hint="Docs: README.md (Devcontainer integration) • docs/usage.md"

usage() {
  cat <<'USAGE'
Usage: ./scripts/firewall-refresh.sh [--no-download]

Fetch the shared allowlist (unless --no-download) and re-run the devcontainer
firewall initialiser with the required environment variables preserved.

Options:
  --no-download   Skip the download step and just re-run the firewall script.

Need more detail? See README.md and docs/usage.md.
USAGE
}

download_allowlist=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-download)
      download_allowlist=false
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
  shift
done

if [[ -z "${FIREWALL_ALLOWLIST_URL:-}" ]]; then
  echo "ERROR: FIREWALL_ALLOWLIST_URL is not set. Export it to the raw GitHub URL of the shared allowlist." >&2
  echo "${doc_hint}"
  exit 1
fi

readonly ref="${FIREWALL_ALLOWLIST_REF:-main}"
readonly url="${FIREWALL_ALLOWLIST_URL}"
readonly cache_dir="${FIREWALL_ALLOWLIST_CACHE_DIR:-$HOME/.claude/firewall-cache}"
readonly init_script="${FIREWALL_INIT_SCRIPT:-/usr/local/bin/init-firewall.sh}"

mkdir -p "$cache_dir"

if "$download_allowlist"; then
  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' EXIT

  echo "Fetching allowlist from ${url}…"
  if curl --fail --retry 3 --retry-delay 1 --silent --show-error "$url" -o "$tmp"; then
    mv "$tmp" "${cache_dir}/global.txt"
    chmod 0644 "${cache_dir}/global.txt"
    echo "Allowlist cached at ${cache_dir}/global.txt"
  else
    echo "WARNING: download failed; keeping existing cached copy (if any)." >&2
  fi
fi

preserve_vars=(
  FIREWALL_ALLOWLIST_URL
  FIREWALL_ALLOWLIST_REF
  FIREWALL_ALLOWLIST_CACHE_DIR
  FIREWALL_ALLOWLIST_LOCAL
)
preserve_arg=$(IFS=,; echo "${preserve_vars[*]}")

echo "Re-applying firewall rules via ${init_script}"
sudo --preserve-env="${preserve_arg}" "$init_script"
echo "Refresh complete. ${doc_hint}"
