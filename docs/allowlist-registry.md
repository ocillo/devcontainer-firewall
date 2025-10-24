# Shared Allowlist Registry

This registry is the single source of truth for every hostname we consider for the shared
devcontainer firewall allowlist. Use it to stage candidates, document approved entries, and
record removals so future reviewers understand the history at a glance.

- **Scope:** shared tooling, documentation portals, package registries, AI providers, and other
  infrastructure every project (or our automation) must reach.
- **Out of scope:** client- or project-specific domains (keep those in per-repo overrides),
  temporary investigation hosts, and any domain that contains NDA-restricted information.

## How to use this registry

1. **Collect evidence** for a new hostname (DNS resolution, documentation link, reason). Add a
   row to the *Pending entries* table below.
2. **Promote the entry**: once the domain is approved, move it to *Approved entries*, set
   `Last Verified` to the date you ran `./scripts/allowlist-add.sh <domain>` and validated with
   `./scripts/validate-allowlist.sh` / `./scripts/firewall-refresh.sh --no-download`.
3. **Run the tooling**: keep `allowlists/global.txt` sorted via the helper script, and append a
   short note to `CHANGELOG.md` describing the change.
4. **Retire when necessary**: if we remove an entry from the shared allowlist, move its row to the
   *Removed entries* table with the removal date and reason (e.g. “project-specific – moved to
   downstream overrides”).

### Baseline references

The following upstream guides define the default Anthropic/OpenAI entries we inherit. You do not
need to duplicate those hostnames here unless we are adding extra context or deviating from the
baseline behaviour.

- Anthropic devcontainer firewall allowlist: `https://anthropic.mintlify.app/en/docs/claude-code/devcontainer`
- OpenAI Codex/ChatGPT allowlist: `https://developers.openai.com/codex/cloud/internet-access/`

## Pending entries

| Hostname | Category | Reason | Source | Notes |
| --- | --- | --- | --- | --- |
| _None_ | | | | |

## Approved entries

| Hostname | Category | Reason | Source | Last Verified | Notes |
| --- | --- | --- | --- | --- | --- |
| accounts.hetzner.com | Hosting provider | Hetzner account portal for billing/access management | `https://dns.google/resolve?name=accounts.hetzner.com&type=A` | 2025-10-17 | Shares IP with Robot legacy console |
| api.cloudflare.com | Cloudflare | REST API for firewall/Workers automation | `https://dns.google/resolve?name=api.cloudflare.com&type=A` | 2025-10-17 |  |
| api.github.com | GitHub | REST/GraphQL API for automation | `https://dns.google/resolve?name=api.github.com&type=A` | 2025-10-17 |  |
| api.openai.com | OpenAI | REST API for models/embeddings | `https://dns.google/resolve?name=api.openai.com&type=A` | 2025-10-17 |  |
| api.vercel.com | Vercel | API used by deployment tooling | `https://dns.google/resolve?name=api.vercel.com&type=A` | 2025-10-17 |  |
| app.vercel.com | Vercel | Vercel deployment dashboard | `https://dns.google/resolve?name=app.vercel.com&type=A` | 2025-10-17 |  |
| avatars.githubusercontent.com | GitHub | User avatar CDN (docs, changelog visuals) | `https://dns.google/resolve?name=avatars.githubusercontent.com&type=A` | 2025-10-17 |  |
| astral.sh | Python tooling | uv package manager homepage and installer endpoint | `https://dns.google/resolve?name=astral.sh&type=A` | 2025-10-23 | Required for uv installation and updates; Cloudflare CDN |
| blog.cloudflare.com | Cloudflare | Engineering/security announcements | `https://dns.google/resolve?name=blog.cloudflare.com&type=A` | 2025-10-17 |  |
| chat.openai.com | OpenAI | ChatGPT UI for quick validation | `https://dns.google/resolve?name=chat.openai.com&type=A` | 2025-10-17 |  |
| chatgpt.com | OpenAI | ChatGPT landing domain used in redirect/login flows | `https://dns.google/resolve?name=chatgpt.com&type=A` | 2025-10-22 | Redirects to ChatGPT product; blocking it breaks Codex login and responses |
| auth.openai.com | OpenAI | Authentication for ChatGPT/Platform login flows | `https://dns.google/resolve?name=auth.openai.com&type=A` | 2025-10-21 | CNAME to Cloudflare CDN |
| cli.github.com | GitHub | GitHub CLI releases | `https://dns.google/resolve?name=cli.github.com&type=A` | 2025-10-17 | CNAME to cli.github.io |
| codeload.github.com | GitHub | Archive downloads (zip/tar) | `https://dns.google/resolve?name=codeload.github.com&type=A` | 2025-10-17 |  |
| community.cloudflare.com | Cloudflare | Community troubleshooting forum | `https://dns.google/resolve?name=community.cloudflare.com&type=A` | 2025-10-17 |  |
| community.openai.com | OpenAI | Community discussions/support | `https://dns.google/resolve?name=community.openai.com&type=A` | 2025-10-17 | CNAME to Discourse |
| console.anthropic.com | Anthropic | API console (keys, usage) | `https://dns.google/resolve?name=console.anthropic.com&type=A` | 2025-10-17 |  |
| console.aws.amazon.com | AWS | Management console (infra visibility) | `https://dns.google/resolve?name=console.aws.amazon.com&type=A` | 2025-10-17 | Global Accelerator IPs |
| console.hetzner.cloud | Hetzner | Cloud console access | `https://dns.google/resolve?name=console.hetzner.cloud&type=A` | 2025-10-17 |  |
| containers.dev | Devcontainers | Dev Container specification and feature catalog | `https://dns.google/resolve?name=containers.dev&type=A` | 2025-10-17 |  |
| context7.com | Documentation | Context7 dashboard and API for library searches | `https://dns.google/resolve?name=context7.com&type=A` | 2025-10-17 |  |
| dash.cloudflare.com | Cloudflare | Main Cloudflare dashboard | `https://dns.google/resolve?name=dash.cloudflare.com&type=A` | 2025-10-17 |  |
| developers.cloudflare.com | Cloudflare | Product documentation | `https://dns.google/resolve?name=developers.cloudflare.com&type=A` | 2025-10-17 |  |
| developers.openai.com | OpenAI | Platform/API documentation | `https://dns.google/resolve?name=developers.openai.com&type=A` | 2025-10-17 | CNAME to Vercel |
| dns.google | Utility | DNS-over-HTTPS lookups for diagnostics | `https://dns.google/resolve?name=dns.google&type=A` | 2025-10-17 |  |
| docs.anthropic.com | Anthropic | Claude/Anthropic documentation | `https://dns.google/resolve?name=docs.anthropic.com&type=A` | 2025-10-17 |  |
| docs.aws.amazon.com | AWS | AWS documentation CDN | `https://dns.google/resolve?name=docs.aws.amazon.com&type=A` | 2025-10-17 |  |
| docs.claude.com | Anthropic | Additional Claude developer docs | `https://dns.google/resolve?name=docs.claude.com&type=A` | 2025-10-17 |  |
| docs.astral.sh | Python tooling | uv documentation portal | `https://dns.google/resolve?name=docs.astral.sh&type=A` | 2025-10-23 | Shares IPs with astral.sh; explicit entry for stability |
| docs.docker.com | Container tooling | Docker product documentation and CLI reference | `https://dns.google/resolve?name=docs.docker.com&type=A` | 2025-10-17 |  |
| docs.github.com | GitHub | GitHub documentation | `https://dns.google/resolve?name=docs.github.com&type=A` | 2025-10-17 |  |
| docs.hetzner.com | Hetzner | Hetzner documentation hub | `https://dns.google/resolve?name=docs.hetzner.com&type=A` | 2025-10-17 |  |
| docs.runcloud.io | RunCloud | RunCloud documentation | `https://dns.google/resolve?name=docs.runcloud.io&type=A` | 2025-10-17 |  |
| duckduckgo.com | Search | Web search endpoint used by MCP tooling | `https://dns.google/resolve?name=duckduckgo.com&type=A` | 2025-10-17 |  |
| eslint.org | Tooling docs | Official ESLint documentation for rule reference and CLI usage | `https://dns.google/resolve?name=eslint.org&type=A` | 2025-10-17 |  |
| files.pythonhosted.org | Python package registry | PyPI CDN for package downloads | `https://dns.google/resolve?name=files.pythonhosted.org&type=A` | 2025-10-23 | Fastly CDN; shares IPs with pythonhosted.org but explicit entry for safety |
| git.io | GitHub | Short URLs referenced in docs | `https://dns.google/resolve?name=git.io&type=A` | 2025-10-17 |  |
| github.githubassets.com | GitHub | Static asset CDN (docs UI) | `https://dns.google/resolve?name=github.githubassets.com&type=A` | 2025-10-17 |  |
| graphql.org | GraphQL | Official GraphQL specification and reference | `https://dns.google/resolve?name=graphql.org&type=A` | 2025-10-17 |  |
| help.openai.com | OpenAI | Help center | `https://dns.google/resolve?name=help.openai.com&type=A` | 2025-10-17 |  |
| hetzner.com | Hetzner | Provider portal | `https://dns.google/resolve?name=hetzner.com&type=A` | 2025-10-17 |  |
| html.duckduckgo.com | Search | HTML search endpoint (used by MCP) | `https://dns.google/resolve?name=html.duckduckgo.com&type=A` | 2025-10-17 | CNAME to duckduckgo.com |
| inlang.com | Localization | Inlang/Paraglide SDK documentation hub | `https://dns.google/resolve?name=inlang.com&type=A` | 2025-10-17 |  |
| lucide.dev | Icons | Lucide icon documentation for `@lucide/svelte` usage | `https://dns.google/resolve?name=lucide.dev&type=A` | 2025-10-17 |  |
| manage.runcloud.io | RunCloud | RunCloud control panel | `https://dns.google/resolve?name=manage.runcloud.io&type=A` | 2025-10-17 |  |
| mcp.context7.com | MCP Server | Context7 MCP endpoint for AI tooling | `https://dns.google/resolve?name=mcp.context7.com&type=A` | 2025-10-17 |  |
| media.githubusercontent.com | GitHub | Media attachments CDN | `https://dns.google/resolve?name=media.githubusercontent.com&type=A` | 2025-10-17 |  |
| nodejs.org | Runtime | Node.js release artifacts and documentation | `https://dns.google/resolve?name=nodejs.org&type=A` | 2025-10-17 |  |
| objects.githubusercontent.com | GitHub | Release assets CDN | `https://dns.google/resolve?name=objects.githubusercontent.com&type=A` | 2025-10-17 |  |
| one.dash.cloudflare.com | Cloudflare | Zero Trust dashboard | `https://dns.google/resolve?name=one.dash.cloudflare.com&type=A` | 2025-10-17 |  |
| openai.com | OpenAI | Root site (redirects, marketing) | `https://dns.google/resolve?name=openai.com&type=A` | 2025-10-17 |  |
| opennext.js.org | Tooling docs | OpenNext.js documentation for Next.js deployment patterns | `https://dns.google/resolve?name=opennext.js.org&type=A` | 2025-10-24 | Cloudflare CDN (3 IPs: 172.67.73.64, 104.26.8.84, 104.26.9.84) |
| pages.cloudflare.com | Cloudflare | Pages dashboard/docs | `https://dns.google/resolve?name=pages.cloudflare.com&type=A` | 2025-10-17 |  |
| payloadcms.com | CMS docs | Payload CMS documentation and configuration reference | `https://dns.google/resolve?name=payloadcms.com&type=A` | 2025-10-24 | Single IP (76.76.21.21) |
| pipelines.actions.githubusercontent.com | GitHub | Actions OIDC endpoint | `https://dns.google/resolve?name=pipelines.actions.githubusercontent.com&type=A` | 2025-10-17 |  |
| pkg.github.com | GitHub | Packages registry | `https://dns.google/resolve?name=pkg.github.com&type=A` | 2025-10-17 |  |
| platform.openai.com | OpenAI | Console (keys, billing) | `https://dns.google/resolve?name=platform.openai.com&type=A` | 2025-10-17 |  |
| playwright.azureedge.net | Tooling CDN | Playwright browser distribution CDN used by `npx playwright install` | `https://dns.google/resolve?name=playwright.azureedge.net&type=A` | 2025-10-17 | CNAME to Azure Front Door |
| playwright.dev | Tooling docs | Playwright test runner documentation | `https://dns.google/resolve?name=playwright.dev&type=A` | 2025-10-17 |  |
| pnpm.io | Package manager | pnpm installation and CLI documentation | `https://dns.google/resolve?name=pnpm.io&type=A` | 2025-10-17 |  |
| prettier.io | Tooling docs | Prettier formatter documentation | `https://dns.google/resolve?name=prettier.io&type=A` | 2025-10-17 |  |
| r.jina.ai | Utility | Plain-text fetch proxy used by Codex CLI | `https://dns.google/resolve?name=r.jina.ai&type=A` | 2025-10-17 | SOC 2 compliant; note privacy impact |
| radar.cloudflare.com | Cloudflare | Radar analytics | `https://dns.google/resolve?name=radar.cloudflare.com&type=A` | 2025-10-17 |  |
| raw.githubusercontent.com | GitHub | Raw file CDN | `https://dns.google/resolve?name=raw.githubusercontent.com&type=A` | 2025-10-17 |  |
| robot.your-server.de | Hetzner | Robot legacy management interface | `https://dns.google/resolve?name=robot.your-server.de&type=A` | 2025-10-17 |  |
| runcloud.io | RunCloud | Marketing/docs root domain | `https://dns.google/resolve?name=runcloud.io&type=A` | 2025-10-17 |  |
| shadcn-svelte.com | Frontend tooling | Component library docs/examples used across projects | `https://dns.google/resolve?name=shadcn-svelte.com&type=A` | 2025-10-17 |  |
| start.duckduckgo.com | Search | Alternate DuckDuckGo UI | `https://dns.google/resolve?name=start.duckduckgo.com&type=A` | 2025-10-17 | CNAME to duckduckgo.com |
| status.anthropic.com | Anthropic | Status page | `https://dns.google/resolve?name=status.anthropic.com&type=A` | 2025-10-17 | Atlassian Statuspage |
| status.hetzner.com | Hetzner | Status page | `https://dns.google/resolve?name=status.hetzner.com&type=A` | 2025-10-17 |  |
| status.openai.com | OpenAI | Status page | `https://dns.google/resolve?name=status.openai.com&type=A` | 2025-10-17 | CNAME to Vercel status |
| support.claude.com | Anthropic | Support knowledge base | `https://dns.google/resolve?name=support.claude.com&type=A` | 2025-10-17 |  |
| support.cloudflare.com | Cloudflare | Help center | `https://dns.google/resolve?name=support.cloudflare.com&type=A` | 2025-10-17 |  |
| support.github.com | GitHub | Support portal | `https://dns.google/resolve?name=support.github.com&type=A` | 2025-10-17 |  |
| support.vercel.com | Vercel | Support portal | `https://dns.google/resolve?name=support.vercel.com&type=A` | 2025-10-17 |  |
| svelte.dev | Frontend tooling | Official Svelte documentation and CDN references | `https://dns.google/resolve?name=svelte.dev&type=A` | 2025-10-17 |  |
| tailwind-variants.org | Frontend tooling | Tailwind Variants documentation for UI utilities | `https://dns.google/resolve?name=tailwind-variants.org&type=A` | 2025-10-17 |  |
| tailwindcss.com | Frontend tooling | Tailwind CSS docs and configuration tooling | `https://dns.google/resolve?name=tailwindcss.com&type=A` | 2025-10-17 |  |
| teams.cloudflare.com | Cloudflare | Cloudflare Teams interface | `https://dns.google/resolve?name=teams.cloudflare.com&type=A` | 2025-10-17 |  |
| the-guild.dev | GraphQL tooling | The Guild’s GraphQL Code Generator documentation | `https://dns.google/resolve?name=the-guild.dev&type=A` | 2025-10-17 |  |
| token.actions.githubusercontent.com | GitHub | Actions token service | `https://dns.google/resolve?name=token.actions.githubusercontent.com&type=A` | 2025-10-17 |  |
| typescript-eslint.io | Tooling docs | TypeScript-ESLint rules and configuration guide | `https://dns.google/resolve?name=typescript-eslint.io&type=A` | 2025-10-17 |  |
| typicode.github.io | Tooling docs | Husky git hook documentation on GitHub Pages | `https://dns.google/resolve?name=typicode.github.io&type=A` | 2025-10-17 |  |
| uploads.github.com | GitHub | Release uploads (alambic) | `https://dns.google/resolve?name=uploads.github.com&type=A` | 2025-10-17 | CNAME to alambic-origin |
| user-images.githubusercontent.com | GitHub | Issue/PR attachments CDN | `https://dns.google/resolve?name=user-images.githubusercontent.com&type=A` | 2025-10-17 |  |
| vercel.com | Vercel | Marketing/docs root domain | `https://dns.google/resolve?name=vercel.com&type=A` | 2025-10-17 |  |
| vite.dev | Tooling docs | Vite build tool documentation (includes `/llms.txt`) | `https://dns.google/resolve?name=vite.dev&type=A` | 2025-10-17 |  |
| vitest.dev | Tooling docs | Vitest test runner documentation | `https://dns.google/resolve?name=vitest.dev&type=A` | 2025-10-17 |  |
| wiki.hetzner.de | Hetzner | Hetzner wiki | `https://dns.google/resolve?name=wiki.hetzner.de&type=A` | 2025-10-17 |  |
| workers.cloudflare.com | Cloudflare | Workers dashboard/docs | `https://dns.google/resolve?name=workers.cloudflare.com&type=A` | 2025-10-17 |  |
| www.anthropic.com | Anthropic | Marketing site | `https://dns.google/resolve?name=www.anthropic.com&type=A` | 2025-10-17 |  |
| www.cloudflarestatus.com | Cloudflare | Status page (Atlassian) | `https://dns.google/resolve?name=www.cloudflarestatus.com&type=A` | 2025-10-17 |  |
| www.githubstatus.com | GitHub | Status page (Atlassian) | `https://dns.google/resolve?name=www.githubstatus.com&type=A` | 2025-10-17 |  |
| www.typescriptlang.org | Tooling docs | TypeScript handbook and compiler reference | `https://dns.google/resolve?name=www.typescriptlang.org&type=A` | 2025-10-17 | CNAME to microsoft.github.io |
| zod.dev | Tooling docs | Zod schema validation documentation | `https://dns.google/resolve?name=zod.dev&type=A` | 2025-10-17 |  |

## Removed entries

| Hostname | Removed On | Reason |
| --- | --- | --- |
