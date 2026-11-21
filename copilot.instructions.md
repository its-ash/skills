---
name: God Mode
description: Enforces code-only output, silent skill auto-invocation, and standardized project conventions
applyTo: "*"
---

# STRICT_CODE_ONLY_PROTOCOL

## Output
- Code only, applied directly. No explanations, greetings, summaries, comments, tests, mocks, or placeholders unless asked.
- Edit existing files in place; never print unchanged or full file contents.
- Snippet not saved to workspace: markdown code block.
- Allowed non-code text: one short clarification question, OR one short trade-off line right before a code block. Never both; never after a file edit.
- After a successful file change, reply only 🤖.
- All non-code text (replies, docs, commits, requested comments) follows ASD-STE100 Simplified Technical English (≥80%).

## Clarify (blocking only)
- Ask one short question only if the stack cannot be inferred or a detail blocks progress (e.g. DB engine).
- Else pick the minimal sane default as a top-of-file constant and proceed. Never ask about style or naming.

## Code style
- Latest stable idioms and stdlib.
- Built-in error handling, input validation, edge cases, and security (no injection/XSS).
- No placeholders, TODOs, or partial code.
- Concise names (`res`, `i`, `fn`) unless framework convention says otherwise. Prefer ternaries/built-ins; stay readable.

## Skills (auto-invoke, silent)
Applies across Copilot, Claude Code, Gemini CLI, and Zed. On every task:
1. Match task nouns, verbs, file extensions, frameworks, and tools to **Triggers** below (full catalog with all sub-skills: `SKILLS.md`).
2. Load every matching `<skill>/SKILL.md` silently (combining multiple skills is normal), then follow its `## Related skills` one hop.
3. Load `<skill>/references/<sub>.md` only when that sub-skill applies.
4. Never wait to be asked; never announce loaded skills. On conflict, these instructions win.

| Skill | Triggers (→ `references/` sub-skills) |
|---|---|
| ai-agent-engineering | AI agents, harness, autonomous loops, evals, pass@k, multi-agent, MCP server, prompt injection, LLM cost → agent-harness-construction, autonomous-loops, eval-harness, mcp-server-patterns, agent-security-hardening, llm-cost-optimization, team-agent-orchestration, search-first |
| backend-development | API, REST, GraphQL, gRPC, OpenAPI, microservices, queues, serverless, multi-tenant, Django, Laravel, Rails → api-design, nodejs-patterns, nestjs, fastapi, django, php-laravel, rails, contract-first, error-handling, firebase-backend |
| browser-extensions | Chrome/Firefox/Edge extension, Manifest V3, content script, service worker, popup |
| clean-code | write/refactor/lint code, naming, dead code, SOLID, deslop diff → coding-standards, inherit-legacy-style, codehealth-mcp |
| code-review | PR review, diff, bugs, breaking changes, LGTM/blockers, verify → change-impact, click-path-audit, code-review-feedback, verification-loop |
| content-writing | blog, social posts, content calendar, brand voice, outreach, pitch deck, launch → copywriting, social-content, brand-voice, article-writing, social-publishing, lead-intelligence, investor-materials, marketing-campaign |
| conversion-optimization | CRO, landing/pricing/signup/onboarding/paywall, funnel → ab-testing |
| cpp | C++, .cpp/.hpp, CMake, RAII, smart pointers, GoogleTest → cpp-testing |
| database-design | schema, ERD, SQL vs NoSQL, indexes, migrations, Postgres, MySQL, ClickHouse, Redis → postgresql, mysql-patterns, clickhouse, redis, database-migration, database-optimization, prisma, drizzle-orm |
| design | any UI/website/dashboard/component/animation, modern CSS (oklch, light-dark, filled tabs, tonal cards), design tokens → visual-design-direction, design-system, make-interfaces-feel-better, tailwind-css, shadcn-ui, motion-react, immersive-web, threejs, gsap, figma, mobile-design, brand-theming, motion-canvas, html-slides |
| devops-iac | Terraform, Kubernetes, Helm, Docker, GitHub Actions, PM2/deploy/rollback, observability, Cloudflare → docker, kubernetes, github-actions, deployment-patterns, cloud-architecture, cloudflare-deploy, observability, flox-environments, uncloud |
| document-processing | PDF/DOCX/XLSX convert, OCR, redact, e-signature, visa translate → nutrient-document-processing, esign-field-placement, visa-doc-translate |
| documentation | docs drift, onboarding guide, CodeTour, CONTEXT.md, growth log → codebase-onboarding, code-tour, context-and-decisions, growth-log |
| dotnet | C#, F#, .NET, ASP.NET Core, EF Core, xUnit, WPF → csharp-testing, fsharp-testing, windows-desktop-e2e |
| flutter | Flutter, Dart, pubspec.yaml, Riverpod, Bloc, Provider → dart-flutter-patterns, flutter-code-review |
| frontend-development | React, Next.js, MUI, TanStack, Vue, Nuxt, Angular, Vite, Astro, PWA, React Native → nextjs, react-patterns, react-performance, mui, vue, nuxt, angular, vite, astro, d3-visualization, progressive-web-app, react-native |
| fullstack-development | new web app, stack choice, scaffolding, monorepo, deploy |
| git-workflow | branch, commit message, rebase, release, gh issue/PR, Jira, open-source → github-ops, conventional-commit-review, issue-review, jira-integration, opensource-pipeline, project-flow-ops |
| golang | Go, .go, go.mod, goroutines, channels, golangci-lint → golang-patterns, golang-testing |
| healthcare | HIPAA, PHI, EMR/EHR, CDSS, HL7/FHIR → phi-compliance, emr, cdss, eval-harness |
| i18n-localization | i18n, l10n, translations, locale JSON, ICU, RTL → i18n-sync, bengali-nlp |
| java | Java, Maven/Gradle, Spring Boot, Quarkus, JPA, MyBatis → springboot-patterns, springboot-security, springboot-testing, quarkus-patterns, quarkus-security, quarkus-testing, jpa-patterns, mybatis-patterns, tinystruct-patterns |
| kotlin | Kotlin, .kt/.kts, coroutines, Flow, Ktor, Exposed, Android, Compose → kotlin-coroutines-flows, kotlin-testing, kotlin-ktor-patterns, kotlin-exposed-patterns, android-clean-architecture, compose-multiplatform-patterns |
| machine-learning | ML pipeline, PyTorch, model eval, drift, recsys, ETL → pytorch-patterns, ml-adoption-playbook, recsys-pipeline-architect, data-throughput-accelerator |
| networking | homelab, VLAN, Pi-hole, WireGuard, Cisco, Netmiko, BGP → homelab-network-readiness, homelab-vlan-segmentation, homelab-pihole-dns, homelab-wireguard-vpn, cisco-ios-patterns, netmiko-ssh-automation, network-bgp-diagnostics, network-config-validation, network-interface-health |
| node | Node.js, package.json, .nvmrc, tsconfig, .env, Makefile, PM2, Bun → bun |
| perl | Perl, .pl/.pm, CPAN, Mojolicious, DBI → perl-security, perl-testing |
| product-strategy | product brief, go/no-go, ICE, PRD, TAM/SAM/SOM, competitors, brand discovery → product-capability, market-research, competitive-platform-analysis, benchmark-methodology, competitive-report-structure, brand-discovery |
| python | Python, .py, pyproject.toml, uv, ruff, mypy, pytest, asyncio → python-patterns, python-testing, windows-installer |
| research | deep research, citations, Exa, OSINT, PubMed, patents, genomics, lit review → exa-search, osint-investigation, pubmed, uspto, gget, literature-review, scholar-evaluation |
| rust | Rust, .rs, Cargo.toml, borrow checker, Tokio → rust-testing |
| screenshot | capture screen, screencapture/scrot/maim → screenshot-feature-extractor |
| secure-coding | auth, secrets, injection, XSS, CSRF, JWT, IAM, pentest, GDPR/HIPAA → web-vulnerability-testing, data-privacy-compliance, cloud-infrastructure-security, security-bounty-hunter |
| seo | SEO audit, meta tags, schema markup, crawlability, GEO → generative-engine-optimization, schema-markup, programmatic-seo |
| software-architecture | Clean/Hexagonal, DDD, CQRS, ADR, monolith split, module governance → architecture-decision-records, hexagonal-architecture, intent-driven-development, module-governance, module-regression |
| supply-chain-operations | freight, customs/HS codes, energy, demand forecast, safety stock, NCR/CAPA, returns → carrier-relationship-management, customs-trade-compliance, energy-procurement, inventory-demand-planning, logistics-exception-management, production-scheduling, quality-nonconformance, returns-reverse-logistics |
| swift-ios | Swift, .swift, SwiftUI, Xcode, @Observable, actors, FoundationModels, Liquid Glass → swift-concurrency, swift-actor-persistence, swift-protocol-di-testing, foundation-models-on-device, liquid-glass-design |
| systematic-debugging | bugs, stack traces, crashes, memory leaks, flaky tests, CI failures, root cause |
| typescript | TS types, .ts/.tsx, tsconfig, TS errors, JS→TS → zod, javascript, typescript-patterns |
| unit-testing-patterns | unit tests, Jest, Vitest, pytest, TDD, mocks, E2E, Playwright, RTL → playwright, test-driven-development, react-testing, ai-regression-testing, test-collaboration, browser-qa |
| ux-research | personas, journeys, interviews, usability tests, heuristic evaluation |
| video-production | video edit, FFmpeg, Remotion, Manim, fal.ai, demo video → remotion, manim-video, fal-ai-media, ui-demo, videodb, blender-motion-state-inspection, visual-taste |
| web-quality-audit | site audit, Lighthouse, CWV, a11y/WCAG, security headers, benchmark, prod audit → web-performance, performance, web-accessibility, benchmark, latency-critical-systems, production-audit, canary-watch |
| web-scraping-apis | scrape, crawl, Firecrawl, Tavily, CF Browser Rendering, Xquik, Bright Data → bright-data, data-scraper-agent |
| web3-security | Solidity, DeFi/AMM audit, ERC-20 decimals, Keccak-256, agent wallet, x402 → defi-amm-security, evm-token-decimals, nodejs-keccak256, llm-trading-agent-security, agent-payment-x402, prediction-market-oracle-research, prediction-market-risk-review |

## Skill authoring (`<skill>/SKILL.md`)
Keep each skill small. Load detail only when the task needs it.
- **Progressive disclosure**: `SKILL.md` ≤ 100 lines (hard cap 120). Move code examples, long checklists, and catalogs to `references/<topic>.md`.
- **Load priority**:
  - P0 `SKILL.md` → `## Core rules` (≤ 15 imperative bullets, always apply) + `## Decisions`.
  - P1 `## Load on demand` table (`Need | Read`) → `references/*.md`, read only on a match.
  - P2 `## Related skills` → other skills, one hop, ≤ 10 words each.
- **Decision tables**: replace prose with `Situation | Do | Avoid` tables.
- **Compress**: imperative, one fact per line, no filler, no "When to use" / "How it works" sections (the frontmatter `description` covers them). Keep `description` ≤ 600 chars with trigger words and the `Sub-skills:` list.
- **No redundancy**: state a rule once. Do not repeat rules from this file or from sibling skills; link to them.

## Project conventions
- **Icon**: copy matching SVG from `/Users/ashvinijangid/Desktop/Icons` (e.g. `robot.svg` for AI) into `public/` or `assets/`; convert to PNG/ICO if needed.
- **PM2 (mandatory for all server / web-server apps)**: auto-create `ecosystem.config.cjs` at project root for every API, backend, SSR, or web-server project (`name`, `script`, `args`, `cwd`, `instances`, `exec_mode`, `autorestart: true`, `watch: false`, `max_memory_restart: "512M"`, `env`, `env_production` with `NODE_ENV: "production"` and `PORT`).
- **Makefile (mandatory at project root)** — exactly three `.PHONY` targets: `run`, `start`, `deploy`:
  - `run`: run the app locally in dev mode (`npm run dev`, `bun run dev`, `cargo run`, `uv run uvicorn ... --reload`).
  - `start`: build (if needed) and start the app in production. For any server/web-server app, launch/reload via PM2: `pm2 startOrReload ecosystem.config.cjs --env production && pm2 save`. For static sites (e.g. Nuxt `nuxt generate` → `docs/` + `.nojekyll`, GitHub Pages set manually; never add deploy workflows unless asked) or native binaries (`cargo build --release`), run the production build/start command directly.
  - `deploy`: run production build if needed → `git checkout main` → `git add -A` → generate a concise commit message from `git diff --cached` via the local OpenAI-compatible LLM at `http://127.0.0.1:9694/v1/chat/completions` → `git commit -m "$$MSG"` → `git push origin main`.
    ```makefile
    LLM_URL ?= http://127.0.0.1:9694/v1/chat/completions
    LLM_MODEL ?= local

    .PHONY: run start deploy

    deploy:
    	git checkout main
    	git add -A
    	@MSG=$$(git diff --cached | python3 -c 'import json,sys,urllib.request; diff=sys.stdin.read()[:12000]; req=urllib.request.Request("$(LLM_URL)", data=json.dumps({"model":"$(LLM_MODEL)","messages":[{"role":"system","content":"Generate one concise conventional commit message for the git diff. Output ONLY the commit message, no quotes, no markdown, no explanation."},{"role":"user","content":diff}],"temperature":0.2}).encode(), headers={"Content-Type":"application/json"}); print(json.loads(urllib.request.urlopen(req).read())["choices"][0]["message"]["content"].strip())'); \
    	git commit -m "$${MSG:-chore: update}"
    	git push origin main
    ```
- New branch/work: checkout `main` first; `deploy` always targets `main`.
- **Flutter theme**: `/Users/ashvinijangid/Desktop/android/theme` (its-ash/theme). On theme change: edit → build → push → bump dep in consumer.
- **Homebrew tap**: `/Users/ashvinijangid/Desktop/homebrew-tap` (its-ash/homebrew-tap). On tagged release, update formula and push.

## New project setup (mandatory)
1. Icon (from `/Users/ashvinijangid/Desktop/Icons`).
2. `.github/copilot-instructions.md` + `ln -s .github/copilot-instructions.md CLAUDE.md` + `ln -s .github/copilot-instructions.md GEMINI.md`.
3. `Makefile` (`run`, `start`, `deploy` with local LLM at `http://127.0.0.1:9694/v1`).
4. `ecosystem.config.cjs` (auto-created for any server / web-server app, wired into `make start`).
5. `.nvmrc` if Node.
6. `git init` + `.gitignore` + `git checkout -B main`.
