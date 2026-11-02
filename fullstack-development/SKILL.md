---
name: fullstack-development
description: "Fullstack Development skill guides planning, scaffolding, coding, testing, and deploying modern web applications with React, Next.js, Node.js, GraphQL, REST, and PostgreSQL. Use when creating a new project, selecting a tech stack, setting up architecture, enforcing code quality, or automating deployment with npm, pnpm, yarn, Docker, CI/CD, monorepo, API routes, Prisma, Drizzle, Jest, Vitest, Playwright, Vercel, Railway, environment variables, auth, and migrations."
---
# Fullstack Development
Plan, scaffold, build, and ship a complete web app across UI, API, and database.

## Core rules
- Detect the project type first, then pick one template ([scaffolding](references/scaffolding.md)).
- Default stack: Next.js + TypeScript, Node API routes or Express (or Apollo GraphQL), PostgreSQL via Prisma, Clerk or Auth0, Cloudinary or Supabase Storage.
- Data flow: client (TanStack Query / Apollo Client) → API layer (validate, authorize) → service layer (business logic) → ORM → PostgreSQL.
- Validate every request body with zod (TS) or Joi at the API boundary.
- Throw a typed `HttpError(status, message)`; one central middleware returns `{ error, code }`. Log with winston on the server.
- Keep secrets in `.env`; commit only `.env.example`.
- Use parameterized queries only (Prisma does this).
- Add CSRF protection to form posts, CSP headers, rate limiting (`express-rate-limit`), HTTPS everywhere (`mkcert` locally).
- Hash passwords with bcrypt, or use third-party auth.
- Version the schema with migrations (`prisma migrate`).
- Document public APIs with OpenAPI or GraphQL schema comments.
- Measure before optimizing (Web Vitals, `pg_stat_statements`).
- Paginate list responses; keep payloads small.
- CI gate: lint, type-check, tests, image build, `npm audit`.

## Decisions
| Situation | Do | Avoid |
|---|---|---|
| SaaS | Default stack + Stripe | Hand-rolled billing |
| Mobile app | React Native (Expo) or Flutter | Next.js |
| Static or marketing site | Next.js static export or Nuxt | Server runtime you do not need |
| API only | Express template or FastAPI | Full Next.js app |
| Multi-package repo | Turborepo + pnpm workspaces | Copy-paste shared code |
| Hosting, managed | Vercel (frontend) + Railway or Render (backend) | Self-managed VMs |
| Hosting, self-hosted | Docker + Kubernetes | Bare `npm start` on a host |

| Situation | Do | Avoid |
|---|---|---|
| Read-heavy query | Redis or edge cache | Recompute per request |
| Page can pre-render | ISR / static generation | SSR per request |
| Heavy client component | `React.lazy` + `Suspense` | Load in the main bundle |

## Load on demand
| Need | Read |
|---|---|
| Project-type keywords, templates, setup steps, folder layout, commands, agent order | [references/scaffolding.md](references/scaffolding.md) |
| Dockerfile, Compose, Kubernetes manifest, release checklist | [references/deployment.md](references/deployment.md) |

## Related skills
- [`frontend-development`](../frontend-development/SKILL.md) — React, Next.js, TanStack, MUI UI work
- [`nextjs`](../frontend-development/references/nextjs.md) — Next.js App Router patterns
- [`backend-development`](../backend-development/SKILL.md) — API design, services, resilience
- [`node`](../node/SKILL.md) — Node project conventions, scripts, tsconfig
- [`database-design`](../database-design/SKILL.md) — schema, migrations, Prisma, Drizzle
- [`typescript`](../typescript/SKILL.md) — TS types and config
- [`devops-iac`](../devops-iac/SKILL.md) — CI/CD, Docker, Kubernetes depth
- [`secure-coding`](../secure-coding/SKILL.md) — auth, injection, XSS, CSRF
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — Jest, Vitest, Playwright tests
