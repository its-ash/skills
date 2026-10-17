# Browser Support and Progressive Enhancement

Read when deciding whether a CSS feature is safe to ship, writing `@supports` fallbacks, handling browser bugs, or planning polyfills.

## Rules
- Use Baseline as the default bar. "Newly available" means it works in the latest Chrome, Edge, Firefox, and Safari. "Widely available" means it has done so for 30 months.
- Build in layers: a working base for every browser, then enhancement inside `@supports` or through CSS's own forgiveness (unknown declarations are ignored).
- Put the fallback declaration first, then the modern one: `height: 100vh; height: 100dvh;`.
- Use feature queries, not browser sniffing or user-agent hacks.
- A missing enhancement must never hide content or block interaction. Example: scroll-reveal animations must start visible when unsupported.
- Remove fallbacks once your browserslist target covers the feature. Document the target in the repo.
- Evergreen does not mean every user has the latest version. Safari ships with OS updates and lags; enterprise Chrome can be pinned.

## Feature queries
```css
@supports (container-type: inline-size) { … }
@supports not (anchor-name: --a) { .menu { inset-block-start: 100%; } }
@supports selector(:has(*)) { … }
@supports (animation-timeline: view()) {
  @media (prefers-reduced-motion: no-preference) { … }   /* combine by nesting */
}
@supports font-tech(color-COLRv1) { … }
@supports font-format(woff2) { … }
```
- `@supports at-rule(@starting-style)` is in the spec but has limited support. Do not depend on it.
- `@supports` tests properties, values, selectors, and font tech, not media features. Combine with `@media` by nesting.
- Test the exact value you use: `@supports (display: grid-lanes)`, `@supports (width: stretch)`.
- For functions, test them in a property that accepts them: `@supports (color: contrast-color(red))`, `@supports (width: calc-size(auto, size))`, `@supports (animation-delay: calc(sibling-index() * 1ms))`.
- Value-level fallback without `@supports`: declare twice. The browser keeps the last declaration it understands.
- Selector lists: one unsupported selector drops the whole rule. Use a separate rule, or wrap in `:is()`/`:where()` (forgiving lists).
- `@when` / `@else` are proposed only; do not use them.
- JS: `CSS.supports('anchor-name', '--a')`, `CSS.supports('selector(:popover-open)')`.

## Status snapshot (October 2026)

**Baseline (safe to use):** Grid, subgrid, flex `gap`, `aspect-ratio`, container size queries and units, `:has()`, `:is()`/`:where()`, `@layer`, native nesting, `:focus-visible`, `:user-valid`/`:user-invalid`, logical properties, `dvh`/`svh`/`lvh`, media range syntax, `clamp()`/`min()`/`max()`, trig and `round()`/`mod()`, `oklch()`/`oklab()`/`color()`, `color-mix()`, relative color syntax, `light-dark()`, `@property`, `linear()` easing, individual transforms, `@starting-style`, `transition-behavior: allow-discrete`, `text-wrap: balance`, `<dialog>`, `popover`, exclusive `<details name>`, `inert`, `content-visibility`, `fetchpriority`, `@scope`, same-document view transitions, `contrast-color()`, `shape()`, `text-box` trim, `sibling-index()`/`sibling-count()` (with Firefox 154).

**Partly supported (enhancement with fallback):**
| Feature | Where (per sources) | Fallback |
|---|---|---|
| Anchor positioning | Chrome 125+, Safari 26+ | Absolute positioning under the trigger |
| Scroll-driven animations | Chromium 115+, Safari 26 | Static, visible content |
| Cross-document view transitions | Chrome 126+, Safari 18.2+ | Normal navigation |
| Container style queries | Chromium, Safari 18+ | Classes or attributes |
| Scroll-state queries | Chromium (133+) | JS `IntersectionObserver` |
| `text-wrap: pretty` | Chrome 117+, Safari 26 | Normal wrapping |
| `field-sizing: content` | Chrome 123+, Firefox 152 | Fixed sizes / JS autosize |
| `interpolate-size` / `calc-size()` | Chromium | Instant change or grid `0fr → 1fr` |
| Customizable `<select>` | Chrome 135+ | Native select |
| `::scroll-button()` / `::scroll-marker` | Chrome 135+ | Plain scroller or JS buttons |
| `if()`, `@function` | Chromium | Static values / build-time functions |
| Typed `attr()` | Chromium | Custom properties set inline |
| `corner-shape` | Chrome 139+ | Normal `border-radius` |
| `background-clip: border-area` | Safari, Chrome 150 | Two-layer background trick |
| Gap decorations (`row-rule`, `column-rule` in grid/flex) | Chrome/Edge 149 | Borders or no lines |
| `column-wrap`/`column-height` | Chrome 145 | Normal columns |
| `light-dark()` with images | Chrome 148, Firefox 150 | `<picture>` + `prefers-color-scheme` |
| Name-only container queries | Chrome 148, Firefox 149, Safari 26.4 | Class-based scoping |
| `random()` | Safari 26.2 | Static values |

**Experimental (do not depend on):** `display: grid-lanes` masonry, `flex-wrap: balance`, `border-shape`, `text-fit`/`text-grow`, interest invokers (`interestfor`), `reading-flow`, `ident()`, `@when`.

Verify current numbers on caniuse.com, MDN browser-compat data, or webstatus.dev before shipping. Release numbers above come from the source articles.

## Polyfills
- Prefer polyfills that defer to native support and are removable (they check `CSS.supports` first).
- Common ones: anchor positioning (`@oddbird/css-anchor-positioning`), scroll-driven animations (`scroll-timeline` polyfill), `inert` (old Safari), `dialog-polyfill` (only for very old browsers).
- CSS polyfills that parse stylesheets in JS cause a flash of unstyled content and cost INP. Load them only when the feature is missing.
- Some features cannot be polyfilled well (`:has()`, container queries without layout cost, `sibling-index()`). Design a non-feature layout instead.

## Known quirks
- iOS Safari: `100vh` includes the area under the toolbar (use `dvh`/`svh`). Inputs under 16px font zoom the page. `background-attachment: fixed` is ignored.
- Safari: `list-style: none` removes list semantics in VoiceOver. `<details>` summary markers need `::-webkit-details-marker`. Customized built-in elements (`is=`) are not supported.
- Chrome: non-integer `text-decoration-thickness` can round down. Setting standard `scrollbar-color`/`scrollbar-width` disables `::-webkit-scrollbar` styles.
- Firefox: `:host-context()` is unsupported.
- `overflow` on replaced elements (`img`, `video`) is respected only from Chrome 108. Older versions always clipped.
- `position: sticky` fails inside any ancestor with `overflow` other than `visible`/`clip`.
- Chrome's Auto Dark Theme for Android can recolor sites that do not declare `color-scheme`. Declare `color-scheme` (and real dark styles) to opt out.

## Testing
- Test in real Safari (macOS and iOS via the simulator or a device with Web Inspector), Firefox, and Chromium.
- Force fallbacks: temporarily misspell the `@supports` condition, or use DevTools to disable the feature (Chrome flags, Firefox `about:config`).
- Run Interop-focused checks for features in Interop 2026 (`shape()`, view transitions, `sibling-index()`, anchor positioning) to watch for behavior differences.

## Gotchas
- `@supports` with a valid-looking but wrong syntax returns false silently. Test the exact form you ship.
- Old browsers that do not understand `@supports` ignore the whole block. That is the fallback path, so keep base styles outside.
- `@layer` is not understood by pre-2022 browsers; they drop all layered rules. Keep a pre-layer fallback only if you must support them.
- `-webkit-` prefixes still needed: `-webkit-line-clamp` (with `display: -webkit-box`), `-webkit-text-stroke`, `-webkit-text-size-adjust`, `-webkit-backdrop-filter` for Safari before 18, and `-webkit-mask` for Safari before 15.4.
