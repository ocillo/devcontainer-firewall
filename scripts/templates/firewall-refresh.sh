#!/usr/bin/env bash
set -euo pipefail

readonly DOC_README_URL="https://github.com/ocillo/devcontainer-firewall#readme"
readonly DOC_USAGE_URL="https://github.com/ocillo/devcontainer-firewall/blob/main/docs/usage.md"
readonly doc_hint="Docs: ${DOC_README_URL} • ${DOC_USAGE_URL}"

usage() {
  cat <<USAGE
Usage: ./scripts/firewall-refresh.sh

Re-run the devcontainer firewall initialiser with the required environment
variables preserved. The init script now downloads the shared allowlist on
every run and exits loudly if it cannot fetch the latest list.

Need more detail? See:
  - ${DOC_README_URL}
  - ${DOC_USAGE_URL}
USAGE
}

while [[ $# -gt 0 ]]; do
  arg="$1"
  shift

  case "$arg" in
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      usage
      exit 1
      ;;
  esac
done

readonly init_script="${FIREWALL_INIT_SCRIPT:-/usr/local/bin/init-firewall.sh}"

if [[ -z "${FIREWALL_ALLOWLIST_URL:-}" ]]; then
  echo "WARNING: FIREWALL_ALLOWLIST_URL is not set. The firewall will fall back to the baseline allowlist only." >&2
  echo "${doc_hint}"
fi

preserve_vars=(
  FIREWALL_ALLOWLIST_URL
  FIREWALL_ALLOWLIST_REF
  FIREWALL_ALLOWLIST_LOCAL
)
preserve_arg=$(IFS=,; echo "${preserve_vars[*]}")

echo "Re-applying firewall rules via ${init_script}"
sudo --preserve-env="${preserve_arg}" "$init_script"
echo "Refresh complete. ${doc_hint}"
