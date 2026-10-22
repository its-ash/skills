# skills

Single source of truth for GitHub Copilot & Claude Code **skills** and **instructions**.

A live index of all skills is served via GitHub Pages: **[its-ash.github.io/skills](https://its-ash.github.io/skills)**

## Layout

```
skills/
├── copilot.instructions.md      # global instructions (source of truth)
├── setup.sh                      # install / unlink / status
├── Makefile                      # run / build / deploy
├── docs/                         # GitHub Pages site (index.html, favicon, fonts)
├── design/SKILL.md               # unified frontend design skill (auto-invoked)
├── design/references/css/        # CSS reference files loaded on demand by design (Section 25)
├── node/SKILL.md                 # Node.js project conventions
├── performance/SKILL.md          # web performance audit (Core Web Vitals)
├── …other skills…/SKILL.md
├── agents/<agent>.md             # Claude Code / Copilot subagents
```

## Skills

### design (auto-invoked)

The unified skill for any website design, redesign, landing page, dashboard, product UI, app shell, component build, animation, or frontend UI work. Merges design-foundation rules (accessibility, motion, typography, content discipline), layout composition (hero discipline, section rhythm, grid mechanics, responsive collapse), and engineering depth (animation framework, spring physics, gesture interactions, component craftsmanship, Apple fluid interfaces, performance, redesign protocol, UI library selection, prototyping).

Covers: brief inference (Section 0), three-dial system (Section 1), design-system selection (Section 2), default architecture (Section 3), bias correction directives (Section 4), animation decision framework (Section 5), motion mechanics (Section 6), component building (Section 7), performance guardrails (Section 8), accessibility (Section 9), anti-slop content discipline (Section 10), dial definitions (Section 11), context-aware proactivity (Section 12), UI library selection (Section 13), redesign protocol (Section 14), progressive enhancement (Section 15), debugging (Section 16), component principles (Section 17), Apple design foundations (Section 18), reference vocabulary (Section 19), scope (Section 20), final pre-flight check (Section 21), review checklist (Section 22), prototyping (Section 23), default site packs (Section 24), CSS implementation (Section 25).

Section 25 holds the CSS core rules, a technique decision guide, and a CSS pre-flight checklist. Detail lives in `design/references/css/`: layout, responsive, selectors and cascade, custom properties and math, color, visual effects, typography, animation, native UI components, SVG, accessibility, performance, architecture and tooling, frontend JS, and browser support.

### node (auto-invoked)

Node.js project conventions and setup rules. `.nvmrc`, `package.json` scripts, Makefile targets, build/deploy, TypeScript, env files, and project scaffolding for Nuxt, Next.js, Express, Vite, CLI tools, and more.

### performance

Analyzes web performance using Chrome DevTools MCP. Measures Core Web Vitals (LCP, INP, CLS) and supplementary metrics (FCP, TBT, Speed Index), identifies render-blocking resources, network dependency chains, layout shifts, caching issues, and accessibility gaps.

## Skill catalog

Sub-skills live in `<skill>/references/` and load only when the task needs them.

| Skill | Purpose | Sub-skills |
|-------|---------|------------|
| [`ab-testing`](ab-testing/SKILL.md) | Plans, designs, runs, and analyzes A/B split tests and multivariate experiments, including hypothesis framing, sample-size calculation, variant design, traffic allocation, and result interpretation | — |
| [`astro`](astro/SKILL.md) | Astro builds content-heavy websites with zero JavaScript by default, selective hydration via islands, file-based routing, content collections, layouts, and optional SSR or SSG | — |
| [`backend-development`](backend-development/SKILL.md) | Guides designing building and operating scalable backend services and APIs covering REST GraphQL gRPC contract design microservice decomposition event-driven messaging security resilience observability testing and cloud-native deployment with sub-topics for API design Node.js patterns multi-tenant SaaS and serverless architectures | [`api-design`](backend-development/references/api-design.md), [`nodejs-patterns`](backend-development/references/nodejs-patterns.md), [`saas-multi-tenant`](backend-development/references/saas-multi-tenant.md), [`serverless`](backend-development/references/serverless.md) |
| [`brand-theming`](brand-theming/SKILL.md) | Applies Anthropic brand colors, typography, and visual identity rules to slides, documents, presentations, reports, spreadsheets, and other visual artifacts | — |
| [`bright-data`](bright-data/SKILL.md) | Bright Data skill guides using Bright Data services including local unfancy-search server, SERP API, Web Unlocker, Web Scraper API, Browser API, and Bright Data MCP to perform web searches, fetch pages as markdown, extract structured data, and run browser automation | — |
| [`browser-extensions`](browser-extensions/SKILL.md) | Guides building, testing, and publishing cross-browser WebExtensions for Chrome, Edge, and Firefox using Manifest V3, covering project structure, manifest, content scripts, service worker backgrounds, popup and options UI, permissions, storage, and cross-context messaging | — |
| [`clean-code`](clean-code/SKILL.md) | Enforces pragmatic clean code standards for AI-assisted development covering naming, function design, structure, and anti-patterns via a mandatory deslop workflow that audits git diffs against main to strip AI-generated slop: excessive comments, defensive checks, type casts, inline imports, style inconsistencies | — |
| [`cloud-architecture`](cloud-architecture/SKILL.md) | Designs and optimizes cloud architectures across AWS, Azure, and GCP with secure, cost-effective, resilient patterns, IaC, FinOps, and DevOps integration | — |
| [`cloudflare-deploy`](cloudflare-deploy/SKILL.md) | Deploy applications and infrastructure to Cloudflare using Workers, Pages, D1, KV, R2, Vectorize, and AI Gateway via wrangler CLI or Terraform | — |
| [`code-review`](code-review/SKILL.md) | Reviews code changes for correctness, security, performance, maintainability, test coverage, and production readiness across pull requests, branch audits, and codebase inspections | [`code-review-feedback`](code-review/references/code-review-feedback.md) |
| [`content-writing`](content-writing/SKILL.md) | Guides brand-voice creation, SEO blog drafting, social-media post production, content-calendar planning, and collaborative research-writing | [`social-content`](content-writing/references/social-content.md) |
| [`conversion-optimization`](conversion-optimization/SKILL.md) | Conversion optimization skill audits and improves conversion rates for marketing pages, landing pages, pricing pages, forms, popups, signup flows, onboarding experiences, and in-app paywalls with CRO recommendations, A/B test ideas, and step-by-step audits | — |
| [`copywriting`](copywriting/SKILL.md) | Creates clear, compelling marketing copy for webpages including home, landing, pricing, feature, about, and product pages, with headline formulas, CTA guidance, page structure, and editing checklists | — |
| [`d3-visualization`](d3-visualization/SKILL.md) | Build interactive D3.js data visualizations with SVG, Canvas, scales, axes, transitions, tooltips, zoom, brush, force layouts, maps, and custom charts | — |
| [`data-privacy-compliance`](data-privacy-compliance/SKILL.md) | Implement and audit privacy compliance for GDPR, DSGVO, CCPA, CPRA, and HIPAA covering lawful basis, consent, data subject rights, DPIA, privacy by design, minimization, breach response, international transfers, and audits | — |
| [`database-design`](database-design/SKILL.md) | Designs data layers by selecting database technologies, modeling schemas, and planning migrations for scalable architectures | [`postgresql`](database-design/references/postgresql.md) |
| [`database-migration`](database-migration/SKILL.md) | Guides database schema and data migrations across Sequelize, TypeORM, and Prisma with safe column additions, renames, type changes, data backfills, and zero-downtime patterns like expand-contract and dual-write | — |
| [`database-optimization`](database-optimization/SKILL.md) | Expert database optimization for SQL and NoSQL systems | — |
| [`design`](design/SKILL.md) | Unified frontend design skill covering the full lifecycle from brief inference to production, combining content discipline, accessibility, motion mechanics, typography, performance, layout composition, animation frameworks, spring physics, gesture interactions, component craftsmanship, fluid interface principles, progressive enhancement, design-system selection and building (design tokens, atomic component architecture, theming, dark mode), and modern CSS implementation with Grid, subgrid, container queries, cascade layers, :has(), custom properties, oklch, scroll-driven animations, view transitions, native dialog and anchor positioning | [`shadcn-ui`](design/references/shadcn-ui.md), [`tailwind-css`](design/references/tailwind-css.md), [`visual-design-direction`](design/references/visual-design-direction.md) |
| [`devops-iac`](devops-iac/SKILL.md) | This skill guides infrastructure as code workflows covering Terraform provisioning, Kubernetes cluster operations, GitHub Actions CI/CD pipelines, GitOps with ArgoCD and Flux, service mesh configuration, observability stacks, security hardening, cost optimization, and disaster recovery planning | [`github-actions`](devops-iac/references/github-actions.md), [`kubernetes`](devops-iac/references/kubernetes.md) |
| [`django`](django/SKILL.md) | Django 5.x guidance for async views, DRF APIs, Celery tasks, Channels WebSockets, ORM optimization, migrations, auth, testing, security, and deployment | — |
| [`docker`](docker/SKILL.md) | Optimizes Dockerfiles with multi-stage builds, BuildKit cache mounts, build-time secrets, and distroless images; hardens container security through non-root users, read-only filesystems, and capability dropping; configures production Docker Compose with healthchecks, resource limits, and override patterns; enables cross-platform builds via buildx | — |
| [`drizzle-orm`](drizzle-orm/SKILL.md) | Use Drizzle ORM in TypeScript projects to define schemas, infer types, run relational queries, manage migrations, and connect serverless databases | — |
| [`fastapi`](fastapi/SKILL.md) | Build async FastAPI endpoints with Pydantic v2 schemas, SQLAlchemy 2.0 models, dependency-injected auth, cursor pagination, caching, and pytest-asyncio tests | — |
| [`figma`](figma/SKILL.md) | Fetches design context, screenshots, and assets from a Figma MCP server and translates a Figma node URL or node ID into production-ready React, Next.js, or TypeScript components that follow project design-system conventions and achieve 1:1 visual parity | — |
| [`firebase-backend`](firebase-backend/SKILL.md) | Builds and secures Firebase backends using Firestore data modeling, security rules, Cloud Functions, Cloud Storage, Hosting, and cost controls | — |
| [`flutter`](flutter/SKILL.md) | Provides expert guidance for building multi-platform Flutter apps with Dart 3, covering architecture, state management, UI, platform integration, performance, testing, security, and deployment | — |
| [`frontend-development`](frontend-development/SKILL.md) | Build modern React and Next.js applications with TypeScript, MUI v7 components, TanStack Query and Router, and performance-focused patterns for components, routing, styling, data fetching, and bundle optimization | [`mui`](frontend-development/references/mui.md), [`react-patterns`](frontend-development/references/react-patterns.md), [`react-performance`](frontend-development/references/react-performance.md) |
| [`fullstack-development`](fullstack-development/SKILL.md) | Fullstack Development skill guides planning, scaffolding, coding, testing, and deploying modern web applications with React, Next.js, Node.js, GraphQL, REST, and PostgreSQL | — |
| [`golang`](golang/SKILL.md) | Provides expert guidance for Go 1.21+ development, covering concurrency patterns, performance tuning, microservice architecture, testing, DevOps, and security best practices | — |
| [`i18n-localization`](i18n-localization/SKILL.md) | Adds internationalization and localization to web and Python apps, including string extraction, translation catalogs, pluralization, locale-aware date and number formatting, and RTL layout support | — |
| [`immersive-web`](immersive-web/SKILL.md) | The immersive-web skill guides creation of scroll-driven, parallax, and 3D web experiences for storytelling sites, product showcases, and interactive portfolios, covering library selection, animation patterns, performance, and accessibility | — |
| [`javascript`](javascript/SKILL.md) | Reference for JavaScript primitives, type coercion, equality, scope types, var let const hoisting, closures, call stack, this binding, event loop phases, promise async await, prototype inheritance, and ES6+ features like arrow functions destructuring modules | — |
| [`mobile-design`](mobile-design/SKILL.md) | Mobile-first design guidelines for iOS, Android, and cross-platform apps covering touch targets, performance budgets, platform conventions, and anti-patterns across React Native, Flutter, and native development | — |
| [`motion-canvas`](motion-canvas/SKILL.md) | Configure Motion Canvas projects with Vite, write TypeScript animation scenes using generator functions, signals, and refs, resolve ESM and CommonJS plugin import errors, and export rendered video or image sequences for motion graphics and generative art | — |
| [`nestjs`](nestjs/SKILL.md) | Guides NestJS development covering modules, dependency injection, controllers, guards, interceptors, pipes, Jest/Supertest testing, TypeORM/Mongoose, Passport JWT auth, config, error handling, and performance | — |
| [`nextjs`](nextjs/SKILL.md) | This skill guides Next.js 14+ App Router development: component type choices, data fetching with fetch and cache, file-system routing with layouts and pages, route handlers for APIs, image and font optimization, metadata API, caching with revalidatePath and unstable_cache, server actions for mutations, and Supabase auth integration | — |
| [`node`](node/SKILL.md) | Defines Node.js project conventions covering version pinning with .nvmrc, package.json scripts, Makefile targets, dependency management, TypeScript configuration, error handling patterns, and environment file structure | — |
| [`observability`](observability/SKILL.md) | This skill teaches production-grade observability: instrumenting metrics, logs, and traces; querying and visualizing with Datadog CLI and Grafana; defining SLOs and alerting rules | — |
| [`performance`](performance/SKILL.md) | Analyzes web page performance with Chrome DevTools MCP, measuring Core Web Vitals (LCP, INP, CLS), FCP, TBT, Speed Index, render-blocking resources, network chains, layout shifts, caching, and accessibility gaps, preferring current documentation over pre-trained knowledge | — |
| [`php-laravel`](php-laravel/SKILL.md) | Provides idiomatic PHP 8.1+ and Laravel 10/11 patterns for services, jobs, controllers, policies, Eloquent models, and Octane-ready code | — |
| [`playwright`](playwright/SKILL.md) | Playwright automates Chromium, Firefox, and WebKit for end-to-end testing and browser scripting with TypeScript or JavaScript | — |
| [`prisma`](prisma/SKILL.md) | Provides expert guidance for Prisma ORM tasks such as schema design, migrations, query optimization, relation modeling, connection management, and transactions | — |
| [`programmatic-seo`](programmatic-seo/SKILL.md) | Creates thousands of SEO-optimized landing pages from structured data and reusable templates to capture long-tail keyword patterns at scale | [`competitor-pages`](programmatic-seo/references/competitor-pages.md) |
| [`progressive-web-app`](progressive-web-app/SKILL.md) | Builds Progressive Web Apps with a manifest.json for installability, a service worker sw.js implementing cache-first and stale-while-revalidate strategies, beforeinstallprompt handling for native install banners, HTTPS enforcement, and offline fallback pages | — |
| [`python`](python/SKILL.md) | Guidance for modern Python 3.12+ development covering project layout, async versus sync decisions, framework selection, uv/ruff/mypy tooling, testing, profiling, and deployment | — |
| [`screenshot`](screenshot/SKILL.md) | Capture desktop screenshots on macOS, Linux, and Windows via native utilities — screencapture, gnome-screenshot, scrot, maim, spectacle, and PowerShell — supporting full-screen, window, region, and app modes with configurable output paths and formats | — |
| [`screenshot-feature-extractor`](screenshot-feature-extractor/SKILL.md) | Extract product features, user interactions, and business functions from UI screenshots, design mockups, competitor app screens, or wireframes and convert them into a structured development task checklist with acceptance criteria | — |
| [`secure-coding`](secure-coding/SKILL.md) | Secure coding guidance and review checklists for secrets, authentication, authorization, input validation, SQL injection, XSS, CSRF, API security, rate limiting, and deployment hardening | — |
| [`seo`](seo/SKILL.md) | SEO audits and optimizes websites for search visibility across technical SEO, on-page elements, content quality, keyword strategy, schema markup, Core Web Vitals, mobile SEO, and local SEO, with checklists and tool guidance | [`generative-engine-optimization`](seo/references/generative-engine-optimization.md), [`schema-markup`](seo/references/schema-markup.md) |
| [`shopify`](shopify/SKILL.md) | Provides Shopify app extension theme patterns with CLI commands GraphQL queries for products orders metafields webhook config in shopify.app.toml Polaris UI and Liquid templates | — |
| [`software-architecture`](software-architecture/SKILL.md) | Provides a unified workflow for making software architecture decisions, selecting patterns such as Clean Architecture, Hexagonal, DDD, CQRS, and event sourcing, documenting trade-offs, applying code-style and quality rules, and validating designs | — |
| [`stripe`](stripe/SKILL.md) | Implements Stripe payments, subscriptions, billing portal, checkout sessions, and webhooks with idempotency keys, signature verification, and dunning handling for reliable payment processing | — |
| [`systematic-debugging`](systematic-debugging/SKILL.md) | Systematic-debugging provides a structured four-phase methodology for isolating root causes of software defects, test failures, crashes, and unexpected runtime behavior across any language or stack | — |
| [`twilio`](twilio/SKILL.md) | Implements Twilio communication features: sending SMS messages, phone and email verification with Verify, and IVR call flows with TwiML | — |
| [`typescript`](typescript/SKILL.md) | Guides TypeScript compiler options, advanced type patterns, migration, monorepo setup, linting, testing, and debugging | — |
| [`unit-testing-patterns`](unit-testing-patterns/SKILL.md) | Covers unit-testing patterns for JavaScript and TypeScript with Jest and for Python with pytest including test-driven development workflows, factory functions for test data, mocking strategies, parametrized tests, async testing, and test structure conventions | [`test-driven-development`](unit-testing-patterns/references/test-driven-development.md) |
| [`ux-research`](ux-research/SKILL.md) | Generates data-driven personas, customer journey maps, usability test plans, findings synthesis, and design validation workflows for UX research | — |
| [`vercel`](vercel/SKILL.md) | Deploy, host, and optimize applications on Vercel | — |
| [`web-accessibility`](web-accessibility/SKILL.md) | Provides guidance for auditing and fixing web accessibility to meet WCAG 2.1 POUR principles and ARIA standards covering alt text, color contrast, keyboard navigation, landmarks, forms, modals, and media | — |
| [`web-performance`](web-performance/SKILL.md) | Measures, diagnoses, and improves website speed and runtime efficiency, covering Core Web Vitals (LCP, INP, FID, CLS), bundle size, caching, critical rendering path, resource loading, image and font optimization, and JavaScript performance | — |
| [`web-quality-audit`](web-quality-audit/SKILL.md) | Performs a full web quality audit measuring Core Web Vitals LCP FID CLS TTFB resource loading, accessibility WCAG ARIA screen reader compliance, SEO meta tags structured data sitemaps robots.txt, security headers CSP HSTS X-Frame-Options, HTML validation standards, and code quality best practices | — |
| [`web-scraping-apis`](web-scraping-apis/SKILL.md) | Unified guide for using Firecrawl, Tavily, Cloudflare Browser Rendering, and Xquik to scrape pages, search the web, crawl sites into markdown, render JavaScript, and fetch X/Twitter posts | — |
| [`web-vulnerability-testing`](web-vulnerability-testing/SKILL.md) | Test web applications and APIs for OWASP vulnerabilities including SQL injection, XSS, CSRF, SSRF, IDOR, authentication bypass, path traversal, insecure headers, and misconfiguration | [`api-security-testing`](web-vulnerability-testing/references/api-security-testing.md), [`broken-authentication-testing`](web-vulnerability-testing/references/broken-authentication-testing.md), [`burp-suite`](web-vulnerability-testing/references/burp-suite.md), [`path-traversal-testing`](web-vulnerability-testing/references/path-traversal-testing.md), [`sql-injection-testing`](web-vulnerability-testing/references/sql-injection-testing.md), [`xss-html-injection-testing`](web-vulnerability-testing/references/xss-html-injection-testing.md) |
| [`zod`](zod/SKILL.md) | Defines, parses, and validates TypeScript schemas with Zod, including primitives, objects, coercion, refinements, transforms, custom errors, and integrations for forms, Next.js actions, and environment variables | — |

## Agents

Subagents in `agents/`. Each file has `name`, `description`, and optional `tools` frontmatter.

| Agent | Purpose |
|-------|---------|
| [`ai-engineer`](agents/ai-engineer.md) | Senior AI engineer for end-to-end classical ML and generative-AI/LLM systems: architecture, model selection, training, RAG/agents, optimization, deployment, evaluation, and governance. |
| [`backend-architect`](agents/backend-architect.md) | Backend system architecture and API design specialist. |
| [`business-analyst`](agents/business-analyst.md) | Analyzes business processes, elicits and documents requirements, maps stakeholders, and recommends data-driven improvements. |
| [`cli-developer`](agents/cli-developer.md) | CLI developer for command design, argument parsing, automation, validation, and testing. |
| [`cloud-architect`](agents/cloud-architect.md) | Designs, evaluates, and optimizes cloud and hybrid network architectures across AWS, Azure, and GCP. |
| [`code-reviewer`](agents/code-reviewer.md) | Code review for changed code: checks correctness, security, performance, maintainability, and architecture. |
| [`content-marketer`](agents/content-marketer.md) | Content marketing strategy, SEO-optimized content, campaigns, audience analysis, and ROI measurement across channels. |
| [`data-engineer`](agents/data-engineer.md) | Designs, builds, and optimizes data pipelines, ETL/ELT processes, and data infrastructure across Kafka, BigQuery, Databricks, Snowflake, and Iceberg lakehouses. |
| [`data-scientist`](agents/data-scientist.md) | Data science: analyze data, build and validate predictive models, and translate findings into business recommendations. |
| [`database-architect`](agents/database-architect.md) | Database architecture and design specialist for data modeling, schema design, technology selection, scalability planning, and multi-tenant isolation. |
| [`database-optimizer`](agents/database-optimizer.md) | Database performance optimization specialist for query tuning, index design, execution plan analysis, and system configuration across PostgreSQL, MySQL, SQL Server, Oracle, MongoDB, Redis, Cassandra, ClickHouse, and Elasticsearch. |
| [`dead-code-cleaner`](agents/dead-code-cleaner.md) | Detects and removes unused imports, functions, classes, and exports across multiple languages with safety checks, backups, and test validation. |
| [`debugger`](agents/debugger.md) | Diagnose and fix software bugs, analyze logs, traces, and errors, and troubleshoot production incidents. |
| [`devops-engineer`](agents/devops-engineer.md) | Designs and operates CI/CD pipelines, infrastructure as code, Kubernetes deployments, and observability for reliable releases. |
| [`fact-checker`](agents/fact-checker.md) | Verifies claims, sources, citations, and statistics; detects misinformation and assesses credibility. |
| [`frontend-developer`](agents/frontend-developer.md) | Build and maintain modern frontend applications across React, Vue, Angular, and Next.js, including architecture, state, testing, accessibility, performance, and migration. |
| [`fullstack-developer`](agents/fullstack-developer.md) | Builds complete features across database, API, and frontend layers in a TypeScript-first stack. |
| [`game-designer`](agents/game-designer.md) | Game design specialist for mechanics, progression, economy balancing, difficulty curves, level flow, and player psychology. |
| [`git-workflow-manager`](agents/git-workflow-manager.md) | Git Flow workflow manager for branch creation, validation, merging, releases, pull requests, changelogs, and conflict resolution. |
| [`golang-pro`](agents/golang-pro.md) | Builds and optimizes Go 1.21+ services, CLIs, and cloud-native systems with idiomatic concurrency, robust error handling, testing, and performance profiling. |
| [`mcp-expert`](agents/mcp-expert.md) | Model Context Protocol specialist for server architecture, transport layers, tool and resource design, JSON configurations, authentication, security, and performance. |
| [`ml-engineer`](agents/ml-engineer.md) | Builds end-to-end production ML systems: data validation, feature pipelines, distributed training, model validation, initial deployment, monitoring, and automated retraining. |
| [`mobile-developer`](agents/mobile-developer.md) | Builds and optimizes cross-platform and native iOS mobile apps with offline-first architecture, native module integration, platform-specific UI, and store-ready deployment. |
| [`performance-engineer`](agents/performance-engineer.md) | Performance engineer for profiling, bottleneck analysis, load testing, caching, database and frontend optimization across stacks. |
| [`php-pro`](agents/php-pro.md) | Senior PHP 8.3+ developer for strict typing, PSR compliance, Laravel/Symfony architecture, async patterns, performance, security, and quality assurance. |
| [`product-strategist`](agents/product-strategist.md) | Product strategy: turn market and competitive inputs into positioning, RICE-prioritized roadmaps, and go-to-market plans. |
| [`python-pro`](agents/python-pro.md) | Python development for type-safe, production-ready code: APIs, async systems, data pipelines, tests, and modernization. |
| [`report-generator`](agents/report-generator.md) | Transforms synthesized research findings into a comprehensive, cited, well-structured final report. |
| [`research-orchestrator`](agents/research-orchestrator.md) | Coordinates end-to-end research projects across clarification, planning, execution, synthesis, and reporting. |
| [`researcher`](agents/researcher.md) | Researches web, technical, and academic sources; verifies claims, analyzes repositories and papers, and delivers structured findings with citations and gaps. |
| [`security-auditor`](agents/security-auditor.md) | Security auditor for compliance, control, vulnerability, and risk assessments across systems, cloud, applications, APIs, and third parties. |
| [`security-engineer`](agents/security-engineer.md) | Security infrastructure and compliance specialist. |
| [`seo-specialist`](agents/seo-specialist.md) | Technical SEO auditor and strategist: audits crawlability, Core Web Vitals, structured data, keywords, AI search visibility, and competitors; delivers prioritized, sourced recommendations and roadmaps. |
| [`task-orchestrator`](agents/task-orchestrator.md) | Task orchestration agent for complex multi-step goals: gathers requirements, builds a work breakdown with dependencies, parallel tracks, effort, risks, validation gates, context packages, and specialist handoffs. |
| [`technical-writer`](agents/technical-writer.md) | Create, improve, and maintain technical documentation for software projects, including API references, user guides, tutorials, SDK docs, and release notes. |
| [`test-engineer`](agents/test-engineer.md) | Designs and automates unit, integration, end-to-end, visual, and performance tests with quality gates and CI/CD pipelines. |
| [`typescript-pro`](agents/typescript-pro.md) | TypeScript and modern JavaScript specialist for advanced type systems, strict full-stack type safety, migrations, and performance-tuned builds. |
| [`ui-ux-designer`](agents/ui-ux-designer.md) | Reviews and designs web interfaces using research-backed usability, accessibility, and distinctive visual direction; includes terminal/CLI-inspired interfaces. |

## How it works

`setup.sh` symlinks everything into the right global directories:

| Repo file / dir                | Symlinked to                          |
|--------------------------------|---------------------------------------|
| `copilot.instructions.md`      | `~/.copilot/instructions/copilot.instructions.md` |
| ↑ (same file)                  | `~/.claude/CLAUDE.md`                 |
| `<skill>/`                     | `~/.copilot/skills/<skill>/`          |
| `~/.copilot/skills/` (whole dir)| `~/.claude/skills`                   |
| `agents/`                      | `~/.copilot/agents`                   |
| `~/.copilot/agents` (whole dir)| `~/.claude/agents`                    |

Edit a skill here → it's live in both Copilot and Claude instantly.

## Setup

```bash
git clone https://github.com/its-ash/skills.git ~/skills
cd ~/skills
./setup.sh            # install / update symlinks
./setup.sh --status   # show current link state
./setup.sh --unlink   # remove symlinks (backups kept on first install)
```

## Deploy

The `docs/` folder is served via GitHub Pages (configured in repo settings). The Makefile handles the full cycle:

```bash
make run      # show setup status
make build    # run setup.sh + touch docs/.nojekyll
make deploy   # build → commit → push to main
```

## Adding a new skill

1. `mkdir <skill-name> && touch <skill-name>/SKILL.md`
2. Write the skill content.
3. Add the skill to `docs/index.html` (the `skills` array in the `<script>` block).
4. Re-run `./setup.sh`.