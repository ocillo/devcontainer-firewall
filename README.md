# Ocillo Devcontainer Firewall

Note: This repo is public so client projects can consume `allowlists/global.txt`.

Shared outbound allowlist + helper scripts so every project starts from the same secure defaults. This repository is the **single source of truth** for:

- the baseline domains we allow (`allowlists/global.txt`)
- the helper utilities developers run (add, validate, refresh)
- the documented workflow for wiring firewall rules into devcontainers
- the version history of changes (see `CHANGELOG.md`)

> **Visibility:** this repository is public so consuming projects can fetch `allowlists/global.txt` over HTTPS without credentials. Keep NDA-sensitive or client-specific domains in each project’s local override file instead of the shared list.

Every consuming project copies the published shell scripts from here, sets a handful of environment variables in its `devcontainer.json`, and keeps any project‑specific domains in its own repository. The goal is a consistent mental model that gives teams freedom without fragmenting our tooling.

## How the pieces fit together

| Responsibility | Lives in this repo? | Notes |
| --- | --- | --- |
| Shared baseline allowlist | ✅ `allowlists/global.txt` | Reviewed list of domains/CIDRs used across projects. PRs here keep everyone aligned. |
| Helper scripts (`allowlist-add`, `validate`, `firewall-refresh`) | ✅ `scripts/` | Shared tooling; each script supports `--help` and links back to these docs. |
| Devcontainer wiring guide | ✅ `docs/usage.md` | Step-by-step instructions for environment variables, overrides, and verification. |
| Baseline devcontainer scripts (`setup-firewall.sh`, `init-firewall.sh`) | ✅ `scripts/templates/` *(coming soon)* | Templates that client repos vendor into `.devcontainer/`. |
| Project-specific overrides | ❌ (lives in client repo) | Each project owns `.devcontainer/firewall-allowlist.local.txt` for client-only domains. |

**Day-to-day flow**

1. **Central maintenance (this repo):** update `allowlists/global.txt`, run the helpers, document changes in `CHANGELOG.md`. Improvements to the setup/init scripts land here first.
2. **Project setup (client repo):** copy the latest `setup-firewall.sh`/`init-firewall.sh` templates into `.devcontainer/`, add the standard env vars, and optionally create `.devcontainer/firewall-allowlist.local.txt` for project-only domains.
3. **Developers:** run `./scripts/firewall-refresh.sh` (or rebuild the container) to apply new allowlist entries. Runtime logs point back to this README so nobody has to guess.

Projects rarely modify the firewall scripts themselves—custom needs should go into the local override file or be upstreamed here. If a project must deviate, document the reason in the local script and consider opening a PR to share the change.

## Repository layout

```
.
├── allowlists/
│   └── global.txt            # Shared defaults
├── docs/
│   └── usage.md              # Devcontainer wiring + verification
├── scripts/
│   ├── allowlist-add.sh      # Add an entry, sort, validate
│   ├── validate-allowlist.sh # Lint + optional DNS resolution
│   ├── firewall-refresh.sh   # Refresh rules inside a devcontainer
│   └── templates/            # Baseline setup/init scripts for client repos (TBD)
└── CHANGELOG.md              # Versioned change log
```

## Everyday commands

```bash
# Add a hostname/CIDR to the shared defaults (auto-sorts + validates)
./scripts/allowlist-add.sh registry.npmjs.org

# Validate without modifying the file
./scripts/validate-allowlist.sh

# Need a reminder? every helper supports --help
./scripts/firewall-refresh.sh --help
```

Each script prints a short summary and links back here for the full workflow.

### What belongs in the shared list?

- Anthropic-required domains so Claude Code’s firewall keeps working.
- GitHub, npm, and other registries we rely on day-to-day.
- Ocillo-common services (Cloudflare, Svelte ecosystem, agency tooling).

Anything sensitive or client-specific goes in the consuming repo’s `.devcontainer/firewall-allowlist.local.txt`. The init script merges local overrides after the shared defaults, so those entries never leave the project.

## Devcontainer integration (client repo workflow)

Most projects follow the steps documented in [`docs/usage.md`](docs/usage.md):

1. Set the standard environment variables in `.devcontainer/devcontainer.json` (`FIREWALL_ALLOWLIST_URL`, `FIREWALL_ALLOWLIST_REF`, cache dir, local override path).
2. Copy the baseline `setup-firewall.sh` and `init-firewall.sh` templates into `.devcontainer/` and commit them. The setup script installs dependencies; the init script downloads the shared allowlist, merges local overrides, and applies iptables rules on every container start.
3. Add the optional refresh helper so developers can pull allowlist updates without rebuilding the container.
4. Keep `.devcontainer/firewall-allowlist.local.txt` for project-only domains, with comments explaining why each domain is needed.

`docs/usage.md` also includes a verification checklist (allowed domain succeeds, blocked domain fails, offline fallback works) so new projects can confirm everything is wired correctly.

## Contribution workflow (shared repo)

1. `./scripts/allowlist-add.sh <domain>` (or edit manually and run `./scripts/validate-allowlist.sh --fix`).
2. Update `CHANGELOG.md` with a short note about the change.
3. Commit with context (why the domain/script update matters).
4. Open a PR; the validator runs in CI. After merge, notify consuming projects to refresh or sync the updated scripts.

## References

- [Anthropic devcontainer baseline](https://anthropic.mintlify.app/en/docs/claude-code/devcontainer)
- [Anthropic firewall/network configuration](https://anthropic.mintlify.app/en/docs/claude-code/network-config)
- [Anthropic IP ranges](https://anthropic.mintlify.app/en/api/ip-addresses)

These documents shape the baseline entries and guardrails we keep in the downstream `init-firewall.sh`.
