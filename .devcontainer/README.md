# Devcontainer Firewall Development Environment

This directory defines the local development container for contributors to **ocillo/devcontainer-firewall**. It mirrors the setup we expect downstream projects to vendor while giving us a fast way to test the shared firewall scripts.

## What you get

- Debian 12 / Node.js 22 base image from the official Dev Containers catalog
- GitHub CLI plus the Claude and Codex CLIs (credentials stored in dedicated Docker volumes)
- Shared firewall helpers copied from `scripts/templates/`
- VS Code defaults for linting/formatting and AI pair-programming extensions

## Lifecycle

1. `postCreateCommand` runs `.devcontainer/setup-firewall.sh` under sudo. The script installs iptables/ipset dependencies and places `init-firewall.sh` into `/usr/local/bin/`.
2. `postStartCommand` runs `/usr/local/bin/init-firewall.sh` on **every** container start, preserving the firewall environment variables defined in `containerEnv`. The script downloads the shared allowlist, merges `.devcontainer/firewall-allowlist.local.txt`, applies rules, and verifies the firewall by curling an allowed and a blocked domain.

## Local overrides

Project-specific or experimental domains belong in `.devcontainer/firewall-allowlist.local.txt`. Keep one entry per line with a short comment. Long-lived domains should be upstreamed to `allowlists/global.txt` instead.

## Refreshing the firewall manually

After editing allowlists you can either rebuild the container or run:

```bash
./scripts/firewall-refresh.sh
```

The refresh script reuses the same init logic. It downloads the shared allowlist every time and prints a loud warning if it has to fall back to the bundled baseline because the remote list is unavailable.

## Troubleshooting

### CLI login flows fail or freeze

If OAuth login flows (e.g., Claude Code, Codex CLI) freeze, check VS Code's **PORTS** tab for port conflicts. Multiple running devcontainers may compete for the same localhost port (e.g., 1455). Close other devcontainers before running login flows, or manually stop/restart port forwarding.
