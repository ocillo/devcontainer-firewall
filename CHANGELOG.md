# Changelog
All notable changes to this project will be documented in this file.

The format loosely follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and dates use ISO 8601 (YYYY-MM-DD).
We cut date-based releases: move entries from `Unreleased` into a `## [vYYYY.MM.DD] – YYYY-MM-DD`
section and tag the commit `vYYYY.MM.DD`. Leave `Unreleased` empty between releases.

## [Unreleased]

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
