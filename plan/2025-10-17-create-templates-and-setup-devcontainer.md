# Extract Templates and Setup Devcontainer

**Date:** 2025-10-17
**Status:** Initial research - validating findings

---

## Goals

1. Create `scripts/templates/` with the firewall setup scripts (docs say this should exist but it's marked "coming soon")
2. Create `.devcontainer/` for this repo to develop and test the firewall

---

## Current Situation

- `.devcontainer.example/` exists (brought from TarmacTimes)
- `scripts/templates/` does not exist
- `.devcontainer/` does not exist

---

## Research Done

### Devcontainer Workspace Paths

**Source:** [Dev Container Specification - devcontainerjson-reference.md](https://github.com/devcontainers/spec/blob/main/docs/specs/devcontainerjson-reference.md)

**What I verified:**
- `/workspaces/${localWorkspaceFolderBasename}` is shown as an example mount pattern in the spec
- `${localWorkspaceFolderBasename}` is a devcontainer.json variable
- It CAN be passed to shell scripts if explicitly set via `containerEnv`

**TarmacTimes verification:**
- `.devcontainer.example/devcontainer.json` line 22: Uses `/workspaces/tarmactimes/`
- No `workspaceMount` or `workspaceFolder` customization found
- Confirms they use the default `/workspaces/` pattern

### Found in `.devcontainer.example/init-firewall.sh`

Line 24 contains:
```bash
: "${FIREWALL_ALLOWLIST_LOCAL:=/workspaces/tarmactimes/.devcontainer/firewall-allowlist.local.txt}"
```

This hardcodes `/workspaces/tarmactimes/` which makes it TarmacTimes-specific.

**Why it matters:** Line 80 already handles missing files gracefully with `if [[ -f "$FIREWALL_ALLOWLIST_LOCAL" ]]`, so the default can be empty. Projects set the full path via `devcontainer.json` `containerEnv`.

---

### Script Analysis

Searched both scripts for "tarmactimes" (case-insensitive):

**`setup-firewall.sh`:** No TarmacTimes-specific references found - fully generic

**`init-firewall.sh`:** Only ONE reference found - line 24 (the hardcoded path)

**Conclusion:** To make templates generic, only need to change line 24 in `init-firewall.sh`

---

## Templates Content

Based on docs and analysis:
- `scripts/templates/setup-firewall.sh` - copy as-is (already generic)
- `scripts/templates/init-firewall.sh` - copy with line 24 changed to empty default
