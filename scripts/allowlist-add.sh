#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
allowlist_file="${repo_root}/allowlists/global.txt"
validate_script="${script_dir}/validate-allowlist.sh"

readonly DOC_README_URL="https://github.com/ocillo/devcontainer-firewall#readme"
readonly DOC_USAGE_URL="https://github.com/ocillo/devcontainer-firewall/blob/main/docs/usage.md"
readonly repo_doc_hint="See ${DOC_README_URL} (project workflow) and ${DOC_USAGE_URL} (devcontainer integration)."

usage() {
  cat <<USAGE
Usage: ./scripts/allowlist-add.sh <domain-or-cidr>

Adds the entry to allowlists/global.txt (if it is not already present),
then re-runs the validation script to sort/dedupe the list.

Need a refresher? All helper scripts accept --help and the full workflow
is documented in:
  - ${DOC_README_URL}
  - ${DOC_USAGE_URL}
USAGE
}

entry=""

while [[ $# -gt 0 ]]; do
  arg="$1"
  shift

  case "$arg" in
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [[ -n "$entry" ]]; then
        echo "Multiple entries provided. Only one domain/CIDR at a time." >&2
        exit 1
      fi
      entry="$(printf '%s' "$arg" | tr '[:upper:]' '[:lower:]')" # normalise to lowercase
      ;;
  esac
done

if [[ -z "$entry" ]]; then
  echo "No domain/CIDR supplied." >&2
  usage
  exit 1
fi

if [[ ! -f "$allowlist_file" ]]; then
  echo "Allowlist file not found at $allowlist_file" >&2
  exit 1
fi

if grep -Fxq "$entry" "$allowlist_file"; then
  echo "Entry '$entry' already present in global allowlist. Nothing to do. ${repo_doc_hint}"
  exit 0
fi

printf '%s\n' "$entry" >>"$allowlist_file"

echo "Added '$entry' to allowlists/global.txt"
echo "Reformatting + validating…"
"$validate_script" --file "$allowlist_file" --fix

echo "Done. ${repo_doc_hint}"
