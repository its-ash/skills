# Performance

Read when optimizing CSS delivery, rendering cost, animation smoothness, fonts, images, or Core Web Vitals (LCP, CLS, INP).

## Rules
- Targets (75th percentile): LCP ≤ 2.5s, CLS ≤ 0.1, INP ≤ 200ms. Measure field data (CrUX, `web-vitals`) as well as lab tools.
- CSS blocks rendering. Keep the critical path small: one main stylesheet in `<head>`, no `@import` chains, and inline critical CSS only for the above-the-fold layout when it is measurably faster.
- Give the LCP image `fetchpriority="high"` and no `loading="lazy"`. Lazy-load below-the-fold images and iframes with `loading="lazy"`.
- Always set `width`/`height` (or `aspect-ratio`) on images, video, iframes, and ad slots to prevent CLS.
- Use `content-visibility: auto` + `contain-intrinsic-size: auto <estimate>` on long, off-screen sections.
- Animate only compositor-friendly properties (`transform`, `opacity`). Add `will-change` briefly, not globally.
- Self-host subset WOFF2, preload at most 1-2 critical fonts, and use `font-display: swap` or `optional` with metric-matched fallbacks.
- Remove unused CSS with build tools (Tailwind's class scanning, PurgeCSS, Lightning CSS). Safelist classes added at runtime.
- Prefer CSS over JS for UI behavior (popover, dialog, `:has()`, scroll-driven animation). Less JS gives better INP.

## Delivering CSS
```html
<link rel="stylesheet" href="/app.css">                         <!-- critical, render-blocking -->
<link rel="stylesheet" href="/print.css" media="print">          <!-- non-matching media: low priority, non-blocking -->
<link rel="preload" href="/below.css" as="style" onload="this.rel='stylesheet'">
<noscript><link rel="stylesheet" href="/below.css"></noscript>
```
- `@import` inside CSS creates serial requests. Bundle at build time.
- Split CSS by route or component when the full bundle is large. HTTP/2 makes several small files cheap.
- Use content-hashed filenames with long `Cache-Control: max-age=31536000, immutable`.
- `<link rel="preconnect" href="https://cdn.example.com" crossorigin>` for critical third-party origins.

## Resource priority
- `fetchpriority="high|low|auto"` on `<img>`, `<link rel="preload">`, `<script>`, and `fetch()`. Baseline since 2024. The old `importance` attribute is obsolete.
- Lower priority for carousels' hidden slides and below-fold hero variants: `fetchpriority="low"`.
- Preload only resources discovered late (fonts from CSS, LCP background images). Too many preloads compete with critical requests.
- Use `<link rel="modulepreload">` for critical JS modules. Use `defer` for app scripts and `async` for independent third-party scripts.

## Rendering cost
```css
.feed-section { content-visibility: auto; contain-intrinsic-size: auto 800px; }
.widget { contain: layout paint; }   /* isolate layout and paint */
```
- `content-visibility: auto` skips layout and paint of off-screen content and keeps it in the a11y tree and find-in-page. Baseline since 2024.
- `contain-intrinsic-size: auto 800px` reserves an estimate and then remembers the real size after first render, which prevents scrollbar jumps.
- `contain: strict` (size + layout + paint + style) needs explicit dimensions or the box collapses. Prefer `contain: layout paint` or `content`.
- Avoid layout thrashing in JS: batch reads (`getBoundingClientRect`) before writes, and use `requestAnimationFrame` for visual updates.
- Large `box-shadow`, `filter: blur()`, and `backdrop-filter` are paint-heavy. Avoid animating them and limit their area.
- Very broad selectors are rarely a real problem. Big DOMs (over about 1,500 nodes) and frequent style invalidation (changing a class on `<body>`, global custom property updates) cost more.

## Animation performance
- Compositor-only: `transform`, `opacity`, and (in most engines) `filter`. Everything else runs on the main thread each frame.
- `will-change: transform` promotes a layer. Too many layers waste GPU memory. Add it on `:hover`/`pointerenter` of the parent or right before a JS animation, and remove it after.
- Scroll-driven CSS animations run off the main thread, unlike scroll listeners. For listeners, use `{ passive: true }`.
- Pause off-screen loops with `animation-play-state` toggled by `IntersectionObserver`, or rely on `content-visibility`.

## Images
- Formats: AVIF > WebP > JPEG for photos; SVG for vector; PNG only for lossless needs.
- Use `srcset` + `sizes` so phones do not download desktop images.
- `decoding="async"` on non-critical images.
- Do not lazy-load the LCP image. Do not set the LCP image as a CSS background (the preload scanner finds `<img>` sooner); if you must, preload it.
- Replace animated GIFs with `<video autoplay muted loop playsinline>` (much smaller).
- Facade heavy embeds (YouTube, maps): show a static preview and load the iframe on click.

## Fonts
- WOFF2 only. Subset with `unicode-range` and tools like glyphhanger or fonttools.
- One variable font file often replaces 4-6 static files.
- `font-display: optional` + preload removes font-swap CLS. `swap` + `size-adjust` fallback metrics minimizes it.
- System font stacks have zero cost.

## CLS checklist
- Reserve space for images, embeds, ads, and late UI (cookie banners as overlays, not pushed-in content).
- Use `transform` animations instead of animating `top`/`height` on content.
- `scrollbar-gutter: stable` stops layout jumps when scrollbars appear.
- Avoid inserting content above existing content after load unless it follows a user action.

## INP checklist
- Break long tasks (over 50ms): `await scheduler.yield()` (fallback: `setTimeout`), and move heavy work to Web Workers.
- Give instant visual feedback (CSS `:active` states, optimistic UI) before expensive work.
- Debounce input handlers. Avoid forced synchronous layout in event handlers.

## Caching and service workers
- Service workers: cache-first for hashed static assets, network-first (or stale-while-revalidate) for HTML and API. Version caches and delete old ones on `activate`.
- `bfcache`: avoid `unload` handlers and `Cache-Control: no-store` on HTML, so back/forward navigations are instant.

## Measuring
- Chrome DevTools Performance panel (live CWV, LCP element, layout-shift regions), Coverage panel for unused CSS and JS, Lighthouse, and WebPageTest.
- `PerformanceObserver` for `largest-contentful-paint`, `layout-shift`, `event` entries, or the `web-vitals` library.

## Gotchas
- `content-visibility: auto` without `contain-intrinsic-size` causes scrollbar jumps.
- `content-visibility: hidden` keeps rendering state but hides content from AT and find-in-page; `auto` does not.
- Lazy-loading images above the fold delays LCP.
- `media="print" onload` tricks need a `<noscript>` fallback.
- Purging CSS removes classes built with string concatenation. Write full class names in source.
