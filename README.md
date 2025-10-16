# Ocillo Devcontainer Firewall Allowlist

The goal of this package is to keep our devcontainers secure **without** getting in the way of day–to–day development. The shared allowlist lives here so every project pulls the same defaults, and adding a new domain stays a two‑minute job.

## Repository Layout

```
firewall-allowlist/
├── allowlists/
│   └── global.txt        # Shared defaults consumed by every project
├── docs/
│   └── usage.md          # Integration notes for devcontainers
└── scripts/
    ├── allowlist-add.sh      # Helper for adding entries + auto-validation
    ├── validate-allowlist.sh # Formatting & safety checks (also used in CI)
    └── firewall-refresh.sh   # Optional helper for reloading rules inside a devcontainer
```

## Quick Start (while prototyping here)

All commands assume you are working inside this directory **before** we publish the dedicated GitHub repository. Once the repo exists, the same scripts continue to work there.

- Add a domain to the shared defaults (sorts/dedupes automatically):
  ```bash
  ./scripts/allowlist-add.sh example.com
  ```
- Validate without modifying:
  ```bash
  ./scripts/validate-allowlist.sh
  ```
- Optional resolution check (warn-only when offline):
  ```bash
  ./scripts/validate-allowlist.sh --resolve
  ```

Commit locally for now; once the shared repo is live we’ll open PRs there so the history is centralised.

### Default Coverage

- Anthropic-required domains for Claude Code firewall bootstrap.
- OpenAI’s recommended outbound allowlist for common package registries and tooling ([doc](https://developers.openai.com/codex/cloud/internet-access/)).
- Ocillo staples (Cloudflare, Svelte ecosystem, agency domains). Update `allowlists/global.txt` and the docs whenever we refine this baseline.

## Devcontainer Integration (high level)

1. Copy the raw allowlist from GitHub during container start:
   - set `FIREWALL_ALLOWLIST_URL` to the raw link (or pin to a tag) once the new repo is published.
   - reuse Anthropic’s `init-firewall.sh`, adding the download/merge shim described in `docs/usage.md`.
2. Developers can refresh the rules without rebuilding the container:
   - run `./scripts/firewall-refresh.sh` (requires `FIREWALL_ALLOWLIST_URL` to be set) or rebuild if you prefer the heavier path.
3. Baseline guardrails stay in the script so a network hiccup never leaves the firewall open.

See [`docs/usage.md`](docs/usage.md) for detailed wiring guidance, including environment variables and fallback behaviour.

## Contribution Workflow (once repo is live)

1. `./scripts/allowlist-add.sh <domain>` (or edit manually, then `./scripts/validate-allowlist.sh --fix`).
2. Commit with `chore(firewall): allow <domain>` and note why it’s needed.
3. Open a PR – any teammate can review. CI runs the validation script.
4. Merge; devs refresh at their convenience.

Until the shared repo exists, keep iterating locally and capture decisions in the plan; we’ll move the history across when we publish.

## Why a Shared Repo?

- One source of truth across projects.
- Git history + reviews make it obvious who added what and why.
- Distribution strategy can grow with us (start with raw GitHub, later a package if we need it).

### Publishing Plan

1. Finish prototyping in this `firewall-allowlist/` folder.
2. Create the GitHub repository (e.g. `tonikangas/devcontainer-firewall` or an `ocillo/*` namespace if/when we register it).
3. Copy or move this directory into that repo and push the initial commit (include scripts + docs).
4. Update consuming projects so `FIREWALL_ALLOWLIST_URL` points at the new raw link.

## References

- [Anthropic devcontainer baseline](https://anthropic.mintlify.app/en/docs/claude-code/devcontainer)
- [Network requirements](https://anthropic.mintlify.app/en/docs/claude-code/network-config)
- [Anthropic IP ranges](https://anthropic.mintlify.app/en/api/ip-addresses)

These docs inform the baseline entries and the extra egress restrictions we inherit from the upstream `init-firewall.sh`.
