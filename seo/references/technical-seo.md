# Technical SEO

Crawlability, indexation, speed, mobile, HTTPS, URLs, international. Parent: [`seo`](../SKILL.md).

## Crawlability

- robots.txt: allow every indexable page; block only non-public areas.

```text
User-agent: *
Allow: /
Disallow: /admin/
Disallow: /api/
Sitemap: https://example.com/sitemap.xml
```

- XML sitemap: reachable, canonical indexable URLs only, submitted in Search Console. Max 50,000 URLs or 50 MB per file; use a sitemap index above that. Match the intended public surface, not every URL the app can make.
- Architecture: every key page within 3 clicks of the homepage. No orphan pages.
- Crawl budget (large sites): control parameterized URLs, paginate infinite scroll, remove session IDs from URLs.

## Indexation

- Compare `site:example.com` with the Search Console page indexing report.
- Remove `noindex` from pages that must rank.
- Add a self-referencing canonical on each page. Keep canonicals consistent and loop-free. Do not let duplicate URLs compete without canonical control.
- Fix redirect chains, loops, soft 404s. Max 2 hops per chain.
- Put `<meta name="robots" content="noindex, follow">` on pagination, tag, and internal search result pages.

## Core Web Vitals

| Metric | Target | Typical fixes |
|---|---|---|
| LCP | < 2.5 s | Compress above-the-fold images (WebP, `width`/`height`), preload critical CSS, CDN |
| INP | < 200 ms | Split long JS tasks, web workers |
| CLS | < 0.1 | Explicit image/video size; no content inserted above existing content |

Deep diagnosis: [web-performance](../../web-quality-audit/references/web-performance.md).

## Mobile, HTTPS, URLs

- Responsive design; no separate mobile subdomain unless necessary. Same content on mobile and desktop.
- `<meta name="viewport" content="width=device-width, initial-scale=1">`. Tap targets >= 48 x 48 px.
- HTTPS site-wide, no mixed content, HSTS: `Strict-Transport-Security: max-age=31536000; includeSubDomains`.
- URLs: lowercase, hyphen-separated, < 75 chars, primary keyword where natural, no needless query parameters.

## International (hreflang)

```html
<link rel="alternate" hreflang="en" href="https://example.com/page">
<link rel="alternate" hreflang="es" href="https://example.com/es/page">
<link rel="alternate" hreflang="x-default" href="https://example.com/page">
```

## Tools

| Tool | Use |
|---|---|
| Google Search Console | Indexing, coverage, CWV, performance |
| PageSpeed Insights / WebPageTest | LCP, INP, CLS; load waterfall |
| Google Analytics 4 | Traffic, engagement, conversions |
| Screaming Frog / Sitebulb | Crawl, broken links, redirect chains |
| Ahrefs / Semrush | Keywords, backlinks, competitors |
| Rich Results Test | Validate JSON-LD |
