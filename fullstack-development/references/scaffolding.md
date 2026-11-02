# Scaffolding and templates

## Project type detection
| Category | Keywords |
|---|---|
| Social media | feed, post, like, follow, profile |
| SaaS | subscription, billing, stripe, dashboard |
| Landing page | static, marketing, hero, cta |
| API service | REST, GraphQL, endpoint, microservice |
| Mobile app | react-native, expo, flutter, android, ios |

Use the first match. No match: full-stack web app.

## Templates
| Template | Stack | Use for |
|---|---|---|
| `nextjs-fullstack` | Next.js + Prisma + PostgreSQL | General full-stack app |
| `nextjs-saas` | Next.js + Prisma + Stripe | SaaS |
| `nextjs-static` | Next.js static export | Landing page |
| `nuxt-app` | Nuxt + Pinia + PostgreSQL | Vue full-stack |
| `express-api` | Express + JWT + PostgreSQL | REST API |
| `python-fastapi` | FastAPI + PostgreSQL | Python API |
| `react-native-app` | Expo + Zustand | Mobile |
| `flutter-app` | Flutter + Riverpod | Cross-platform mobile |
| `electron-desktop` | Electron + React | Desktop |
| `cli-tool` | Node.js + Commander | CLI |
| `monorepo-turborepo` | Turborepo + pnpm | Multi-package repo |

## Steps
1. Create directory, `git init`.
2. Copy the template into the root.
3. `npm install` (or `pnpm install` / `yarn install`).
4. `cp .env.example .env`; set DB URL and API keys.
5. `npx prisma generate` and `npx prisma migrate dev --name init`.

## Folder layout (Next.js)
```
src/
  app/ or pages/   # routes; API routes under app/api or pages/api
  components/      # reusable UI
  lib/             # helpers, API clients, auth utilities
  styles/          # CSS modules or Tailwind config
prisma/            # schema and migrations
public/            # static assets
tests/             # unit/integration tests
```

## Commands
```bash
npx prisma migrate dev --name <migration>
npx prisma studio                 # inspect DB
npm run dev | build | start | test | lint
npm run type-check                # tsc --noEmit
npx eslint . --fix && npx prettier --write .
npm audit fix
```

## Agent coordination order
1. project-planner: task list and dependency graph.
2. frontend-specialist: UI components and pages.
3. backend-specialist: API routes and business logic.
4. database-architect: schema and migrations.
5. devops-engineer: Dockerfiles, CI/CD, manifests.

Give each agent only the scoped files from the previous step.
