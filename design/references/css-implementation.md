# CSS Implementation

Section §25 of [`design`](../SKILL.md). Apply the core rules always; read the matching `css/` file before non-trivial work; check [css/browser-support.md](css/browser-support.md) for partial features.

## 25.B Core Rules

1. Native first: `<dialog>`, `popover`, `<details name>`, `:has()`, anchor positioning, scroll-driven animation, view transitions.
2. `@layer reset, base, components, utilities;` one-class selectors, `:where()` resets, no ID styling, `!important` only in utilities.
3. Grid 2D, Flex 1D, `gap` not margins. Intrinsic layouts (`repeat(auto-fill, minmax(min(100%, 16rem), 1fr))`, `clamp()`); container queries for components.
4. Logical properties. `rem` + fluid `clamp()` type, ~65ch, unitless line-height. `dvh`/`svh`, never `100vw`.
5. Role-named token custom properties; theme by swapping semantic tokens. `oklch()`, relative color / `color-mix()`, `color-scheme` + `light-dark()`.
6. Contrast 4.5:1 (3:1 large/UI); `:focus-visible` always; targets 24px (44 touch). DOM order = visual order.
7. Animate `transform`/`opacity`/`translate`/`rotate`/`scale`, 150-300ms, movement in `prefers-reduced-motion: no-preference`. `@starting-style` + `allow-discrete` for entry/exit; `@property` before animating vars.
8. Reserve media space (`aspect-ratio`, `contain-intrinsic-size`); LCP image `fetchpriority="high"`, never lazy; lazy below fold; `content-visibility: auto` for long sections.
9. Self-host subset WOFF2, preload <= 2, metric-matched fallback.
10. Enhancements behind `@supports` or value fallbacks; missing features never hide content.
11. Inline SVG with `currentColor`; `aria-hidden` decorative, `role="img"` + `<title>` meaningful.
12. Never `innerHTML` untrusted strings; pass values via `setProperty('--x', v)`; state via attributes.
13. Gate hover with `@media (hover: hover)`; every hover has focus/tap equivalents.

## 25.C Decision Guide

| Need | Use | Avoid |
|---|---|---|
| Wrapping card grid / row alignment | `auto-fill minmax()` / `subgrid` | Breakpoint columns, JS equalizers |
| Masonry | `grid-lanes` in `@supports` | JS-only masonry |
| Slot-aware component | Container queries + `cqi` | Viewport media queries |
| Full-bleed row | Named grid lines | `100vw` + negative margins |
| Parent by child | `:has()` | JS class toggles |
| Third-party / scoped CSS | `layer(vendor)` / `@scope` | Specificity wars |
| State colors / dynamic text color | `oklch(from ...)`, `color-mix()` / `contrast-color()` | Hex per state, hard white |
| Modal / menu / tooltip | `<dialog>` / `popover` + anchor positioning | Custom traps, JS coords |
| Accordion / textarea / select | `<details name>` / `field-sizing: content` / `appearance: base-select` | ARIA rebuilds, JS sizing, div selects |
| Carousel | Scroll snap + `::scroll-button()` | JS sliders, unpausable autoplay |
| Animate to `auto` | `interpolate-size` or grid `0fr -> 1fr` | JS measuring |
| Scroll / page transitions | `animation-timeline` / View Transitions | Scroll listeners, manual FLIP |
| Spring easing | `linear()` | JS physics for simple UI |
| Gradient border with radius | `padding-box`/`border-box` layers | `border-image` |
| Text balance / optical centering | `text-wrap: balance` / `text-box: trim-both` | `<br>`, magic padding |
| Stagger | `sibling-index()` (`--i` fallback) | `:nth-child` lists |
| Tokens / styling | DTCG -> Style Dictionary; Tailwind v4, CSS Modules | Hard-coded values, runtime CSS-in-JS |

## 25.D Topic Files (`css/`)

| Topic | File |
|---|---|
| Flex, Grid, positioning | [layout.md](css/layout.md) |
| Queries, fluid, units | [responsive.md](css/responsive.md) |
| `@layer`, `@scope`, `:has()` | [selectors-cascade.md](css/selectors-cascade.md) |
| `@property`, math, `if()` | [custom-properties-math.md](css/custom-properties-math.md) |
| OKLCH, dark mode | [color.md](css/color.md) |
| Gradients, shadows, masks | [visual-effects.md](css/visual-effects.md) |
| Fonts, scales | [typography.md](css/typography.md) |
| Transitions, scroll-driven, view transitions | [animation-motion.md](css/animation-motion.md) |
| Forms, dialog, popover, carousel | [components-ui.md](css/components-ui.md) |
| SVG | [svg.md](css/svg.md) |
| Accessibility | [accessibility.md](css/accessibility.md) |
| Performance | [performance.md](css/performance.md) |
| Tokens, Tailwind, linting | [architecture-tooling.md](css/architecture-tooling.md) |
| DOM, web components | [frontend-js.md](css/frontend-js.md) |
| Baseline (Oct 2026) | [browser-support.md](css/browser-support.md) |

## 25.E CSS Pre-Flight

- [ ] Fallbacks work; keyboard + visible focus; DOM order = visual order
- [ ] Contrast in light, dark, forced-colors; reduced motion respected
- [ ] Holds at 320px and 200% zoom; no CLS; LCP not lazy
- [ ] Tokens over hard-coded values; flat selectors
