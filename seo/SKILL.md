---
name: seo
description: "SEO audits and optimizes websites for search visibility across technical SEO, on-page elements, content quality, keyword strategy, schema markup, Core Web Vitals, mobile SEO, and local SEO. Use when a site needs a health check, ranking improvement, crawlability fixes, indexation issues, title tags, meta descriptions, headings, structured data, rich snippets, GEO, AI search citations, keyword research, Google Search Console, Lighthouse, Screaming Frog, Ahrefs, or Semrush. Sub-skills: generative-engine-optimization, schema-markup, programmatic-seo."
---

# SEO

Find and fix what blocks a site from ranking and from AI-search citation.

## Core rules

- Audit in this order: crawlability and indexation -> technical (speed, security, mobile) -> on-page -> content quality (E-E-A-T) -> authority and links.
- Fix technical blockers before you optimize content.
- Read the real page before you give content advice.
- Tie each finding to a page, file, or asset. Use the finding format in [audit-checklist.md](references/audit-checklist.md).
- Give each page one primary search intent and one primary keyword. Prevent cannibalization.
- Assume mobile-first indexing. Serve the same content on mobile and desktop.
- Give each page a unique title (50-60 chars), unique meta description (150-160 chars), one `<h1>`, and a self-referencing canonical.
- Keep only canonical, indexable URLs in the sitemap. Keep redirect chains to <= 2 hops.
- Add schema only for content that is visible on the page. Validate with Rich Results Test.
- Target CWV: LCP < 2.5 s, INP < 200 ms, CLS < 0.1.
- Prefer long-term quality signals. Never use manipulative patterns.

## Decisions

| Situation | Do | Avoid |
|---|---|---|
| Keyword stuffing found | Write for users; 1-2% density with semantic variants | Repeating the exact phrase |
| Thin near-duplicate pages | Consolidate or differentiate | Letting them compete without canonicals |
| Schema for content not on page | Match schema to visible content | Markup for rich results only |
| Generic "improve SEO" request | Page-specific, implementable fixes | Boilerplate advice |
| Pagination, tag, internal search pages | `noindex, follow` | Indexing them |
| Large site, crawl waste | Control parameters, paginate infinite scroll, drop session IDs | Blocking needed pages in robots.txt |
| Multilingual site | `hreflang` per locale + `x-default` | Auto-redirect by IP only |
| New page published | Backfill internal links from strong related pages | Orphan pages |

| Page type | Schema |
|---|---|
| Homepage | `Organization` or business type |
| Editorial | `Article` / `BlogPosting` |
| Product | `Product` + `Offer` |
| Step-by-step guide | `HowTo` |
| Interior pages | `BreadcrumbList` |
| Local business | `LocalBusiness` (NAP, hours) |
| Q&A section | `FAQPage`, only when the visible content is Q&A |

## Load on demand

| Need | Read |
|---|---|
| robots.txt, sitemap limits, indexation, CWV fixes, mobile, HTTPS, URLs, hreflang, tools | [technical-seo.md](references/technical-seo.md) |
| Title/meta/heading/image rules, OG and Twitter tags, content length, E-E-A-T, internal links, keyword mapping, local SEO | [on-page-content.md](references/on-page-content.md) |
| Prioritized checklist, audit process, finding format | [audit-checklist.md](references/audit-checklist.md) |
| JSON-LD workflow, schema type examples, framework patterns | [schema-markup.md](references/schema-markup.md) |
| GEO: get cited by ChatGPT, Claude, Perplexity, Gemini | [generative-engine-optimization.md](references/generative-engine-optimization.md) |
| Pages at scale from data and templates (location, comparison, alternative pages) | [programmatic-seo.md](references/programmatic-seo.md) |

## Related skills

- [`web-quality-audit`](../web-quality-audit/SKILL.md) - full audit: perf, a11y, SEO, security
- [`performance`](../web-quality-audit/references/performance.md) - CWV with Chrome DevTools MCP
- [`content-writing`](../content-writing/SKILL.md) - SEO blog drafts, brand voice
- [`nextjs`](../frontend-development/references/nextjs.md) - Next.js metadata and rendering
