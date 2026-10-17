# Selectors and Cascade

Read when writing selectors, fighting specificity, structuring the cascade with `@layer`/`@scope`, using nesting, or writing resets.

## Rules
- Keep component selectors at one class (0,1,0). Do not style with IDs. Avoid chains like `.nav ul li a`.
- Declare layer order once, first in the entry stylesheet: `@layer reset, base, components, utilities;`.
- Later layers beat earlier layers regardless of specificity. Unlayered styles beat all layers. For `!important`, the order reverses (earlier layers win).
- Put third-party CSS into a low layer: `@import url(vendor.css) layer(vendor);`.
- Use `:where()` for zero-specificity defaults and resets. Use `:is()` to group; it takes the highest specificity of its arguments.
- Use `:has()` for parent and state selection instead of JS class toggling.
- Use `:focus-visible` for focus rings. Never remove outlines without a replacement.
- Use `:user-invalid` / `:user-valid` for form errors so fields do not look wrong before the user interacts.
- Use native nesting, but keep it to 2-3 levels. Native nesting cannot concatenate strings: `&__title` is invalid.
- Use `!important` only in utilities or to override inline/third-party styles, and preferably inside a layer.

## Specificity
- Counted as (IDs, classes/attributes/pseudo-classes, elements/pseudo-elements). `*`, combinators, and `:where()` add 0.
- `:is()`, `:not()`, `:has()`, and `:nth-child(… of S)` take the specificity of their most specific argument.
- `:root` is a pseudo-class (0,1,0), so it beats `html` (0,0,1).
- Bump specificity without IDs: `.btn.btn` or `:is(.btn, #\#)` tricks. Prefer layers over bumps.
- Attribute selectors `[id="x"]` match an ID with class-level specificity.

## Cascade layers
```css
@layer reset, base, components, utilities;
@import url("reset.css") layer(reset);
@layer components {
  .card { padding: 1rem; }
}
@layer components.overrides { … }   /* nested layer */
```
- Anonymous `@layer { … }` blocks cannot be appended to later.
- `revert-layer` rolls a property back to the value from the previous layer.
- Baseline since 2022 (Chrome 99, Firefox 97, Safari 15.4).
- Tailwind v4 emits `@layer theme, base, components, utilities`. Put your own overrides in the matching layer or unlayered.

## Scope
```css
@scope (.card) {
  :scope { border: 1px solid; }
  img { border-radius: .5rem; }
}
@scope (.tabs) to (.tab-panel) {     /* donut scope: stop at inner boundary */
  a { color: var(--tab-link); }
}
```
- `@scope` adds proximity to the cascade: when specificity ties, the closer scope root wins.
- Use donut scopes to keep component styles out of slotted or nested content.
- Supported in Chromium (118+), Safari 17.4+, and now Firefox.

## Nesting
```css
.card {
  padding: 1rem;
  & h2 { margin-block: 0 .5rem; }
  &:hover { background: var(--hover); }
  .dark & { background: #111; }       /* & at the end: parent-context */
  @media (width >= 40rem) { padding: 2rem; }
}
```
- A nested selector without `&` is treated as a descendant (`.card h2`). Element selectors at the start of nesting are allowed since late 2023.
- Nested rules behave like `:is()`, so `.a, #b { & .c {} }` gets ID specificity for both branches.
- Baseline since 2023.

## `:has()`
```css
.card:has(img) { grid-template-rows: auto 1fr; }
form:has(:user-invalid) .submit { opacity: .5; }
label:has(+ input:required)::after { content: " *"; }
html:has(dialog[open]) { overflow: hidden; }           /* scroll lock */
li:has(+ li:hover), li:hover + li { scale: 1.05; }     /* neighbours of hovered item */
.grid:has(> :nth-child(5)) { grid-template-columns: repeat(3, 1fr); } /* quantity query */
```
- Baseline since Dec 2023 (Chrome 105, Safari 15.4, Firefox 121).
- Feature-test: `@supports selector(:has(*)) { … }`.
- `:has()` cannot nest inside `:has()` and does not accept pseudo-elements.
- Anchor `:has()` to a close, specific subject (`.card:has(…)`). Selectors like `body:has(.x)` or `*:has(…)` force wide style invalidation.

## Useful pseudo-classes
- `:focus-visible`, `:focus-within`.
- `:user-valid`, `:user-invalid`, `:placeholder-shown`, `:autofill`, `:checked`, `:indeterminate`, `:disabled`, `:read-only`.
- `:popover-open`, `:modal`, `:open` (details, dialog, select).
- `:target`, `:any-link`, `:defined` (custom elements).
- `:nth-child(2 of .item)` to count only matching siblings.
- `:not(.a, .b)` accepts lists.
- `:lang(ar)`, `:dir(rtl)`.

## Pseudo-elements
- `::before`/`::after` need `content` (use `content: ""`). They do not work on replaced elements (`img`, `input`).
- `::marker` accepts only a limited property set (color, font, `content`, white-space, animation/transition).
- `::selection`, `::placeholder`, `::file-selector-button`, `::backdrop`, `::details-content`.
- `::highlight(name)` styles ranges registered with the Custom Highlight API (search hits, syntax highlighting) without DOM changes.
- `::target-text` styles text fragments (`#:~:text=`). `::search-text` (Chrome 144+) styles find-in-page matches.

## Resets
```css
*, *::before, *::after { box-sizing: border-box; }
:where(body, h1, h2, h3, h4, p, figure, blockquote, dl, dd) { margin: 0; }
:where(ul, ol)[role="list"] { list-style: none; padding: 0; }
:where(img, picture, video, canvas, svg) { display: block; max-inline-size: 100%; }
:where(input, button, textarea, select) { font: inherit; }
:where(h1, h2, h3) { text-wrap: balance; }
```
- Wrap reset selectors in `:where()` or put them in a `reset` layer so any later rule overrides them.
- `list-style: none` makes Safari/VoiceOver drop list semantics. Add `role="list"` when the list matters, or use `list-style-type: ""`.

## Inheritance keywords
- `inherit`, `initial` (spec default, not the browser default), `unset`, `revert` (browser stylesheet value), `revert-layer`.
- `all: unset` is aggressive; prefer `all: revert` or targeted resets.

## Gotchas
- An unknown pseudo-class in a selector list invalidates the whole rule: `a:hover, a:unknown {}` drops both. Wrap risky selectors in `:is()`/`:where()`, which are forgiving.
- Unlayered CSS beats every layer. A single unlayered library file can override your entire layered system.
- `:is()` in a large list can raise the specificity of every branch to the highest one.
- Style changes on `:has()` subjects re-run when descendants change. Avoid `:has()` on the root with broad descendant selectors in hot paths.
- `@import` must come before other rules (except `@charset` and `@layer` statements).
