#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
repo_doc_hint="Docs: README.md (Everyday tasks) • docs/usage.md"

file="${repo_root}/allowlists/global.txt"
do_fix=false
do_resolve=false

required_entries=(
  "api.anthropic.com"
  "claude.ai"
  "sentry.io"
  "statsig.anthropic.com"
  "statsig.com"
)

usage() {
  cat <<'USAGE'
Usage: ./scripts/validate-allowlist.sh [--file path] [--fix] [--resolve]

Checks formatting, duplicates, and required entries for an allowlist file.
--fix      rewrite the file with sorted, deduplicated entries.
--resolve  attempt DNS resolution for hostnames (warn-only).

Docs: README.md (Everyday tasks) and docs/usage.md.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)
      shift || { echo "Missing value for --file" >&2; exit 1; }
      file="$1"
      ;;
    --fix)
      do_fix=true
      ;;
    --resolve)
      do_resolve=true
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

if [[ ! -f "$file" ]]; then
  echo "Allowlist file not found: $file" >&2
  exit 1
fi

comments=()
while IFS= read -r line; do
  comments+=("$line")
done < <(awk '/^#/ { print }' "$file")

entries=()
while IFS= read -r line; do
  entries+=("$line")
done < <(awk '!/^#/ { sub(/[[:space:]]+$/, "", $0); if (length($0) > 0) print }' "$file")

if [[ ${#entries[@]} -eq 0 ]]; then
  echo "ERROR: allowlist contains no entries ($file)" >&2
  exit 1
fi

sorted_entries=()
if [[ ${#entries[@]} -gt 0 ]]; then
  while IFS= read -r line; do
    sorted_entries+=("$line")
  done < <(printf '%s\n' "${entries[@]}" | LC_ALL=C sort -u)
fi

joined_original="$(printf '%s\n' "${entries[@]}")"
joined_sorted="$(printf '%s\n' "${sorted_entries[@]}")"

if [[ "$joined_original" != "$joined_sorted" ]]; then
  if "$do_fix"; then
    {
      printf '%s\n' "${comments[@]}"
      if [[ ${#comments[@]} -gt 0 ]]; then
        printf '\n'
      fi
      printf '%s\n' "${sorted_entries[@]}"
    } >"$file"
    echo "Normalised allowlist: sorted + deduplicated ($file)"
  else
    echo "ERROR: allowlist not sorted or contains duplicates. Run with --fix." >&2
    exit 1
  fi
fi

missing_required=0
for req in "${required_entries[@]}"; do
  if ! grep -Fxq "$req" "$file"; then
    echo "ERROR: required entry missing -> $req" >&2
    missing_required=1
  fi
done

if [[ $missing_required -ne 0 ]]; then
  exit 1
fi

if "$do_resolve"; then
  if ! command -v dig >/dev/null 2>&1; then
    echo "WARNING: dig not available; skipping resolution checks" >&2
  else
    echo "Attempting DNS resolution…"
    while IFS= read -r entry; do
      [[ -z "$entry" ]] && continue
      [[ "$entry" == \#* ]] && continue
      if [[ "$entry" == *"/"* ]]; then
        # CIDR: skip resolution
        continue
      fi
      if ! dig +time=2 +tries=1 +short A "$entry" >/dev/null 2>&1; then
        echo "WARNING: DNS lookup returned no A records for $entry" >&2
      fi
    done <"$file"
  fi
fi

echo "Allowlist validation passed ($file). ${repo_doc_hint}"
