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
Match task nouns/verbs to triggers below; load each matching `<skill>/SKILL.md` (several is normal), then its `## Related skills` one hop. Load `references/*.md` only for that sub-topic. Full router: `SKILLS.md`. Don't wait to be asked; don't list loaded skills. On conflict, these instructions win.

| Skill | Triggers |
|---|---|
| ab-testing | A/B, multivariate, experiment, sample size, power, significance |
| astro | Astro, islands, content collections, MDX, SSG blog/docs |
| backend-development | API, REST, GraphQL, gRPC, microservices, Kafka, auth, rate limit, queues, serverless |
| brand-theming | brand colors, fonts, style guide, PPTX/DOCX/XLSX theming |
| bright-data | Bright Data, SERP API, Web Unlocker, scraping proxies |
| browser-extensions | Chrome/Firefox/Edge extension, Manifest V3, content script |
| clean-code | write/refactor/lint code, naming, dead code, deslop diff |
| cloud-architecture | AWS/Azure/GCP design, IaC, VPC, IAM, HA/DR, FinOps |
| cloudflare-deploy | Workers, Pages, D1, KV, R2, wrangler |
| code-review | PR review, diff, bugs, LGTM/blockers |
| content-writing | blog, social posts, content calendar, brand voice |
| conversion-optimization | CRO, landing/pricing/signup/paywall optimization |
| copywriting | web copy, headlines, CTA, value prop |
| d3-visualization | D3, SVG charts, scales, axes, force layout |
| data-privacy-compliance | GDPR, CCPA, HIPAA, consent, DPIA |
| database-design | schema, ERD, normalization, SQL vs NoSQL |
| database-migration | migrations, ALTER TABLE, backfill, zero-downtime, Sequelize/TypeORM/Prisma |
| database-optimization | slow query, index, EXPLAIN, partitioning, pooling |
| design | any UI/website/landing/dashboard/component/animation, any CSS |
| devops-iac | Terraform, Kubernetes, GitHub Actions, Helm, ArgoCD |
| django | Django, DRF, Celery, Channels |
| docker | Dockerfile, compose, buildx, image size |
| drizzle-orm | Drizzle, drizzle-kit, pgTable |
| fastapi | FastAPI, Pydantic, SQLAlchemy |
| figma | Figma to code, design tokens |
| firebase-backend | Firebase, Firestore, rules, Cloud Functions |
| flutter | Flutter, Dart, Riverpod, Bloc |
| frontend-development | React, Next.js, MUI, TanStack |
| fullstack-development | new web app, stack choice, scaffolding |
| golang | Go, goroutines, go.mod |
| i18n-localization | i18n, translations, locale, RTL |
| immersive-web | scroll animation, parallax, GSAP, Three.js, R3F |
| javascript | JS semantics, closures, this, event loop, coercion |
| mobile-design | mobile UI, iOS/Android, React Native, touch targets |
| motion-canvas | Motion Canvas, programmatic video |
| nestjs | NestJS |
| nextjs | Next.js App Router, server actions, caching |
| node | any Node.js project, package.json, .nvmrc, tsconfig |
| observability | metrics, logs, traces, Grafana, Datadog, SLO, alerts |
| performance | DevTools perf audit, Core Web Vitals, Lighthouse |
| php-laravel | PHP, Laravel, Eloquent |
| playwright | e2e tests, browser automation |
| prisma | Prisma schema/client/migrate |
| programmatic-seo | pSEO, mass template pages |
| progressive-web-app | PWA, service worker, manifest, offline |
| python | Python, uv, ruff, mypy, asyncio |
| screenshot | capture screen |
| screenshot-feature-extractor | screenshots/mockups to feature checklist |
| secure-coding | auth, secrets, injection, XSS, CSRF, security review |
| seo | SEO audit, meta tags, schema markup, GSC |
| shopify | Shopify apps/themes, Liquid, Polaris |
| software-architecture | architecture, DDD, CQRS, ADR, monolith split |
| stripe | Stripe, payments, subscriptions, webhooks |
| systematic-debugging | bugs, stack traces, crashes, flaky tests, root cause |
| twilio | SMS, OTP, Verify, TwiML |
| typescript | TS types, tsconfig, TS errors |
| unit-testing-patterns | unit tests, Jest, pytest, TDD, mocks |
| ux-research | personas, journeys, usability tests |
| vercel | Vercel deploy, vercel.json |
| web-accessibility | a11y, WCAG, ARIA, contrast, keyboard |
| web-performance | page speed, bundle size, caching, lazy load |
| web-quality-audit | full site audit: perf, a11y, SEO, security headers |
| web-scraping-apis | Firecrawl, Tavily, CF Browser Rendering, Xquik |
| web-vulnerability-testing | pentest, OWASP, SQLi, XSS, SSRF, IDOR |
| zod | Zod, schema validation |

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
