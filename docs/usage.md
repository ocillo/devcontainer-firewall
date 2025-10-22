# Devcontainer Integration Guide

This note captures how projects consume the shared allowlist while keeping Anthropic’s firewall guarantees intact. Every helper script in this repo accepts `--help` and links back here when you need a reminder.

## 1. Wire up Environment Variables

Add the following to your `devcontainer.json` (or equivalent):

```jsonc
{
  "containerEnv": {
    "FIREWALL_ALLOWLIST_REF": "main",
    "FIREWALL_ALLOWLIST_URL": "https://raw.githubusercontent.com/ocillo/devcontainer-firewall/main/allowlists/global.txt",
    "FIREWALL_ALLOWLIST_LOCAL": "${containerWorkspaceFolder}/.devcontainer/firewall-allowlist.local.txt"
  }
}
```

- `FIREWALL_ALLOWLIST_REF` can pin a git tag/commit for reproducibility.
- If a project doesn’t need local overrides you can omit `FIREWALL_ALLOWLIST_LOCAL`; the script ignores missing files.
- The old `FIREWALL_ALLOWLIST_CACHE_DIR` setting is gone—every run downloads the shared allowlist directly and warns if it has to fall back to the bundled baseline.
- Dev Containers do **not** expand `${ENV_VAR}` placeholders inside `containerEnv`. If you want to pin to a specific tag or commit, update both `FIREWALL_ALLOWLIST_REF` and the hard-coded path in `FIREWALL_ALLOWLIST_URL` (e.g. replace `main` with the tag name).

## 2. Copy the baseline scripts

- Grab the latest `setup-firewall.sh` and `init-firewall.sh` from the shared repo:
  - https://raw.githubusercontent.com/ocillo/devcontainer-firewall/main/scripts/templates/setup-firewall.sh
  - https://raw.githubusercontent.com/ocillo/devcontainer-firewall/main/scripts/templates/init-firewall.sh
- Copy both into your project’s `.devcontainer/` folder and commit them.

- `setup-firewall.sh` installs prerequisites (iptables, ipset, etc.) and copies `init-firewall.sh` into `/usr/local/bin/`.
- `init-firewall.sh` reads the environment variables you set in step 1, downloads the shared allowlist (with retry), merges it with any local overrides, and applies the iptables/ipset rules. When the download fails it falls back to the bundled baseline and logs a loud warning so nobody misses the degraded state.
- The script logs a one-line summary (`Allowlist sources: baseline, remote@<ref>, local overrides: …`) and links back to this documentation. IPv6 destinations are currently logged and ignored; the firewall only permits IPv4 egress right now.

If you need to customise the script for a specific project, add a comment explaining why and consider upstreaming the change here so other projects benefit.

## 3. Optional Refresh Helper

Ship `./scripts/firewall-refresh.sh` in consuming repos (template here: https://raw.githubusercontent.com/ocillo/devcontainer-firewall/main/scripts/templates/firewall-refresh.sh):

```bash
#!/usr/bin/env bash
set -euo pipefail

readonly doc_hint="Docs: https://github.com/ocillo/devcontainer-firewall#readme • https://github.com/ocillo/devcontainer-firewall/blob/main/docs/usage.md"
readonly init_script="${FIREWALL_INIT_SCRIPT:-/usr/local/bin/init-firewall.sh}"

preserve_vars=(
  FIREWALL_ALLOWLIST_URL
  FIREWALL_ALLOWLIST_REF
  FIREWALL_ALLOWLIST_LOCAL
)
preserve_arg=$(IFS=,; echo "${preserve_vars[*]}")

echo "Re-applying firewall rules via ${init_script}"
sudo --preserve-env="${preserve_arg}" "$init_script"
echo "Refresh complete. ${doc_hint}"
```

Developers can run this anytime instead of rebuilding the entire container. If you prefer to keep scripts minimal, omit this helper and rely on container rebuilds – the firewall logic will still work.

## 4. Project Overrides

Add `.devcontainer/firewall-allowlist.local.txt` when a project needs extra domains. Keep the same “one entry per line” format and add a short comment explaining the dependency.

Example:

```
# Temporary until vendor fixes IP allowlist
openai.com
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

1. Start the devcontainer – confirm the firewall logs `Allowlist sources: baseline, remote@<ref>, local overrides: …`.
2. `curl https://api.anthropic.com` → succeeds.
3. `curl https://example.com` → fails with `Egress denied`.
4. Add a local override and re-run `./scripts/firewall-refresh.sh`; confirm the log now mentions the local override and the new domain succeeds.
5. Disconnect from the network (or temporarily point `FIREWALL_ALLOWLIST_URL` at an invalid URL) and restart – the script should warn that it failed to download the shared allowlist, log `remote@<ref> (unavailable)`, and state that it is falling back to the baseline (IPv4-only) entries.

That’s enough confidence for our current scale.
