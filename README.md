# skills

Single source of truth for GitHub Copilot, Claude Code & Zed **skills** and **instructions**.

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

### web-quality-audit → performance

Analyzes web performance using Chrome DevTools MCP. Measures Core Web Vitals (LCP, INP, CLS) and supplementary metrics (FCP, TBT, Speed Index), identifies render-blocking resources, network dependency chains, layout shifts, caching issues, and accessibility gaps.

## Skill catalog

Sub-skills live in `<skill>/references/` and load only when the task needs them.

| Skill | Purpose | Sub-skills |
|-------|---------|------------|
| [`backend-development`](backend-development/SKILL.md) | Guides designing building and operating scalable backend services and APIs covering REST GraphQL gRPC contract design microservice decomposition event-driven messaging security resilience observability testing and cloud-native deployment with sub-topics for API design Node.js patterns multi-tenant SaaS and serverless architectures | [`api-design`](backend-development/references/api-design.md), [`django`](backend-development/references/django.md), [`fastapi`](backend-development/references/fastapi.md), [`firebase-backend`](backend-development/references/firebase-backend.md), [`nestjs`](backend-development/references/nestjs.md), [`nodejs-patterns`](backend-development/references/nodejs-patterns.md), [`php-laravel`](backend-development/references/php-laravel.md), [`saas-multi-tenant`](backend-development/references/saas-multi-tenant.md), [`serverless`](backend-development/references/serverless.md) |
| [`browser-extensions`](browser-extensions/SKILL.md) | Guides building, testing, and publishing cross-browser WebExtensions for Chrome, Edge, and Firefox using Manifest V3, covering project structure, manifest, content scripts, service worker backgrounds, popup and options UI, permissions, storage, and cross-context messaging | — |
| [`clean-code`](clean-code/SKILL.md) | Enforces pragmatic clean code standards for AI-assisted development covering naming, function design, structure, and anti-patterns via a mandatory deslop workflow that audits git diffs against main to strip AI-generated slop: excessive comments, defensive checks, type casts, inline imports, style inconsistencies | — |
| [`code-review`](code-review/SKILL.md) | Reviews code changes for correctness, security, performance, maintainability, test coverage, and production readiness across pull requests, branch audits, and codebase inspections | [`code-review-feedback`](code-review/references/code-review-feedback.md) |
| [`content-writing`](content-writing/SKILL.md) | Guides brand-voice creation, SEO blog drafting, social-media post production, content-calendar planning, and collaborative research-writing | [`copywriting`](content-writing/references/copywriting.md), [`social-content`](content-writing/references/social-content.md) |
| [`conversion-optimization`](conversion-optimization/SKILL.md) | Conversion optimization skill audits and improves conversion rates for marketing pages, landing pages, pricing pages, forms, popups, signup flows, onboarding experiences, and in-app paywalls with CRO recommendations, A/B test ideas, and step-by-step audits | [`ab-testing`](conversion-optimization/references/ab-testing.md) |
| [`database-design`](database-design/SKILL.md) | Designs data layers by selecting database technologies, modeling schemas, and planning migrations for scalable architectures | [`database-migration`](database-design/references/database-migration.md), [`database-optimization`](database-design/references/database-optimization.md), [`drizzle-orm`](database-design/references/drizzle-orm.md), [`postgresql`](database-design/references/postgresql.md), [`prisma`](database-design/references/prisma.md) |
| [`design`](design/SKILL.md) | Unified frontend design skill from brief to production: content discipline, accessibility, typography, layout composition, motion and spring physics, gestures, component craft, design systems (tokens, theming, dark mode), and modern CSS (Grid, subgrid, container queries, cascade layers, :has(), oklch, scroll-driven animations, view transitions, dialog, anchor positioning) | [`brand-theming`](design/references/brand-theming.md), [`figma`](design/references/figma.md), [`immersive-web`](design/references/immersive-web.md), [`mobile-design`](design/references/mobile-design.md), [`motion-canvas`](design/references/motion-canvas.md), [`shadcn-ui`](design/references/shadcn-ui.md), [`tailwind-css`](design/references/tailwind-css.md), [`visual-design-direction`](design/references/visual-design-direction.md) |
| [`devops-iac`](devops-iac/SKILL.md) | This skill guides infrastructure as code workflows covering Terraform provisioning, Kubernetes cluster operations, GitHub Actions CI/CD pipelines, GitOps with ArgoCD and Flux, service mesh configuration, observability stacks, security hardening, cost optimization, and disaster recovery planning | [`cloud-architecture`](devops-iac/references/cloud-architecture.md), [`cloudflare-deploy`](devops-iac/references/cloudflare-deploy.md), [`docker`](devops-iac/references/docker.md), [`github-actions`](devops-iac/references/github-actions.md), [`kubernetes`](devops-iac/references/kubernetes.md), [`observability`](devops-iac/references/observability.md) |
| [`flutter`](flutter/SKILL.md) | Provides expert guidance for building multi-platform Flutter apps with Dart 3, covering architecture, state management, UI, platform integration, performance, testing, security, and deployment | — |
| [`frontend-development`](frontend-development/SKILL.md) | Build modern React and Next.js applications with TypeScript, MUI v7 components, TanStack Query and Router, and performance-focused patterns for components, routing, styling, data fetching, and bundle optimization | [`astro`](frontend-development/references/astro.md), [`d3-visualization`](frontend-development/references/d3-visualization.md), [`mui`](frontend-development/references/mui.md), [`nextjs`](frontend-development/references/nextjs.md), [`progressive-web-app`](frontend-development/references/progressive-web-app.md), [`react-patterns`](frontend-development/references/react-patterns.md), [`react-performance`](frontend-development/references/react-performance.md) |
| [`fullstack-development`](fullstack-development/SKILL.md) | Fullstack Development skill guides planning, scaffolding, coding, testing, and deploying modern web applications with React, Next.js, Node.js, GraphQL, REST, and PostgreSQL | — |
| [`golang`](golang/SKILL.md) | Provides expert guidance for Go 1.21+ development, covering concurrency patterns, performance tuning, microservice architecture, testing, DevOps, and security best practices | — |
| [`i18n-localization`](i18n-localization/SKILL.md) | Adds internationalization and localization to web and Python apps, including string extraction, translation catalogs, pluralization, locale-aware date and number formatting, and RTL layout support | — |
| [`node`](node/SKILL.md) | Defines Node.js project conventions covering version pinning with .nvmrc, package.json scripts, Makefile targets, dependency management, TypeScript configuration, error handling patterns, and environment file structure | — |
| [`python`](python/SKILL.md) | Guidance for modern Python 3.12+ development covering project layout, async versus sync decisions, framework selection, uv/ruff/mypy tooling, testing, profiling, and deployment | — |
| [`screenshot`](screenshot/SKILL.md) | Capture desktop screenshots on macOS, Linux, and Windows via native utilities — screencapture, gnome-screenshot, scrot, maim, spectacle, and PowerShell — supporting full-screen, window, region, and app modes with configurable output paths and formats | [`screenshot-feature-extractor`](screenshot/references/screenshot-feature-extractor.md) |
| [`secure-coding`](secure-coding/SKILL.md) | Secure coding guidance and review checklists for secrets, authentication, authorization, input validation, SQL injection, XSS, CSRF, API security, rate limiting, and deployment hardening | [`data-privacy-compliance`](secure-coding/references/data-privacy-compliance.md), [`web-vulnerability-testing`](secure-coding/references/web-vulnerability-testing.md) |
| [`seo`](seo/SKILL.md) | SEO audits and optimizes websites for search visibility across technical SEO, on-page elements, content quality, keyword strategy, schema markup, Core Web Vitals, mobile SEO, and local SEO, with checklists and tool guidance | [`generative-engine-optimization`](seo/references/generative-engine-optimization.md), [`programmatic-seo`](seo/references/programmatic-seo.md), [`schema-markup`](seo/references/schema-markup.md) |
| [`software-architecture`](software-architecture/SKILL.md) | Provides a unified workflow for making software architecture decisions, selecting patterns such as Clean Architecture, Hexagonal, DDD, CQRS, and event sourcing, documenting trade-offs, applying code-style and quality rules, and validating designs | — |
| [`systematic-debugging`](systematic-debugging/SKILL.md) | Systematic-debugging provides a structured four-phase methodology for isolating root causes of software defects, test failures, crashes, and unexpected runtime behavior across any language or stack | — |
| [`typescript`](typescript/SKILL.md) | Guides TypeScript compiler options, advanced type patterns, migration, monorepo setup, linting, testing, and debugging | [`javascript`](typescript/references/javascript.md), [`zod`](typescript/references/zod.md) |
| [`unit-testing-patterns`](unit-testing-patterns/SKILL.md) | Covers unit-testing patterns for JavaScript and TypeScript with Jest and for Python with pytest including test-driven development workflows, factory functions for test data, mocking strategies, parametrized tests, async testing, and test structure conventions | [`playwright`](unit-testing-patterns/references/playwright.md), [`test-driven-development`](unit-testing-patterns/references/test-driven-development.md) |
| [`ux-research`](ux-research/SKILL.md) | Generates data-driven personas, customer journey maps, usability test plans, findings synthesis, and design validation workflows for UX research | — |
| [`web-quality-audit`](web-quality-audit/SKILL.md) | Performs a full web quality audit measuring Core Web Vitals LCP FID CLS TTFB resource loading, accessibility WCAG ARIA screen reader compliance, SEO meta tags structured data sitemaps robots.txt, security headers CSP HSTS X-Frame-Options, HTML validation standards, and code quality best practices | [`performance`](web-quality-audit/references/performance.md), [`web-accessibility`](web-quality-audit/references/web-accessibility.md), [`web-performance`](web-quality-audit/references/web-performance.md) |
| [`web-scraping-apis`](web-scraping-apis/SKILL.md) | Unified guide for using Firecrawl, Tavily, Cloudflare Browser Rendering, and Xquik to scrape pages, search the web, crawl sites into markdown, render JavaScript, and fetch X/Twitter posts | [`bright-data`](web-scraping-apis/references/bright-data.md) |

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

Edit a skill here → it's live in Copilot, Claude and Zed instantly.

| Repo file / dir                | Symlinked to                          |
|--------------------------------|---------------------------------------|
| `copilot.instructions.md`      | `~/.copilot/instructions/copilot.instructions.md` |
| ↑ (same file)                  | `~/.claude/CLAUDE.md`                 |
| `<skill>/`                     | `~/.copilot/skills/<skill>/`          |
| `~/.copilot/skills/` (whole dir)| `~/.claude/skills`                   |
| `agents/`                      | `~/.copilot/agents`                   |
| `~/.copilot/agents` (whole dir)| `~/.claude/agents`                    |
| ↑ (same file)                  | `~/.config/zed/AGENTS.md` (Zed)       |
| `<skill>/`                     | `~/.agents/skills/<skill>/` (Zed)     |

Edit a skill here → it's live in Copilot, Claude and Zed instantly.

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