# Frontend JavaScript for UI

Read when writing JavaScript that drives UI: DOM updates, events, observers, web components and shadow DOM styling, CSS from JS, view transitions, and framework styling patterns.

## Rules
- Reach for HTML/CSS first (dialog, popover, details, `:has()`, invokers, scroll-driven animation). Use JS only for what they cannot do.
- Toggle state with attributes or classes (`el.dataset.state = 'open'`, `classList.toggle('is-open', open)`, `aria-expanded`). Keep visual rules in CSS.
- Pass dynamic values to CSS through custom properties: `el.style.setProperty('--progress', pct)`. Do not write many inline style properties.
- Never insert untrusted strings with `innerHTML`/`insertAdjacentHTML`. Use `textContent`, `createElement`, or the Sanitizer / `setHTML()` where available.
- Do not use `innerHTML +=` to append. It reparses everything and destroys listeners and state. Use `append()` or `insertAdjacentHTML('beforeend', trustedHtml)`.
- Use event delegation (one listener on a container + `event.target.closest()`) for lists.
- Use `IntersectionObserver`, `ResizeObserver`, and `MutationObserver` instead of polling or scroll/resize handlers. Disconnect them when done.
- Clean up with `AbortController`: `addEventListener(type, fn, { signal })` and `fetch(url, { signal })`, then `controller.abort()`.
- Feature-detect (`'popover' in HTMLElement.prototype`, `CSS.supports('anchor-name: --a')`, `document.startViewTransition`) and enhance progressively.

## DOM
```js
const list = document.querySelector('[data-list]');
list.addEventListener('click', (e) => {
  const btn = e.target.closest('button[data-remove]');
  if (!btn || !list.contains(btn)) return;
  btn.closest('li')?.remove();
});

const li = document.createElement('li');
li.textContent = userInput;             // safe
list.append(li);
```
- Use `querySelector`/`getElementById`. Do not rely on implicit globals from element IDs (`window.myId`).
- `<template>` + `content.cloneNode(true)` for repeated markup.
- `element.replaceChildren(...nodes)` to swap content in one step.
- `classList.replace(a, b)` returns `false` when `a` is missing.
- `event.detail === 0` on `click` usually means keyboard activation (Enter/Space).
- Use Pointer Events (`pointerdown`, `pointermove`, `pointerup`, `setPointerCapture`) for mouse, touch, and pen in one path. Set `touch-action: none` in CSS on drag surfaces.

## CSS from JavaScript
```js
const sheet = new CSSStyleSheet();
sheet.replaceSync(':host { display: block; }');
shadowRoot.adoptedStyleSheets = [sheet];
document.adoptedStyleSheets = [...document.adoptedStyleSheets, sheet];
```
- Read computed values with `getComputedStyle(el).getPropertyValue('--token').trim()`.
- `CSS.registerProperty({ name: '--x', syntax: '<length>', inherits: false, initialValue: '0px' })` is the JS form of `@property`.
- `matchMedia('(prefers-reduced-motion: reduce)')` and its `change` event keep JS in sync with media queries.
- `CSS.supports('selector(:has(*))')` for selector support.
- Custom Highlight API: `CSS.highlights.set('search', new Highlight(...ranges))` + `::highlight(search)` for search-hit highlighting without wrapping text in elements.

## Observers
```js
const io = new IntersectionObserver((entries) => {
  for (const e of entries) e.target.classList.toggle('in-view', e.isIntersecting);
}, { rootMargin: '0px 0px -10% 0px', threshold: 0 });
document.querySelectorAll('.reveal').forEach((el) => io.observe(el));

const ro = new ResizeObserver(([entry]) => {
  const w = entry.contentBoxSize[0].inlineSize;
  entry.target.style.setProperty('--w', w);
});
```
- Prefer container queries over `ResizeObserver` when the goal is only styling.
- Changing an observed element's size inside a `ResizeObserver` callback can cause "ResizeObserver loop" errors. Defer with `requestAnimationFrame` or guard against no-op changes.
- `MutationObserver` callbacks are batched microtasks. Keep them light and avoid layout reads inside them.

## Web components
```js
class XCard extends HTMLElement {
  static observedAttributes = ['variant'];
  #root = this.attachShadow({ mode: 'open' });
  connectedCallback() { this.#render(); }
  attributeChangedCallback() { if (this.isConnected) this.#render(); }
  #render() {
    const v = this.getAttribute('variant') === 'compact' ? '.5rem' : '1rem';
    this.#root.innerHTML = `<style>:host{display:block;padding:${v}}</style><slot name="title"></slot><slot></slot>`;
  }
}
customElements.define('x-card', XCard);
```
- Names need a hyphen. `connectedCallback` can run several times (moves); make it idempotent.
- Form-associated elements: `static formAssociated = true;` + `this.attachInternals()` for `setFormValue()`, `setValidity()`, labels, and `:state()` custom states (`internals.states.add('checked')` → `x-check:state(checked)`).
- Declarative Shadow DOM: `<template shadowrootmode="open">` renders shadow roots from server HTML without JS.
- Customized built-ins (`is="…"`) do not work in Safari. Use autonomous elements.

## Shadow DOM styling
- `:host`, `:host(.active)`, `:host([disabled])` style the element from inside.
- `:host-context()` is not supported in Firefox or Safari. Use inherited custom properties or attributes instead.
- `::slotted(selector)` matches only direct slotted children, not their descendants. Slotted content keeps light-DOM styles.
- Expose internals with `part="label"` and style from outside with `x-card::part(label)`. Forward nested parts with `exportparts`.
- Inherited properties (`color`, `font`, custom properties) cross the shadow boundary. Selectors do not.
- `:defined` / `:not(:defined)` hides or reserves space for elements before they upgrade, which prevents a flash of unstyled content.
- Container queries work inside shadow roots; `:host { container-type: inline-size; }` makes the component its own container for its internals.

## View Transitions from JS
```js
async function navigate(update) {
  if (!document.startViewTransition || matchMedia('(prefers-reduced-motion: reduce)').matches) return update();
  const vt = document.startViewTransition({ update, types: ['slide'] });
  await vt.finished;
}
```
- `vt.ready` resolves when pseudo-elements exist (use it to run custom WAAPI animations on `::view-transition-*`).
- Element-scoped `el.startViewTransition()` is in Chrome 147+.

## Focus management
- Native `<dialog>` handles focus. For custom widgets, use roving `tabindex` (one item `tabindex="0"`, others `-1`) with arrow keys.
- After async rendering, move focus to the new heading or first control: `heading.focus({ preventScroll: false })` with `tabindex="-1"` on the heading.
- `inert` on background content replaces manual focus traps.

## Networking and lifecycle
- `fetch(url, { keepalive: true })` or `navigator.sendBeacon(url, data)` for analytics on page hide. Listen to `visibilitychange` / `pagehide`, not `unload`.
- `URLPattern` for routing matches: `new URLPattern({ pathname: '/product/:id' }).exec(location.href)`.
- Long work: split with `scheduler.yield()` (fallback `setTimeout(0)`), or move it to a Web Worker (`postMessage`, or Comlink for RPC).

## Framework notes
- **React**: pass CSS variables with `style={{ '--accent': color }}`. Focus after render in `useEffect` with refs. Use `useDeferredValue` / `useTransition` to keep typing responsive. Avoid runtime CSS-in-JS in Server Components.
- **Vue**: `v-bind()` in `<style>` binds reactive values to CSS variables: `color: v-bind(accent)`. Use `<style scoped>` or CSS Modules.
- **Svelte**: `style:--accent={color}` directive, `transition:fade`, custom transitions returning `{ css: (t) => … }` run as CSS animations.
- **Astro**: scoped styles by default. `define:vars={{ accent }}` passes values to CSS. Ship islands only for interactive parts (`client:visible`, `client:idle`).

## Testing
- Query by role and label (Testing Library `getByRole('button', { name: 'Save' })`), not by CSS classes.
- Use `data-testid` only when no accessible query fits.
- Visual tests: Playwright `await expect(page).toHaveScreenshot()`. Emulate `prefers-reduced-motion` and color schemes in tests.

## Gotchas
- `innerHTML` with user input is an XSS hole.
- `offsetParent === null` is a cheap "is hidden" check but fails for `position: fixed` elements. Prefer `el.checkVisibility()`.
- `getBoundingClientRect()` after style writes forces synchronous layout. Read first, then write.
- Passive listeners cannot call `preventDefault()`. Use `{ passive: false }` only where you must block scrolling.
- `sendBeacon` cannot set custom headers.
- Service workers and Web Workers have no DOM access.
