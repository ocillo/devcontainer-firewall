# Validate `.devcontainer.example` Against Best Practices

**Date:** 2025-10-17  
**Status:** Research in progress

---

## Goal

Confirm the borrowed `.devcontainer.example/` is safe to promote as the reference implementation for this repo. We only move forward if every file either meets official guidance or we clearly document the deltas.

---

## Phase 1 — Collect Requirements (What we need to know)

| Topic | Why it matters | Source | Notes |
| --- | --- | --- | --- |
| Lifecycle commands (`postCreateCommand`, `postStartCommand`) | Ensure firewall install runs once, rule application runs every start | [Dev Container spec – lifecycle commands](https://github.com/devcontainers/spec/blob/main/docs/specs/devcontainerjson-reference.md) | `postCreateCommand` fires after container build **and** workspace mount; `postStartCommand` runs on every start. Fits our pattern: install once, then apply firewall each launch. |
| Capabilities (`NET_ADMIN`, `NET_RAW`) | iptables/ipset require elevated network privileges | [Dev Container metadata reference – `capAdd`](https://containers.dev/implementors/json_reference/#general-devcontainerjson-properties) + [Linux `CAP_NET_ADMIN` description](https://man7.org/linux/man-pages/man7/capabilities.7.html) | Spec allows `capAdd`/`runArgs` to append capabilities; man page confirms `CAP_NET_ADMIN` covers firewall changes and `CAP_NET_RAW` allows raw sockets. We must configure both. |
| Environment variables (`containerEnv`) | Firewall scripts need static configuration visible to all processes | [Dev Container metadata reference – `containerEnv`](https://containers.dev/implementors/json_reference/#general-devcontainerjson-properties) | `containerEnv` values are baked into container runtime and shared by every process; prefer over `remoteEnv` for static firewall URLs/paths. |
| Anthropic firewall patterns | Provides a proven baseline for iptables/ipset logic and verification | [Anthropic `.devcontainer/init-firewall.sh`](https://raw.githubusercontent.com/anthropics/claude-code/refs/heads/main/.devcontainer/init-firewall.sh) | Reference script uses `#!/bin/bash`, strict `IFS`, caches baseline, restores Docker DNS, validates GitHub CIDRs, verifies allowed vs blocked curl calls. Use this as north star. |

**Outputs:** concise notes on required behaviour for devcontainer.json, Dockerfile, and firewall scripts (captured in table).

---

## Phase 2 — Build Checklists (What we need to produce)

Using the sources above, convert requirements into explicit checklists we can score later.

### devcontainer.json checklist

| Check | Requirement | Why |
| --- | --- | --- |
| ☐ | `runArgs` or `capAdd` adds both `NET_ADMIN` and `NET_RAW` | Allows iptables/ipset + raw sockets |
| ☐ | `containerEnv` defines `FIREWALL_ALLOWLIST_URL`, `FIREWALL_ALLOWLIST_REF`, `FIREWALL_ALLOWLIST_CACHE_DIR`, `FIREWALL_ALLOWLIST_LOCAL` | Scripts need deterministic configuration |
| ☐ | `postCreateCommand` installs firewall dependencies (invokes setup script with sudo) | One-time install step |
| ☐ | `postStartCommand` calls init script with preserved env vars | Reapplies rules each boot |
| ☐ | Project-specific bits (name, extensions, forwarded ports, mounts) match this repo | Avoid leaking TarmacTimes branding/pathing |

### setup-firewall.sh checklist

| Check | Requirement | Why |
| --- | --- | --- |
| ☐ | Uses `#!/usr/bin/env bash` and `set -euo pipefail` | Align with repo scripting standard |
| ☐ | Guards against non-root execution | Prevent partial installs |
| ☐ | Installs `iptables`, `ipset`, `iproute2`, `curl`, `dnsutils`, `jq` | Provides required tooling |
| ☐ | Copies `init-firewall.sh` to `/usr/local/bin` with `0755` | Makes init script accessible |

### init-firewall.sh checklist

| Check | Requirement | Why |
| --- | --- | --- |
| ☐ | `#!/bin/bash`, `set -euo pipefail`, root guard, error trap | Baseline robustness |
| ☐ | Honors `FIREWALL_DISABLE*` env vars | Allow emergency opt-out |
| ☐ | Establishes defaults for ref/cache/local path without hardcoding project name | Template friendliness |
| ☐ | Handles baseline allowlist, download with retries, cache fallback, empty-check | Resilient sources |
| ☐ | Restores Docker DNS rules, resets iptables/ipset safely | Avoids breaking container networking |
| ☐ | Adds DNS/SSH/loopback allowances | Keep essential traffic flowing |
| ☐ | Populates ipset from GitHub CIDRs + hostname lookups | Allow required services |
| ☐ | Detects host network for intra-host comms | Preserve `docker host` talk |
| ☐ | Sets DROP policies and verifies blocked/allowed curl checks | Enforce firewall + test |
| ☐ | (Nice) Notes: strict `IFS`, CIDR/IP regex, `aggregate -q` usage | Potential follow-ups |

### Dockerfile checklist

| Check | Requirement | Why |
| --- | --- | --- |
| ☐ | Inherits from maintained devcontainers image (Node 22 Bookworm matches our tooling needs) | Keep base secure and current |
| ☐ | Prepares user-owned directories, installs CLI tooling as non-root | Match devcontainer security approach |

**Outputs:** tables above form the scoring rubric for Phase 3.

---

## Phase 3 — Validate `.devcontainer.example/` (What we need to do)

1. Compare `devcontainer.json` against the checklist.
2. Compare `setup-firewall.sh` and `init-firewall.sh` against the checklist and Anthropic reference.
3. Confirm Dockerfile alignment.
4. Record findings:
   - ✅ compliant items.
   - ⚠️ acceptable deviations (document rationale).
   - 🔴 blockers that must change before templating.

When a check requires tooling (e.g., `shellcheck`), note how we will run it once the repo has a devcontainer rather than marking it as failed.

### Findings

#### devcontainer.json (`.devcontainer.example/devcontainer.json`)

| Status | Item | Notes |
| --- | --- | --- |
| ✅ | Adds `NET_ADMIN` and `NET_RAW` via `runArgs` | Lines 16-21 |
| ✅ | Defines all four firewall env vars in `containerEnv` | Lines 22-31 |
| ✅ | `postCreateCommand` runs setup script with sudo | Line 53 |
| ✅ | `postStartCommand` preserves env vars when invoking init script | Lines 54-55 |
| 🔴 | Project-specific branding/paths (name, `FIREWALL_ALLOWLIST_LOCAL`, forwarded ports, mount names, VS Code extensions) still reference TarmacTimes | Lines 1, 26, 36-52, 57-66 |

#### setup-firewall.sh (`.devcontainer.example/setup-firewall.sh`)

| Status | Item | Notes |
| --- | --- | --- |
| ✅ | `#!/usr/bin/env bash` + `set -euo pipefail` | Lines 1-2 |
| ✅ | Root guard prevents non-sudo execution | Lines 4-8 |
| ✅ | Installs iptables, ipset, iproute2, curl, dnsutils, jq | Lines 11-18 |
| ✅ | Copies init script to `/usr/local/bin` with `install -m 0755` | Lines 20-22 |

#### init-firewall.sh (`.devcontainer.example/init-firewall.sh`)

| Status | Item | Notes |
| --- | --- | --- |
| ✅ | `#!/bin/bash`, strict error handling, root guard, failure trap | Lines 1-14 |
| ✅ | Supports `FIREWALL_DISABLE*` variables | Lines 16-20 |
| 🔴 | `FIREWALL_ALLOWLIST_LOCAL` default hard-codes `/workspaces/tarmactimes/...` | Lines 22-28 (line 24 specifically) |
| ✅ | Baseline + download + cache fallback + empty guard | Lines 41-97 |
| ✅ | Restores Docker DNS, resets iptables/ipset safely | Lines 99-134 |
| ✅ | Allows DNS/SSH/loopback + creates ipset | Lines 136-156 |
| ✅ | Adds GitHub CIDRs and hostnames | Lines 158-183 |
| ✅ | Detects host network and applies policies, including verification curls | Lines 185-221 |
| ⚠️ | Nice-to-haves (strict `IFS`, CIDR/IP regex, `aggregate -q`) absent | Comparison against Anthropic reference |

#### Dockerfile (`.devcontainer.example/Dockerfile`)

| Status | Item | Notes |
| --- | --- | --- |
| ✅ | Base image `mcr.microsoft.com/devcontainers/typescript-node:22-bookworm` | Line 1 |
| ✅ | Prepares user-owned directories and installs CLI tooling as non-root | Lines 5-22 |

**Shellcheck reminder:** run inside future repo devcontainer once built; tooling not available on host today.

---

## Phase 4 — Decisions & Next Actions (What we need to communicate)

- Summarise whether `.devcontainer.example/` can be promoted as-is.
- List required edits (e.g., change `FIREWALL_ALLOWLIST_LOCAL` default, rename mounts/ports/extensions for this repo).
- Capture optional improvements we might upstream later (strict `IFS`, CIDR validation, aggregation).
- Outline verification to perform after changes:
  - Run `shellcheck` inside the future repo devcontainer.
  - Execute `./scripts/firewall-refresh.sh --no-download` once templates land.

### Decision summary

- **Promotable?** Yes, after addressing two blockers: (1) remove TarmacTimes branding/paths from `devcontainer.json`; (2) make `FIREWALL_ALLOWLIST_LOCAL` default blank or generic in `init-firewall.sh`.
- **Mandatory edits before templating:**
  1. Update `devcontainer.json` metadata (name, extension set, port forwards, volume names, local allowlist path) to match this repo.
  2. Replace the hard-coded local allowlist default path in `init-firewall.sh`.
- **Optional improvements (future work):**
  - Add `IFS=$'\n\t'` and CIDR/IP validation similar to Anthropic reference.
  - Consider `aggregate -q` for GitHub IP ranges if we accept dependency.
- **Verification once changes land:**
  - Run `shellcheck` inside the new devcontainer (all scripts).
  - Exercise `./scripts/firewall-refresh.sh --no-download` to confirm caching/merge logic still holds.

Deliverable: share these points before moving on to implementation/template creation.

---

### Notes

- Removed references to internal paths or censored data from the prior draft.
- Treat AGENTS.md as guidance for us (analysis-first, test when possible) but not as an external compliance spec.
- Keep sourcing explicit so future reviewers can audit decisions quickly.
