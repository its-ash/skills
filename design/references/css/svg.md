# SVG

Read when embedding, styling, animating, or optimizing SVG: icons, sprites, illustrations, filters, patterns, and charts.

## Rules
- Inline SVG when CSS must style its parts or it must react to hover, focus, or theme. Use `<img src="x.svg">` for static artwork (cached, no DOM cost).
- Always keep `viewBox`. Remove fixed `width`/`height` from the file, or override them in CSS for scaling.
- Use `fill="currentColor"` / `stroke="currentColor"` so icons follow text color.
- Size icons in `em` so they follow text: `.icon { inline-size: 1em; block-size: 1em; }`.
- Mark decorative SVG `aria-hidden="true" focusable="false"`. Give meaningful SVG `role="img"` + `<title>` (or `aria-label`).
- Reuse with `<symbol>` + `<use href="#id">`. `xlink:href` is legacy.
- Optimize with SVGO. Keep `viewBox`, and keep IDs that CSS or JS targets.
- Prefer CSS animation of SVG transforms and properties. Keep SMIL for attribute animation that CSS cannot do (for example path `d` morphing in older engines).

## Embedding
| Method | CSS from page | Caching | Scripts | Use for |
|---|---|---|---|---|
| Inline `<svg>` | Yes | No | Yes | Icons, interactive art, charts |
| `<img>` / CSS `background` | No | Yes | No | Logos, illustrations |
| `<use href="sprite.svg#icon">` | Inherited only (`currentColor`, custom properties) | Yes | No | Icon systems |
| CSS `mask: url(icon.svg)` + `background: currentColor` | Color only | Yes | No | Single-color icons from files |
| `<object>` | No (own document) | Yes | Yes | Rare legacy cases |

- External sprite `<use>` must be same-origin.
- SVG in `<img>` runs no scripts and loads no external resources. It can still use its own `<style>` with media queries (for example dark mode).

## Icon system
```html
<svg hidden><symbol id="i-search" viewBox="0 0 24 24"><path d="…"/></symbol></svg>
<svg class="icon" aria-hidden="true" focusable="false"><use href="#i-search"/></svg>
```
```css
.icon { inline-size: 1em; block-size: 1em; fill: none; stroke: currentColor; stroke-width: 2; vertical-align: -0.125em; }
```
- Content inside `<use>` is a closed shadow tree. Style it through inherited properties (`fill`, `stroke`, `color`) and custom properties (`fill: var(--icon-accent, currentColor)` inside the symbol).

## Styling with CSS
- Presentation attributes (`fill="red"`) have the lowest priority; any CSS rule beats them. Inline `style=""` in the SVG beats page CSS.
- CSS-styleable geometry: `cx`, `cy`, `r`, `rx`, `ry`, `x`, `y`, `width`, `height`, and `d: path("…")` (Chromium, Firefox) can be set and transitioned in CSS.
- `transform-box: fill-box; transform-origin: center;` makes transforms rotate around the shape itself, not the SVG origin.
- `vector-effect: non-scaling-stroke` keeps stroke width steady when the SVG scales.
- `paint-order: stroke` draws stroke behind fill (outlined text without eating glyphs).

## Strokes and line drawing
```css
.draw { stroke-dasharray: 1; stroke-dashoffset: 1; animation: draw 2s ease forwards; }
@keyframes draw { to { stroke-dashoffset: 0; } }
```
```html
<path class="draw" pathLength="1" d="…"/>
```
- `pathLength="1"` normalizes dash values, so you do not need to measure path length in JS.
- `stroke-linecap: round`, `stroke-linejoin: round`. `stroke-miterlimit` caps sharp miter spikes.
- `stroke-dasharray` with an odd number of values repeats the list to make it even.

## Masks, clip paths, patterns
- `<clipPath clipPathUnits="objectBoundingBox">` with 0-1 coordinates gives a responsive clip for HTML via `clip-path: url(#c)`.
- In `<mask>`, luminance controls visibility: white shows, black hides, gray is partly transparent.
- `<pattern>` for repeating fills. For page backgrounds, a CSS gradient or a small SVG data URI is usually lighter.
- Data URI in CSS: URL-encode `#` as `%23` and use single quotes inside the SVG: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' …")`.

## Filters
```html
<filter id="grain"><feTurbulence type="fractalNoise" baseFrequency=".8" numOctaves="3"/><feColorMatrix type="saturate" values="0"/></filter>
<filter id="goo"><feGaussianBlur stdDeviation="8"/><feColorMatrix values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 20 -8"/></filter>
```
- Apply to HTML with `filter: url(#goo)`. The filter element must be in the same document.
- Common primitives: `feTurbulence` (noise and textures), `feDisplacementMap` (warp and liquid), `feMorphology` (thicken and outline), `feComposite`, `feDropShadow`.
- Large filtered areas are expensive. Keep filter regions tight (`x`, `y`, `width`, `height` on `<filter>`).

## Animation
- CSS transitions and keyframes work on SVG `transform`, `opacity`, `fill`, `stroke`, `stroke-dashoffset`, and CSS-settable geometry.
- SMIL `<animate>`, `<animateTransform>`, and `<animateMotion>` work in all modern browsers and inside `<img>` SVGs, where CSS from the page cannot reach.
- For path morphing between different point counts, use GSAP MorphSVG or flubber. CSS `d` interpolation needs matching commands.

## Accessibility
```html
<svg role="img" aria-labelledby="t d" viewBox="0 0 100 100"><title id="t">Sales 2025</title><desc id="d">Bar chart, Q4 highest</desc>…</svg>
```
- Interactive SVG parts need real focusable elements (`<a href>` inside SVG, or HTML buttons overlaid). Do not add click handlers on `<path>` alone.
- For icon-only buttons, label the button (`aria-label="Search"`), and hide the SVG.
- In forced-colors mode, use `currentColor` or system colors so icons stay visible.

## Gotchas
- Missing `viewBox` means the SVG cannot scale. Setting only `width`/`height` crops it.
- Inline SVGs are `display: inline` and leave a baseline gap; set `display: block` or `vertical-align: middle`.
- Duplicate IDs across inline SVGs (gradients, clip paths, filters) collide. Make IDs unique per instance.
- A `fill` attribute on a child path blocks the `fill` inherited from `<svg>`. Remove hard-coded `fill` attributes (or set them to `currentColor`) in icon files.
- Fetch-and-inline scripts need CORS for cross-origin files. Cache the result.
