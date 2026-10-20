---
name: web-performance
description: "Measures, diagnoses, and improves website speed and runtime efficiency, covering Core Web Vitals (LCP, INP, FID, CLS), bundle size, caching, critical rendering path, resource loading, image and font optimization, and JavaScript performance. Use when optimizing Lighthouse scores, fixing slow page loads, reducing bundle size, improving Time to First Byte, lazy loading assets, tuning cache headers, or debugging layout shift and input delay."
---

# Web Performance Optimization

Improve loading speed, interactivity, and visual stability of a website or web app. Use this skill to measure current performance, identify bottlenecks, apply targeted fixes, and verify improvements. It covers Core Web Vitals, asset optimization, caching, JavaScript handling, and profiling workflows.

## When to use
- Site loads slowly or fails Lighthouse performance thresholds.
- Core Web Vitals (LCP, INP/FID, CLS) are in the "needs work" or "poor" range.
- JavaScript bundle is large or blocks the main thread.
- Images, fonts, or third‑party scripts cause layout shifts or delays.
- You need a performance budget, caching plan, or CI/CD audit.

## Measurement & Profiling Workflow
1. **Baseline** – Run a Lighthouse audit (`npx lighthouse <url>`) and collect real‑user metrics via the `web-vitals` library or Chrome User Experience Report.
2. **Identify** – Use Chrome DevTools Performance panel, Network waterfall, and the Performance Observer API to locate long tasks, render‑blocking resources, and layout shifts.
3. **Fix** – Apply the targeted optimizations described in the sections below.
4. **Validate** – Re‑run the audit, compare before/after numbers, and monitor RUM data.

### Core Tools
- **Lighthouse** (local, CI, or Chrome extension)
- **WebPageTest** for detailed waterfall and filmstrip
- **Chrome DevTools** – Performance, Network, Memory tabs
- **web‑vitals** npm package for field data
- **Bundle analyzer** (`npx webpack-bundle-analyzer`) for JS size

## Performance Budget
| Resource | Budget |
|---|---|
| Total page weight | < 1.5 MB |
| JavaScript (gzipped) | < 300 KB |
| CSS (gzipped) | < 100 KB |
| Above‑fold images | < 500 KB |
| Fonts | < 100 KB |
| Third‑party scripts | < 200 KB |

## Critical Rendering Path & Server Response
- **TTFB** < 800 ms. Use CDN, edge caching, and efficient back‑ends.
- Enable **Brotli** or **gzip** compression for text assets.
- Serve over **HTTP/2** or **HTTP/3** to multiplex requests.
- Cache static HTML at the edge when possible.

## Resource Loading Strategies
```html
<!-- Preconnect to required origins -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://cdn.example.com" crossorigin>

<!-- Preload critical assets -->
<link rel="preload" href="/hero.webp" as="image" fetchpriority="high">
<link rel="preload" href="/fonts/heading.woff2" as="font" type="font/woff2" crossorigin>

<!-- Inline critical CSS (keep < 14 KB) -->
<style>/* above‑fold styles */</style>

<!-- Defer non‑critical CSS -->
<link rel="preload" href="/styles.css" as="style" onload="this.onload=null;this.rel='stylesheet'">
<noscript><link rel="stylesheet" href="/styles.css"></noscript>

<!-- Defer or async JavaScript -->
<script defer src="/app.js"></script>
<script async src="https://analytics.example.com/track.js"></script>
```

## Core Web Vitals

### Largest Contentful Paint (LCP)
- **Goal:** ≤ 2.5 s (75th percentile).
- **Typical element:** hero image, large text block, background image, or SVG.
- **Common issues & fixes**
  1. **Slow server response** – use CDN, cache HTML, enable compression.
  2. **Render‑blocking CSS/JS** – inline critical CSS, defer scripts, preload styles.
  3. **Unprioritized hero image** – add `fetchpriority="high"` and `<link rel="preload" as="image">`.
  4. **Client‑side rendering delay** – render LCP element on the server (SSR/SSG) or stream HTML.
- **Debugging**
```javascript
new PerformanceObserver(list => {
  const entries = list.getEntries();
  const lcp = entries[entries.length - 1];
  console.log('LCP element:', lcp.element, 'time:', lcp.startTime);
}).observe({type: 'largest-contentful-paint', buffered: true});
```
- **LCP checklist**
  - TTFB < 800 ms
  - Hero image preloaded with `fetchpriority="high"`
  - Image compressed (WebP/AVIF) and sized correctly
  - Critical CSS inlined (< 14 KB)
  - No render‑blocking JS in `<head>`
  - Fonts use `font-display: swap`
  - LCP element present in initial HTML

### Interaction to Next Paint (INP) / First Input Delay (FID)
- **Goal:** ≤ 200 ms (INP) or ≤ 100 ms (FID) for the worst interaction.
- **Components**: Input Delay + Processing Time + Presentation Delay.
- **Common issues & fixes**
  1. **Long tasks (> 50 ms)** – split work into chunks, use `await new Promise(r=>setTimeout(r,0))`, or move heavy work to a **Web Worker**.
  2. **Heavy event handlers** – give immediate visual feedback, defer analytics with `requestIdleCallback`, keep handler < 100 ms.
  3. **Third‑party scripts** – lazy‑load on interaction or visibility (`import()` inside click handler).
  4. **Excessive re‑renders (React/Vue)** – memoize components (`React.memo`, `computed` cache) and use `useTransition` for non‑urgent state.
- **Debugging**
```javascript
new PerformanceObserver(list => {
  for (const entry of list.getEntries()) {
    if (entry.duration > 200) {
      console.warn('Slow interaction', entry);
    }
  }
}).observe({type: 'event', buffered: true, durationThreshold: 16});
```
- **INP checklist**
  - No main‑thread task > 50 ms
  - Event handlers complete < 100 ms
  - Immediate visual feedback provided
  - Non‑critical work deferred (`requestIdleCallback` or Web Worker)
  - Third‑party scripts do not block interaction
  - Input handlers debounced where appropriate

### Cumulative Layout Shift (CLS)
- **Goal:** ≤ 0.1.
- **Formula:** `impact × distance` for each unexpected shift.
- **Common causes & fixes**
  1. **Images without dimensions** – add `width`/`height` attributes or `aspect-ratio` CSS.
  2. **Ads, embeds, iframes** – reserve space with fixed height, `min-height`, or an `aspect-ratio` container.
  3. **Dynamically injected content** – insert below the viewport or animate with `transform` instead of layout changes.
  4. **Web‑font FOUT/FOIT** – use `font-display: optional` or match fallback metrics with `size-adjust`.
  5. **Layout‑changing animations** – animate `transform` or `opacity` only.
- **Debugging**
```javascript
new PerformanceObserver(list => {
  for (const entry of list.getEntries()) {
    if (!entry.hadRecentInput) {
      console.log('CLS shift', entry.value);
      entry.sources?.forEach(s => {
        console.log(' element', s.node);
        console.log(' from', s.previousRect, 'to', s.currentRect);
      });
    }
  }
}).observe({type: 'layout-shift', buffered: true});
```
- **CLS checklist**
  - All images, video, and iframes have width/height or `aspect-ratio`.
  - Ads placed in containers with reserved height.
  - Fonts use `font-display: optional` or matched metrics.
  - Dynamic content inserted below the fold or animated with `transform`.
  - No layout‑changing CSS transitions.

## Image Optimization
- **Preferred formats:** AVIF > WebP > JPEG/PNG.
- **Responsive markup**
```html
<picture>
  <source type="image/avif" srcset="hero-400.avif 400w, hero-800.avif 800w, hero-1200.avif 1200w" sizes="(max-width:600px) 100vw, 50vw">
  <source type="image/webp" srcset="hero-400.webp 400w, hero-800.webp 800w, hero-1200.webp 1200w" sizes="(max-width:600px) 100vw, 50vw">
  <img src="hero-800.jpg" srcset="hero-400.jpg 400w, hero-800.jpg 800w, hero-1200.jpg 1200w" sizes="(max-width:600px) 100vw, 50vw" width="1200" height="600" alt="Hero" loading="lazy" decoding="async">
</picture>
```
- **Above‑fold image** – `loading="eager"` and `fetchpriority="high"`.
- **Batch conversion (Node)**
```bash
npm install sharp
```
```javascript
const sharp = require('sharp');
const fs = require('fs');
const path = require('path');
async function convert(file) {
  const name = path.basename(file, path.extname(file));
  await sharp(file).avif({quality:70}).toFile(`./opt/${name}.avif`);
  await sharp(file).webp({quality:80}).toFile(`./opt/${name}.webp`);
  await sharp(file).jpeg({quality:80, progressive:true}).toFile(`./opt/${name}.jpg`);
}
fs.readdirSync('./images').forEach(f=>convert(`./images/${f}`));
```

## Font Optimization
```css
@font-face {
  font-family: 'Custom';
  src: url('/fonts/custom.woff2') format('woff2');
  font-display: swap; /* or optional for non‑critical fonts */
  unicode-range: U+0000-00FF; /* subset */
}
```
- Preload critical fonts:
```html
<link rel="preload" href="/fonts/heading.woff2" as="font" type="font/woff2" crossorigin>
```
- Use variable fonts to replace multiple weight files.

## JavaScript Optimization
- **Code splitting** (dynamic `import` or framework‑specific lazy loading).
- **Tree shaking** – import only needed functions.
```javascript
// Bad
import _ from 'lodash';
_.debounce(fn,300);
// Good
import debounce from 'lodash/debounce';
```
- **Defer/async** scripts as shown earlier.
- **Break long tasks** into smaller chunks or use a Web Worker.
- **Debounce** scroll/resize handlers.
```javascript
function debounce(fn, d){let t;return(...a)=>{clearTimeout(t);t=setTimeout(()=>fn(...a),d);};}
window.addEventListener('scroll', debounce(handleScroll,100));
```
- **Use `requestAnimationFrame`** for visual updates.
- **Virtualize long lists** (e.g., `react-window`).

## Caching Strategy
```http
# HTML (no cache)
Cache-Control: no-cache, must-revalidate

# Static assets with hash (immutable)
Cache-Control: public, max-age=31536000, immutable

# Static assets without hash
Cache-Control: public, max-age=86400, stale-while-revalidate=604800
```
- Service worker simple cache‑first for images, CSS, JS:
```javascript
self.addEventListener('fetch', e => {
  if (['image','style','script'].includes(e.request.destination)) {
    e.respondWith(caches.match(e.request).then(r => r || fetch(e.request).then(resp => {
      const copy = resp.clone();
      caches.open('static-v1').then(c => c.put(e.request, copy));
      return resp;
    })));
  }
});
```

## Runtime Performance Tips
- **Avoid layout thrashing** – batch reads then writes.
```javascript
// Bad
elements.forEach(el => { const h = el.offsetHeight; el.style.height = h+10+'px'; });
// Good
const heights = elements.map(el => el.offsetHeight);
elements.forEach((el,i)=>{ el.style.height = heights[i]+10+'px'; });
```
- **Use `requestIdleCallback`** for analytics or non‑essential work.
- **Keep main‑thread work < 50 ms per task**.
- **Prefer CSS `contain` and `content-visibility: auto`** for off‑screen elements.

## Third‑Party Script Management
- Load asynchronously or after user interaction.
```html
<script async src="https://analytics.example.com/track.js"></script>
```
- Facade pattern for embeds:
```html
<div class="yt-facade" data-id="abc123" onclick="loadYT(this)">
  <img src="/thumbs/abc123.jpg" alt="Video">
  <button aria-label="Play video">▶</button>
</div>
<script>
function loadYT(el){
  const id = el.dataset.id;
  const iframe = document.createElement('iframe');
  iframe.src = `https://www.youtube.com/embed/${id}`;
  iframe.width = '560'; iframe.height = '315';
  el.replaceWith(iframe);
}
</script>
```

## Verification
1. Re‑run Lighthouse (`npx lighthouse <url> --output html --output-path report.html`).
2. Compare metric table before vs. after.
3. Deploy to a staging environment and collect field data via the `web-vitals` library or Search Console Core Web Vitals report.

## Consolidated Checklist
- **Server**: TTFB < 800 ms, compression enabled, HTTP/2/3.
- **Critical Rendering**: Inline critical CSS, defer non‑critical CSS/JS, preload LCP image and critical fonts.
- **LCP**: Hero image preloaded, optimized format, correct dimensions, present in initial HTML.
- **INP/FID**: No task > 50 ms, handlers < 100 ms, use `requestIdleCallback`/Web Workers, lazy‑load third‑party scripts.
- **CLS**: All media have width/height or `aspect-ratio`, reserve space for ads/iframes, fonts use `font-display: optional`, animate with `transform`.
- **Images**: AVIF/WebP, responsive `srcset`, lazy load below‑fold, size < 200 KB each.
- **Fonts**: `font-display: swap|optional`, preload critical, use variable fonts.
- **JavaScript**: Bundle < 300 KB gzipped, code‑split, tree‑shake, defer/async, avoid long tasks.
- **CSS**: Critical CSS inlined, unused CSS removed, minified.
- **Caching**: Proper `Cache-Control` headers, service worker cache‑first for static assets.
- **Third‑Party**: Async or lazy‑loaded, use facades for embeds.
- **Monitoring**: Lighthouse CI, RUM (web‑vitals), CrUX, analytics events.

## Related skills

Load these when the task spans more than this skill.

- [`frontend-development`](../frontend-development/SKILL.md) — Frontend Development skill for building modern React/Next.js applications with TypeScript, MUI, TanStack Query…
- [`performance`](../performance/SKILL.md) — Analyzes web performance using Chrome DevTools MCP. Measures Core Web Vitals (LCP, INP, CLS) and supplementary…
- [`web-quality-audit`](../web-quality-audit/SKILL.md) — Runs a full web quality audit that checks performance (Core Web Vitals, resource loading), accessibility, SEO,…
- [`nextjs`](../nextjs/SKILL.md) — Guidelines for building Next.js 14+ applications with the App Router. Includes component type decisions, data…
- [`vercel`](../vercel/SKILL.md) — Deploy and optimize applications on Vercel. Use for tasks involving 'vercel', 'deploy', 'hosting', or 'product…
- [`astro`](../astro/SKILL.md) — Astro is a web framework for content‑heavy sites that ships zero JavaScript by default and hydrates interactiv…
- [`playwright`](../playwright/SKILL.md) — Playwright skill for building reliable end‑to‑end test suites and browser automation. Use it to set up Playwri…
