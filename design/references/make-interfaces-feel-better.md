# Make Interfaces Feel Better

Small design-engineering details that make an interface feel polished. Use these details together with the parent [`design`](../SKILL.md) rules; when a value here is different, the parent value wins.

## When to use

- The user says the UI feels off, flat, generic, cramped, jumpy, or unfinished.
- You build controls, cards, lists, dashboards, navigation, forms, or toolbars.
- A component needs hover, active, focus, enter, exit, loading, or empty states.
- A frontend review needs specific before/after recommendations.

## Core principles

### Concentric radius

For nested rounded surfaces that are near each other:

```text
outer radius = inner radius + padding
```

Pick both values from the one radius scale of the page (parent §4.4). If the padding is large, treat the layers as separate surfaces. The goal is optical coherence.

### Optical alignment

Geometric center is not always visual center. Icon buttons, play triangles, arrows, stars, and asymmetric icons often need a small offset. Fix the SVG when possible. If not, adjust the margin or padding by 1-2px.

### Shadows and borders

Use borders for separation and focus rings. Use layered shadows when a card, button, dropdown, or popover needs depth. Make shadows transparent and subtle, tinted to the background (parent §4.4). For selection, obey parent §7: never a one-side border.

### Text wrapping and numbers

- Use `text-wrap: balance` on headings and short titles.
- Use `text-wrap: pretty` on short-to-medium body text, captions, descriptions, and list items.
- Do not use them on long prose, code, or preformatted content.
- Use `font-variant-numeric: tabular-nums` for counters, timers, prices, tables, and other numbers that update.

### Font smoothing

On macOS, set antialiased font smoothing at the root when the project does not already do it:

```css
html {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
```

### Image outlines

Give images a subtle inset outline so their edges do not blur into the surface:

```css
img {
  outline: 1px solid rgb(0 0 0 / 0.1);
  outline-offset: -1px;
}

@media (prefers-color-scheme: dark) {
  img { outline-color: rgb(255 255 255 / 0.1); }
}
```

Use neutral black or white alpha outlines. Do not tint image outlines with the brand color.

### Motion

- Use CSS transitions for interactive state changes, because they can retarget mid-motion. Use keyframes only for one-shot entrances or loading sequences.
- Enter: opacity + small `translateY`, optionally a small blur.
- Exit: shorter and quieter than enter, usually 150ms.
- Press: use the parent press values (§4.5, §7). Let the user disable the movement where it distracts.
- Icon swaps: cross-fade with opacity, scale, and blur. Do not toggle visibility instantly.

### Transition scope

Never use `transition: all`. Name the properties that change:

```css
.button {
  transition-property: transform, background-color, box-shadow;
  transition-duration: 150ms;
  transition-timing-function: var(--ease-out);
}
```

Use `will-change` only to fix first-frame stutter on `transform`, `opacity`, or `filter`. Never use `will-change: all`.

### Hit areas

Give each interactive control a hit area of 44x44px (parent §9). When the visible icon is smaller, expand the hit area with a pseudo-element. Expanded hit areas must not overlap.

```css
.icon-btn { position: relative; }
.icon-btn::after { content: ""; position: absolute; inset: -10px; }
```

## Review output

For a polish pass, report each change as a before/after row:

| Principle | Before | After |
| --- | --- | --- |
| Concentric radius | Same radius on parent and child | Parent radius includes the padding |
| Tabular numbers | Counter shifts when digits change | Counter uses `tabular-nums` |
| Transition scope | `transition: all` | Named transition properties |

Include file paths and properties when the snippet does not make them clear. Do not list principles that you checked but did not change.

## Checklist

- Nested rounded elements are optically coherent.
- Icons are visually centered.
- Buttons, cards, and popovers use borders or shadows for the correct reason.
- Headings and short text do not wrap badly.
- Dynamic numbers use tabular numerals.
- Images have neutral outlines where necessary.
- Enter and exit animations are different, subtle, and interruptible.
- Buttons have tactile active states without exaggerated motion.
- No `transition: all` and no `will-change: all`.
- Small controls still have usable hit areas.

## Related skills

- [`design`](../SKILL.md) - mandatory rules for cards, headers, selection, motion.
- [`design-system`](design-system.md) - audit visual consistency first.
- [`motion-react`](motion-react.md) - Motion for React when CSS is not sufficient.
