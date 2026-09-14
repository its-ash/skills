---
name: node
description: Node.js project conventions and setup rules. Load when creating, configuring, or working on any Node.js project — Nuxt, Next.js, Express, Vite, CLI tools, etc. Covers .nvmrc, package.json scripts, Makefile targets, build/deploy, and project scaffolding.
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