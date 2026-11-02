# Web quality audit checklist

Typical issue share: Performance ~40 %, Accessibility ~30 %, SEO ~15 %, Best Practices ~15 %.

## Performance

- Core Web Vitals: LCP < 2.5 s (images, fonts, server response); INP < 200 ms (split long tasks, code-split, web workers); CLS < 0.1 (explicit media width/height, reserve ad slots).
- Images: WebP/AVIF, `srcset` for responsive sizes.
- JS: minify, tree-shake, defer non-critical scripts.
- CSS: extract critical CSS, remove unused rules, no `@import`.
- Fonts: `font-display: swap`, preload key fonts, subset glyphs.
- `<link rel="preconnect">` to third-party origins; `<link rel="preload">` for LCP image, fonts, above-fold CSS.
- Lazy-load below-fold images, iframes, heavy components.
- Long `Cache-Control` TTL for static assets; `immutable` for hashed files.

## Accessibility (WCAG POUR)

- Perceivable: meaningful `alt`; decorative `alt=""`. Contrast ≥ 4.5:1 (large text ≥ 3:1). Captions for video, transcripts for audio.
- Operable: all controls keyboard-reachable, no focus traps, visible focus ring, "Skip to main content" link, extendable time limits, no auto-advance.
- Understandable: `<html lang>`, consistent navigation, every control has a `<label>`, errors linked to fields.
- Robust: valid HTML (no duplicate IDs, correct nesting). Native elements first; ARIA only when needed with correct role/name/value.

## SEO

- Crawl: `robots.txt` does not block needed resources; XML sitemap in Search Console; canonical tags; no stray `noindex`.
- On-page: unique `<title>` 50–60 chars; meta description 150–160 chars; one `<h1>`, logical heading order; descriptive link text (no "click here").
- Technical: responsive, tap targets ≥ 48 px; HTTPS; fast load; JSON-LD structured data (Article, Product, FAQ).

## Best practices

Security:
- HTTPS everywhere; no mixed content.
- HSTS `Strict-Transport-Security: max-age=31536000; includeSubDomains; preload` (only after HTTPS is stable on all subdomains; preload is hard to undo).
- Strict CSP; nonces for allowed inline scripts.
- `X-Frame-Options: DENY`, `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin`, `Permissions-Policy` to turn off unused features.
- `npm audit` / `yarn audit` regularly. Sanitize user HTML (DOMPurify). Cookies `Secure; HttpOnly; SameSite=Strict`.

Compatibility:
- `<!DOCTYPE html>`; `<meta charset="UTF-8">` first in `<head>`; viewport meta.
- Feature detection, not UA sniffing. Load polyfills only when needed; self-host them (do not use `polyfill.io`: domain was compromised in 2024).
- No `document.write`, sync XHR, AppCache. Passive scroll/touch listeners unless `preventDefault` is needed.

Code quality:
- No console errors or `console.log` in production. Global error handler; React error boundaries.
- Hide source maps in production (`devtool: 'hidden-source-map'` or off).
- Semantic HTML5 (`header`, `nav`, `main`, `article`). Event delegation over many identical listeners. Clean up listeners, timers, AbortControllers on unmount.

## Report format

```markdown
## Audit results

### Critical issues (X found)
- **[Category]** Issue. File: `path/to/file.js:123`
  - **Impact:** why it matters.
  - **Fix:** exact code or config change.

### High priority (X found)
- …

### Summary
- Performance: X issues (Y critical)
- Accessibility: X issues (Y critical)
- SEO: X issues
- Best Practices: X issues

### Recommended priority
1. Critical security and Core Web Vitals failures.
2. High-impact accessibility barriers.
3. Medium SEO and performance items.
4. Low code-quality items.
```

## Cadence

- Every deploy: CWV pass; no axe/Lighthouse a11y violations; no console errors; HTTPS without mixed content; `title`, `description`, `viewport`, `charset` present.
- Weekly: Search Console crawl/index issues; CWV trends; `npm audit`; screen-reader pass (NVDA, VoiceOver) on main pages.
- Monthly: full Lighthouse on critical pages; DevTools CPU/network profile; manual a11y walkthrough with real users; keyword ranking review.

## Tools

| Tool | Purpose |
|---|---|
| Lighthouse | Perf, a11y, SEO, best-practice scores |
| axe-core | Detailed a11y testing |
| WebPageTest | Real-world metrics, filmstrip |
| npm/yarn audit | Dependency vulnerabilities |
| W3C Markup Validator | HTML validation |
| SecurityHeaders.com | Header check |
| Google Search Console | Crawl, index, field CWV |
