# Custom Properties and Math

Read when using CSS variables, `@property`, `calc()` and math functions, `if()`, `@function`, `attr()`, `random()`, `sibling-index()`, or variable-driven state.

## Rules
- Store design tokens as custom properties on `:root`; override them on components or themes.
- Use custom properties as component APIs: `.btn { background: var(--btn-bg, var(--color-accent)); }`.
- Register a property with `@property` when you need to animate or transition it, type-check it, or stop it from inheriting.
- Give `var()` a fallback when the property may be undefined. The fallback is everything after the first comma: `var(--font, system-ui, sans-serif)`.
- Remember that an invalid custom property value does not fall back to the previous declaration. The property becomes "invalid at computed-value time" and resets to `inherit` or `initial`.
- Prefer `clamp(min, preferred, max)` over nested `min()`/`max()` for bounded fluid values.
- Use new functions (`if()`, `@function`, `random()`, `sibling-index()`, typed `attr()`) only as enhancement, with a static value declared first.

## Custom property basics
```css
:root { --space: 1rem; --radius: .5rem; --accent: oklch(60% .2 260); }
.card { padding: var(--space); border-radius: var(--radius); }
.card.compact { --space: .5rem; }             /* change the API, not the property */
.icon { inline-size: calc(var(--size, 1) * 1em); }   /* unitless number -> length */
```
- Store unitless numbers and multiply by a unit: `calc(var(--n) * 1px)`. You cannot convert `10` to `10px` by appending.
- Empty fallback trick: `var(--extra-shadow,)` resolves to nothing, so `box-shadow: 0 1px 2px #0003 var(--extra-shadow,)` stays valid. Watch comma placement.
- Space toggle: `--on: initial` / `--on: ;` lets one variable switch many values. Prefer `if()` or style queries where supported.
- Custom properties inherit into Shadow DOM, so they are the main theming API for web components.
- Custom property names are case-sensitive.

## `@property`
```css
@property --angle {
  syntax: "<angle>";
  inherits: false;
  initial-value: 0deg;
}
.spinner { background: conic-gradient(from var(--angle), red, blue); animation: spin 2s linear infinite; }
@keyframes spin { to { --angle: 360deg; } }
```
- `syntax`, `inherits`, and `initial-value` are required (`initial-value` is optional only for `syntax: "*"`). An invalid registration is ignored.
- Unregistered properties animate discretely (flip at 50%). Registered typed ones interpolate, which makes gradient, mask, and color animations possible.
- `inherits: false` improves performance for high-frequency animated variables.
- Baseline since 2024 (Firefox 128).

## `calc()` and math functions
- `calc()` can mix units: `calc(100% - 2rem)` and `calc(10px + 2rem)` are valid. You cannot add a length to a unitless number.
- `+` and `-` need spaces around them.
- Comparison: `min()`, `max()`, `clamp()`.
- Stepped: `round(nearest, var(--x), 1rem)`, `mod()`, `rem()`.
- Sign: `abs()`, `sign()`.
- Trig: `sin()`, `cos()`, `tan()`, `asin()`, `acos()`, `atan()`, `atan2()`.
- Powers: `pow()`, `sqrt()`, `hypot()`, `log()`, `exp()`.
- Constants: `pi`, `e`, `infinity`.
- Circular layout:
```css
.item {
  --angle: calc(var(--i) * 360deg / var(--total));
  translate: calc(cos(var(--angle)) * var(--r)) calc(sin(var(--angle)) * var(--r));
}
```
- Typed division (unit / unit gives a number, e.g. `calc(100cqi / 1px)`) is new (Chrome 140, Safari 18.2+). It enables a responsive value from a container size without JS.
- `infinity` is useful for pills: `border-radius: calc(infinity * 1px)`.

## `if()`
```css
.btn {
  background: if(style(--variant: danger): var(--red); style(--variant: ghost): transparent; else: var(--accent));
  padding: if(media(width >= 40rem): 1rem 2rem; else: .5rem 1rem);
  backdrop-filter: if(supports(backdrop-filter: blur(1px)): blur(8px); else: none);
}
```
- Syntax: `if(<condition>: <value>; <condition>: <value>; else: <value>)`. Conditions are `style()`, `media()`, `supports()`. Use semicolons between branches and a colon after each condition.
- Range comparisons work in `style()`: `if(style(--count > 5): …)` (Chrome 142+).
- Chromium only today. Declare a plain fallback before the `if()` declaration.

## `@function`
```css
@function --fluid(--min, --max) {
  result: clamp(var(--min), calc(var(--min) + 2vi), var(--max));
}
h1 { font-size: --fluid(2rem, 4rem); }
```
- Function and parameter names are dashed idents. `result` gives the return value, and `@media` / `if()` can appear inside.
- Chromium first (Chrome 139+), Safari Technology Preview. Use for enhancement and keep compiled fallbacks.

## `attr()` with types
```css
.bar { inline-size: attr(data-value type(<percentage>), 0%); }
.swatch { background: attr(data-color type(<color>), gray); }
```
- Typed `attr()` works on any property (not only `content`). Chromium first (Chrome 133+).
- Without a type, `attr()` returns a string, which is useful only in `content`.

## `sibling-index()` and `sibling-count()`
```css
li { animation-delay: calc(sibling-index() * 60ms); }
li { inline-size: calc(100% / sibling-count()); }
```
- Replaces `--i` inline styles and long `:nth-child` lists for stagger, distribution, and hue rotation.
- Chrome 138+; Firefox 154 marks them Baseline. Fallback: set `style="--i: 3"` from markup.

## `random()`
```css
.star { rotate: random(-10deg, 10deg); inline-size: random(1rem, 3rem, by 0.5rem); }
```
- Generates values once per element. Supports a step and sharing options (`element-shared`).
- Safari 26.2+ only. Use only for decoration and give a static value first.

## State via variables
```css
.toggle { --on: 0; }
.toggle:has(:checked) { --on: 1; }
.knob { translate: calc(var(--on) * 1.5rem) 0; background: color-mix(in oklch, var(--off-color), var(--on-color) calc(var(--on) * 100%)); }
```
- Drive many properties from one 0/1 variable. Register it with `@property` (`<number>`) to animate the switch.

## Gotchas
- `var()` cannot build property names or selectors, and it cannot work inside media query conditions.
- A `var()` with an invalid resolved value makes the whole declaration invalid at computed time, and the previous valid declaration is not used.
- Custom properties set on `*` or `:root` that change often force style recalc for the whole document. Scope frequently-changing variables to the element that uses them.
- A shorthand that contains `var()` is resolved as a whole at computed time. Longhands set later still win, but DevTools shows the longhands as "pending-substitution".
