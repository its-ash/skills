# Layout

Read when building page or component layout: Flexbox, Grid, subgrid, masonry, multi-column, positioning, sizing, centering, stacking, overflow.

## Rules
- Pick Grid for two-dimensional layout (rows and columns together); pick Flexbox for one-dimensional flow (a row of buttons, a wrapping tag list).
- Use `gap` for spacing between flex/grid/multi-column items. Do not use margins on children for gutters.
- Use `minmax(0, 1fr)` (not bare `1fr`) when a track must shrink below its content's min-content width (long words, `<pre>`, wide images).
- Use logical properties (`margin-inline`, `padding-block`, `inset-inline-start`, `inline-size`) so layouts work in RTL and vertical writing modes.
- Do not change visual order with `order`, `row-reverse`, or `grid-auto-flow: dense` when the content is interactive. Keyboard focus follows DOM order.
- Set `min-width: 0` (or `min-inline-size: 0`) on flex items that hold long text or nested scrollers. The default `min-width: auto` prevents shrinking.
- Use `aspect-ratio` to reserve media and card space. Explicit `width` + `height` on both axes overrides it.
- Create a stacking context on purpose with `isolation: isolate`. Do not escalate `z-index` values.
- `position: sticky` needs an inset (`top: 0`) and fails when any ancestor between the element and the scroller has `overflow: hidden|auto|scroll`. Use `overflow: clip` on such ancestors when you only need clipping.
- Prefer `overflow: clip` over `overflow: hidden` when you need clipping without a scroll container.
- Use `display: contents` carefully: it removes the box, so the element loses backgrounds, borders, and padding. Do not use it on buttons or other interactive elements.

## Flexbox
```css
.row   { display: flex; flex-wrap: wrap; gap: 1rem; align-items: center; }
.grow  { flex: 1; }            /* 1 1 0%: share free space equally */
.fixed { flex: 0 0 15rem; }    /* no grow, no shrink, 15rem basis */
.push  { margin-inline-start: auto; } /* push item (and following) to the end */
```
- `flex: 1` sets `flex-basis: 0`, so items become equal width regardless of content. `flex: auto` keeps content-based sizes.
- Wrap-then-fill without media queries: `flex: 1 1 20rem` on items in a wrapping container.
- `justify-content: space-between` on a wrapping row leaves a gap in the last line; use Grid `auto-fill` for even columns instead.
- `flex-wrap: balance` is an experimental Chrome value that balances lines like `text-wrap: balance`. Treat it as enhancement only.

## Grid
```css
.cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(min(100%, 16rem), 1fr));
  gap: 1rem;
}
```
- `auto-fill` keeps empty tracks; `auto-fit` collapses them, so few items stretch to fill the row.
- Wrap the minimum in `min(100%, …)` so a single column never overflows narrow containers.
- Named areas for page shells:
```css
.page {
  display: grid;
  grid-template: "head head" auto "side main" 1fr "foot foot" auto / 15rem minmax(0, 1fr);
  min-block-size: 100dvh;
}
.page > header { grid-area: head; }
```
- Stack layers without absolute positioning: give every child `grid-area: 1 / 1` (or one named area). The container sizes to the largest child.
- Full-bleed rows in a centered column:
```css
.content { display: grid; grid-template-columns: [full-start] minmax(1rem, 1fr) [content-start] min(65ch, 100% - 2rem) [content-end] minmax(1rem, 1fr) [full-end]; }
.content > * { grid-column: content; }
.content > .bleed { grid-column: full; }
```
  This avoids the `100vw` + negative-margin hack, which overflows when a vertical scrollbar shows.

### Subgrid
```css
.card { display: grid; grid-row: span 3; grid-template-rows: subgrid; }
```
- Use subgrid to align titles, bodies, and footers across sibling cards. Baseline since 2023 (Chrome 117, Firefox 71, Safari 16).

### Masonry (`grid-lanes`)
```css
@supports (display: grid-lanes) {
  .wall { display: grid-lanes; grid-template-columns: repeat(auto-fill, minmax(14rem, 1fr)); gap: 1rem; }
}
```
- Native masonry is now spelled `display: grid-lanes`. Support is experimental; detect with `@supports` and fall back to a regular grid or multi-column.

### Gap decorations
```css
.grid { column-rule: 1px solid var(--line); row-rule: 1px solid var(--line); row-rule-inset: 4px; }
```
- `row-rule`, `column-rule`, and their `-inset`, `-break`, `-outset` longhands and `gap-rule-paint-order` draw separators in flex, grid, and multi-column gaps. Chrome/Edge 149+. Without support you get no lines, so use them as enhancement.

## Multi-column
```css
.cols { columns: 18rem; column-gap: 2rem; column-rule: 1px solid var(--line); }
.cols > * { break-inside: avoid; }
.cols h2 { column-span: all; }
```
- `column-height` + `column-wrap: wrap` (Chrome 145+) wraps overflow columns into a new row below, which gives vertical scrolling instead of horizontal overflow.

## Sizing keywords
- `min-content`, `max-content`, `fit-content` / `fit-content(20rem)` for intrinsic sizing.
- `width: stretch` fills the containing block while respecting margins (unlike `100%`, which ignores margins and can overflow). Chromium has shipped it; keep `-webkit-fill-available` / `-moz-available` fallbacks.
- `interpolate-size: allow-keywords` on `:root` lets transitions animate to and from `auto`, `min-content`, `stretch` (Chromium).

## Centering
```css
.center-grid { display: grid; place-items: center; }
.center-flex { display: flex; justify-content: center; align-items: center; }
.center-abs  { position: absolute; inset: 0; margin: auto; inline-size: fit-content; block-size: fit-content; }
.center-block { align-content: center; } /* block containers, no flex/grid needed (Baseline 2024) */
```
- Use `safe` alignment (`align-items: safe center`) so overflowing content does not get cut off at the start edge.
- For perfect optical centering of text, trim font leading with `text-box: trim-both cap alphabetic` (see typography).

## Positioning
- `inset: 0` is shorthand for `top/right/bottom/left: 0`.
- An absolutely positioned element is positioned against the nearest ancestor with `position` other than `static`, or with `transform`, `filter`, `contain: layout|paint`, or `container-type`.
- `position: fixed` is relative to the viewport, except inside an ancestor with `transform`, `filter`, `perspective`, `contain`, or `will-change: transform`. Those ancestors become the containing block.
- For popups and tooltips, use anchor positioning (see components-ui).

## Stacking contexts
- New stacking context: `position` + `z-index` other than `auto`, `opacity < 1`, `transform`, `filter`, `mix-blend-mode`, `isolation: isolate`, `contain: paint`, `will-change` on those properties, flex/grid children with `z-index`.
- `z-index` only competes inside the same stacking context. A child cannot escape a parent context with a higher number.
- Keep a small z-index token scale (`--z-dropdown: 10; --z-modal: 100;`). For dialogs and popovers, use the top layer (`showModal()`, `popover`) instead of z-index.

## Overflow
- `overflow: auto` shows scrollbars only when needed.
- `overflow: clip` clips without creating a scroll container. Pair it with `overflow-clip-margin` to let shadows bleed.
- `scrollbar-gutter: stable` reserves scrollbar space so layout does not shift when content starts to scroll.
- `overscroll-behavior: contain` on a scroller stops scroll chaining to the page (modals, side panels).

## Gotchas
- Percent heights need a parent with a definite height. In grid/flex, stretched items count as definite.
- `100vh` on mobile includes the area behind browser UI; use `100dvh` (dynamic) or `100svh` (small).
- Margins collapse in block flow but never inside flex or grid containers.
- `gap` does not apply to block flow. Use `> * + *` (lobotomized owl) or flex column with `gap`.
- `grid-auto-flow: dense` fills holes but breaks reading and focus order.
- `transform` on an ancestor breaks `position: fixed` and `position: sticky` expectations.
