---
name: cloudflare-deploy
description: "Deploy applications and infrastructure to Cloudflare using Workers, Pages, D1, KV, R2, Vectorize, and AI Gateway via wrangler CLI or Terraform. Use when publishing code to Cloudflare Workers, configuring Pages builds, binding D1 databases, KV namespaces, R2 buckets, Vectorize indexes, setting up AI Gateway, managing DNS records, configuring Zero Trust tunnels, applying WAF rules, or running wrangler deploy, wrangler pages deploy, wrangler secret put, terraform apply for cloudflare provider."
---

# Cloudflare Deploy
Deploy code and infrastructure to Cloudflare. Choose the appropriate Cloudflare product, authenticate, and run the deployment command.

## When to use
Use this skill when the user asks to **deploy**, **host**, **publish**, or **set up** a project on Cloudflare. It covers serverless functions, static sites, storage, AI, networking, security, media, and infrastructure‑as‑code.

## Prerequisites
- Ensure the deployment environment can make outbound network calls. If a sandbox blocks them, rerun with `sandbox_permissions=require_escalated`.
- Expect the deployment to take a few minutes. Set a timeout longer than the default (e.g., 300 s).

## Authentication (required before any `wrangler` command)
1. Verify you are logged in:
   ```bash
   npx wrangler whoami   # Shows the Cloudflare account if authenticated
   ```
2. If not logged in, choose the appropriate method:
   - **Interactive / local development**: run `wrangler login` and complete the OAuth flow.
   - **CI/CD pipelines**: set the environment variable `CLOUDFLARE_API_TOKEN` with a token that has `Account Settings → API Tokens → Edit` permissions for the target account.

## Decision Guide
Select the Cloudflare product that matches your requirement.

### Compute & Runtime
| Need | Product | Typical command |
|------|---------|-----------------|
| Run serverless code at the edge | **Workers** | `npx wrangler deploy` |
| Full‑stack web app with Git‑based deploys | **Pages** | `npx wrangler pages deploy ./public` |
| Stateful coordination or real‑time data | **Durable Objects** | Define DO class, deploy with Workers |
| Multi‑step background jobs | **Workflows** | `npx wrangler workflows deploy` |
| Container workloads | **Containers** | `npx wrangler containers deploy` |
| Multi‑tenant platform (customers upload code) | **Workers for Platforms** | Use platform SDK and deploy per tenant |
| Scheduled tasks (cron) | **Cron Triggers** | Add `triggers.cron` in `wrangler.toml` |
| Simple edge request modification | **Snippets** | Add snippet script and publish |
| Observe Worker execution logs | **Tail Workers** | `npx wrangler tail` |
| Optimize latency to backend services | **Smart Placement** | Enable `smart_placement` in `wrangler.toml` |

### Storage & Data
| Need | Product |
|------|---------|
| Key‑value store for config, sessions, cache | **KV** |
| Relational SQL (SQLite) | **D1** |
| PostgreSQL / MySQL compatible | **Hyperdrive** |
| Object / file storage (S3‑compatible) | **R2** |
| Message queue for async processing | **Queues** |
| Vector embeddings for AI search | **Vectorize** |
| Strongly‑consistent per‑entity state | **Durable Objects (storage)** |
| Secrets management | **Secrets Store** |
| Streaming ETL pipelines to R2 | **Pipelines** |
| Long‑term persistent cache | **Cache Reserve** |

### AI / Machine Learning
| Need | Product |
|------|---------|
| Run inference (LLMs, embeddings, images) | **Workers AI** |
| Vector database for retrieval‑augmented generation | **Vectorize** |
| Build stateful AI agents | **Agents SDK** |
| Cache / route requests to any AI provider | **AI Gateway** |
| AI‑powered search widget | **AI Search** |

### Networking & Connectivity
| Need | Product |
|------|---------|
| Expose a local service to the internet | **Tunnel** |
| TCP/UDP proxy for non‑HTTP traffic | **Spectrum** |
| WebRTC TURN server | **TURN** |
| Private network interconnect between Cloudflare and other clouds | **Network Interconnect** |
| Global traffic acceleration | **Argo Smart Routing** |
| Optimize backend latency (not user‑facing) | **Smart Placement** |
| Real‑time video/audio | **RealtimeKit** or **Realtime SFU** |

### Security
| Need | Product |
|------|---------|
| Web Application Firewall | **WAF** |
| DDoS protection | **DDoS** |
| Bot detection and management | **Bot Management** |
| API protection and schema validation | **API Shield** |
| CAPTCHA‑free human verification | **Turnstile** |
| Credential leak detection | **WAF (managed ruleset)** |

### Media & Content
| Need | Product |
|------|---------|
| Image optimization and transformation | **Images** |
| Video streaming and on‑the‑fly encoding | **Stream** |
| Browser automation / screenshots | **Browser Rendering** |
| Third‑party script management | **Zaraz** |

## Infrastructure as Code (IaC)
- **Pulumi**: Write TypeScript, Python, Go, or .NET code and run `pulumi up`.
- **Terraform**: Use the `cloudflare` provider. Example:
  ```hcl
  provider "cloudflare" {
    api_token = var.cloudflare_api_token
  }
  ```
- **Direct REST API**: Call `https://api.cloudflare.com/client/v4/…` with the API token.

## Troubleshooting
### Deploy fails due to network restrictions
If you see timeouts, DNS errors, or connection resets, the sandbox may be blocking outbound traffic. Rerun the deployment with escalated network permissions:
```bash
# Example for a CI step
npx wrangler deploy --sandbox-permissions=require_escalated
```
Prompt the user before doing this, e.g., "The deployment needs escalated network access. Shall I retry with the required permissions?"

### Common errors
- **Authentication error**: `wrangler login` again or verify `CLOUDFLARE_API_TOKEN`.
- **Missing KV namespace**: Create it with `npx wrangler kv:namespace create "MY_KV"` and add the binding to `wrangler.toml`.
- **Pages build failure**: Ensure the build command produces a `dist/` folder and that `wrangler.toml` points to it.
- **Rate‑limit**: Back off and retry after the `Retry-After` header value.

## Checklist
- [ ] Verify `npx wrangler whoami` shows the correct account.
- [ ] Set `CLOUDFLARE_API_TOKEN` in CI environments.
- [ ] Choose the correct Cloudflare product (Workers, Pages, R2, etc.).
- [ ] Add required bindings (KV, D1, R2, etc.) to `wrangler.toml`.
- [ ] Configure any `triggers` (cron, routes, custom domains).
- [ ] Run `npx wrangler deploy` (or `pages deploy`) with appropriate timeout.
- [ ] If deployment fails, check network permissions and retry with `sandbox_permissions=require_escalated`.
- [ ] Verify the deployed service works by sending a test request.

## Related skills

Load these when the task spans more than this skill.

- [`devops-iac`](../devops-iac/SKILL.md) — DevOps IaC skill provides a step-by-step workflow for designing, implementing, and operating cloud infrastruct…
- [`deployment-procedures`](../deployment-procedures/SKILL.md) — Provides a concise, platform‑agnostic procedure for safely deploying production services, covering pre‑checks,…
- [`cloud-architecture`](../cloud-architecture/SKILL.md) — Provides step‑by‑step guidance, best‑practice rules, and checklists for designing, building, and optimizing se…
- [`observability`](../observability/SKILL.md) — Observability skill provides practical guidance for building, querying, and visualizing production‑grade monit…
- [`secrets-management`](../secrets-management/SKILL.md) — Manage secrets for CI/CD and runtime systems with Vault, AWS Secrets Manager, GitHub/GitLab variables, Kuberne…
- [`file-uploads`](../file-uploads/SKILL.md) — Handles file uploads and cloud storage with S3, Cloudflare R2, presigned URLs, multipart uploads, and image op…
