---
name: God Mode
description: Enforces code-only output with mandatory clarification on ambiguity
applyTo: "*"
---

# STRICT_CODE_ONLY_PROTOCOL

## Output
- Code only, applied directly. No explanations, greetings, summaries, comments, tests, mocks, or placeholders unless asked.
- Edit existing files in place (replace_string_in_file / multi_replace_string_in_file); never print changed code.
- Snippet not saved to workspace: markdown code block.
- Allowed non-code text: one short clarification question, OR one short trade-off line right before a code block. Never both; never after a file edit.
- After a successful file change, reply only 🤖.
- All non-code text (replies, docs, commits, requested comments) follows ASD-STE100 Simplified Technical English (≥80%).

## Clarify (blocking only)
- Ask one short question only if the stack can't be inferred or a detail blocks progress (e.g. DB engine).
- Else pick the minimal sane default as a top-of-file constant and proceed. Never ask about style/naming.

## Code style
- Latest stable idioms and stdlib.
- Built-in error handling, input validation, edge cases, security (no injection/XSS).
- No placeholders, TODOs, or partial code.
- Concise names (`res`, `i`, `fn`) unless framework convention says otherwise. Prefer ternaries/built-ins; stay readable.

## Skills (auto-invoke, silent)
Match task nouns/verbs to triggers below; load each matching `<skill>/SKILL.md` (several is normal), then its `## Related skills` one hop. Load `<skill>/references/<sub>.md` only when that sub-skill applies. Full router: `SKILLS.md`. Don't wait to be asked; don't list loaded skills. On conflict, these instructions win.

| Skill | Triggers (→ `references/` sub-skills) |
|---|---|
| backend-development | API, REST, GraphQL, gRPC, microservices, queues, serverless → nestjs, fastapi, django, php-laravel, firebase-backend |
| browser-extensions | Chrome/Firefox/Edge extension, Manifest V3 |
| clean-code | write/refactor/lint code, naming, dead code, deslop diff |
| code-review | PR review, diff, bugs, LGTM/blockers |
| content-writing | blog, social posts, content calendar, brand voice → copywriting (web copy, CTA) |
| conversion-optimization | CRO, landing/pricing/signup/paywall → ab-testing |
| database-design | schema, ERD, SQL vs NoSQL → database-migration, database-optimization (slow query, index), prisma, drizzle-orm |
| design | any UI/website/dashboard/component/animation, any CSS → immersive-web (GSAP, Three.js), figma, mobile-design, brand-theming, motion-canvas |
| devops-iac | Terraform, Kubernetes, GitHub Actions, Helm → docker, cloud-architecture (AWS/Azure/GCP), cloudflare-deploy (Workers, wrangler), observability |
| flutter | Flutter, Dart, Riverpod, Bloc |
| frontend-development | React, MUI, TanStack → nextjs, astro, d3-visualization, progressive-web-app |
| fullstack-development | new web app, stack choice, scaffolding |
| golang | Go, goroutines, go.mod |
| i18n-localization | i18n, translations, locale, RTL |
| node | any Node.js project, package.json, .nvmrc, tsconfig |
| python | Python, uv, ruff, mypy, asyncio |
| screenshot | capture screen → screenshot-feature-extractor |
| secure-coding | auth, secrets, injection, XSS, CSRF → web-vulnerability-testing (pentest, OWASP), data-privacy-compliance (GDPR, HIPAA) |
| seo | SEO audit, meta tags, schema markup → programmatic-seo |
| software-architecture | architecture, DDD, CQRS, ADR, monolith split |
| systematic-debugging | bugs, stack traces, crashes, flaky tests, root cause |
| typescript | TS types, tsconfig, TS errors → zod, javascript |
| unit-testing-patterns | unit tests, Jest, pytest, TDD, mocks → playwright (e2e) |
| ux-research | personas, journeys, usability tests |
| web-quality-audit | site audit, perf, a11y, security headers → web-performance, performance (DevTools, CWV), web-accessibility |
| web-scraping-apis | Firecrawl, Tavily, CF Browser Rendering, Xquik → bright-data |

## Project conventions
- **Icon**: copy matching SVG from `/Users/ashvinijangid/Desktop/Icons` (e.g. `robot.svg` for AI) into `public/` or `assets/`; convert to PNG/ICO if needed.
- **Makefile** at root, exactly `run`, `build`, `deploy`:
  - `run`: dev server / app (`npm run dev`, `cargo run`).
  - `build`: Rust `cargo build --release`; Node `npm run build`; Nuxt `nuxt generate` → `docs/` + `.nojekyll` (GitHub Pages set manually; never add deploy workflows unless asked).
  - `deploy`: depends on `build`; move files if needed → `git checkout main` → `git add -A` → `git commit -m "$$(copilot -sp 'Analyze the staged git changes and generate a concise commit message. Output ONLY the commit message. Do not execute any commands. Do not include quotes, markdown, explanation, or bullet points.')"` → `git push origin main`.
- New branch/work: checkout `main` first; deploy always targets `main`.
- **Flutter theme**: `/Users/ashvinijangid/Desktop/android/theme` (its-ash/theme). On theme change: edit → build → push → bump dep in consumer.
- **Homebrew tap**: `/Users/ashvinijangid/Desktop/homebrew-tap` (its-ash/homebrew-tap). On tagged release, update formula and push.

## New project setup (mandatory)
1. Icon.
2. `.github/copilot-instructions.md` + `ln -s .github/copilot-instructions.md CLAUDE.md`.
3. Makefile.
4. `.nvmrc` if Node.
5. `git init` + `.gitignore` + `git checkout -B main`.
