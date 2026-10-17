# Accessibility

Read when writing HTML/CSS that must work with keyboards, screen readers, zoom, high contrast, and reduced motion, or when auditing against WCAG 2.2.

## Rules
- Use semantic HTML first. The first rule of ARIA: do not use ARIA when a native element does the job.
- Every interactive element must be reachable and operable by keyboard, with a visible focus indicator (`:focus-visible`, at least 2px, 3:1 contrast against adjacent colors).
- Never write `outline: none` without a replacement focus style.
- Contrast: 4.5:1 for normal text, 3:1 for large text (24px, or 18.66px bold) and for UI component boundaries and icons.
- Target size: at least 24×24 CSS px (WCAG 2.2 AA 2.5.8). Aim for 44×44 on touch UI.
- Every form control needs a programmatic label (`<label for>`, wrapping `<label>`, or `aria-labelledby`). A placeholder is not a label.
- Do not convey information by color alone. Add text, icons, or patterns.
- Support 200% zoom and 320px-wide reflow without horizontal scroll (WCAG 1.4.10). Use `rem`, intrinsic layouts, and no fixed-height text boxes.
- Respect `prefers-reduced-motion`, and give a pause control for auto-moving content.
- Keep DOM order equal to visual order. CSS reordering (`order`, `grid-area`, `row-reverse`) does not change focus or reading order.

## Focus
```css
:focus-visible { outline: 2px solid var(--focus, Highlight); outline-offset: 2px; }
.card:focus-within { box-shadow: 0 0 0 2px var(--focus); }
```
- `:focus-visible` shows rings for keyboard focus and hides them for mouse clicks on buttons. Text inputs always match. Baseline 2022.
- Use two-color rings (`outline` + `box-shadow` in a contrasting color) on surfaces that change color.
- Do not let sticky headers hide focused elements (WCAG 2.4.11). Use `scroll-padding-block-start: var(--header-h)` on `html`.
- Manage focus on route changes and after deleting items: move focus to the new heading or the next item.
- `tabindex="0"` adds an element to tab order. `tabindex="-1"` makes it focusable by script only. Never use positive `tabindex`.
- `reading-flow: flex-visual | grid-rows | …` + `reading-order` (Chromium, experimental) make focus follow visual order in flex/grid. Do not depend on them.

## Hiding content
| Goal | Technique |
|---|---|
| Hidden from everyone | `hidden` attribute, `display: none`, `visibility: hidden` |
| Visible, hidden from AT | `aria-hidden="true"` (never on focusable content) |
| Hidden visually, read by AT | `.sr-only` below |
| Hidden, findable with Ctrl+F | `hidden="until-found"` |
| Present but not interactive | `inert` |

```css
.sr-only:not(:focus):not(:active) {
  position: absolute; inline-size: 1px; block-size: 1px; margin: -1px; padding: 0;
  overflow: hidden; clip-path: inset(50%); white-space: nowrap; border: 0;
}
```

## Skip link
```html
<a class="skip-link" href="#main">Skip to content</a> … <main id="main" tabindex="-1">
```
```css
.skip-link { position: absolute; inset-inline-start: 1rem; translate: 0 -200%; }
.skip-link:focus { translate: 0 0; }
```

## Forms
- Group related controls with `<fieldset>` + `<legend>` (radio groups, addresses).
- Errors: set `aria-invalid="true"` on the field, link the message with `aria-describedby`, and move focus to the first invalid field or an error summary on submit.
- Use `:user-invalid` styling so errors appear only after interaction.
- Mark required fields with `required` and a visible indicator. `aria-required` is only for custom controls.
- Use the correct `type` and `autocomplete` (`email`, `tel`, `one-time-code`, `current-password`) for autofill and WCAG 1.3.5.
- Do not disable the submit button to show invalid state. Disabled buttons are hard to discover and do not explain why.

## ARIA essentials
- Names: `aria-label` (string), `aria-labelledby` (IDs, overrides `aria-label`). Descriptions: `aria-describedby`.
- States: `aria-expanded` on disclosure triggers, `aria-pressed` for toggle buttons, `aria-current="page"` for active navigation links, `aria-selected` in tabs and listboxes.
- `aria-controls` is weakly supported; it is optional.
- Live regions: `<div role="status">` (polite) for confirmations, `role="alert"` (assertive) for errors. The region must exist in the DOM before its text changes.
- `ariaNotify("Saved", { priority: "normal" })` announces without a live region (WAI-ARIA 1.3; Firefox 150, Chromium). Keep a live-region fallback.
- Style from ARIA state to keep one source of truth: `[aria-expanded="true"] .chevron { rotate: 180deg; }`.
- Do not add roles that repeat native semantics (`<button role="button">`), and do not put `role="presentation"` on focusable elements.

## Dialogs and overlays
- Native `dialog.showModal()` handles focus containment, Esc, and inert background. Label it with `aria-labelledby`.
- Return focus to the trigger on close (native dialogs do this).
- Do not apply `inert` to an ancestor of the open dialog.
- Toasts: use `role="status"`, do not steal focus, and keep them on screen long enough (or until dismissed).

## Landmarks and structure
- One `<main>`, plus `<header>`, `<nav aria-label="Primary">`, `<footer>`, `<aside>`. Label repeated landmarks.
- Use one `<h1>` and do not skip heading levels for styling; style with classes.
- Lists: `list-style: none` removes list semantics in Safari/VoiceOver. Add `role="list"` when the count matters.
- Use `<table>` with `<th scope>` and `<caption>` for data. Do not use `display: grid/flex` on table elements, which can remove table semantics in some browsers.
- `display: contents` on buttons and some other elements has a history of removing them from the a11y tree. Avoid it on semantic or interactive elements.

## Images and media
- Informative images: concise `alt`. Decorative: `alt=""`. Functional images (inside a link or button): describe the action.
- Complex images (charts): short alt + a full text alternative nearby.
- Video: captions; audio: transcripts. Do not autoplay sound.
- CSS background images are not announced. Do not use them for content images.

## Color and contrast modes
- Support `forced-colors: active`: keep borders on controls (backgrounds are removed), use system colors, and do not rely on `box-shadow` for focus (it is removed). Add `outline: 2px solid transparent` so a ring appears in forced colors.
- `prefers-contrast: more`: increase border and text contrast.
- `color-scheme: light dark` gives accessible native controls in dark mode.

## Text
- Do not lock zoom (`maximum-scale=1`, `user-scalable=no`).
- Text spacing (WCAG 1.4.12): layouts must survive line-height 1.5, paragraph spacing 2em, letter-spacing 0.12em, and word-spacing 0.16em. Avoid fixed heights on text containers.
- Links in body text need more than color to stand out (underline).
- `user-select: none` only on UI chrome, never on content.

## Testing checklist
- Tab through the whole page: order, visibility of focus, no traps.
- Screen reader smoke test: VoiceOver (Safari), NVDA (Firefox/Chrome), JAWS, TalkBack.
- Zoom to 200% and 400%, and test 320px width.
- Run axe or Lighthouse, then check manually. Automated tools find about a third of issues.
- Test forced colors (Windows High Contrast) and reduced motion.

## Gotchas
- `aria-hidden="true"` on an element that contains focusable children creates "ghost" focus stops.
- `display: none` and `visibility: hidden` remove content from the a11y tree, but `aria-labelledby` / `aria-describedby` can still reference hidden elements for their text. This is a valid pattern.
- `pointer-events: none` does not stop keyboard activation. Use `disabled` or `inert`.
- Placeholder text usually fails contrast and disappears on input.
- Hover-only content (menus, tooltips) needs focus and tap equivalents.
