---
name: web-quality-audit
description: "Performs a full web quality audit measuring Core Web Vitals LCP FID CLS TTFB resource loading, accessibility WCAG ARIA screen reader compliance, SEO meta tags structured data sitemaps robots.txt, security headers CSP HSTS X-Frame-Options, HTML validation standards, and code quality best practices. Use when you need to audit analyze scan assess review optimize a website webpage for speed performance accessibility a11y SEO security compliance standards code quality linting Lighthouse PageSpeed scores before launch redesign migration or debugging slow loading broken markup ranking drops vulnerabilities."
---

# Web Quality Audit

Perform a systematic review of a website. The audit evaluates **Performance**, **Accessibility**, **SEO**, and **Best Practices** (security, compatibility, code quality). Findings are grouped by severity and include concrete remediation steps.

## When to use
- Requested to “audit my site”, “review web quality”, or “run a Lighthouse audit”.
- Before a public launch or major release.
- As part of regular maintenance (weekly or monthly checks).

## Workflow
1. **Run Lighthouse** (or an equivalent tool) on the target pages.
2. Export the JSON report and parse the relevant sections.
3. Classify each issue by category and severity (Critical, High, Medium, Low).
4. Write a summary with actionable fixes and code snippets.
5. Deliver the report in the prescribed markdown format.

## Severity levels
| Level | When to fix |
|-------|-------------|
| **Critical** | Security flaws, complete failures, or Core Web Vitals that break the page experience. Fix immediately. |
| **High** | Core Web Vitals failures, major accessibility barriers, or broken functionality. Fix before launch. |
| **Medium** | Performance improvements, SEO enhancements, or non‑blocking best‑practice gaps. Fix within the current sprint. |
| **Low** | Minor optimisations, lint warnings, or cosmetic issues. Fix when convenient. |

## Audit categories

### Performance (≈40 % of issues)
- **Core Web Vitals**
  - **LCP** < 2.5 s – optimise images, fonts, and server response time.
  - **INP** < 200 ms – reduce long JavaScript tasks, split code, use web workers.
  - **CLS** < 0.1 – set explicit width/height on media, avoid layout‑shifting ads.
- **Resource optimisation**
  - Serve images in WebP/AVIF, use `srcset` for responsive sizes.
  - Minify and tree‑shake JavaScript; defer non‑critical scripts.
  - Extract critical CSS, remove unused rules, avoid `@import`.
  - Use `font-display: swap`; preload key fonts; subset to needed glyphs.
- **Loading strategy**
  - `<link rel="preconnect">` to third‑party origins.
  - `<link rel="preload">` for LCP images, fonts, and above‑fold CSS.
  - Lazy‑load below‑fold images, iframes, and heavy components.
  - Set long `Cache‑Control` TTLs for static assets; use immutable caching for hashed files.

### Accessibility (≈30 % of issues)
- **Perceivable**
  - Every `<img>` has meaningful `alt`; decorative images use `alt=""`.
  - Text contrast ≥ 4.5:1 (large text ≥ 3:1).
  - Provide captions for video and transcripts for audio.
- **Operable**
  - All interactive elements reachable via keyboard; no focus traps.
  - Visible focus indicator on focusable elements.
  - Include a “Skip to main content” link.
  - Allow users to extend time limits; avoid auto‑advancing content.
- **Understandable**
  - Set `<html lang="…">`.
  - Consistent navigation across pages.
  - Clear form error messages linked to the offending fields.
  - Every form control has an associated `<label>`.
- **Robust**
  - Valid HTML (no duplicate IDs, proper nesting).
  - Prefer native elements; use ARIA only when needed and ensure role/name/value are correct.

### SEO (≈15 % of issues)
- **Crawlability**
  - `robots.txt` does not block essential resources.
  - XML sitemap submitted to Search Console.
  - Canonical tags prevent duplicate content.
  - No `noindex` on pages that should be indexed.
- **On‑page**
  - Unique `<title>` (50‑60 chars) with primary keyword.
  - Compelling `<meta name="description">` (150‑160 chars).
  - Single `<h1>` per page; logical heading hierarchy.
  - Descriptive link text, avoid generic “click here”.
- **Technical**
  - Mobile‑friendly responsive layout; tap targets ≥ 48 px.
  - Serve over HTTPS.
  - Fast loading (performance directly impacts ranking).
  - Structured data via JSON‑LD for rich snippets (Article, Product, FAQ, etc.).

### Best Practices (≈15 % of issues)
#### Security
- Enforce HTTPS; eliminate mixed content.
- Enable HSTS: `Strict-Transport-Security: max-age=31536000; includeSubDomains; preload`.
- Deploy a strict Content‑Security‑Policy (CSP) header; use nonces for allowed inline scripts.
- Add security headers: `X-Frame-Options: DENY`, `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin`, `Permissions-Policy` to disable unused features.
- Run `npm audit` / `yarn audit` regularly; fix vulnerable dependencies.
- Sanitize any HTML inserted from user input (e.g., `DOMPurify`).
- Set cookies with `Secure; HttpOnly; SameSite=Strict`.
#### Compatibility & Standards
- Use HTML5 doctype `<!DOCTYPE html>`.
- Declare charset first in `<head>`: `<meta charset="UTF-8">`.
- Include responsive viewport meta tag.
- Prefer feature detection over user‑agent sniffing.
- Load polyfills only when needed (e.g., via `polyfill.io`).
- Avoid deprecated APIs: `document.write`, synchronous XHR, Application Cache.
- Use passive listeners for scroll/touch events unless `preventDefault` is required.
#### Code Quality
- No console errors or `console.log` statements in production.
- Implement global error handling and, for React, error boundaries.
- Hide source maps in production (`devtool: 'hidden-source-map'` or disabled).
- Use semantic HTML5 elements (`<header>`, `<nav>`, `<main>`, `<article>`, etc.).
- Ensure valid HTML (no duplicate IDs, proper nesting).
- Apply event delegation instead of attaching identical listeners to many elements.
- Clean up listeners, timers, or AbortControllers when components unmount.

## Audit output format
```markdown
## Audit results

### Critical issues (X found)
- **[Category]** Issue description. File: `path/to/file.js:123`
  - **Impact:** Brief explanation of why it matters.
  - **Fix:** Precise code change or configuration recommendation.

### High priority (X found)
- …

### Summary
- Performance: X issues (Y critical)
- Accessibility: X issues (Y critical)
- SEO: X issues
- Best Practices: X issues

### Recommended priority
1. Fix critical security and Core Web Vitals failures.
2. Resolve high‑impact accessibility barriers.
3. Apply medium‑level SEO and performance improvements.
4. Tackle low‑priority code‑quality items.
```

## Checklists
### Before every deploy
- Core Web Vitals pass the thresholds.
- No accessibility violations reported by axe/Lighthouse.
- No console errors or uncaught exceptions.
- HTTPS works without mixed‑content warnings.
- Essential meta tags (`title`, `description`, `viewport`, `charset`) are present.

### Weekly review
- Scan Search Console for crawl or indexing issues.
- Monitor Core Web Vitals trends.
- Run `npm audit` and update vulnerable packages.
- Test major pages with a screen‑reader (NVDA, VoiceOver).

### Monthly deep dive
- Run a full Lighthouse audit on all critical pages.
- Profile performance with Chrome DevTools (CPU, network).
- Conduct a manual accessibility walkthrough with real users.
- Review keyword rankings and update on‑page SEO content.

## Tools
| Tool | Purpose |
|------|---------|
| Lighthouse | Automated performance, accessibility, SEO, and best‑practice scores |
| axe-core (browser extension or CLI) | Detailed accessibility testing |
| WebPageTest | Real‑world performance metrics and filmstrip view |
| npm audit / yarn audit | Dependency vulnerability detection |
| W3C Markup Validation Service | HTML validation |
| SecurityHeaders.com | Verify security header configuration |
| Google Search Console | Crawl errors, indexing status, and Core Web Vitals reports |

---
*This skill provides the structure and guidance needed to deliver a thorough web quality audit. Adapt the recommendations to the specific technology stack and project constraints.*

## Related skills

Load these when the task spans more than this skill.

- [`web-performance`](../web-performance/SKILL.md) — Provides step‑by‑step guidance to measure, diagnose, and improve web performance, focusing on Core Web Vitals…
- [`web-accessibility`](../web-accessibility/SKILL.md) — Provides concise guidance for auditing and fixing web accessibility to meet WCAG 2.1 (POUR) and ARIA standards…
- [`seo`](../seo/SKILL.md) — SEO provides a complete audit and optimization guide covering technical SEO, on-page elements, content quality…
- [`web-vulnerability-testing`](../web-vulnerability-testing/SKILL.md) — Test web applications for OWASP-aligned vulnerabilities across injection, authentication, access control, API,…
- [`progressive-web-app`](../progressive-web-app/SKILL.md) — Guides you to build a Progressive Web App (PWA) with HTTPS, a web app manifest, a service worker, offline fall…
- [`performance`](../performance/SKILL.md) — Analyzes web performance using Chrome DevTools MCP. Measures Core Web Vitals (LCP, INP, CLS) and supplementary…
- [`screenshot`](../screenshot/SKILL.md) — Capture a desktop screenshot (full screen, window, region, or app) on macOS, Linux, or Windows. Use when the u…
