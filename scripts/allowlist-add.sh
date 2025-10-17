#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
allowlist_file="${repo_root}/allowlists/global.txt"
validate_script="${script_dir}/validate-allowlist.sh"

readonly repo_doc_hint="See README.md (Project overrides & workflow)."

usage() {
  cat <<'USAGE'
Usage: ./scripts/allowlist-add.sh <domain-or-cidr>

Adds the entry to allowlists/global.txt (if it is not already present),
then re-runs the validation script to sort/dedupe the list.

Need a refresher? All helper scripts accept --help and the full workflow
is documented in README.md and docs/usage.md.
USAGE
}

entry=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [[ -n "$entry" ]]; then
        echo "Multiple entries provided. Only one domain/CIDR at a time." >&2
        exit 1
      fi
      entry="$(printf '%s' "$1" | tr 'A-Z' 'a-z')" # normalise to lowercase
      ;;
  esac
  shift
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
