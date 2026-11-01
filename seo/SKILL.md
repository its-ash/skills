---
name: seo
description: "SEO audits and optimizes websites for search visibility across technical SEO, on-page elements, content quality, keyword strategy, schema markup, Core Web Vitals, mobile SEO, and local SEO, with checklists and tool guidance. Use when a site needs a health check, ranking improvement, crawlability fixes, indexation issues, title tags, meta descriptions, headings, structured data, rich snippets, GEO, AI search citations, keyword research, Google Search Console, Lighthouse, Screaming Frog, Ahrefs, or Semrush. Sub-skills: generative-engine-optimization, schema-markup, programmatic-seo."
---

# SEO Audit & Optimization Guide

This skill helps you evaluate a website’s SEO health, identify problems, and apply concrete fixes. It covers technical foundations, on‑page elements, content quality, keyword strategy, structured data, Core Web Vitals, mobile and local considerations, and provides a ready‑to‑use checklist.

---

## When to Use
- You need a full SEO health check ("SEO audit", "technical SEO", "why am I not ranking").
- You want to improve on‑page tags, URLs, or internal linking.
- You must fix crawlability, indexation, speed, or mobile issues.
- You are adding or correcting schema markup, Core Web Vitals, or local SEO.
- You are planning keyword research and content clusters.

---

## 1. Audit Framework
Prioritize the following areas in order:
1. **Crawlability & Indexation** – Can search engines find and index the pages?
2. **Technical Foundations** – Speed, security, mobile experience.
3. **On‑Page Optimization** – Titles, meta descriptions, headings, URLs, images.
4. **Content Quality** – Depth, freshness, E‑E‑A‑T.
5. **Authority & Links** – Backlinks, internal linking, schema.

### Principles
- Fix technical blockers before you optimize content.
- Give each page one clear primary search intent.
- Prefer long-term quality signals to manipulative patterns.
- Assume mobile-first, because indexing is mobile-first.
- Make each recommendation page-specific and implementable. Read the real page before you give content advice.

---

## 2. Technical SEO
### 2.1 Crawlability
- **robots.txt** – Ensure important pages are allowed and only non‑public areas are blocked.
```text
User-agent: *
Allow: /
Disallow: /admin/
Disallow: /api/
Sitemap: https://example.com/sitemap.xml
```
- **XML Sitemap** – Must be accessible, contain only canonical, indexable URLs, and be submitted in Google Search Console. Limit 50 000 URLs or 50 MB per file; use a sitemap index for larger sites.
- **Site Architecture** – All key pages within three clicks from the homepage. No orphan pages.
- **Crawl Budget** – For large sites, control parameterized URLs, avoid infinite scroll without pagination, and remove session IDs from URLs.

### 2.2 Indexation
- Run `site:example.com` in Google and compare with the Search Console Coverage report.
- Fix **noindex** tags on pages that should rank.
- Ensure every page has a self‑referencing **canonical** tag.
- Resolve redirect chains, loops, and soft 404s. Keep each redirect chain to two hops or fewer.
- Make canonicals self-consistent and free of loops. Do not let duplicate URLs compete without canonical control.
- Make the sitemap match the intended public surface, not every URL the app can produce.

### 2.3 Core Web Vitals & Speed
| Metric | Target | Typical Fixes |
|--------|--------|---------------|
| LCP (Largest Contentful Paint) | < 2.5 s | Optimize above‑the‑fold images, use a CDN, preload critical CSS |
| INP (Interaction to Next Paint) | < 200 ms | Reduce long JavaScript tasks, use web workers |
| CLS (Cumulative Layout Shift) | < 0.1 | Set explicit width/height on images & videos, avoid inserting content above existing elements |

**Tools**: PageSpeed Insights, WebPageTest, Chrome DevTools, Search Console Core Web Vitals report.

### 2.4 Mobile‑First
- Responsive design; no separate mobile sub‑domain unless necessary.
- Viewport meta tag: `<meta name="viewport" content="width=device-width, initial-scale=1">`
- Tap targets ≥ 48 × 48 px.
- Same content on mobile and desktop.

### 2.5 Security & HTTPS
- Serve the entire site over HTTPS.
- Use HSTS header (e.g., `Strict-Transport-Security: max-age=31536000; includeSubDomains`).
- Eliminate mixed content.

### 2.6 URL Structure
- Use lowercase, hyphen‑separated words.
- Keep URLs under 75 characters.
- Include the primary keyword naturally.
- Avoid unnecessary query parameters.

---

## 3. On‑Page SEO
### 3.1 Title Tags
- Length: 50‑60 characters (visible in SERP).
- Place primary keyword near the start.
- Unique for every page; optional brand name at the end.
```html
<title>Ultimate Guide to React Hooks – Learn useEffect & useState | MySite</title>
```

### 3.2 Meta Descriptions
- Length: 150‑160 characters.
- Include primary keyword and a clear call‑to‑action.
- Unique per page.
```html
<meta name="description" content="Master React Hooks with step‑by‑step examples. Learn useState, useEffect, and custom hooks. Start building better apps today.">
```

### 3.3 Heading Structure
- One `<h1>` per page, containing the primary keyword.
- Logical hierarchy (H1 → H2 → H3 …). Do not skip levels.
- Headings describe the section content.

### 3.4 Content Optimization
- Place the primary keyword within the first 100 words.
- Use semantic variations naturally; keep density around 1‑2%.
- Aim for comprehensive coverage: 1 500‑2 500 words for in‑depth guides, 300‑500 words for product pages.
- Avoid thin or duplicate content.

### 3.5 Image Optimization
- Descriptive, keyword‑rich filenames.
- Alt text that describes the image purpose.
- Compress images; serve WebP/AVIF when possible.
- Add `width`/`height` attributes to prevent CLS.
- Use `loading="lazy"` for below‑fold images.
```html
<img src="react-hooks-diagram.webp" alt="Diagram of React useState and useEffect hooks" width="800" height="600" loading="lazy">
```

### 3.6 Internal Linking
- Link to important pages from relevant context.
- Use descriptive anchor text (avoid "click here").
- Aim for 3‑5 internal links per 1 000 words.
- Regularly audit for broken links.
- Link from strong pages to the pages you want to rank.
- When you publish a new page, backfill links from relevant existing pages to it.

### 3.7 Keyword Targeting & Cannibalization
- Assign a single primary keyword to each page.
- Map keywords to pages in a spreadsheet.
- Ensure no two pages compete for the same keyword unless intentional.
- Mapping steps: define the search intent, collect realistic variants, rank by intent match, value, and competition, map one primary theme to one URL, then check for cannibalization.

---

## 4. Content Quality & E‑E‑A‑T
| Pillar | Signals |
|--------|---------|
| Experience | First‑hand examples, case studies, original data |
| Expertise | Author credentials, detailed explanations |
| Authoritativeness | Citations, backlinks, industry recognition |
| Trustworthiness | HTTPS, clear contact info, privacy policy |

- Provide comprehensive answers that cover follow‑up questions.
- Keep content fresh; update at least annually.
- Monitor user engagement: time on page, bounce rate, pages per session.

---

## 5. Schema Markup (JSON‑LD)
Add appropriate structured data to improve rich results.
```json
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "Complete Guide to React Hooks",
  "image": "https://example.com/react-hooks.jpg",
  "author": {"@type": "Person", "name": "Jane Developer"},
  "publisher": {"@type": "Organization", "name": "Tech Academy", "logo": {"@type": "ImageObject", "url": "https://example.com/logo.png"}},
  "datePublished": "2024-01-15",
  "dateModified": "2024-02-01"
}
```
Common types:
- **Article** – blog posts, news.
- **Product** – e‑commerce items.
- **FAQPage** – question‑answer sections.
- **HowTo** – step‑by‑step guides.
- **Organization** – company info.
- **LocalBusiness** – address, phone, opening hours.
- **BreadcrumbList** – navigation hierarchy.

Page-type mapping:
| Page | Schema |
|------|--------|
| Homepage | `Organization` or business type |
| Editorial | `Article` / `BlogPosting` |
| Product | `Product` + `Offer` |
| Interior pages | `BreadcrumbList` |
| Q&A section | `FAQPage`, only when the visible content really is Q&A |

Add schema only for content that is on the page. Validate with Google Rich Results Test or Schema.org Validator.

---

## 6. Keyword Research & Content Strategy
1. **Identify seed keywords** from business goals.
2. Expand using tools (Google Keyword Planner, Ahrefs, SEMrush).
3. Group keywords into topical clusters.
4. Create a **pillar page** (3 000+ words) for each core topic.
5. Write supporting **cluster articles** (1 500‑2 000 words) that link to the pillar and vice‑versa.
6. Prioritize long‑tail keywords for quick wins.

**On‑Page Formula**
- Title: primary keyword + secondary keyword + brand.
- H1: primary keyword.
- URL: short, keyword‑rich.
- First paragraph: primary keyword.
- Meta description: primary + secondary keyword.
- Alt text: descriptive, include keyword if natural.

---

## 7. International & Local SEO
### hreflang
```html
<link rel="alternate" hreflang="en" href="https://example.com/page">
<link rel="alternate" hreflang="es" href="https://example.com/es/page">
<link rel="alternate" hreflang="x-default" href="https://example.com/page">
```
### Local Business Schema
```json
{
  "@context": "https://schema.org",
  "@type": "LocalBusiness",
  "name": "Tech Solutions Inc",
  "address": {"@type": "PostalAddress","streetAddress":"123 Main St","addressLocality":"San Francisco","addressRegion":"CA","postalCode":"94102"},
  "telephone": "+1-415-555-0123"
}
```
- Ensure NAP (Name, Address, Phone) consistency across citations.
- Optimize Google Business Profile with photos, posts, and reviews.

---

## 8. Checklist
### Critical (fix before launch)
- HTTPS enabled site‑wide.
- robots.txt allows crawling of all indexable pages.
- No `noindex` on important pages.
- Unique, keyword‑rich title tags (50‑60 chars).
- Single `<h1>` per page.
- Canonical tag present and correct.
- Mobile‑responsive design.
- Core Web Vitals passing (LCP < 2.5 s, INP < 200 ms, CLS < 0.1).

### High Priority
- Meta descriptions (150‑160 chars, unique).
- XML sitemap submitted to Search Console.
- Structured data for articles, products, FAQs, breadcrumbs.
- Internal linking to all pillar and cluster pages.
- Image `alt` text and size attributes.

### Medium Priority
- Content depth ≥ 1 500 words for guides.
- E‑E‑A‑T author bios and credentials.
- Schema for Organization and LocalBusiness.
- hreflang tags for multilingual sites.
- Font and resource preloading.

### Ongoing
- Monitor Search Console for crawl errors.
- Update sitemap when new content is added.
- Track keyword rankings and organic traffic.
- Refresh outdated content quarterly.
- Audit backlinks and disavow toxic links.

---

## 9. Tools & Resources
| Tool | Use |
|------|-----|
| Google Search Console | Indexing, coverage, Core Web Vitals, performance reports |
| Google PageSpeed Insights | LCP, INP, CLS, optimization suggestions |
| Google Analytics 4 | Traffic, engagement, conversion tracking |
| Screaming Frog / Sitebulb | Crawl analysis, broken links, redirect chains |
| Ahrefs / Semrush | Keyword research, backlink profile, competitor analysis |
| Rich Results Test | Validate JSON‑LD structured data |
| WebPageTest | Detailed load‑time waterfall and resource timing |

---

## 10. Quick Fix Patterns
### Title Tag
```html
<title>Primary Keyword – Secondary Keyword | Brand</title>
```
### Meta Description
```html
<meta name="description" content="Compelling sentence with primary keyword. 150‑160 characters, includes a call‑to‑action.">
```
### Canonical URL
```html
<link rel="canonical" href="https://example.com/current-page">
```
### Open Graph (social)
```html
<meta property="og:title" content="Page Title">
<meta property="og:description" content="Page description">
<meta property="og:image" content="https://example.com/image.jpg">
<meta property="og:url" content="https://example.com/page">
<meta property="og:type" content="website">
```
### Twitter Card
```html
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="Page Title">
<meta name="twitter:description" content="Page description">
<meta name="twitter:image" content="https://example.com/image.jpg">
```
### Formulas
```text
Title:            Primary Topic - Specific Modifier | Brand
Meta description: Action + topic + value proposition + one supporting detail
```

### Audit Finding Format
Tie each finding to a page, file, or asset:
```text
[HIGH] Duplicate title tags on product pages
Location: src/routes/products/[slug].tsx
Issue: Dynamic titles collapse to the same default string, which weakens relevance and creates duplicate signals.
Fix: Generate a unique title per product using the product name and primary category.
```

### Anti-Patterns
| Anti-pattern | Fix |
|---|---|
| Keyword stuffing | Write for users first |
| Thin near-duplicate pages | Consolidate or differentiate them |
| Schema for content that is not on the page | Match schema to reality |
| Content advice without reading the page | Read the real page first |
| Generic "improve SEO" output | Tie each recommendation to a page or asset |

---

## 11. Frequently Asked Questions
**Q: My site has a low LCP. What should I do first?**
- Optimize above‑the‑fold images (compress, serve WebP, add `width`/`height`).
- Preload the main CSS file.
- Use a CDN to serve static assets.

**Q: How many internal links are too many?**
- Keep links relevant; 3‑5 per 1 000 words is a good rule. Avoid excessive footer or navigation links that dilute link equity.

**Q: Should I use `noindex` on search result pages?**
- Yes. Add `<meta name="robots" content="noindex, follow">` to pagination, tag, and internal search result pages.

---

## 12. Next Steps
1. Run a Lighthouse or Screaming Frog crawl on the target URL.
2. Record findings using the **Audit Report Structure** (Issue, Impact, Evidence, Fix, Priority).
3. Apply the quick‑fix patterns above.
4. Re‑audit to confirm score improvements.
5. Implement the keyword‑driven content plan and monitor results monthly.

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/generative-engine-optimization.md](references/generative-engine-optimization.md) | Generative Engine Optimization (GEO) guides the creation of web content that AI‑powered search engines (ChatGPT, Claude, Perplexity, Gemini) are likely to cite. Use it when you want your pages to appear as sources in AI responses. |
| [references/schema-markup.md](references/schema-markup.md) | Provides a step‑by‑step workflow for adding, fixing, or optimizing JSON‑LD schema markup (structured data) on web pages. Use when the user mentions schema markup, structured data, JSON‑LD, rich snippets, or specific schema types such as FAQ, Product, Breadcrumb, etc. |
| [references/programmatic-seo.md](references/programmatic-seo.md) | Creates thousands of SEO-optimized landing pages from structured data and reusable templates to capture long-tail keyword patterns at scale. Use when building location-specific service pages, comparison grids, pricing calculators, template libraries, or any repeatable search intent; triggers include programmatic SEO, pSEO, mass page generation, template-driven content, data-driven pages, competitor comparison pages, alternative pages, versus pages, location pages, city pages, keyword clustering, content automation, internal linking architecture, schema markup, canonical tags, crawl budget optimization, indexation strategy, and ranking for competitor brand terms. |

## Related skills

Load these when the task spans more than this skill.

- [`web-quality-audit`](../web-quality-audit/SKILL.md) — Runs a full web quality audit that checks performance (Core Web Vitals, resource loading), accessibility, SEO,…
- [`performance`](../web-quality-audit/references/performance.md) — Analyzes web performance using Chrome DevTools MCP. Measures Core Web Vitals (LCP, INP, CLS) and supplementary…
- [`content-writing`](../content-writing/SKILL.md) — The content-writing skill guides brand-voice creation, SEO blog drafting, social-media post production, conten…
- [`programmatic-seo`](references/programmatic-seo.md) — Programmatic SEO skill guides you to design, build, and launch large numbers of SEO-optimized pages using temp…
- [`nextjs`](../frontend-development/references/nextjs.md) — Guidelines for building Next.js 14+ applications with the App Router. Includes component type decisions, data…
