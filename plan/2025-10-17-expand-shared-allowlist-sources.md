# Goal
- Capture candidate external services (docs, consoles, APIs) that developers rely on but are not yet in the shared allowlist.
- Determine which ones require explicit subdomain entries because of IP-based filtering.

# Open Questions
- Which Cloudflare surfaces we touch (dash, workers, API, radar) resolve to unique IPs vs `cloudflare.com`?
- What search/documentation engines do we expect AI tooling (Claude Code, Codex, etc.) to reach during runs?
- Are there platform-specific hostnames (AWS, Vercel, Hetzner, RunCloud, Ocillo internals) with separate infrastructure footprints?
- How should we document the research trail so downstream teams can validate before adding entries?

# Next Steps
1. Inventory current workflows (Cloudflare workers, Vercel deployments, AWS consoles, etc.) and map the hostnames actually used.
2. Resolve each hostname and compare IP sets against existing allowlist entries to confirm whether new lines are required.
3. Prioritize additions based on frequency of use and security posture, then prepare PRs updating `allowlists/global.txt` with supporting notes.

# Research Notes
## Hetzner
- `hetzner.com` resolves to `213.133.116.44`, but key surfaces live elsewhere.
- `docs.hetzner.com` → `213.133.116.46` (docs portal).
- `console.hetzner.cloud` → `213.239.246.73` (Cloud Console).
- `accounts.hetzner.com` and `robot.your-server.de` → `213.133.116.45` (legacy/credential flows).
- `status.hetzner.com` → `193.47.99.7` (status page).
- `wiki.hetzner.de` → `85.10.215.232` (knowledge base).

## RunCloud
- `runcloud.io` covers marketing/docs but the platform spans extra hosts.
- `manage.runcloud.io` (login/app) and `docs.runcloud.io` front Cloudflare IPs `104.26.10.235/104.26.11.235/172.67.68.114`.
- `supportkb.runcloud.io` (KB) → `137.184.118.238`.
- `features.runcloud.io` (feature flags) → `138.68.44.87`.
- `blog.runcloud.io`/`community.runcloud.io` share Cloudflare IPs with the root domain.

## Cloudflare
- Core domain (`cloudflare.com`) resolves to `104.16.132.229/104.16.133.229`, but major services use distinct ranges.
- `dash.cloudflare.com` (main dashboard) → `104.17.110.184/104.17.111.184`.
- `one.dash.cloudflare.com` (Zero Trust) → `104.18.4.19/104.18.5.19`.
- `api.cloudflare.com` → `104.19.192.29/174/175/176/177` + `104.19.193.29`.
- `developers.cloudflare.com` → `104.16.2.189`–`104.16.6.189`.
- `workers.cloudflare.com` → `104.16.196.131/104.16.197.131`.
- `pages.cloudflare.com` → `104.18.8.122/104.18.9.122`.
- `radar.cloudflare.com` → `104.18.30.78/104.18.31.78`.
- `support.cloudflare.com` → `104.18.2.186/104.18.3.186`; `community.cloudflare.com` → `104.18.2.67/104.18.3.67`.
- `blog.cloudflare.com` → `104.18.28.7/104.18.29.7`.
- Status lives at `www.cloudflarestatus.com` (CNAME into Atlassian Statuspage IPs `13.226.2.9/23/59/95`).

## Anthropic / Claude
- Many Anthropic properties share the same IP `160.79.104.10` behind Cloudflare, but we should still track the hostnames explicitly.
- `claude.ai` (main product UI) → `160.79.104.10`.
- `docs.anthropic.com` (API docs) → `160.79.104.10`.
- `console.anthropic.com` (API console/keys) → `160.79.104.10`.
- `api.anthropic.com` (API endpoint) → `160.79.104.10`.
- `support.claude.com` (knowledge base) → `160.79.104.10`.
- Status page `status.anthropic.com` CNAMEs to Atlassian Statuspage IPs `3.169.71.14/53/56/73`.
- `www.anthropic.com` marketing site also sits on `160.79.104.10`.

## OpenAI
- Root `openai.com` → `104.18.33.45/172.64.154.211` (Cloudflare).
- Auth flows: `auth.openai.com` → `104.18.41.241/172.64.146.15` (needed for OAuth token exchange).
- API traffic: `api.openai.com` → `172.66.0.243/162.159.140.245`.
- Console: `platform.openai.com` → `104.18.33.45/172.64.154.211`.
- Developer docs: `developers.openai.com` CNAME to Vercel (`64.239.109.1/64.239.123.1`).
- Help center: `help.openai.com` → `104.18.33.45/172.64.154.211`.
- ChatGPT UI: `chat.openai.com` → `104.18.37.228/172.64.150.28`.
- Community forum: `community.openai.com` CNAME to Discourse (`184.105.99.79`).
- Status page: `status.openai.com` CNAME to Vercel status host (`66.33.60.35/66.33.60.130`).
- Pending/unknown: `support.openai.com`, `labs.openai.com`, and `login.openai.com` currently return only NS authority—monitor for future A/CNAME records.

## GitHub
- `github.com` already ships in the shared allowlist but resolves to `140.82.112.3`; many companion services live on other networks.
- API + package endpoints: `api.github.com` (`20.217.135.0`), `codeload.github.com` (`20.217.135.8`), `pkg.github.com` (`20.217.135.3`), `uploads.github.com` (CNAME to `alambic-origin.githubusercontent.com` → `20.217.135.1`).
- Static/documentation: `docs.github.com` & `github.githubassets.com` share the GitHub Pages CDN block `185.199.108/109/110/111.*`; the same range serves `raw/avatars/objects/user-images/media.githubusercontent.com`.
- Developer tooling: `cli.github.com` (CNAME to `cli.github.io`) resolves to `185.199.108/109/110/111.153` for CLI downloads.
- GitHub Actions: `pipelines.actions.githubusercontent.com` (CNAME to `l-msedge.net` → `13.107.42.16`) and `token.actions.githubusercontent.com` (`140.82.114.21`).
- Support & status: `support.github.com` uses the 185.199.*.133 block; status lives at `www.githubstatus.com` (Statuspage IPs `65.9.112.51/60/88/95`).
- Short links: `git.io` resolves to `140.82.112.21` and is common in documentation.
