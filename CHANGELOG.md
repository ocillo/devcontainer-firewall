# Changelog
All notable changes to this project will be documented in this file.

The format loosely follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and dates use ISO 8601 (YYYY-MM-DD).
We cut date-based releases: move entries from `Unreleased` into a `## [vYYYY.MM.DD] – YYYY-MM-DD`
section and tag the commit `vYYYY.MM.DD`. Leave `Unreleased` empty between releases.

## [Unreleased]

## [v2025.10.22] – 2025-10-22
### Added
- Provide `scripts/templates/` copies of `setup-firewall.sh` and `init-firewall.sh` plus a project `.devcontainer/` for validating shared firewall changes locally.
- Add `auth.openai.com` to the shared `allowlists/global.txt` and record it in `docs/allowlist-registry.md` (required for OpenAI authentication flows).
- Add `chatgpt.com` to the shared allowlist and document it in the registry (new ChatGPT routing domain).

### Changed
- Update README and usage guide to point consumers at the new templates.
- Point helper script hints to the canonical GitHub documentation.
- `.devcontainer/init-firewall.sh` now fetches the shared allowlist fresh on every run, logs the exact sources used, and falls back loudly to the bundled baseline (IPv4-only) when the download fails.
- `scripts/firewall-refresh.sh` delegates downloads to the init script so refreshes surface failures immediately.

### Removed
- Drop the legacy `.devcontainer.example/` snapshot in favour of the shared templates.
- The `FIREWALL_ALLOWLIST_CACHE_DIR` environment variable and all cache-based fallback logic.

## [v2025.10.17] – 2025-10-17
### Added
- Document shared vs. per-project responsibilities in README.
- Add documentation hints to helper scripts and init-firewall logging.
- Introduce `CHANGELOG.md` to track future updates.
- Establish `docs/allowlist-registry.md` as the single location for pending/approved/removed allowlist entries (includes Svelte/Shadcn/Tailwind rationale).
- Promote the shared tooling/docs hostnames into `allowlists/global.txt` and `docs/allowlist-registry.md` (Ocillo team feat. Codex & Claude).

### Changed
- Clarify `docs/usage.md` entry point for quick navigation.
- Enhance helper script `--help` output with links to docs.
- Note IP-based matching requirement in README devcontainer workflow section.
- Simplify README allowlist workflow to reference the registry doc and remove `allowlists/domain-suggestions.txt` in favour of the registry tables.

## [Initial]
- Baseline `allowlists/global.txt`, helper scripts, and usage guide prototyped prior to publishing this changelog.
