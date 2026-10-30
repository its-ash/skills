---
name: design
description: "Unified frontend design skill from brief to production: content discipline, accessibility, typography, layout composition, motion and spring physics, gestures, component craft, design systems (tokens, theming, dark mode), and modern CSS (Grid, subgrid, container queries, cascade layers, :has(), oklch, scroll-driven animations, view transitions, dialog, anchor positioning). Use when designing websites, landing pages, dashboards, product UIs, app shells, component libraries, animations, or any frontend UI work; writing, reviewing, or debugging CSS; implementing responsive layouts, hero sections, gestures, or spring animations. Sub-skills: immersive-web, figma, mobile-design, brand-theming, motion-canvas."
---

# Design

**Philosophy:** taste is trained; unseen details compound (work exactly as assumed); beauty is leverage.

**Workflow:** brief + dials (§0-1) -> system/aesthetic (§2) -> defaults + bias correction (§3-4) -> motion (§5-7), perf (§8), a11y (§9) -> anti-slop (§10) -> reference (§11-19) -> checks (§21-22) -> CSS depth (§25).

---

## 0. Brief Inference

Read before coding: **page kind**, **vibe words**, **references**, **audience** (picks the aesthetic, not your taste), **brand assets**, **quiet constraints** (a11y-first, public-sector, regulated, kids - these OVERRIDE aesthetics).

Output one line first: **"Reading this as: \<page kind> for \<audience>, with a \<vibe> language, leaning toward \<system/aesthetic>."** Ask at most one question, only if the read truly diverges.

* **Anti-default:** no AI-purple gradients, centered hero on dark mesh, three equal feature cards, generic glassmorphism, infinite micro-loops, Inter + slate-900.
* **Refinement preserves; redesign replaces** (keeps product truth, old look is anti-reference).
* **Mode from surface:** Persuade (marketing - earn attention), Operate (app UI - scanability first), Read (docs - comprehension), Experience (portfolio - artifact leads).

## 1. The Three Dials

`DESIGN_VARIANCE` (1 symmetric - 10 chaos), `MOTION_INTENSITY` (1 static - 10 cinematic), `VISUAL_DENSITY` (1 airy - 10 cockpit). **Baseline `8 / 6 / 4`.**

| Signal / use case | VAR | MOT | DEN |
|---|---|---|---|
| Minimalist / editorial / Linear-style | 5-6 | 3-4 | 2-3 |
| Premium consumer / luxury | 7 | 6 | 3 |
| Playful / Awwwards / agency | 9-10 | 8-10 | 3 |
| Landing (SaaS default) | 7 | 6 | 4 |
| Portfolio designer / developer | 8 / 6 | 7 / 5 | 3 / 4 |
| Editorial / blog | 6 | 4 | 3 |
| Dashboard / product UI | 4-5 | 4-5 | 6-8 |
| Trust-first / public-sector | 3 | 2 | 5 |
| Redesign preserve / overhaul | = / +2 | +1 / +2 | = |

## 2. Design System Selection

Never hand-roll CSS for an official package. **One system per project.**

| Brief | Use |
|---|---|
| Microsoft / enterprise | `@fluentui/react-components` |
| Material | `@material/web` + M3 tokens |
| IBM B2B | `@carbon/react` |
| Shopify / Atlassian / GitHub | Polaris / `@atlaskit/*` / `@primer/*` |
| UK / US public-sector | `govuk-frontend` / `uswds` |
| Accessible React base / own components | `@radix-ui/themes` / shadcn/ui |
| Tailwind SaaS | Tailwind v4 + `dark:` |

**Aesthetics (no library):** glassmorphism (`backdrop-filter` + layered borders, solid fallback for `prefers-reduced-transparency`), bento (mixed Grid cells), brutalism, editorial, dark tech, mesh gradients, kinetic type. Apple Liquid Glass on web = labeled approximation.

## 3. Default Architecture

* **Stack:** React/Next.js Server Components; motion/scroll/pointer code only in `'use client'` leaves. Tailwind v4. Raw CSS -> §25.
* **Animation:** Motion (`motion/react`). **Fonts:** `next/font` or self-hosted + `font-display: swap`; never Google Fonts `<link>`.
* **State:** local first; global only vs prop-drilling. Never `useState` for continuous input - use `useMotionValue`/`useTransform`/`useScroll`.
* **Icons:** `@phosphor-icons/react` > `hugeicons-react` > `@radix-ui/react-icons` > `@tabler/icons-react` (`lucide-react` only if present). One family, global `strokeWidth`, never hand-rolled SVG. **No emoji** unless asked.
* **Layout:** breakpoints `640/768/1024/1280/1536`; `max-w-7xl`; `min-h-[100dvh]` never `h-screen`; Grid over `calc()` flex math.
* **Dependencies (mandatory):** check `package.json`; output install command if missing.

---

## 4. Bias Correction

### 4.1 Typography

* Display `text-4xl md:text-6xl tracking-tighter leading-none`; body `text-base text-gray-600 leading-relaxed max-w-[65ch]`.
* No Inter default (OK for neutral/public-sector) - use Geist, Outfit, Cabinet Grotesk, Satoshi. Pairs: Geist+Geist Mono, Satoshi+JetBrains Mono.
* **Serif:** only when brand/editorial truly justifies. **Banned: Fraunces, Instrument_Serif.** Emphasis = italic/bold of the same font.
* **Italic descenders (mandatory):** `leading-[1.1]` min + `pb-1`.
* Negative tracking at large sizes; leading 1.0-1.1 display, 1.5-1.6 body. No `#000` text. Spacing in `rem`.

### 4.2 Color

* One accent (saturation < 80%), one gray family, no pure `#000`/`#fff`. **Lock (mandatory):** same accent on the whole page.
* **Lila rule:** no default purple/blue glow - neutral base + one sharp accent (Emerald, Electric Blue, Deep Rose, Burnt Orange) unless brand says purple.
* **Premium-consumer ban (mandatory):** no beige/cream + brass/oxblood + espresso. Rotate: Cold Luxury, Forest, Black and Tan, Cobalt + Cream, Terracotta + Slate, mono + one pop.

### 4.3 Layout

Anti-center: no centered hero when `VARIANCE > 4` (split, asymmetric, scroll-pinned) unless editorial/manifesto/launch.

### 4.4 Cards & Shape

Cards only for real hierarchy (else `divide-y` / space); banned at `DENSITY > 7`. Shadows tinted to background. **Shape lock (mandatory):** one radius scale (0, 12-16px, or pill). **Card padding (mandatory):** every card has internal padding on all sides (min `p-4`; `p-6` at `DENSITY` 1-4).

### 4.5 Interactive States

* Loading = layout-shaped skeletons; composed empty states; inline/contextual errors.
* `:active` = `scale-[0.98]` or `-translate-y-[1px]` on pointer-down.
* **Contrast (mandatory):** CTAs, inputs, placeholders, focus rings, helper/error text pass AA (4.5:1 / 3:1 large). No ghost buttons over photos without scrim.
* **CTA (mandatory):** one line at desktop (1-3 words); one label per intent page-wide.

### 4.6 Forms

Label above, helper in markup, error below, `gap-2`. Never placeholder-as-label.

### 4.7 Layout Hard Rules

* **Hero:** fits viewport; headline <= 2 lines, subtext <= 20 words / 4 lines, CTA visible; default `text-4xl md:text-5xl lg:text-6xl` (`7xl` only for 3-5 words); max `pt-24`; max 4 text elements (eyebrow/brand, headline, subtext, 1+1 CTAs). Logo wall goes under the hero.
* **Nav:** one line at desktop, 64-80px tall.
* **Bento (mandatory):** N items = N cells, varied rhythm, 2-3 cells with real visual variation.
* **Repetition:** each layout family max twice; 8 sections need >= 4 families; max 2 consecutive image+text splits.
* **Eyebrows (mandatory):** <= `ceil(sections / 3)`, default none. **Split headers banned.**
* **Mobile collapse explicit per section:** `grid-cols-1`, remove rotation/overlap < 768px, floor `w-full px-4 py-8`.

### 4.8 Images

Order: image-gen tool -> `picsum.photos/seed/{seed}/{w}/{h}` / provided URLs -> labeled slots. Minimal sites still need real images. Logos via Simple Icons CDN, no category labels. **Banned:** div-based fake screenshots, decorative hand-rolled SVG, text + blob heroes.

### 4.9 Content Density

* Per section: headline <= 8 words, sub <= 25 words, one visual or CTA.
* No data dumps: top 3-5 + "View all". Lists > 5 -> grouped split, card grid, tabs, pills, carousel. No `border-b` spec tables.
* **Copy audit (mandatory):** rewrite broken, vague, or LLM-sounding strings. Precise numbers must be real or labeled mock. One copy register.

### 4.10 Quotes

Max 3 lines; name + role (+ company); real typographic quotes.

### 4.11 Theme Lock

One theme per page, set at root; no inverted sections (except a deliberate single theme switch). Respect `prefers-color-scheme`.

---

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

**5.E Tool (cheapest first):** CSS transition > `@starting-style` > CSS animation > WAAPI > Motion (springs, layout, gestures).

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

* Press: `scale(0.97)` 160ms ease-out. Tooltips: delay first, instant after.
* Transitions over keyframes (retarget mid-flight). Small `blur(2px)` hides rough crossfades.
* Enter states via `@starting-style` (fallback `data-mounted`). Hold-to-act: `clip-path` 2s linear in, 200ms out.
* **Floating Pill Nav (default nav):** `rounded-full bg-white shadow-lg/50` over blurred backdrop, text tabs, right accent pill with icon + label + badge.

### Component Selection & Tabs

* **Tabs filled + rounded (mandatory):** active tab = filled background on the page radius scale. No underline-only or bare-text tabs.
* **Selection never border-only (mandatory):** selected dropdown items, cards, options get a distinct background, a filled style, or an all-around border (accent color + 2px weight + tint). Never use a one-side border (`border-l`, `border-t`, etc.) to mark selection or highlight a card.
* **Checkbox & radio filled (mandatory):** checked = accent fill (`accent-color` or custom) + contrasting mark.

## 8. Performance

* CSS variables cascade - set `el.style.transform` for per-frame values. Motion `x`/`y` run on main thread; use a full `transform` string under load.
* Blur/grain only on fixed `pointer-events-none` layers. `IntersectionObserver`, never scroll listeners. `will-change` sparingly. No `z-[9999]`.
* Lazy-init WebGL/WASM; pause off-screen. **CWV:** LCP < 2.5s, INP < 200ms, CLS < 0.1.

## 9. Accessibility

* AA contrast everywhere; touch targets 44px; `rem` spacing.
* **Reduced motion:** cross-fade, not zero: `@media (prefers-reduced-motion: reduce) { transition: opacity 200ms; transform: none }`.
* Reduced transparency: solid surfaces. `prefers-contrast: more`: solid + border. No full-screen moving backgrounds; soft theme switches.

## 10. Anti-Slop

* **Banned words:** Elevate, Seamless, Unleash, Next-Gen, Game-changer, Delve, Revolutionize.
* **Banned content:** John Doe, Acme, Nexus, Lorem Ipsum, egg avatars, fake-perfect numbers.
* **Banned visuals:** neon glows, gradient text headers, custom cursors, oversized H1s, 3 equal feature cards, default shadcn.
* **Banned tells:** em-dashes anywhere (hyphen only); hero version labels; `01 / 4` and section-number eyebrows; date-range labels; > 1 middle-dot per line; status/decorative dots; default `<br>` italic headlines; rotated text; crosshair grids; fake hero UI; "Quietly trusted by"; "Field notes" labels; weather/city strips; micro-meta sentences; "Phase 01"; pills over images; photo credits; version footers; hero-bottom strips; floating top-right sub-text; filled-track score bars; scroll cues; bordered every-row lists.

## 11. Dial Definitions

* **VARIANCE** 1-3 centered 12-col; 4-7 offsets, mixed ratios; 8-10 masonry, `2fr 1fr 1fr`, big empty zones. 4+ collapses to one column < 768px.
* **MOTION** 1-3 hover/active only; 4-7 CSS transitions + cascades; 8-10 scroll choreography via Motion hooks.
* **DENSITY** 1-3 `py-32+`; 4-7 `py-16-24`; 8-10 tight, no cards, 1px rules, `font-mono` numbers.

## 12. Context-Aware Tools

* Glass: premium/media only, with inner border + reduced-transparency fallback. Magnetic physics / perpetual loops: `MOTION > 5` and fitting brief, motion values only.
* `MOTION > 4` means the page visibly moves.
* **Forbidden:** scroll listeners, `scrollY` in state, rAF loops on React state, `layout` props on static content.

## 13. UI Libraries

base-ui (headless), cmdk, sonner (toasts), input-otp, Leva, motion, NumberFlow, torph, Cobe, Satori, shiki, Liveline/recharts, dnd kit, Virtuoso, zustand, next-themes, clsx/cva. Replace hand-rolled toasts, div dialogs, re-render number tickers, 1k+ unvirtualized rows, nested className ternaries.

## 14. Redesign Protocol

* **Mode:** Greenfield, Preserve (evolve brand), Overhaul (new visuals, keep content + IA). Ambiguous -> ask once.
* **Audit:** tokens, IA, content, patterns to keep/retire, current dials, SEO baseline (#1 risk).
* **Preserve:** IA, slugs, brand colors, voice, a11y wins, analytics IDs.
* **Levers in order:** type -> spacing -> color -> motion -> key sections -> block replacement.
* **Never change silently:** URLs, nav labels, form fields, logo, legal/consent copy.

## 15. Progressive Enhancement

Gate with `@supports` / feature checks (WebGPU -> WebGL2). Toolkit: View Transitions, `@starting-style`, scroll-driven animation, `@property`, WAAPI, Workers, OffscreenCanvas, WASM. Polish the last 20%.

## 16. Debugging Animations

Slow-motion (2-5x), DevTools Animations panel frame-by-frame, real devices for touch, fresh eyes next day.

## 17. Loved Components

Zero-setup DX (`<Toaster />` + `toast()`); great defaults over options; memorable names; edge cases handled invisibly (pause on hidden tab); transitions over keyframes. Motion matches personality; slow where the user decides, fast where the system responds.

## 18. Apple Foundations

Purpose, Agency (undo over confirms), Responsibility, Familiarity, Flexibility, Simplicity (not minimalism), Craft, Delight. Validate inline; every screen answers where am I / where next / how out; controls mirror what they change; specific labels.

## 19. Reference Vocabulary

* **Hero:** Asymmetric Split, Editorial Manifesto, Video Mask, Kinetic Type, Curtain Reveal, Scroll-Pinned.
* **Nav:** Floating Pill Nav, Dock Magnification, Magnetic Button, Gooey Menu, Dynamic Island, Radial Menu, Mega Menu.
* **Layout:** Bento, Masonry, Split-Screen Scroll, Sticky-Stack.
* **Cards:** Parallax Tilt, Spotlight Border, Glass Panel, Swipe Stack, Morphing Modal.
* **Scroll:** Horizontal Hijack, Zoom Parallax, Progress Path. **Media:** Coverflow, Drag-to-Pan, Hover Trail.
* **Text:** Marquee, Mask Reveal, Scramble, Circular Path. **Micro:** Skeleton Shimmer, Ripple, SVG Line Draw, Mesh Gradient.
* **Libraries:** Motion default; GSAP + ScrollTrigger for scrolltelling; Three.js for 3D - isolated leaves with cleanup; never mix GSAP/Three with Motion in one tree.

## 20. Out of Scope

Dense dashboards/admin (Fluent, Carbon, Polaris), data tables (TanStack Table, AG Grid), wizards, code editors (Monaco), native mobile (HIG/Material), realtime collab. Say so and apply only marketing parts.

---

## 21. Pre-Flight Check (mandatory)

- [ ] Design read + dials declared; system honest (§2); redesign audited (§14)
- [ ] One theme, accent, radius scale; zero em-dashes; no banned serif/palette; descender clearance
- [ ] AA contrast on CTAs/forms/focus; CTAs one line; one label per intent; empty/loading/error states; reduced motion; dark mode tested
- [ ] Hero rules; eyebrow cap; no split headers; zigzag cap; >= 4 layout families; bento cell count; logo wall under hero
- [ ] Nav one line <= 80px; explicit mobile collapse; `100dvh`
- [ ] Real images; no fake screenshots; lists > 5 reshaped; quotes <= 3 lines
- [ ] Filled rounded tabs; selection not border-only; filled checkbox/radio
- [ ] No §10 tells
- [ ] Every animation justified; motion shown if claimed; one marquee max; no scroll listeners; `useEffect` cleanup
- [ ] Allowed icon library; CWV plausible; one design system

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

## 23. Prototyping Variants

Isolated surface, never production code. 3-5 variants diverging on a named axis, named by direction ("Quiet", "Dense", never "Option A"), fully working. Picker harness -> verify -> user chooses -> promote -> delete prototype.

## 24. Default Site Packs

* **4:** Hero, Features, Social proof, CTA.
* **8:** + Trust bar, Showcase, Use cases, Pricing.
* **12:** + Feature grid, Preview, Problem/solution, Workflow, Metrics/integrations, FAQ.

---

## 25. CSS Implementation

Apply core rules always; read the matching `references/css/` file before non-trivial work; check `browser-support.md` for partial features.

### 25.B Core Rules

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

### 25.C Decision Guide

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

### 25.D References (`references/css/`)

`layout.md` (Flex, Grid, positioning), `responsive.md` (queries, fluid, units), `selectors-cascade.md` (`@layer`, `@scope`, `:has()`), `custom-properties-math.md` (`@property`, math, `if()`), `color.md` (OKLCH, dark mode), `visual-effects.md` (gradients, shadows, masks), `typography.md` (fonts, scales), `animation-motion.md` (transitions, scroll-driven, view transitions), `components-ui.md` (forms, dialog, popover, carousel), `svg.md`, `accessibility.md`, `performance.md`, `architecture-tooling.md` (tokens, Tailwind, linting), `frontend-js.md` (DOM, web components), `browser-support.md` (Baseline, Oct 2026).

### 25.E CSS Pre-Flight

- [ ] Fallbacks work; keyboard + visible focus; DOM order = visual order
- [ ] Contrast in light, dark, forced-colors; reduced motion respected
- [ ] Holds at 320px and 200% zoom; no CLS; LCP not lazy
- [ ] Tokens over hard-coded values; flat selectors

## 26. Design Systems

**Workflow:** principles -> tokens (palette 50-950, modular type, 8pt spacing, radius, shadows, breakpoints) -> theming -> atomic components -> a11y -> docs -> semver.

* **Tokens:** one versioned source; UI uses semantic tokens (`color.semantic.brand.primary`) that reference primitives.
* **Theming:** swap semantic tokens via `data-theme` on `<html>`, ThemeProvider, or Tailwind `dark:`.
* **Components:** atoms -> molecules -> organisms -> templates -> pages; props `variant`/`size`/`disabled`/`loading`; composition (`<Card.Header>`) over boolean props; polymorphic `as`.
* **A11y (WCAG 2.1 AA):** keyboard reach, `:focus-visible`, modal focus traps, `aria-label` on icon buttons, `aria-expanded`, `role="alert"`; axe + manual tests; Storybook a11y addon.
* **Pitfalls:** hard-coded values, inconsistent props, missing focus, unchecked dark contrast, unversioned tokens.

## Sub-skills

`design` is the umbrella; load a sub-skill only when needed, then return here.

| Sub-skill | Use when |
|---|---|
| [`mobile-design`](references/mobile-design.md) | iOS/Android conventions, touch targets, React Native, Flutter, phone/tablet layouts |
| [`brand-theming`](references/brand-theming.md) | Enforcing brand colors, type, identity across decks, docs, UI |
| [`figma`](references/figma.md) | Figma node to production code with 1:1 parity |
| [`immersive-web`](references/immersive-web.md) | GSAP ScrollTrigger, parallax, React Three Fiber, Three.js, WebGL |
| [`motion-canvas`](references/motion-canvas.md) | Motion Canvas scenes, Vite plugin setup, video export |
| [`visual-design-direction`](references/visual-design-direction.md) | Opinionated visual direction: type, color, layout, motion, 3D |

## Related skills

- [`frontend-development`](../frontend-development/SKILL.md) - React/Next.js, TypeScript, MUI, TanStack
- [`ux-research`](../ux-research/SKILL.md) - personas, journeys, usability tests
- [`web-accessibility`](../web-quality-audit/references/web-accessibility.md) - WCAG 2.1 and ARIA audits
- [`web-performance`](../web-quality-audit/references/web-performance.md) - Core Web Vitals diagnosis
