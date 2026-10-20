---
name: node
description: "Defines Node.js project conventions covering version pinning with .nvmrc, package.json scripts, Makefile targets, dependency management, TypeScript configuration, error handling patterns, and environment file structure. Use when initializing a Node.js project, configuring npm pnpm yarn workspaces, writing package.json scripts for build test lint dev start, setting .nvmrc for version consistency, creating Makefile targets for common tasks, adding TypeScript with tsconfig.json, structuring .env .env.local .env.production files, or scaffolding Express Fastify NestJS CLI applications."
---

# Node.js Skill

## Version management
- **Always** add `.nvmrc` at project root with the LTS or installed Node version.
  ```bash
  node -v > .nvmrc
  ```
- Pin the exact version (e.g. `20.17.0`), never a vague major like `20`.

## package.json
- `type: "module"` by default unless the framework requires CommonJS.
- Scripts: always include `dev`, `build`, `start` at minimum.
  ```json
  {
    "scripts": {
      "dev": "<framework dev command>",
      "build": "<framework build command>",
      "start": "node dist/index.js",
      "lint": "eslint .",
      "typecheck": "tsc --noEmit"
    }
  }
  ```
- Engines field matching `.nvmrc`:
  ```json
  { "engines": { "node": ">=20.0.0" } }
  ```

## Makefile (Node.js specific)
```makefile
run:
	npm run dev

build:
	npm run build

deploy: build
	git checkout main
	git add -A
	git commit -m "$$(copilot -sp 'Analyze the staged git changes and generate a concise commit message. Output ONLY the commit message. Do not execute any commands. Do not include quotes, markdown, explanation, or bullet points.')"
	git push origin main
```

### Nuxt.js variant
- `build`: `nuxt generate`, output copied/configured into `docs/` at project root + `.nojekyll` file.
- `docs/` is served via GitHub Pages configured manually in repo settings — never add a GitHub Actions/extension deploy workflow unless explicitly asked.
```makefile
build:
	npx nuxt generate
	cp -r .output/public/* docs/ 2>/dev/null || cp -r dist/* docs/ 2>/dev/null
	touch docs/.nojekyll
```

## Project setup (all mandatory)
1. `.nvmrc` — per above.
2. `package.json` — per above.
3. `Makefile` — per above.
4. `.gitignore` — at minimum: `node_modules/`, `dist/`, `.env`, `.DS_Store`.
5. `git init` + `git checkout -B main`.

## Dependencies
- Prefer npm over yarn/pnpm unless the existing project uses another manager.
- Install exact versions for prod deps, caret for dev deps.
- Never commit `package-lock.json` for libraries; always commit for apps.

## TypeScript
- Use TypeScript by default for new Node.js projects.
- `tsconfig.json` with `strict: true`, `esModuleInterop: true`, `skipLibCheck: true`.
- Output to `dist/`, source in `src/`.

## Error handling & security
- Validate all external input (env vars, request bodies, CLI args) — use zod or similar.
- Never hardcode secrets; load from env with a `.env` file (gitignored) + dotenv.
- Use helmet for Express apps.
- No `eval`, no `child_process` with unsanitized input.

## Env files
- `.env` in `.gitignore`.
- `.env.example` committed with all required keys documented (no real values).
- Load via `process.env` directly (Node 20+ loads `.env` natively with `--env-file`).

## Related skills

Load these when the task spans more than this skill.

- [`typescript`](../typescript/SKILL.md) — Provides expert guidance for TypeScript projects, covering setup analysis, migration, monorepo configuration,…
- [`nextjs`](../nextjs/SKILL.md) — Guidelines for building Next.js 14+ applications with the App Router. Includes component type decisions, data…
- [`nestjs`](../nestjs/SKILL.md) — Expert guidance for NestJS applications covering module architecture, dependency injection, middleware, guards…
- [`prisma`](../prisma/SKILL.md) — Provides expert guidance for Prisma ORM tasks such as schema design, migrations, query optimization, relation…
- [`docker`](../docker/SKILL.md) — Provides expert guidance for Dockerfile optimization, multi‑stage builds, image size reduction, container secu…
- [`stripe`](../stripe/SKILL.md) — Implements Stripe payments, subscriptions, billing portal, checkout sessions, and webhooks with idempotency, s…
- [`vercel`](../vercel/SKILL.md) — Deploy and optimize applications on Vercel. Use for tasks involving 'vercel', 'deploy', 'hosting', or 'product…
