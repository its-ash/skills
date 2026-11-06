# Motion, Components, Performance, Accessibility

Sections §5-§9, §12, §13, §15-§19, §22 of [`design`](../SKILL.md). Code patterns: [motion-react.md](motion-react.md). CSS animation: [css/animation-motion.md](css/animation-motion.md).

## 5. Animation Decisions

**5.A Frequency:** 100+/day (shortcuts) = none; tens/day (hover) = subtle or none; occasional (modal, toast) = standard; rare (onboarding, success) = delight. Never animate keyboard actions.

**5.B Purpose:** feedback, spatial consistency, state, bridging, explanation, delight. Can't name it -> don't build it. Data the user reads must not move for style.

**5.C Easing:** enter/exit `ease-out`; on-screen move `ease-in-out`; hover `ease`; constant `linear`. Never `ease-in`.

```css
--ease-out: cubic-bezier(0.23, 1, 0.32, 1);
--ease-in-out: cubic-bezier(0.77, 0, 0.175, 1);
--ease-drawer: cubic-bezier(0.32, 0.72, 0, 1);
```

**5.D Duration (UI < 300ms):** press 100-160ms, tooltip 125-200ms, dropdown 150-250ms, modal/drawer 200-500ms.

**5.E Tool (cheapest first):** CSS transition > `@starting-style` > CSS animation > scroll-driven animation / View Transitions > WAAPI > Motion (springs, layout, gestures).

## 6. Motion Mechanics

### 6.A Core

* Animate only `transform`, `opacity` (+ `clip-path`). Never from `scale(0)` - start `0.95` + `opacity: 0`.
* Springs for gestures/interruptible motion; interrupt from the live on-screen value.
* Symmetric enter/exit; `transform-origin` at the trigger (modals exempt). Exit faster than enter.
* Stagger 30-80ms; never block input. Hover behind `@media (hover: hover) and (pointer: fine)`.
* **Mandatory:** every animation justified in one sentence; max one marquee per page.

### 6.B Springs

Damping 1.0 (no bounce) default; ~0.8 only after momentum gestures (flick, drag release). Move `1.0/0.4`, rotate `0.8/0.4`, drawer `0.8/0.3`.

```js
animate(el, { y: 0 }, { type: 'spring', bounce: 0, duration: 0.4 });
```

### 6.C-G Gestures

* **Velocity handoff:** pass release velocity to the spring (`v / (target - current)` if normalized).
* **Momentum projection:** `end = pos + (v / 1000) * d / (1 - d)`, `d = 0.998`, then snap nearest.
* **Interruptible always:** never lock input; split X/Y springs; blend velocity on reversal.
* **Rubber-band edges:** `(o * dim * 0.55) / (dim + 0.55 * |o|)`, never hard stops.
* Pointer capture during drag; ignore extra touches; dismiss on velocity > ~0.11.

### 6.H Materials

Translucent chrome (`backdrop-filter`) with content scrolling under; never light-glass on light-glass; boost text contrast on blur; animate blur + scale together.

## 7. Component Principles

* Press: `scale(0.97)` 160ms ease-out. Tooltips: `popover="hint"` + anchor positioning; delay first, instant after.
* Transitions over keyframes (retarget mid-flight). Small `blur(2px)` hides rough crossfades.
* Enter states via `@starting-style` + `transition-behavior: allow-discrete`. Modals: native `<dialog>` with `closedby`. Hold-to-act: `clip-path` 2s linear in, 200ms out.
* **Header (mandatory):** full-width, square edges (`rounded-none`), never a floating or rounded pill. Pick by theme: `sticky top-0 z-50` with solid or `backdrop-blur` background + bottom hairline for app/dashboard/long-scroll pages; normal static flow for editorial/minimal/landing pages. Nav items inside may use the radius scale.
* **Tabs filled + rounded (mandatory):** active tab = filled background on the page radius scale. No underline-only or bare-text tabs.
* **Selection never border-only (mandatory):** selected dropdown items, cards, options get a distinct background, a filled style, or an all-around border (accent color + 2px weight + tint). Never use a one-side border (`border-l`, `border-t`, etc.) to mark selection or highlight a card.
* **Checkbox & radio filled (mandatory):** checked = accent fill (`accent-color` or custom) + contrasting mark.

## 8. Performance

* CSS variables cascade - set `el.style.transform` for per-frame values. Motion `x`/`y` run on main thread; use a full `transform` string under load.
* Blur/grain only on fixed `pointer-events-none` layers. `animation-timeline: scroll()/view()` or `IntersectionObserver`, never scroll listeners. `will-change` sparingly. No `z-[9999]`; use the top layer (`dialog`, `popover`).
* Lazy-init WebGL/WASM; pause off-screen. **CWV:** LCP < 2.5s, INP < 200ms, CLS < 0.1.

## 9. Accessibility

* WCAG 2.2 AA contrast everywhere; targets 24px minimum, 44px on touch; focus not obscured by sticky chrome; drag actions have a pointer alternative; `rem` spacing.
* **Reduced motion:** cross-fade, not zero: `@media (prefers-reduced-motion: reduce) { transition: opacity 200ms; transform: none }`.
* Reduced transparency: solid surfaces. `prefers-contrast: more`: solid + border. `forced-colors: active`: keep borders and outlines. No full-screen moving backgrounds; soft theme switches.

## 12. Context-Aware Tools

* Glass: premium/media only, with inner border + reduced-transparency fallback. Magnetic physics / perpetual loops: `MOTION > 5` and fitting brief, motion values only.
* `MOTION > 4` means the page visibly moves.
* **Forbidden:** scroll listeners, `scrollY` in state, rAF loops on React state, `layout` props on static content.

## 13. UI Libraries

Base UI 1.0 / Radix (headless), Ark UI, cmdk, sonner (toasts), input-otp, Leva, motion, NumberFlow, torph, Cobe, Satori, shiki, Liveline/recharts, dnd kit, Virtuoso, zustand, clsx/cva. Theme: `color-scheme` + `light-dark()`; next-themes only to persist a manual override. Replace hand-rolled toasts, div dialogs, re-render number tickers, 1k+ unvirtualized rows, nested className ternaries.

## 15. Progressive Enhancement

Gate with `@supports` / feature checks (WebGPU -> WebGL2). Baseline toolkit: View Transitions (same-document and cross-document; React 19.3 `<ViewTransition>` in Next.js 16.4), `@starting-style`, scroll-driven animation, anchor positioning, `@property`, WAAPI, Workers, OffscreenCanvas, WASM. Progressive (Chrome 137+/139+, not Baseline): CSS `if()`, `@function`, `sibling-index()`, `corner-shape`. Polish the last 20%.

## 16. Debugging Animations

Slow-motion (2-5x), DevTools Animations panel frame-by-frame, Chrome DevTools MCP traces for INP, real devices for touch, fresh eyes next day.

## 17. Loved Components

Zero-setup DX (`<Toaster />` + `toast()`); great defaults over options; memorable names; edge cases handled invisibly (pause on hidden tab); transitions over keyframes. Motion matches personality; slow where the user decides, fast where the system responds.

## 18. Apple Foundations

Purpose, Agency (undo over confirms), Responsibility, Familiarity, Flexibility, Simplicity (not minimalism), Craft, Delight. Validate inline; every screen answers where am I / where next / how out; controls mirror what they change; specific labels.

## 19. Reference Vocabulary

* **Hero:** Asymmetric Split, Editorial Manifesto, Video Mask, Kinetic Type, Curtain Reveal, Scroll-Pinned.
* **Nav:** Sticky Header, Static Header, Dock Magnification, Magnetic Button, Gooey Menu, Dynamic Island, Radial Menu, Mega Menu.
* **Layout:** Bento, Masonry, Split-Screen Scroll, Sticky-Stack.
* **Cards:** Parallax Tilt, Spotlight Border, Glass Panel, Swipe Stack, Morphing Modal.
* **Scroll:** Horizontal Hijack, Zoom Parallax, Progress Path. **Media:** Coverflow, Drag-to-Pan, Hover Trail.
* **Text:** Marquee, Mask Reveal, Scramble, Circular Path. **Micro:** Skeleton Shimmer, Ripple, SVG Line Draw, Mesh Gradient.
* **Libraries:** Motion default; GSAP 3.13 (free, all plugins) + ScrollTrigger for scrolltelling, Lenis for smooth scroll; Three.js r186+ / R3F 9 for 3D - isolated leaves with cleanup; never mix GSAP/Three with Motion in one tree.

## 22. Review Fixes

| Issue | Fix |
|---|---|
| `transition: all` | Name properties |
| `scale(0)` entry | `scale(0.95)` + `opacity: 0` |
| `ease-in` | `--ease-out` |
| Popover origin `center` | Trigger origin |
| Keyboard-action animation | Remove |
| UI > 300ms | 150-250ms |
| Ungated hover | `(hover: hover) and (pointer: fine)` |
| Keyframes on rapid triggers | Transitions |
| Equal enter/exit speed | Faster exit |
| Mass mount | 30-80ms stagger |
| Layout-property animation | `transform` / `opacity` |
| No reduced motion | Gentler variant |
