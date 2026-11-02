---
name: web-quality-audit
description: "Full web quality audit: Core Web Vitals (LCP, INP, CLS, TTFB), resource loading, accessibility (WCAG, ARIA, screen readers), SEO (meta tags, structured data, sitemaps, robots.txt), security headers (CSP, HSTS, X-Frame-Options), HTML validity, and code quality. Use to audit or optimize a site for speed, a11y, SEO, or security, run Lighthouse or PageSpeed, check launch readiness, or debug slow loads, broken markup, ranking drops, or regressions after deploy. Sub-skills: web-performance, performance, web-accessibility, benchmark, latency-critical-systems, production-audit, canary-watch."
---
# Web Quality Audit
Audit a site for Performance, Accessibility, SEO, and Best Practices; report findings by severity with exact fixes.

## Core rules
- Run Lighthouse (or equivalent) on each target page. Export JSON and parse it; do not guess scores.
- Classify each finding by category and severity (Critical, High, Medium, Low).
- Give each finding a file path and line, its impact, and an exact code or config fix.
- Use the report format in the checklist reference.
- Fix order: Critical security and CWV → High a11y barriers → Medium SEO/perf → Low code quality.
- CWV targets: LCP < 2.5 s, INP < 200 ms, CLS < 0.1. INP replaces FID.
- Prefer field data (Search Console, CrUX) over one lab run when they disagree.
- Prefer native HTML to ARIA. Contrast ≥ 4.5:1 (large text ≥ 3:1).
- Do not run audits or load tests against third-party sites without permission.

## Decisions
| Severity | Criteria | Fix by |
|---|---|---|
| Critical | Security flaw, total failure, CWV that breaks the page | Now |
| High | CWV failure, major a11y barrier, broken function | Before launch |
| Medium | Perf or SEO gain, non-blocking best-practice gap | This sprint |
| Low | Minor tuning, lint warning, cosmetic | When convenient |

| Situation | Do | Avoid |
|---|---|---|
| "Audit my site" / pre-launch | Full four-category audit + report | Perf-only Lighthouse score |
| Slow page, CWV regression | Load `performance` (DevTools MCP trace) then `web-performance` fixes | Guessing from source alone |
| Before/after a change | `benchmark` baseline and compare | Single unpaired run |
| "Ready to ship?" | `production-audit` score + blockers | Generic checklist only |
| Just deployed | `canary-watch` against baseline | Waiting for user reports |
| p95/p99, feeds, streams | `latency-critical-systems` | Page-load tuning only |
| HSTS | Enable only after HTTPS works on all subdomains | `preload` before rollback is clear |
| Polyfills | Load on demand, self-host | `polyfill.io` (compromised 2024) |

## Load on demand
| Need | Read |
|---|---|
| Per-category checklists, report template, cadence, tools | [references/audit-checklist.md](references/audit-checklist.md) |
| Fix CWV, bundles, caching, images, fonts | [references/web-performance.md](references/web-performance.md) |
| Chrome DevTools MCP traces, LCP/INP/CLS diagnosis | [references/performance.md](references/performance.md) |
| WCAG 2.1/2.2, ARIA, forms, modals, mobile a11y | [references/web-accessibility.md](references/web-accessibility.md) |
| Baselines and before/after measurement loop | [references/benchmark.md](references/benchmark.md) |
| Realtime p95/p99 latency, throughput, freshness | [references/latency-critical-systems.md](references/latency-critical-systems.md) |
| Ship-readiness score and blockers | [references/production-audit.md](references/production-audit.md) |
| Post-deploy URL monitoring | [references/canary-watch.md](references/canary-watch.md) |

## Related skills
- [`seo`](../seo/SKILL.md) — deep SEO audit and schema markup
- [`secure-coding`](../secure-coding/SKILL.md) — CSP, headers, cookies in code
- [`web-vulnerability-testing`](../secure-coding/references/web-vulnerability-testing.md) — OWASP pentest of the site
- [`progressive-web-app`](../frontend-development/references/progressive-web-app.md) — manifest, service worker, offline
- [`screenshot`](../screenshot/SKILL.md) — capture pages for the report
