# Animation and Motion

Read when adding transitions, keyframes, easing, scroll-driven animation, view transitions, entry/exit animation, 3D transforms, or reduced-motion handling.

## Rules
- Animate `transform`, `opacity`, `filter`, and `clip-path` where possible. Avoid animating `width`, `height`, `top`, `left`, and `margin`, which trigger layout every frame.
- Use the individual transform properties (`translate`, `rotate`, `scale`) so states compose without repeating the whole `transform` list.
- Keep UI transitions short: 150-300ms for small elements, up to about 500ms for large movement. Use ease-out for entrances and ease-in for exits.
- Honor `prefers-reduced-motion: reduce`. Replace movement with fades or no animation. Do not just shorten durations for parallax and large motion.
- Use `@starting-style` + `transition-behavior: allow-discrete` for entry/exit animations of `display: none` elements, popovers, and dialogs.
- Use scroll-driven animations (`animation-timeline`) before reaching for scroll listeners.
- Use the View Transitions API for page and state changes instead of hand-rolled FLIP when you can.
- Register custom properties with `@property` before animating them.
- Use `will-change` only just before an animation and on few elements. Do not put it in global CSS.

## Transitions
```css
.btn { transition: background-color .2s, translate .2s cubic-bezier(.2, .8, .2, 1); }
.btn:hover { translate: 0 -2px; }
```
- List properties explicitly. `transition: all` animates unexpected properties and costs more.
- Different durations in and out: put the "out" transition on the base state and the "in" transition on the `:hover` state.
- `transition-delay` on hover-out (`.menu { transition: visibility 0s .3s; }`) gives forgiving hover menus.

## Easing
- `cubic-bezier(.34, 1.56, .64, 1)` overshoots (back-out). Values outside 0-1 on the y-axis create overshoot.
- `steps(n, jump-none)` for sprite sheets, typewriters, and ticking clocks. `steps(1)` switches a value at once (for example `z-index` mid-animation).
- `linear()` creates spring and bounce curves from points:
```css
--spring: linear(0, .009, .035 2.1%, .141, .281 6.7%, .723 12.9%, .938 16.7%, 1.017, 1.077 21.4%, 1.121, 1.149 27.2%, 1.159, 1.152 31.5%, 1.112 36.1%, 1.002 45.3%, .971 50.8%, .975 59.7%, 1.003 72.5%, 1);
.panel { transition: translate .6s var(--spring); }
```
  Baseline since 2023. Generate curves with a linear() easing generator.

## Keyframes
```css
@keyframes fade-up { from { opacity: 0; translate: 0 1rem; } }   /* "to" = current styles */
.item { animation: fade-up .4s ease-out both; animation-delay: calc(var(--i, 0) * 60ms); }
```
- Omit `to` (or `from`) to animate to or from the element's own styles.
- `animation-fill-mode: both` keeps the first frame during delay and the last frame after the end.
- A negative `animation-delay` starts mid-cycle. Use it for staggered loops that start at once.
- Pause with `animation-play-state: paused` (for example on `:hover` or when off-screen).
- `animation-composition: add` stacks a keyframe value on top of the base (for example add rotation to an existing transform).
- Stagger with `sibling-index()` where supported: `animation-delay: calc(sibling-index() * 50ms)`.

## Entry and exit with `@starting-style`
```css
.toast {
  transition: opacity .3s, translate .3s, display .3s allow-discrete, overlay .3s allow-discrete;
}
.toast[hidden] { display: none; opacity: 0; translate: 0 1rem; }
@starting-style { .toast:not([hidden]) { opacity: 0; translate: 0 1rem; } }

[popover] { transition: opacity .2s, display .2s allow-discrete, overlay .2s allow-discrete; opacity: 0; }
[popover]:popover-open { opacity: 1; }
@starting-style { [popover]:popover-open { opacity: 0; } }
```
- `@starting-style` defines the "before" styles for the first style update. `allow-discrete` keeps `display` and `overlay` at their visible value until the exit transition ends.
- Transition `overlay` for popovers and dialogs so they stay in the top layer during exit.
- Baseline since 2024.

## Animating to `auto`
```css
:root { interpolate-size: allow-keywords; }       /* opt in globally */
.panel { block-size: 0; overflow: clip; transition: block-size .3s; }
.panel.open { block-size: auto; }
.panel.open { block-size: calc-size(auto, size); } /* per-property alternative */

details::details-content { block-size: 0; overflow: clip; transition: block-size .3s, content-visibility .3s allow-discrete; }
details[open]::details-content { block-size: auto; }
```
- `interpolate-size` and `calc-size()` are Chromium only. Elsewhere the change is instant, which is an acceptable fallback.
- Cross-browser fallback: grid `grid-template-rows: 0fr` → `1fr` with an inner `min-block-size: 0` / `overflow: hidden` wrapper.

## Scroll-driven animations
```css
@keyframes grow { from { scale: 0 1; } }
.progress { transform-origin: left; animation: grow linear both; animation-timeline: scroll(root block); }

@keyframes reveal { from { opacity: 0; translate: 0 2rem; } }
.card { animation: reveal linear both; animation-timeline: view(); animation-range: entry 0% cover 30%; }

.gallery { view-timeline: --gallery block; }
.gallery img { animation: zoom linear both; animation-timeline: --gallery; }
```
- `scroll()` tracks a scroller's position. `view()` tracks an element's progress through the scrollport.
- Ranges: `cover`, `contain`, `entry`, `exit`, `entry-crossing`, `exit-crossing`, plus offsets.
- Use `linear` easing and no duration (`animation-duration: auto`). Put `animation-timeline` after the `animation` shorthand, because the shorthand resets it.
- `timeline-scope` lets an element use a named timeline from a sibling or descendant.
- Supported in Chromium (115+) and Safari 26. Firefox has it behind a flag. Wrap in `@supports (animation-timeline: view())` and keep content visible without it.
- Scroll-triggered (not scrubbed) animations: toggle a class with `IntersectionObserver`, or use scroll-state container queries (Chromium).

## View Transitions
```js
if (!document.startViewTransition) update();
else document.startViewTransition(() => update());
```
```css
@view-transition { navigation: auto; }      /* cross-document (MPA), same-origin */
.hero-img { view-transition-name: hero; }
.card { view-transition-name: match-element; view-transition-class: card; }
::view-transition-group(.card) { animation-duration: .4s; }
::view-transition-old(root) { animation: fade-out .2s; }
@media (prefers-reduced-motion: reduce) { ::view-transition-group(*), ::view-transition-old(*), ::view-transition-new(*) { animation: none !important; } }
```
- Same-document: Chrome 111+, Safari 18+, Firefox 144+. Cross-document: Chrome 126+, Safari 18.2+.
- Every `view-transition-name` must be unique in the page at capture time. Use `match-element` or set names inline (`style="view-transition-name: item-42"`).
- `view-transition-class` styles groups of named elements together.
- Element-scoped transitions (`element.startViewTransition()`) shipped in Chrome 147 for animating one subtree.
- Types: `document.startViewTransition({ update, types: ['forward'] })` and `:active-view-transition-type(forward)` let you choose direction-specific animations.
- 3D in view transitions: the groups are flat snapshots. Put `perspective()` in the keyframe transform (`transform: perspective(1000px) rotateY(90deg)`), because a parent `perspective` does not apply to the pseudo-element tree.
- The old `<meta name="view-transition">` has no effect. Use the `@view-transition` rule.

## 3D transforms
```css
.scene { perspective: 1000px; }
.card { transform-style: preserve-3d; transition: rotate .6s; }
.card:hover { rotate: y 180deg; }
.face { backface-visibility: hidden; }
.back { rotate: y 180deg; }
```
- `perspective` on the parent gives children a shared vanishing point. `transform: perspective(…)` on the element gives it its own.
- `preserve-3d` is flattened by `overflow` other than `visible`, `filter`, `opacity < 1`, `clip-path`, and `mask` on the same element.
- Layered 3D text: stack copies with `translateZ(calc(var(--i) * -1px))` inside a `preserve-3d` parent.

## Motion paths
```css
.dot { offset-path: path("M0 0 C 50 -50, 150 50, 200 0"); animation: travel 2s ease-in-out infinite alternate; }
@keyframes travel { to { offset-distance: 100%; } }
```
- `offset-path` also accepts `circle()`, `ray()`, `url(#svgPath)`, and `shape()`. `offset-rotate: auto` faces the direction of travel.

## JavaScript animation
- Web Animations API: `el.animate([{ opacity: 0 }, { opacity: 1 }], { duration: 300, easing: 'ease-out', fill: 'forwards' })`. It returns an `Animation` with `.finished` (Promise), `.pause()`, `.reverse()`.
- `getAnimations()` lists running animations, which is useful to wait for completion before removing nodes.
- GSAP: use for complex timelines, SVG morphing, `ScrollTrigger` pinning, and `Flip` layout animation. Respect reduced motion with `gsap.matchMedia()`.
- FLIP pattern: read First rect → apply change → read Last rect → apply Inverse transform → Play to identity.

## Reduced motion
```css
@media (prefers-reduced-motion: no-preference) {
  .hero { animation: float 6s ease-in-out infinite; }   /* opt in to motion */
}
```
- Prefer "opt in" (wrap motion in `no-preference`) over global kill switches. A global `* { animation: none !important }` can break components that rely on `animationend`.
- In JS: `matchMedia('(prefers-reduced-motion: reduce)').matches`, and listen for `change`.
- Give users a pause control for any motion longer than 5 seconds (WCAG 2.2.2).

## Gotchas
- `transition` does not run when the element goes from `display: none` without `@starting-style`.
- `translate`, `rotate`, and `scale` apply before `transform`, always in that order. You can combine them with `transform`, but you cannot change the order.
- `scale()` on text blurs during animation in some browsers. Animate `font-size` only for small numbers of elements.
- Hover animations on touch devices stick after tap; gate them with `@media (hover: hover)`.
- `animation-timeline` placed before the `animation` shorthand is reset to `auto`.
