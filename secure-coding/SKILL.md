---
name: secure-coding
description: "Secure coding guidance and review checklists for secrets, authentication, authorization, input validation, SQL injection, XSS, CSRF, API security, rate limiting, and deployment hardening. Use when writing or reviewing security-sensitive code, APIs, auth, payments, or producing a security report in Python, JavaScript/TypeScript, or Go, or when handling JWT, OAuth, SQL queries, env vars, API keys, npm, pip, or go modules. Sub-skills: web-vulnerability-testing, data-privacy-compliance, security-bounty-hunter, cloud-infrastructure-security."
---
# Secure Coding
Protect trust boundaries: validate input, protect secrets, enforce authorization, prevent injection, do not leak data.

## Core rules
- Validate all input at trust boundaries with a schema (type, format, range, length, allowlist). Never trust client data.
- Prefer allowlists to blocklists. Fail closed: deny by default.
- Never hardcode secrets. Load from env; fail startup if missing. Keep `.env*` out of git; rotate and purge exposed secrets.
- Never concatenate input into SQL. Use parameterized queries or ORM. Select only needed columns; never return hashes or secrets.
- Authenticate every protected endpoint. Check authorization (ownership, role, policy) on every object and function.
- Store tokens in `httpOnly` + `Secure` + `SameSite` cookies, not `localStorage`.
- JWT: secret ≥ 256 bits, ~1 h expiry, validate `iss` and `aud`, no sensitive payload, server-side refresh + revocation.
- Hash passwords with bcrypt (cost ≥ 10) or argon2. Require length ≥ 12 or a strength scorer.
- Use long random public IDs (UUIDv4, random hex). Do not expose sequential IDs.
- Rate-limit per IP and per user; stricter on login, signup, search, expensive ops.
- Return generic errors; log detail server-side. Never log passwords, tokens, cards, or secrets.
- Escape output by framework default; sanitize user HTML with an allowlist; set a strict CSP.
- Apply the same controls to REST, GraphQL, and WebSocket APIs.
- Apply project security docs and approved exceptions before generic rules. Document every bypass.

## Decisions
| Situation | Do | Avoid |
|---|---|---|
| Writing new code | Apply core rules silently (secure by default) | Asking before each control |
| Editing, see critical issue | Flag it; ask before fixing (passive mode) | Silent unrelated fixes |
| User asks for audit | Full review report, fix one finding at a time | Mixed-finding commits |
| Local dev without TLS | Env flag to turn off `Secure` cookies; do not report missing TLS | HSTS before rollback plan is clear |
| Inline script/style needed | Nonce or hash in CSP; log as debt with removal plan | `'unsafe-inline'`, `'unsafe-eval'` by default |
| State-changing request | CSRF token; double-submit cookie if stateless; `SameSite=Strict` | Relying on CORS alone |
| Multi-tenant DB (Supabase) | Row-level security policies | App-only tenant filters |
| Distributed rate limit | Shared store (Redis); `429` + standard headers | Per-instance memory counters |
| File upload | Check size, MIME, extension, content; random name; store outside web root | Trusting user filename |
| Wallet / blockchain | Verify signature; check recipient, amount, balance | Blind signing |
| CORS | Explicit trusted origins | `*` with credentials |

## Load on demand
| Need | Read |
|---|---|
| Code examples (zod, JWT, authz, rate limit, Helmet, CSP, CSRF, RLS, Solana, tests) | [references/secure-patterns.md](references/secure-patterns.md) |
| Report format, pre-deploy checklist, OWASP API Top 10, sources | [references/review-checklist.md](references/review-checklist.md) |
| Pentest, OWASP scans, Burp, ZAP, ffuf, nuclei | [references/web-vulnerability-testing.md](references/web-vulnerability-testing.md) |
| GDPR, CCPA, HIPAA, consent, DSAR, DPIA | [references/data-privacy-compliance.md](references/data-privacy-compliance.md) |
| Bug bounty hunt, PoC, disclosure report | [references/security-bounty-hunter.md](references/security-bounty-hunter.md) |
| Cloud IAM, secrets manager, WAF, CI/CD security, backups | [references/cloud-infrastructure-security.md](references/cloud-infrastructure-security.md) |

## Related skills
- [`code-review`](../code-review/SKILL.md) — general PR review beyond security
- [`golang`](../golang/SKILL.md) — Go-specific security idioms
- [`web3-security`](../web3-security/SKILL.md) — smart contract and DeFi audits
