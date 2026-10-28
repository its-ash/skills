# Skill router

Match task nouns/verbs to **Triggers**, load each matching `<skill>/SKILL.md` (several is normal), follow its **Related skills** one hop, and load `<skill>/references/<sub>.md` only when that sub-skill applies.

| Skill | Triggers (→ sub-skills) |
|---|---|
| [`backend-development`](backend-development/SKILL.md) | API, REST, GraphQL, gRPC, OpenAPI, microservices, Kafka/RabbitMQ, JWT/OAuth, rate limit, Redis, queues, serverless, Lambda → nestjs, fastapi, django, php-laravel, firebase-backend |
| [`browser-extensions`](browser-extensions/SKILL.md) | Chrome/Firefox/Edge extension, Manifest V3, content script, service worker, popup, web store |
| [`clean-code`](clean-code/SKILL.md) | write/refactor/lint code, naming, dead code, magic numbers, SOLID, deslop diff |
| [`code-review`](code-review/SKILL.md) | PR review, diff, bugs, code smells, breaking changes, LGTM/blockers |
| [`content-writing`](content-writing/SKILL.md) | blog, social posts, LinkedIn/X, content calendar, brand voice → copywriting |
| [`conversion-optimization`](conversion-optimization/SKILL.md) | CRO, landing/pricing/signup/onboarding/paywall, forms, popups, funnel → ab-testing |
| [`database-design`](database-design/SKILL.md) | schema, ERD, SQL vs NoSQL, normalization, indexes → database-migration, database-optimization, prisma, drizzle-orm |
| [`design`](design/SKILL.md) | any UI/website/dashboard/component, animation, gestures, design system, theming, any CSS → immersive-web, figma, mobile-design, brand-theming, motion-canvas |
| [`devops-iac`](devops-iac/SKILL.md) | Terraform, Kubernetes, Helm, GitHub Actions, ArgoCD/Flux, service mesh, DR → docker, cloud-architecture, cloudflare-deploy, observability |
| [`flutter`](flutter/SKILL.md) | Flutter, Dart, pubspec.yaml, widgets, Riverpod, Bloc, Provider |
| [`frontend-development`](frontend-development/SKILL.md) | React, MUI, TanStack Query/Router, SSR, bundle size, re-renders → nextjs, astro, d3-visualization, progressive-web-app |
| [`fullstack-development`](fullstack-development/SKILL.md) | new web app, stack choice, scaffolding, monorepo, deploy (Vercel/Railway) |
| [`golang`](golang/SKILL.md) | Go, go.mod, goroutines, channels, golangci-lint, race conditions |
| [`i18n-localization`](i18n-localization/SKILL.md) | i18n, l10n, translations, locale, ICU, Intl, RTL |
| [`node`](node/SKILL.md) | Node.js project, package.json, .nvmrc, tsconfig, .env, Makefile |
| [`python`](python/SKILL.md) | Python, pyproject.toml, uv, ruff, mypy, pytest, asyncio |
| [`screenshot`](screenshot/SKILL.md) | screenshot, screen capture, screencapture/scrot/maim → screenshot-feature-extractor |
| [`secure-coding`](secure-coding/SKILL.md) | auth, secrets, injection, XSS, CSRF, JWT, API keys → web-vulnerability-testing, data-privacy-compliance |
| [`seo`](seo/SKILL.md) | SEO audit, meta tags, schema markup, crawlability, GEO, Search Console → programmatic-seo |
| [`software-architecture`](software-architecture/SKILL.md) | architecture, Clean/Hexagonal, DDD, CQRS, event sourcing, ADR, monolith split |
| [`systematic-debugging`](systematic-debugging/SKILL.md) | bugs, stack traces, crashes, memory leaks, flaky tests, CI failures, root cause |
| [`typescript`](typescript/SKILL.md) | TS types, generics, tsconfig, TS errors, JS→TS migration → zod, javascript |
| [`unit-testing-patterns`](unit-testing-patterns/SKILL.md) | unit tests, Jest, pytest, TDD, mocks, fixtures → playwright |
| [`ux-research`](ux-research/SKILL.md) | personas, journeys, interviews, usability tests, heuristic evaluation |
| [`web-quality-audit`](web-quality-audit/SKILL.md) | site audit, Lighthouse, CWV, a11y/WCAG, security headers → web-performance, performance, web-accessibility |
| [`web-scraping-apis`](web-scraping-apis/SKILL.md) | scrape, crawl, Firecrawl, Tavily, CF Browser Rendering, Xquik, tweets → bright-data |
