# Components and UI Patterns

Read when building forms, selects, dialogs, popovers, menus, tooltips, anchored UI, filled tabs, tonal cards, badges, accordions, carousels, toggles, or custom scrollbars. Aligns with [`design`](../SKILL.md) §4.4 and §7.

## Rules
- Use native elements first: `<button>` for actions, `<a href>` for navigation, `<dialog>` for modals, `[popover]` for light-dismiss overlays, `<details name>` for accordions, `<select>` for picking.
- Open modals with `dialog.showModal()`. It provides the top layer, `::backdrop`, focus moving into the dialog, Esc to close, and inert page content. Do not build custom focus traps on top.
- Use `popover` + `popovertarget` for menus, toasts, and tooltips. You get top layer and light dismiss without JS.
- Position popups with CSS anchor positioning plus `position-try-fallbacks`. Do not compute coordinates in JS.
- Use `command`/`commandfor` invoker buttons to open dialogs and popovers declaratively where supported.
- Use `inert` to disable a whole subtree (background content, off-screen panels).
- **Tabs:** Always use filled, rounded tabs inside a subtle muted track (`padding: 4px`, concentric radius). Never underline-only or bare-text tabs.
- **Cards & callouts:** Use tonal surface elevation + full-perimeter 1px hairline border + uniform padding on all sides. **Never** use one-sided accent borders (`border-inline-start: 4px solid ...`) on cards, callouts, alerts, or selected items. **Never** nest cards inside cards.
- **Selection & forms:** Style checkboxes and radios with filled accent states (`accent-color` or custom filled SVG mark), never hollow outline-only checked states. Use `appearance: base-select` where supported. Keep native controls in the DOM.
- Do not build modals with the checkbox hack or `:target`. They give no focus management or semantics.
- Make cards clickable with one real link stretched by a pseudo-element, not a wrapping `<a>` around block content with other links inside.

## Filled Segmented Tabs
```html
<div class="tabs" role="tablist" aria-label="Views">
  <button class="tab" role="tab" aria-selected="true" id="t-1" aria-controls="p-1">Overview</button>
  <button class="tab" role="tab" aria-selected="false" id="t-2" aria-controls="p-2" tabindex="-1">Analytics</button>
  <button class="tab" role="tab" aria-selected="false" id="t-3" aria-controls="p-3" tabindex="-1">Settings</button>
</div>
```
```css
.tabs {
  display: inline-flex;
  gap: 0.25rem;
  padding: 0.25rem;
  border-radius: calc(var(--radius-control) + 0.25rem); /* concentric outer radius */
  background: var(--surface-muted);
  border: 1px solid var(--border-subtle);
}
.tab {
  padding: 0.4rem 0.85rem;
  border: 0;
  border-radius: var(--radius-control);
  background: transparent;
  color: var(--text-muted);
  font-weight: 500;
  cursor: pointer;
  transition: background-color 150ms var(--ease-out), color 150ms var(--ease-out), box-shadow 150ms var(--ease-out);
}
.tab[aria-selected="true"] {
  background: var(--surface);
  color: var(--text);
  box-shadow: 0 1px 2px oklch(15% 0.01 250 / 0.08);
}
.tab:focus-visible { outline: 2px solid var(--accent); outline-offset: 2px; }
```
- Real tabs require the ARIA tabs pattern (`role="tablist"`, `tab`, `tabpanel`, Left/Right arrow-key navigation).

## Tonal Cards & Callouts (Zero One-Sided Borders)
```css
.card {
  position: relative;
  padding: 1.25rem;
  border-radius: var(--radius-card);
  background: var(--surface);
  border: 1px solid var(--border-subtle);
  box-shadow: 0 1px 2px oklch(15% 0.01 250 / 0.05);
}
.card a.title::after { content: ""; position: absolute; inset: 0; }     /* stretched link */
.card:has(a.title:focus-visible) { outline: 2px solid var(--accent); outline-offset: 2px; }
.card .secondary-link { position: relative; z-index: 1; }              /* stays clickable */

/* Inset subsection inside a card (never a nested card) */
.card-inset {
  padding: 0.875rem 1rem;
  border-radius: calc(var(--radius-card) - 0.5rem);
  background: var(--surface-muted);
}

/* Tonal callout / alert (full hairline + soft tint, never border-inline-start stripe) */
.callout {
  display: flex;
  gap: 0.75rem;
  padding: 0.875rem 1rem;
  border-radius: var(--radius-control);
  background: color-mix(in oklch, var(--accent) 10%, var(--surface));
  border: 1px solid color-mix(in oklch, var(--accent) 22%, transparent);
}
```

## Tonal Badges & Pills
```css
.badge {
  display: inline-flex;
  align-items: center;
  gap: 0.375rem;
  padding: 0.2rem 0.6rem;
  border-radius: 999px;
  font-size: 0.75rem;
  font-weight: 500;
  text-box: trim-both cap alphabetic;
  background: color-mix(in oklch, var(--badge-tone, var(--accent)) 12%, transparent);
  color: var(--badge-tone, var(--accent));
  border: 1px solid color-mix(in oklch, var(--badge-tone, var(--accent)) 20%, transparent);
}
```

## Forms
```css
:root { accent-color: var(--accent); }                       /* filled checkbox, radio, range, progress */
input, textarea, select { font: inherit; }
textarea { field-sizing: content; min-block-size: 3lh; max-block-size: 12lh; }
input:user-invalid { border-color: var(--danger); }
input:user-invalid + .error { display: block; }
label:has(+ :required)::after { content: " *"; color: var(--danger); }
```
- `field-sizing: content` grows inputs, textareas, and selects with their content (Chrome 123+, Firefox 152, Safari TP). Set min and max sizes.
- Use `:user-invalid` instead of `:invalid` so empty required fields do not show errors on page load.
- Use `inputmode` (`numeric`, `email`, `search`), `autocomplete` tokens, and `enterkeyhint` (`search`, `send`, `next`) for better mobile keyboards.
- Submit with `form.requestSubmit(button)` to run validation and fire `submit`. `event.submitter` tells which button submitted.
- Custom switch (filled accent track when checked):
```css
.switch { appearance: none; inline-size: 2.5rem; block-size: 1.5rem; border-radius: 1lh; background: var(--surface-muted); border: 1px solid var(--border-subtle); position: relative; cursor: pointer; transition: background-color 150ms var(--ease-out); }
.switch::before { content: ""; position: absolute; inset: 2px auto 2px 2px; aspect-ratio: 1; border-radius: 50%; background: var(--surface); box-shadow: 0 1px 2px oklch(15% 0.01 250 / 0.2); transition: translate 180ms var(--ease-out); }
.switch:checked { background: var(--accent); border-color: transparent; }
.switch:checked::before { translate: 1rem 0; }
.switch:focus-visible { outline: 2px solid var(--accent); outline-offset: 2px; }
```
  Add `role="switch"` on the input for switch semantics.

## Customizable select
```css
select, ::picker(select) { appearance: base-select; }
select { field-sizing: content; }
::picker(select) { border: 1px solid var(--border-subtle); border-radius: var(--radius-control); padding: .25rem; background: var(--surface); }
option:checked { background: var(--accent-soft); border-radius: calc(var(--radius-control) - 0.25rem); }
option::checkmark { content: "✓"; }
select::picker-icon { transition: rotate .2s; }
select:open::picker-icon { rotate: 180deg; }
```
- Enables rich HTML in `<option>` and full styling while keeping native keyboard and a11y behavior. Chrome 135+. Other browsers render a normal select, which is a good fallback.
- `<selectedcontent>` inside `<button>` mirrors the chosen option's content.
- `<selectmenu>` and `<selectlist>` were earlier experiments and are not shipped. Do not use them.

## Dialog
```html
<button commandfor="dlg" command="show-modal">Open</button>
<dialog id="dlg" aria-labelledby="dlg-title" closedby="any">
  <h2 id="dlg-title">Title</h2>
  <form method="dialog"><button>Close</button></form>
</dialog>
```
```css
dialog::backdrop { background: oklch(0% 0 0 / .45); backdrop-filter: blur(4px); }
html:has(dialog[open]:modal) { overflow: hidden; }   /* scroll lock */
dialog {
  border: 1px solid var(--border-subtle);
  border-radius: var(--radius-card);
  background: var(--surface);
  transition: opacity .2s var(--ease-out), scale .2s var(--ease-out), display .2s allow-discrete, overlay .2s allow-discrete;
  opacity: 0;
  scale: 0.96;
}
dialog[open] { opacity: 1; scale: 1; }
@starting-style { dialog[open] { opacity: 0; scale: 0.96; } }
```
- `<form method="dialog">` closes the dialog and sets `dialog.returnValue` from the button value.
- `closedby="any"` adds light dismiss (click outside). Without support, handle a backdrop click in JS.
- `dialog.show()` opens a non-modal dialog (no backdrop, page stays interactive).
- The browser returns focus to the opener on close. Put `autofocus` on the first useful control.

## Popover
```html
<button popovertarget="menu">Options</button>
<div id="menu" popover>…</div>                     <!-- popover="auto": light dismiss, one at a time -->
<div id="toast" popover="manual">Saved</div>       <!-- stays until hidePopover() -->
<div id="tip" popover="hint">Tooltip</div>         <!-- hint: does not close auto popovers -->
```
- `popovertargetaction="show|hide|toggle"`. JS: `el.showPopover()`, `hidePopover()`, `togglePopover()`, and the `toggle`/`beforetoggle` events.
- Baseline since 2024 (Chrome 114, Firefox 125, Safari 17).
- A popover is not a modal: no focus trap and no inert background. Use `<dialog>` for blocking flows.
- Hover-triggered popovers: interest invokers (`interestfor="tip"`, with `interest-delay-start` / `interest-delay-end`) are Chrome-only. Also make the trigger work on focus and tap.

## Anchor positioning
```css
.trigger { anchor-name: --menu-btn; }
.menu {
  position: absolute;                       /* or fixed; popovers are fixed */
  position-anchor: --menu-btn;
  position-area: block-end span-inline-end; /* below, aligned to start edge */
  margin-block-start: .25rem;
  min-inline-size: anchor-size(inline);
  position-try-fallbacks: flip-block, flip-inline;
}
.tooltip { position-area: top; inset-inline-start: calc(anchor(center) - 1rem); }
```
- `position-area` places the box in a 3×3 grid around the anchor. Use `anchor()` inside inset properties for exact edges. Math needs `calc()`.
- `position-try-fallbacks` with `flip-block`, `flip-inline`, or custom `@position-try --name { … }` rules handles viewport edges.
- `anchor-scope: --name` limits name lookup so repeated components each find their own anchor.
- An implicit anchor is set when a popover opens from a `popovertarget` button, so `position-anchor` is often not needed.
- Chrome 125+, Safari 26+. Check Firefox. Fall back to a simple absolute position under the trigger.
- Anchoring is visual only. Link elements in the a11y tree with `aria-describedby`, `aria-controls`, or `aria-details`.

## Tooltips
- A tooltip is supplementary text only, never interactive content. Use a toggletip (`<button>` + popover) when the content has links.
- Show on hover and focus, dismiss on Esc (WCAG 1.4.13: dismissible, hoverable, persistent).
- `title` attributes are not keyboard or touch accessible. Do not rely on them.

## Accordion
```html
<details name="faq"><summary>Question</summary><p>Answer</p></details>
<details name="faq"><summary>Question 2</summary><p>Answer 2</p></details>
```
- Shared `name` makes the group exclusive (one open at a time). Baseline 2024.
- Hide the marker: `summary { list-style: none; } summary::-webkit-details-marker { display: none; }`.
- Animate opening with `::details-content` and `interpolate-size` (see animation-motion).
- `hidden="until-found"` keeps collapsed content searchable with find-in-page and fires `beforematch` (Chromium, Firefox).

## Carousels and scroll snap
```css
.track { display: grid; grid-auto-flow: column; grid-auto-columns: min(80%, 20rem); gap: 1rem;
         overflow-x: auto; overscroll-behavior-x: contain; scroll-snap-type: x mandatory; scroll-padding-inline: 1rem; }
.track > * { scroll-snap-align: start; }
.track { scroll-marker-group: after; }
.track > *::scroll-marker { content: ""; inline-size: .5rem; aspect-ratio: 1; border-radius: 50%; background: var(--muted); }
.track > *::scroll-marker:target-current { background: var(--accent); }
.track::scroll-button(inline-start) { content: "←" / "Previous"; }
.track::scroll-button(inline-end) { content: "→" / "Next"; }
```
- `::scroll-button()` and `::scroll-marker` give CSS-only carousel controls with built-in a11y (Chrome 135+). Without them, the track still scrolls.
- Use `mandatory` only when every item fits the viewport; otherwise use `proximity`, or content becomes unreachable.
- `scroll-snap-stop: always` stops fast swipes from skipping items.
- Do not auto-advance without a pause button.

## Scrollbars
```css
.scroller { scrollbar-width: thin; scrollbar-color: var(--thumb) transparent; scrollbar-gutter: stable; }
```
- Use the standard `scrollbar-width` and `scrollbar-color` (Baseline Newly available). When a standard property is set, Chrome ignores `::-webkit-scrollbar` rules. Do not write `::-webkit-scrollbar` rules.
- Hide scrollbars only on scrollers that have another visible scroll affordance: `scrollbar-width: none`.

## Loading states
- Skeletons: a subtle shimmer gradient on placeholder boxes matching the final component dimensions and border radius. Add `aria-busy="true"` on the container and stop the shimmer under `prefers-reduced-motion: reduce`.
- Reserve space for async content to avoid layout shift.

## Gotchas
- `<dialog>` without `showModal()` has no backdrop and no inert page.
- Popovers are `position: fixed` in the top layer. They escape `overflow` and `z-index` but not `transform` on themselves.
- `appearance: none` on checkboxes removes the checked mark. You must draw states for `:checked`, `:indeterminate`, `:disabled`, and `:focus-visible`.
- Do not put block content and interactive elements inside one `<a>`. Nested links are invalid HTML.
- `scroll-behavior: smooth` should be wrapped in `prefers-reduced-motion: no-preference`.
