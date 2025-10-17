# Devcontainer Integration Guide

This note captures how projects consume the shared allowlist while keeping Anthropic’s firewall guarantees intact. Every helper script in this repo accepts `--help` and links back here when you need a reminder.

## 1. Wire up Environment Variables

Add the following to your `devcontainer.json` (or equivalent):

```jsonc
{
  "containerEnv": {
    "FIREWALL_ALLOWLIST_REF": "main",
    "FIREWALL_ALLOWLIST_URL": "https://raw.githubusercontent.com/ocillo/devcontainer-firewall/${FIREWALL_ALLOWLIST_REF}/allowlists/global.txt",
    "FIREWALL_ALLOWLIST_LOCAL": "/workspace/.devcontainer/firewall-allowlist.local.txt",
    "FIREWALL_ALLOWLIST_CACHE_DIR": "/home/node/.claude/firewall-cache"
  }
}
```

- `FIREWALL_ALLOWLIST_REF` can pin a git tag/commit for reproducibility.
- If a project doesn’t need local overrides you can omit `FIREWALL_ALLOWLIST_LOCAL`; the script will ignore missing files.

## 2. Copy the baseline scripts

Grab the latest `setup-firewall.sh` and `init-firewall.sh` from `scripts/templates/` (until the templates land, copy them from the most recent consuming repo) and place them inside your project’s `.devcontainer/` folder.

- `setup-firewall.sh` installs prerequisites (iptables, ipset, etc.) and copies `init-firewall.sh` into `/usr/local/bin/`.
- `init-firewall.sh` reads the environment variables you set in step 1, downloads the shared allowlist (with retry + cache), merges it with any local overrides, and applies the iptables/ipset rules.
- The script logs which source it used (`remote@main`, `cache@main`, or `baseline`) and points back to this documentation so developers know where to look.

If you need to customise the script for a specific project, add a comment explaining why and consider upstreaming the change here so other projects benefit.

## 3. Optional Refresh Helper

Ship `./scripts/firewall-refresh.sh` in consuming repos:

```bash
#!/usr/bin/env bash
set -euo pipefail

readonly REF="${FIREWALL_ALLOWLIST_REF:-main}"
readonly URL="${FIREWALL_ALLOWLIST_URL:-https://raw.githubusercontent.com/ocillo/devcontainer-firewall/${REF}/allowlists/global.txt}"
readonly CACHE_DIR="${FIREWALL_ALLOWLIST_CACHE_DIR:-$HOME/.claude/firewall-cache}"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

mkdir -p "$CACHE_DIR"
if curl --fail --retry 3 --retry-delay 1 --silent --show-error "$URL" -o "$tmp"; then
  install -m 0644 "$tmp" "$CACHE_DIR/global.txt"
  echo "Allowlist updated from ${URL}"
else
  echo "WARNING: Failed to download allowlist; using cached copy if available." >&2
fi

sudo /usr/local/bin/init-firewall.sh
```

Developers can run this anytime instead of rebuilding the entire container. If you prefer to keep scripts minimal, omit this helper and rely on container rebuilds – the firewall logic will still work.

## 4. Project Overrides

Add `.devcontainer/firewall-allowlist.local.txt` when a project needs extra domains. Keep the same “one entry per line” format and add a short comment explaining the dependency.

Example:

```
# Temporary until vendor fixes IP allowlist
cms.internal.ocillo.cloud
```

Manual overrides should be rare; upstream anything long-lived to `allowlists/global.txt`.

## 5. Opt-out Behaviour

When absolutely necessary (e.g., debugging firewall issues):

```bash
export FIREWALL_DISABLE=1
export FIREWALL_DISABLE_REASON="Need to inspect outbound traffic to staging cluster"
sudo /usr/local/bin/init-firewall.sh
```

The script should log the reason and exit before applying iptables changes. Once you’re done debugging, unset those variables and re-run the firewall script.

## 6. Verification Checklist

After wiring everything together:

1. Start the devcontainer – confirm the firewall logs the selected source (remote/cache/baseline).
2. `curl https://api.anthropic.com` → succeeds.
3. `curl https://example.com` → fails with `Egress denied`.
4. Add a local override and re-run `./scripts/firewall-refresh.sh`; confirm the new domain now succeeds.
5. Disconnect from the network (or fake failure) and restart – script should fall back to cache.

That’s enough confidence for our current scale.
