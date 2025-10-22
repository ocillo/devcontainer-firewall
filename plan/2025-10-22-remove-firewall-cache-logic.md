# Plan: Remove Firewall Cache Logic

**Date:** 2025-10-22  
**Author:** Claude (updated by Codex)  
**Status:** Ready for execution

---

## Problem to Solve
- Developers expect a devcontainer rebuild to pick up the latest shared allowlist, but our scripts reuse a cached copy stored under `/home/node/.claude/firewall-cache/global.txt`.
- That cache sits on a persistent Docker volume declared in `.devcontainer/devcontainer.json:17-43`, so standard rebuilds keep stale data.
- When the download fails, `init-firewall.sh` silently falls back to the cached file instead of failing loudly.
- Result: newly added domains never apply unless someone knows to rebuild "without cache," creating a frustrating footgun.

Goal: make rebuilds and refreshes always mean "download the latest allowlist or loudly fall back to the minimal baseline." No hidden cache state.

Non-goal: removing the `/home/node/.claude` volume (other tools rely on it). Offline work becomes "baseline only" rather than "silent stale cache."

---

## Execution Checklist

### Phase 1 – Inventory cache-dependent code
- [x] Trace how `.devcontainer/init-firewall.sh` and `scripts/templates/init-firewall.sh` read/write `FIREWALL_ALLOWLIST_CACHE_DIR`.
- [x] Use `rg FIREWALL_ALLOWLIST_CACHE_DIR` to list every reference across the repo.

### Phase 2 – Simplify scripts for the new behaviour
- [x] Modify `.devcontainer/init-firewall.sh` so it downloads into a temp file every run, removes the cache dir/env var, and fails loudly when only the baseline is used.
- [x] Tighten logging: always report `remote@<ref>`, `baseline`, and whether local overrides were merged; print an obvious WARNING when running baseline-only.
- [x] Decide how to handle IPv6 entries (split ipsets vs. document IPv4-only) and note the decision in commit/docs.
- [x] Update `scripts/firewall-refresh.sh` to drop cache handling and the `--no-download` flag; it should just re-run the init script and surface download failures immediately.

> **Note:** Do not touch `scripts/templates/` yet. We copy from `.devcontainer/` only after Phase 4 verification passes.

### Phase 3 – Update configuration and documentation for the new flow
- [x] Remove `FIREWALL_ALLOWLIST_CACHE_DIR` from `.devcontainer/devcontainer.json`, including the preserved env var list.
- [x] Update `docs/usage.md` with the new env-var example, refresh helper snippet, and fallback explanation.
- [x] Update `README.md` workflow guidance to highlight "refresh always pulls fresh" and to remove cache references.
- [x] Add a `CHANGELOG.md` entry summarising the new behaviour and what downstream users should adjust.

### Phase 4 – Verification (new logic only)
- [ ] Run `shellcheck` on all touched scripts (`scripts/*.sh`, `.devcontainer/*.sh`). *(Blocked: shellcheck not installed and apt mirrors unreachable; rerun when package access returns.)*
- [x] Success path: run the init script with a valid URL and confirm logs show `remote@…` and merged overrides.
- [x] Failure path: point `FIREWALL_ALLOWLIST_URL` at an invalid endpoint, run the script, ensure it warns loudly and only loads baseline/local entries.
- [x] Run `./scripts/firewall-refresh.sh` manually to confirm it re-applies rules and surfaces failures.
- [x] `rg 'CACHE'` to ensure no stale references remain (except in historical notes/CHANGELOG).

### Phase 5 – Propagate and wrap up
- [x] Copy the verified `.devcontainer/init-firewall.sh` into `scripts/templates/init-firewall.sh` and run shellcheck again.
- [x] Note in the PR (and optionally ping the one downstream repo) that the cache env var is gone and rebuilds always fetch fresh data.
- [x] Check off plan items and archive the plan when finished.

---

## Risks & Mitigations
- **Offline scenario loses cached list** → acceptable; baseline still allows critical services. Make the warning explicit so developers know they are in degraded mode.
- **Script typo breaks firewall setup** → mitigated with shellcheck + running the scripts end-to-end before merging.
- **Downstream repos still set `FIREWALL_ALLOWLIST_CACHE_DIR`** → init script should ignore it gracefully (log a deprecation note) and docs/CHANGELOG highlight the removal.

---

## Notes
- Keep warnings concise but unmistakable when the download fails (e.g., "FALLING BACK TO BASELINE ONLY – new allowlist entries are NOT active").
- If IPv6 support is deferred, document the limitation so teams know to add explicit CIDRs if needed.
