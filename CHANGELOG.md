# Changelog
All notable changes to this project will be documented in this file.

The format loosely follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and dates use ISO 8601 (YYYY-MM-DD).
We cut date-based releases: move entries from `Unreleased` into a `## [vYYYY.MM.DD] – YYYY-MM-DD`
section and tag the commit `vYYYY.MM.DD`. Leave `Unreleased` empty between releases.

### Entry guidelines
- Keep each bullet to a single-line summary; link to `docs/allowlist-registry.md` or other docs when more detail is required.

**Good**
- Add Bitwarden Secrets Manager domains to shared allowlist (see docs/allowlist-registry.md).

**Bad**
- Add `identity.bitwarden.com`, `api.bitwarden.com`, and `bitwarden.com` to shared allowlist so Bitwarden Secrets Manager auth, API calls, and documentation access succeed in devcontainers.

## [Unreleased]
### Added
- _None_

## [v2025.11.04] – 2025-11-04
### Added
- Add Infisical Cloud domains to shared allowlist (see docs/allowlist-registry.md).
- Add Bitwarden Secrets Manager domains to shared allowlist (see docs/allowlist-registry.md).

## [v2025.10.27] – 2025-10-27
### Added
- Add OpenNext.js documentation host to shared allowlist (see docs/allowlist-registry.md).
- Add Payload CMS documentation host to shared allowlist (see docs/allowlist-registry.md).
- Add Cloudflare-managed MCP endpoints and agency portal to shared allowlist (see docs/allowlist-registry.md).

## [v2025.10.23] – 2025-10-23
### Added
- Publish firewall-refresh helper template for downstream repos.
- Enable uv in devcontainer for Python-based MCP tooling.
- Add uv tooling domains to shared allowlist (see docs/allowlist-registry.md).

### Changed
- Clarify `docs/usage.md` template URLs and `FIREWALL_ALLOWLIST_URL` requirements.

## [v2025.10.22] – 2025-10-22
### Added
- Publish setup/init firewall templates and validation devcontainer.
- Add auth.openai.com to shared allowlist (see docs/allowlist-registry.md).
- Add chatgpt.com to shared allowlist (see docs/allowlist-registry.md).

### Changed
- Update README and usage guide to reference the new templates.
- Point helper script hints to the canonical GitHub documentation.
- Have `.devcontainer/init-firewall.sh` fetch the shared allowlist on every run with explicit logging and fallback.
- Make `scripts/firewall-refresh.sh` delegate downloads to the init script so failures surface immediately.

### Removed
- Remove the legacy `.devcontainer.example/` snapshot in favour of the shared templates.
- Remove `FIREWALL_ALLOWLIST_CACHE_DIR` and cache-based fallback logic.

## [v2025.10.17] – 2025-10-17
### Added
- Document shared vs. per-project responsibilities in README.
- Add documentation hints to helper scripts and init-firewall logging.
- Introduce `CHANGELOG.md` to track future updates.
- Establish `docs/allowlist-registry.md` as the canonical approvals log (Svelte/Shadcn/Tailwind rationale included).
- Promote shared tooling and documentation hostnames into `allowlists/global.txt` and the registry.

### Changed
- Clarify `docs/usage.md` entry point for quick navigation.
- Enhance helper script `--help` output with doc links.
- Note IP-based matching requirement in the README devcontainer workflow section.
- Replace `allowlists/domain-suggestions.txt` with the registry tables.

## [Initial]
- Baseline `allowlists/global.txt`, helper scripts, and usage guide prototyped prior to publishing this changelog.
