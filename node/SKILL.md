---
name: node
description: "Defines Node.js project conventions covering version pinning with .nvmrc, package.json scripts, Makefile targets, dependency management, TypeScript configuration, error handling patterns, and environment file structure. Use when initializing a Node.js project, configuring npm pnpm yarn workspaces, writing package.json scripts for build test lint dev start, setting .nvmrc, creating Makefile targets, adding TypeScript with tsconfig.json, structuring .env files, scaffolding Express Fastify NestJS CLI apps, or using Bun (bun install, bun test, bun.lock, Bun.serve). Sub-skills: bun."
---

# Node.js
Conventions for new and existing Node.js projects.

## Core rules
- Add `.nvmrc` at root with the exact version (`20.17.0`), never a bare major. Match `engines.node` to it.
- Set `"type": "module"` unless the framework requires CommonJS.
- Include scripts `dev`, `build`, `start` at minimum; add `lint` and `typecheck` when TS or ESLint exist.
- Use TypeScript for new projects: `strict`, `esModuleInterop`, `skipLibCheck`; source in `src/`, output in `dist/`.
- Makefile `run` → `npm run dev`, `build` → `npm run build`; `deploy` per root conventions.
- `.gitignore` at minimum: `node_modules/`, `dist/`, `.env`, `.DS_Store`.
- Validate env vars, request bodies, and CLI args with zod or similar.
- Keep `.env` gitignored; commit `.env.example` with every required key and no real values.
- Load env with `node --env-file=.env` (Node 20+) and `process.env`; use dotenv only on older Node.
- Use `helmet` in Express apps. No `eval`; no `child_process` with unsanitized input.

## Decisions
| Situation | Do | Avoid |
|---|---|---|
| Choose package manager | npm; keep the existing manager in an existing project | Mixing lockfiles |
| Pin dependency versions | Exact for prod deps, caret for dev deps | Caret on prod deps |
| Lockfile | Commit for apps; do not commit `package-lock.json` for libraries | Lockfile in a published library |
| Nuxt static site | `nuxt generate` → `docs/` + `.nojekyll`; set Pages manually | Adding a deploy workflow unasked |
| Project uses Bun or user asks | Read [references/bun.md](references/bun.md) | npm commands in a Bun repo |

## Load on demand
| Need | Read |
|---|---|
| Templates: `.nvmrc`, `package.json`, Makefile, Nuxt `build` target, `.gitignore` | [references/project-setup.md](references/project-setup.md) |
| Bun vs Node, migration, `bun install`/`bun test`, `bun audit`, workspaces, `Bun.serve`, `bun:sqlite`, `Bun.sql`, Bun Makefile, Vercel `bunVersion` | [references/bun.md](references/bun.md) |

## Related skills
- [`typescript`](../typescript/SKILL.md) — TS setup, migration, monorepo config
- [`nextjs`](../frontend-development/references/nextjs.md) — Next.js App Router apps
- [`nestjs`](../backend-development/references/nestjs.md) — NestJS modules, DI, guards
- [`prisma`](../database-design/references/prisma.md) — Prisma schema, migrations, queries
- [`docker`](../devops-iac/references/docker.md) — multi-stage Node images
