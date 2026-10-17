# Responsive

Read when a UI must adapt to viewport size, container size, input type, or user preferences.

## Rules
- Use intrinsic layout first (`auto-fill` + `minmax()`, flex wrap, `clamp()`). Add breakpoints only where the design actually breaks.
- Use container queries for components; use media queries for page-level layout and device/preference features.
- Write mobile-first: base styles, then `@media (width >= 48rem)` overrides.
- Use range syntax `(width >= 40rem)` and `(30rem <= width < 60rem)`. Baseline since 2023 (Safari 16.4).
- Write breakpoints in `rem`/`em` so they follow user font-size settings.
- Use `100dvh` / `100svh` instead of `100vh` for full-height mobile layouts.
- Do not use `100vw` for full-width elements. It includes the scrollbar and causes horizontal scroll. Use `100%` or a full-bleed grid.
- Keep `font-size` of form inputs at 16px or more to stop iOS Safari auto-zoom.
- Respect user preferences: `prefers-reduced-motion`, `prefers-color-scheme`, `prefers-contrast`, `forced-colors`.

## Media queries
```css
@media (width >= 48rem) { .layout { grid-template-columns: 16rem 1fr; } }
@media (hover: hover) and (pointer: fine) { .card:hover { translate: 0 -2px; } }
@media (pointer: coarse) { .btn { min-block-size: 44px; } }
@media (orientation: landscape) and (height < 30rem) { .hero { min-block-size: auto; } }
```
- Use `hover`/`pointer` to gate hover effects. Touch devices fire sticky `:hover` after a tap.
- `@custom-media --md (width >= 48rem);` is not native in browsers yet; use it only with PostCSS/Lightning CSS.

## Container queries
```css
.card-wrap { container: card / inline-size; }  /* name / type */
@container card (width >= 30rem) {
  .card { grid-template-columns: 10rem 1fr; }
}
```
- A container cannot query itself. Put `container-type` on a wrapper and style the children.
- `container-type: inline-size` applies inline-size containment: the container cannot size from its content in the inline axis. Do not set it on shrink-to-fit elements (inline-block, flex items with `flex: none`, absolutely positioned elements without width), or they collapse to zero.
- `container-type: size` is needed to query height and requires an explicit height.
- Without a name, `@container` matches the nearest ancestor container of the right type.
- Container units: `cqi`, `cqb`, `cqw`, `cqh`, `cqmin`, `cqmax`. Example: `font-size: clamp(1rem, 4cqi, 2rem)`.
- Name-only queries (`@container card { … }`, no condition) match when an ancestor has that container name. Chrome 148, Firefox 149, Safari 26.4. Use them to scope styles by context.
- Support: size queries Baseline 2023 (Chrome 105, Safari 16, Firefox 110).

### Style queries
```css
.theme { --variant: compact; }
@container style(--variant: compact) { .item { padding: .25rem; } }
@container style(--columns > 3) { .item { font-size: .875rem; } }  /* range syntax */
```
- Style queries test custom properties of the container (every element is a style container by default). Supported in Chromium and Safari 18+; check Firefox before relying on them.
- Range comparisons in style queries and `if()` work from Chrome 142.

### Scroll-state queries
```css
.header { container-type: scroll-state; position: sticky; top: 0; }
@container scroll-state(stuck: top) { .header-inner { box-shadow: var(--shadow); } }
@container scroll-state(snapped: x) { .slide-content { scale: 1.05; } }
@container scroll-state(scrollable: top) { .back-to-top { opacity: 1; } }
```
- Chromium only (from Chrome 133). Use as enhancement.

## Fluid sizing
```css
:root { --step-0: clamp(1rem, 0.9rem + 0.5vi, 1.25rem); }
h1 { font-size: clamp(2rem, 1.5rem + 2.5vi, 3.5rem); }
.section { padding-block: clamp(2rem, 6vi, 6rem); }
```
- Always mix `rem` into the preferred value (`1rem + 2vi`). Pure `vw` font sizes do not grow with browser zoom and fail WCAG 1.4.4.
- Use `vi` (viewport inline) over `vw` when the page may use vertical writing modes.

## Viewport units
- `svh/svw`: small viewport (browser UI shown). `lvh`: large viewport (UI hidden). `dvh`: dynamic, updates as UI shows and hides. Baseline 2022.
- `dvh` changes during scroll and can cause layout shifts. Prefer `svh` for hero sections.
- On-screen keyboards: `<meta name="viewport" content="width=device-width, initial-scale=1, interactive-widget=resizes-content">` makes the layout viewport shrink with the keyboard (Chromium).

## Responsive images
```html
<img src="card-800.jpg"
     srcset="card-400.jpg 400w, card-800.jpg 800w, card-1600.jpg 1600w"
     sizes="(width >= 60rem) 33vw, 100vw"
     width="800" height="500" alt="…" loading="lazy" decoding="async">

<picture>
  <source type="image/avif" srcset="hero.avif">
  <source type="image/webp" srcset="hero.webp">
  <img src="hero.jpg" width="1600" height="900" alt="…" fetchpriority="high">
</picture>
```
- Always set `width` and `height` attributes so the browser reserves space (CLS). Add `img { max-inline-size: 100%; block-size: auto; }`.
- `sizes="auto"` works only with `loading="lazy"` (Chromium).
- Art direction (different crops): `<source media="(width < 40rem)" srcset="crop-portrait.jpg">`.
- CSS backgrounds: `background-image: image-set(url(a.avif) type("image/avif"), url(a.jpg) type("image/jpeg"));` with a plain `url()` fallback declared before it.

## User preferences
```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after { animation-duration: 0.01ms !important; animation-iteration-count: 1 !important; transition-duration: 0.01ms !important; scroll-behavior: auto !important; }
}
@media (prefers-contrast: more) { :root { --border: CanvasText; } }
@media (forced-colors: active) { .btn { border: 1px solid ButtonText; } }
```
- `prefers-reduced-motion: reduce` covers transitions too. Include `transition-duration` in the override.
- In `forced-colors` mode (Windows High Contrast), backgrounds and box-shadows are removed. Use borders/outlines for essential shapes and system colors (`ButtonText`, `Highlight`, `CanvasText`).

## Gotchas
- `@media (width >= …)` measures the viewport including the scrollbar.
- Container queries on `inline-size` containers stop children from sizing the container intrinsically.
- `vh`-based heights can hide content under mobile browser bars.
- Hover-only UI (menus, tooltips) is unreachable on touch. Always provide a tap or focus path.
- `<source media>` in `<picture>` evaluates against the viewport, not the container.
