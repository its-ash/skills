---
name: design
description: "Unified frontend design skill covering the full lifecycle from brief inference to production, combining content discipline, accessibility, motion mechanics, typography, performance, layout composition, animation frameworks, spring physics, gesture interactions, component craftsmanship, fluid interface principles, progressive enhancement, design-system selection and building (design tokens, atomic component architecture, theming, dark mode), and modern CSS implementation with Grid, subgrid, container queries, cascade layers, :has(), custom properties, oklch, scroll-driven animations, view transitions, native dialog and anchor positioning. Use when designing websites, landing pages, dashboards, product UIs, app shells, component libraries, animations, or any frontend UI work; writing, reviewing, or debugging CSS, styling HTML or JS; implementing responsive collapse, hero sections, grid mechanics, gesture handling, spring animations, or progressive enhancement."
---

# Design

A single unified skill that encodes everything needed to build interfaces that feel right.

## Core Philosophy

- **Taste is trained, not innate** - surround yourself with great work, think about why it feels good, practice relentlessly.
- **Unseen details compound** - when a feature works exactly as assumed, users proceed without noticing. That is the goal.
- **Beauty is leverage** - good defaults and animations are real differentiators. Use them to stand out.

## Workflow Map

1. Read the brief and set dials (§0-1)
2. Pick a design system or aesthetic honestly (§2)
3. Follow stack defaults and bias-correction directives (§3-4)
4. Apply motion rules (§5-7, §17-18), performance (§8), accessibility (§9)
5. Enforce anti-slop content discipline (§10)
6. Consult technical reference sections as needed (§11-19)
7. Run the checks before delivering (§21-22)
8. Use CSS reference files for implementation depth (§25)

**Scope note (§20):** not for dashboards/data tables/wizards/code editors/native mobile/realtime collab - point to Fluent/Carbon/TanStack/Monaco/HIG instead, and apply only the marketing-page parts where they fit.

---

## 0. Brief Inference (Read the Room Before Anything Else)

Before touching code, infer what the user actually wants. Most bad design output comes from jumping to a default aesthetic instead of reading the room.

**Signals to read:**
1. **Page kind** - landing (SaaS/consumer/agency/event), portfolio, redesign, editorial/blog, dashboard, product UI, app shell, component, settings.
2. **Vibe words** - "minimalist", "Linear-style", "Awwwards", "brutalist", "premium consumer", "playful", "serious B2B", "editorial", "glassy", "dark tech".
3. **References** - URLs, screenshots, products named, brands they compete with.
4. **Audience** - B2B panel vs design-conscious consumer vs recruiter. The audience picks the aesthetic, not your taste.
5. **Existing brand assets** - logo, color, type, photography. For redesigns, starting material.
6. **Quiet constraints** - accessibility-first, public-sector, regulated, trust-first commerce, kids' products. These OVERRIDE aesthetic preference.

**Output** a one-line Design Read before any code: **"Reading this as: \<page kind> for \<audience>, with a \<vibe> language, leaning toward \<design system or aesthetic family>."**

**Ambiguity:** ask at most **one** clarifying question, only when the read genuinely diverges. If you can infer, declare the read and proceed.

**Anti-Default Discipline.** Never default to AI-purple gradients, centered hero on dark mesh, three equal feature cards, generic glassmorphism, infinite-loop micro-animations everywhere, Inter + slate-900. Reach past them deliberately.

**Refinement preserves; redesign replaces.** Refinement keeps incumbent identity, behavior, copy, everything outside scope. Redesign keeps product truth and function but treats the old look as anti-reference. Never polish the discarded look.

**Layout mode from the surface, not the product:**
- **Persuade** (landing/marketing/pricing): design is the product. Earn attention.
- **Operate** (app UI/dashboards/editors/settings): scanability and native expectations outrank expression. Brand lives in precise details.
- **Read** (docs/articles): comprehension first, then make staying worthwhile.
- **Experience** (portfolios/galleries): let the artifact lead from the first viewport.

---

## 1. The Three Dials (Core Configuration)

After the design read, set three dials. Every layout, motion, and density decision is gated by these.

* **`DESIGN_VARIANCE: 8`** (1 = Perfect Symmetry, 10 = Artsy Chaos)
* **`MOTION_INTENSITY: 6`** (1 = Static, 10 = Cinematic / Physics)
* **`VISUAL_DENSITY: 4`** (1 = Art Gallery / Airy, 10 = Cockpit / Packed Data)

**Baseline: `8 / 6 / 4`.** Use unless the design read overrides.

**Dial inference:**

| Signal | VARIANCE | MOTION | DENSITY |
|---|---|---|---|
| "minimalist / clean / calm / editorial / Linear-style" | 5-6 | 3-4 | 2-3 |
| "premium consumer / Apple-y / luxury / brand" | 7-8 | 5-7 | 3-4 |
| "playful / wild / Awwwards / experimental / agency" | 9-10 | 8-10 | 3-4 |
| "landing / portfolio / marketing (default)" | 7-9 | 6-8 | 3-5 |
| "trust-first / public-sector / regulated / a11y-critical" | 3-4 | 2-3 | 4-5 |
| "redesign - preserve" | match existing | +1 | match existing |
| "redesign - overhaul" | +2 | +2 | match existing |

**Use-case presets:**

| Use case | VARIANCE | MOTION | DENSITY |
|---|---|---|---|
| Landing (SaaS, mainstream) | 7 | 6 | 4 |
| Landing (Agency / creative) | 9 | 8 | 3 |
| Landing (Premium consumer) | 7 | 6 | 3 |
| Portfolio (Designer / studio) | 8 | 7 | 3 |
| Portfolio (Developer) | 6 | 5 | 4 |
| Editorial / Blog | 6 | 4 | 3 |
| Dashboard / Product UI | 4-5 | 4-5 | 6-8 |
| Public-sector service | 3 | 2 | 5 |

---

## 2. Design System Selection

Do not invent CSS for things that have an official package. Do not pretend an aesthetic trend is an official system.

### 2.A When to reach for a real design system

| Brief reads as... | Reach for |
|---|---|
| Microsoft / enterprise SaaS / dashboards | `@fluentui/react-components` or `@fluentui/web-components` |
| Google-ish UI, Material-flavored product | `@material/web` + Material 3 tokens |
| IBM-style B2B / enterprise analytics | `@carbon/react` + `@carbon/styles` |
| Shopify app surfaces | `polaris.js` web components / Polaris React |
| Atlassian / Jira-style product | `@atlaskit/*` + `@atlaskit/tokens` |
| GitHub-style devtool / community page | `@primer/css` or `@primer/react-brand` |
| Public-sector UK service | `govuk-frontend` |
| US public-sector / trust-first | `uswds` |
| Modern accessible React foundation | `@radix-ui/themes` |
| Modern SaaS where you own the components | shadcn/ui (`npx shadcn@latest add ...`) |
| Tailwind-based modern SaaS / AI marketing | Tailwind v4 utilities + `dark:` variant |

**Honesty rule:** if the brief reads as one of the systems above, install and use the **official** package. Do not recreate its CSS by hand. **One system per project.** Do not mix design systems in the same tree.

### 2.B When the brief is an aesthetic, not a system

| Aesthetic | Honest implementation |
|---|---|
| Glassmorphism / "frosted glass" | `backdrop-filter`, layered borders, highlight overlays. Solid-fill fallback for `prefers-reduced-transparency`. |
| Bento (Apple-style tile grids) | CSS Grid with mixed cell sizes. No single library owns this. |
| Brutalism | Native CSS, monospace, raw borders. No library. |
| Editorial / magazine | Serif type, asymmetric grid, generous whitespace. No library. |
| Dark tech / hacker | Mono + accent neon, terminal motifs. No library. |
| Aurora / mesh gradients | SVG or layered radial gradients. No library. |
| Kinetic typography | Native CSS animations, scroll-driven animations, GSAP for hijacks. No library. |
| Apple Liquid Glass | Apple documents this for Apple platforms only. Web implementations are approximations using `backdrop-filter` + layered borders + highlights. Label clearly as approximation. |

---

## 3. Default Architecture & Conventions

Defaults unless the design read picks a real design system (§2.A):

* **Stack:** React / Next.js with Server Components; `"use client"` providers; Motion, scroll listeners, pointer physics only in isolated `'use client'` leaf components. Tailwind v4 default (`@tailwindcss/postcss` or Vite plugin, v3 only if the project demands it). Raw CSS: apply §25 + `references/css/`.
* **Animation:** Motion (`motion/react`).
* **Fonts:** `next/font` or self-hosted `@font-face` + `font-display: swap`. Never Google Fonts `<link>` in production.
* **State:** local `useState`/`useReducer` for isolated UI; global (Zustand, Jotai, context) only to avoid deep prop-drilling. **Never** `useState` for continuous input-driven values (mouse, scroll, pointer physics) - use `useMotionValue` / `useTransform` / `useScroll`.
* **Icons:** `@phosphor-icons/react` > `hugeicons-react` > `@radix-ui/react-icons` > `@tabler/icons-react`. `lucide-react` only if already in the project. Never hand-roll SVG; one family per project; global `strokeWidth` (1.5 or 2.0).
* **Emoji:** discouraged in code, markup, visible text. Only on explicit playful/social-native ask, sparingly.
* **Breakpoints:** `sm 640 / md 768 / lg 1024 / xl 1280 / 2xl 1536`. Contain with `max-w-[1400px]` or `max-w-7xl`.
* **Viewport stability:** `min-h-[100dvh]`, never `h-screen` (iOS Safari address-bar jumps).
* **Grid over flex-math:** never `w-[calc(33%-1rem)]`; use `grid grid-cols-1 md:grid-cols-3 gap-6`.
* **Dependency verification (mandatory):** check `package.json` before importing; if missing, output the install command first.

---

## 4. Design Engineering Directives (Bias Correction)

LLMs default to cliches. Override proactively. Each rule has a context-aware override path.

### 4.1 Typography

* Display default: `text-4xl md:text-6xl tracking-tighter leading-none`. Body default: `text-base text-gray-600 leading-relaxed max-w-[65ch]`.
* Sans choice: avoid `Inter` as default - pick `Geist`, `Outfit`, `Cabinet Grotesk`, `Satoshi`, or a brand-appropriate face first. **Override:** Inter OK for neutral / Linear-style / public-sector / a11y-first briefs. Pairings: `Geist`+`Geist Mono`, `Satoshi`+`JetBrains Mono`, `Cabinet Grotesk`+`Inter Tight`, `GT America`+`IBM Plex Mono`.
* **Serif discipline:** very discouraged as default. Only when the brand names a serif, or the aesthetic is genuinely editorial / luxury / publication / heritage AND a specific serif is justifiable. **Banned defaults: `Fraunces`, `Instrument_Serif`.** If justified (rare), rotate: PP Editorial New, GT Sectra Display, Cardinal Grotesque, Reckless Neue, Tiempos Headline, Recoleta, Cormorant Garamond, Playfair Display, EB Garamond, IvyPresto, Migra, Editorial Old, Saol Display.
* **Emphasis rule:** emphasize with italic/bold of the SAME font - never inject a random serif word into a sans headline.
* **Italic descender clearance (mandatory):** italic display words with descenders (`y g j p q`) get `leading-[1.1]` min + `pb-1`/`mb-1` reserve, or the descender clips.
* Tracking is size-specific (negative `-0.02em` to `-0.04em` at large sizes, ~0 on body); leading tracks size inversely (1.0-1.1 display, 1.5-1.6 body). Build hierarchy from weight + size + leading together.
* No absolute `#000` body text - off-black/charcoal for legibility and warmth.
* Respect the user's text-size setting: spacing in `rem`/`em`, not fixed `px`.

### 4.2 Color

* Max 1 accent color, saturation < 80% default. One palette per project (no mixing warm and cool grays). No pure `#000000`/`#ffffff` - off-black/off-white only.
* **Lila rule:** AI-purple / blue-glow aesthetic discouraged as default; no automatic purple glows or neon gradients. Neutral bases (Zinc/Slate/Stone) + high-contrast singular accents (Emerald, Electric Blue, Deep Rose, Burnt Orange). **Override:** brand explicitly asks for purple - then execute with intent.
* **Color consistency lock (mandatory):** one accent used on the WHOLE page - a warm-grey site never gets a blue CTA in section 7.
* **Premium-consumer palette ban (mandatory):** warm beige/cream + brass/clay/oxblood + espresso/ink is the banned LLM default for premium-consumer briefs. Rotate alternatives: Cold Luxury (silver-grey + chrome), Forest (deep green + bone + amber), Black and Tan (off-black + warm tan), Cobalt + Cream, Terracotta + Slate, Olive + Brick + Paper, monochrome + single saturated pop.

### 4.3 Layout Diversification

* **Anti-center bias:** avoid centered hero/H1 when `DESIGN_VARIANCE > 4` - force split screen, left content / right asset, asymmetric whitespace, or scroll-pinned. **Override:** centered hero OK for editorial / manifesto / launch announcements.

### 4.4 Materiality, Shadows, Cards

* Cards ONLY when elevation communicates real hierarchy - otherwise `border-t`, `divide-y`, or negative space.
* Tint shadows to the background hue; no pure-black shadows on light backgrounds. For `VISUAL_DENSITY > 7`, card containers are banned.
* **Shape consistency lock (mandatory):** ONE corner-radius scale for the page - all-sharp (0), all-soft (12-16px), or all-pill. Mixed only with a documented, followed rule.

### 4.5 Interactive UI States

LLMs default to "static successful state only." Always implement full cycles:

* **Loading:** skeletal loaders matching the final layout shape - no generic spinners. **Empty states:** composed, show how to populate. **Error states:** inline (forms) or contextual toasts (transient only).
* **Tactile feedback:** `:active` uses `-translate-y-[1px]` or `scale-[0.98]`, triggered on pointer-down not release.
* **Button contrast check (mandatory, a11y):** every CTA passes WCAG AA (4.5:1 body, 3:1 large text). Banned: white-on-white, `bg-white` + `text-white`, borderless transparent-on-background, ghost buttons over photos (add backdrop/scrim/stroke).
* **CTA wrap ban (mandatory):** button text fits one line at desktop - shorten (max 3 words, ideally 1-2) or widen; never constrain CTA `max-width`.
* **No duplicate CTA intent (mandatory):** one label per intent across the whole page (nav, hero, footer).
* **Form contrast check (mandatory):** inputs, placeholders, focus rings, helper and error text all pass AA against the section background.

### 4.6 Data & Form Patterns

Label ABOVE input, optional helper text present in markup, error text BELOW. `gap-2` input blocks. No placeholder-as-label. Ever.

### 4.7 Layout Discipline (Hard Rules)

* **Hero fits the initial viewport:** headline max 2 lines, subtext max 20 words AND 3-4 lines, CTAs visible without scroll. If copy is too long, reduce font scale or cut copy - never force scroll to find the CTA.
* **Hero font-scale discipline:** plan font and image size together. Headline > 6 words + large asset -> do not start at `text-7xl/8xl`. Sensible default: `text-4xl md:text-5xl lg:text-6xl`; `text-6xl md:text-7xl` only for 3-5 word headlines. A 4-line hero headline is always a font-size error, never a copy-length error.
* **Hero top-padding cap (mandatory):** max `pt-24` at desktop - more reads as a layout bug.
* **Hero stack discipline (max 4 text elements):** (1) eyebrow OR brand strip OR neither, (2) headline, (3) subtext, (4) CTAs (1 primary + max 1 secondary). BANNED in hero: taglines below CTAs, trust micro-strips, pricing teasers, feature bullets, social-proof avatar rows. "Used by / Trusted by" logo wall lives UNDER the hero, never inside.
* **Navigation single-line at desktop;** condense labels, drop secondary items, or hamburger if items don't fit at `lg`. Height cap 80px, default 64-72px.
* **Bento rhythm + exact cell count (mandatory):** vary composition (no 6 stacked identical rows); N content items -> N cells, never a blank tile - re-shape the grid instead.
* **Section-layout-repetition ban:** a layout family appears at most once more. An 8-section page needs at least 4 distinct layout families.
* **Zigzag alternation cap (mandatory):** max 2 consecutive image+text split sections; the 3rd is a failure. Break with full-width, vertical-stack, bento, marquee, or another family.
* **Eyebrow restraint (mandatory, #1 violated rule):** eyebrow = small uppercase wide-tracked label above a headline. Max 1 per 3 sections (hero counts). Mechanical check: `uppercase tracking` instances <= `ceil(sectionCount / 3)`. Default to none.
* **Split-header ban (mandatory):** "left big headline + right small explainer" as a section header is banned. One focused message per section; if both are genuinely needed, stack vertically (headline, body below, 65ch).
* **Bento background diversity (mandatory):** at least 2-3 cells get real visual variation (image, gradient, pattern, tinted background) - an all-white-typography grid is the AI default.
* **Mobile collapse explicit per section**, declared in the same component:
  * Asymmetric bento -> `grid-cols-1`, generous vertical gaps, `col-span` resets to 1.
  * Overlapping/rotated cascade cards -> remove rotation and overlap below 768px (touch-target conflicts).
  * Editorial split -> full-width vertical stack; keep horizontal scroll on the content block if that degrades best.
  * Universal floor: asymmetric layouts fall back to `w-full px-4 py-8` below 768px.

### 4.8 Image & Visual Asset Strategy

* **Priority order:** (1) image-generation tool if available - section-specific assets at the right aspect ratio; (2) real web images - `https://picsum.photos/seed/{seed}/{w}/{h}`, provided stock/brand URLs, open-license sources if explicitly allowed; (3) last resort - clearly-labeled placeholder slots and tell the user exactly what's missing.
* **Even minimalist sites need real images** - a pure-text page is incomplete, not minimalist (2-3 quieter images is fine).
* **Real company logos for social proof:** Simple Icons CDN (`https://cdn.simpleicons.org/{slug}`) or devicon; for invented brands, a simple monogram SVG. **Logo-only rule (mandatory):** no industry/category labels below logos.
* Hand-rolled decorative SVG illustrations strongly discouraged except simple requested geometric marks.
* **Div-based fake screenshots banned** (fake dashboards/terminals/task lists from `<div>` rectangles) - use a real screenshot, generated image, or none.
* Text + gradient blob is not a hero; it's a placeholder.

### 4.9 Content Density

Landing pages live on the **first impression**, not the full read. Cut ruthlessly.

* **Default per section:** headline (<= 8 words) + sub-paragraph (<= 25 words) + one visual OR one CTA. Anything more must be justified.
* **No data-dump sections:** 20-row tables, 30-row award lists, giant pricing matrices get Top 3-5 highlights + "View full list" link, a carousel/marquee, or a different page entirely.
* **Long lists (> 5 items) need a different UI component, not a longer list:** 2-column grouped split, card grid, tabs/accordion, horizontal scroll-snap pills, carousel, marquee. Spec tables with `border-b` on every row are the AI default - banned; same alternatives.
* **Copy self-audit (mandatory before ship):** re-read every visible string; rewrite anything grammatically broken, with unclear referents, hallucinated-sounding, or LLM-smart-sounding.
* **Fake-precise numbers flagged:** `92%`, `4.1x`, `48k` must be real data, explicitly-labeled mock, or dropped.
* One copy register per page - don't mix technical mono, editorial prose, and marketing punch unless the brand voice calls for it.

### 4.10 Quotes & Testimonials

Max 3 lines of body (cut longer originals). Attribution: name + role + optionally company, never name only. Real typographic quotes or none.

### 4.11 Page Theme Lock

The page has ONE theme; sections do not invert. All dark or all light - no sandwiched inverted sections. **Exception:** the brief explicitly calls for a deliberate "Color Block Story" / "Theme Switch on Scroll" device (one full switch, strong transition). Set theme once in `layout.tsx` or page root, never per-section. Respect `prefers-color-scheme` unless the brand insists on one mode.

---

## 5. The Animation Decision Framework

Before writing any animation code, answer in order:

**5.A Should this animate at all?** - gate on frequency:

| Frequency | Decision |
|---|---|
| 100+ times/day (keyboard shortcuts, palette toggle) | **No animation. Ever.** |
| Tens of times/day (hover, list navigation) | Near-imperceptible - fast and subtle, or nothing |
| Occasional (modals, drawers, toasts) | Standard animation |
| Rare / first-time (onboarding, success, celebration) | The delight budget lives here |

Never animate keyboard-initiated actions (Raycast has no open/close animation - that's optimal for something used hundreds of times a day).

**5.B What is the purpose?** Name it before continuing: **Feedback** (interface heard the user), **Spatial consistency** (where something came from/went), **State indication** (legible state change), **Preventing a jarring change** (bridge teleporting content), **Explanation** (marketing/onboarding only), **Delight** (rare/first-time tier only). Can't name it? Don't build it. Also check function: data the user reads or acts on must not move for style - decorative mouse-tracking belongs on marketing pages, not banking-app graphs.

**5.C Easing:**

| Situation | Easing |
|---|---|
| Entering or exiting | `ease-out` |
| Moving / morphing on screen | `ease-in-out` |
| Hover / color change | `ease` |
| Constant motion (marquee, progress) | `linear` |
| Default | `ease-out` |

Never `ease-in` on UI - it delays the exact moment the user watches most. Built-in easings are weak; use:

```css
--ease-out: cubic-bezier(0.23, 1, 0.32, 1);        /* strong ease-out for UI */
--ease-in-out: cubic-bezier(0.77, 0, 0.175, 1);    /* strong ease-in-out */
--ease-drawer: cubic-bezier(0.32, 0.72, 0, 1);     /* iOS-like drawer curve */
```

**5.D Duration - UI stays under 300ms** (a 180ms dropdown feels more responsive than a 400ms one; a faster spinner makes identical load times feel faster):

| Element | Duration |
|---|---|
| Button press feedback | 100-160ms |
| Tooltips, small popovers | 125-200ms |
| Dropdowns, selects | 150-250ms |
| Modals, drawers | 200-500ms |
| Marketing / explanatory | Can be longer |

**5.E Pick the tool - cheapest that works:** CSS transition (hover/press/color/state toggle) > CSS `@starting-style` (mount entry, no JS) > CSS animation (predetermined motion, runs off main thread) > WAAPI (programmatic + CSS performance) > Motion (springs, layout, exit, gesture-driven). CSS beats JS under load - it runs off the main thread while `requestAnimationFrame`-based animation drops frames during page loads. CSS for predetermined motion, JS for dynamic and interruptible motion.

---

## 6. Motion Mechanics (Applies to Every Theme and Layout)

### 6.A Core Principles

* Animate only `transform` and `opacity` (compositor-only); `clip-path` is the sanctioned fourth. Never `width`, `height`, `top`, `left`, `margin`, `padding` (accordions tolerate `height` only because there's no transform equivalent).
* Never `scale(0)` on entrance - start `scale(0.9-0.97)` + `opacity: 0`; nothing appears from nothing. Never `ease-in` on UI. UI stays under 300ms (§5.D).
* Springs for anything gesture-driven or interruptible - they carry velocity through interruption; keyframes restart from zero.
* Always animate from the current on-screen value, never the target, when interrupting - read the live transform.
* Symmetric enter/exit paths (slide in from the right -> dismiss to the right). `transform-origin` anchors to the trigger for popovers/menus/tooltips; modals exempt (not trigger-anchored).
* Stagger, don't mass-mount: lists/grids enter with a 30-80ms cascade, never all at once.
* Gate hover on real pointers: `@media (hover: hover) and (pointer: fine)` - touch fires false hover on tap.
* Frequency gates whether it animates at all (§5.A). Exit faster than entrance: slow where the user is deciding, fast where the system is responding.
* **Motion must be motivated (mandatory):** each animation communicates something (hierarchy, storytelling, feedback, state transition) you can articulate in one sentence - not "it looked cool".
* **Marquee max-one-per-page (mandatory).**

### 6.B Spring Physics (Apple-Inspired)

Apple replaced mass/stiffness/damping with two designer-friendly parameters: **damping ratio** (1.0 = critically damped, no bounce; < 1.0 overshoots; lower = bouncier) and **response** (seconds to reach target; lower = snappier - a spring has no fixed duration, its settle time emerges from the parameters).

Defaults: start most UI at **damping 1.0**; add bounce (~0.8) only when the gesture itself carried momentum (flick, throw, drag release) - overshoot on a menu that faded in feels wrong; overshoot on a card you flicked feels right. Keep bounce 0.1-0.3; reserve it for drag-to-dismiss and playful interactions.

| Interaction | Damping | Response |
|---|---|---|
| Move / reposition | `1.0` | `0.4` |
| Rotation | `0.8` | `0.4` |
| Drawer / sheet | `0.8` | `0.3` |

```js
// Critically damped default (no overshoot)
animate(el, { y: 0 }, { type: 'spring', bounce: 0, duration: 0.4 });
// Momentum interaction - a little bounce
animate(el, { y: target }, { type: 'spring', bounce: 0.2, duration: 0.4 });
```

### 6.C Velocity Handoff

When a gesture ends, the animation continues at the finger's exact velocity - no visible seam between dragging and animating. Pass release velocity as the spring's initial velocity; for relative-velocity APIs, normalize by the remaining distance: `relativeVelocity = gestureVelocity / (targetValue - currentValue)`.

### 6.D Momentum Projection

Don't snap to the nearest boundary from the release point - project the resting position like scroll deceleration, then snap to the target nearest that point:

```js
function project(initialVelocity, decelerationRate = 0.998) {
  return (initialVelocity / 1000) * decelerationRate / (1 - decelerationRate);
}
const projectedEndpoint = currentPosition + project(releaseVelocity);
const target = nearestSnapPoint(projectedEndpoint);
animateSpringTo(target, { velocity: releaseVelocity });
```

### 6.E Interruptibility (The Single Most Important Principle)

Every animation must be interruptible and redirectable at any moment - the user can grab a moving element mid-flight and reverse it without waiting. Never lock out input during a transition. Always animate from the presentation (current) value - on interrupt, read the live on-screen transform and start there. Avoid CSS transitions / `@keyframes` for gesture-driven motion (can't be grabbed mid-flight); springs animate from the current value natively. Blend velocity on gesture reversal - don't hard-cut. Decompose 2D motion into independent X and Y springs (a single 2D-distance spring desyncs when X and Y velocities differ).

### 6.F Spatial Consistency

"If something disappears one way, we expect it to emerge from where it came." Enter and exit along the same path. Anchor interactions to their source (`transform-origin` = trigger). Mirror the easing on reversible transitions so outbound matches return (inverse cubic-bezier).

### 6.G Rubber-Banding (Soft Boundaries)

Resist progressively at edges instead of stopping hard - a hard stop reads as "frozen"; continuous resistance reads as "responsive, but nothing more here." Damping increases the further past the boundary the user drags:

```js
function rubberband(overshoot, dimension, constant = 0.55) {
  return (overshoot * dimension * constant) / (dimension + constant * Math.abs(overshoot));
}
```

### 6.H Materials & Depth

Build nav/toolbars/sheets as translucent layers (`backdrop-filter` + semi-transparent bg) with content scrolling underneath. Material weight encodes hierarchy (darker/heavier = structural; lighter = interactive attention). Never stack light-translucent on light-translucent - legibility collapses. Vibrancy keeps text legible over blur: higher contrast, slightly heavier weight, small letter-spacing bump. Fade a small blur/gradient mask where content meets floating chrome instead of hard dividers. Materialize, don't just fade: animate blur radius and scale together on glass enter/exit.

---

## 7. Component Building Principles

* **Buttons feel responsive:** `transform: scale(0.97)` (0.95-0.98) on `:active` with `transition: transform 160ms ease-out`, triggered on pointer-down not release.
* **Never animate from `scale(0)`:** start `scale(0.95)` + `opacity: 0`.
* **Popovers origin-aware:** scale in from the trigger (`transform-origin: var(--transform-origin)`); modals exempt (keep `center`).
* **Tooltips:** delay before appearing, but skip the delay once one is open - adjacent tooltips open instantly.
* **CSS transitions over keyframes for interruptible UI:** transitions retarget mid-animation; keyframes restart from zero.
* **Blur masks imperfect transitions:** a subtle `filter: blur(2px)` bridges a crossfade that feels off (under 20px - heavy blur is expensive, especially Safari).
* **`@starting-style` for enter states** - replaces the React `useEffect`-set-mounted pattern; fall back to the `data-mounted` attribute where unsupported:

```css
.toast {
  opacity: 1;
  transform: translateY(0);
  transition: opacity 400ms ease, transform 400ms ease;

  @starting-style {
    opacity: 0;
    transform: translateY(100%);
  }
}
```

* **`clip-path` for animation** - hold-to-delete pattern: slow press (`2s linear`), fast release (`200ms ease-out`), using `clip-path: inset()` regions.
* **Gesture and drag:** momentum-based dismissal (velocity `Math.abs(distance)/elapsedTime` > ~0.11 dismisses regardless of distance); damping at boundaries; pointer capture so drags survive leaving element bounds; ignore extra touch points after drag starts; friction instead of hard stops.
* **Stagger:** 30-80ms delays between items entering; never block interaction while stagger plays.
* **Transform mastery:** `translate()` percentages are relative to the element's own size; `scale()` scales children too; `rotateX/Y` + `preserve-3d` for real depth; `transform-origin` matches where the trigger lives.

### Floating Pill Nav (default for tabs & navigation bars)

Wide fully-rounded white pill (`rounded-full bg-white`, soft `shadow-lg/50`) centered over a blurred backdrop; horizontal text tabs with smooth hover; far-right nested accent pill with icon + label ("Account") + counter badge. Tailwind by default, framework-agnostic. Subtle hover/active transitions, motion < 300ms, interruptible, `prefers-reduced-motion` respected. Labels stay placeholders until the design read supplies real names.

---

## 8. Performance Guardrails

* **Only animate `transform` and `opacity`** (GPU, skip layout+paint); animating `padding`/`margin`/`height`/`width` triggers all three rendering steps.
* **CSS variables are inheritable:** setting a variable on a parent recalculates styles for all children - set `element.style.transform` directly instead.
* **Framer Motion caveat:** shorthand props (`x`, `y`, `scale`) run on `requestAnimationFrame` on the main thread - use the full `transform` string (`animate={{ transform: "translateX(100px)" }}`) for hardware acceleration.
* **CSS animations beat JS under load** (run off main thread; Framer Motion drops frames during page loads). **WAAPI** gives JS control with CSS performance - hardware-accelerated, interruptible, no library.
* `backdrop-blur` and grain/noise filters only on fixed, `pointer-events-none` elements - never on scrolling containers (continuous GPU repaints destroy mobile FPS).
* `IntersectionObserver` for scroll-driven reveals, never `window.addEventListener('scroll')`. `will-change` sparingly, only on actively animating elements.
* No arbitrary `z-[9999]` - z-index is reserved for sticky nav, modals, overlays, tooltips.
* `min-h-[100dvh]`, never `h-screen`. Lazy-init heavy resources (WebGL, WASM) near viewport; pause off-screen rendering. Test on real mid-range devices.

**Core Web Vitals:** LCP < 2.5s (preload hero image), INP < 200ms (heavy work off main thread), CLS < 0.1 (reserve space for images, fonts, embeds).

---

## 9. Accessibility

* **Contrast:** WCAG AA - 4.5:1 body, 3:1 large text (18px+ / bold 14px+). Audit buttons, especially white-on-white / transparent-on-photo / ghost buttons - add scrim, stroke, or backdrop over imagery.
* **Forms:** label above input, helper present, error below, no placeholder-as-label; placeholders and helper text also pass AA.
* **Reduced motion:** replace slides/springs/parallax with short opacity cross-fades - *gentler*, not zero; keep comprehension-aiding opacity/color transitions, drop movement:

```css
@media (prefers-reduced-motion: reduce) {
  .element { transition: opacity 200ms ease; transform: none !important; }
}
```

* **Reduced transparency:** raise translucent-surface opacity and drop blur. **Reduced contrast preference (`prefers-contrast: more`):** near-solid backgrounds with defined contrasting border.
* **Additional:** spacing in `rem`/`em` so scaled text doesn't break layout; avoid full-viewport moving backgrounds and 0.2Hz slow oscillations (vestibular triggers); touch targets 44x44px; ease dark<->light theme changes (no abrupt brightness jumps); large moving objects go semi-transparent while traveling, big surfaces fade out during large reposition.
* **Touch hover gating:** touch devices fire hover on tap - gate hover animations behind `@media (hover: hover) and (pointer: fine)`.

---

## 10. Anti-Slop Content Discipline

* **No AI copywriting cliches:** "Elevate", "Seamless", "Unleash", "Next-Gen", "Game-changer", "Delve", "Revolutionize" - plain, specific language.
* **Generic placeholders banned** ("John Doe", "Acme Corp", "Lorem Ipsum"). **Emojis banned by default** in code/markup/UI (override: explicit playful ask, sparingly). One label per intent. Dependency verification mandatory.

### AI Tells (Forbidden Patterns)

**Visual & CSS:** no neon/outer glows (inner borders or subtle tinted shadows); no pure black; no oversaturated accents (desaturate into neutrals); no excessive gradient text on large headers; no custom mouse cursors.

**Typography:** no Inter as default; no oversized screaming H1s (control hierarchy with weight + color); serif only for editorial/luxury/publication, never dashboards.

**Layout:** mathematically clean spacing, no awkward floating gaps; no 3-column equal feature cards (2-col zig-zag, asymmetric grid, scroll-pinned, or horizontal-scroll instead).

**Content & data:** no generic names/avatars (creative, realistic, locale-appropriate names; no SVG egg/Lucide user icons); no fake-perfect numbers (organic, messy data); no startup-slop brand names ("Acme", "Nexus", "SmartFlow"); concrete verbs only, no filler.

**External resources & components:** no hand-rolled SVG icons; no div-based fake screenshots; no broken Unsplash links (`picsum.photos/seed/...`); shadcn/ui never in default state (customize radii, colors, shadows, typography).

**Production-test tells (banned outright):** version labels in hero (unless a launch brief); section-number eyebrows and `01 / 4` pagination; "Index of Work, 2018 - 2026" range labels; more than one middle-dot per metadata line; decorative colored status dots; em-dashes anywhere on the page (regular hyphen only, non-negotiable); `<br>`-broken italicized headlines as a default move; vertical rotated text (unless experimental brief with real purpose); crosshair/hairline grid decoration; fake product UI in the hero; "Quietly in use at / Quietly trusted by" social-proof headers; "From the field / Field notes" poetic labels; weather/locale/city/time strips (unless genuinely about a place); micro-meta-sentences under eyebrows; generic step labels ("Phase 01 / Phase 02"); pills/labels overlaid on images; photo-credit captions as decoration; version footers on marketing pages; hero-bottom decoration text strips; floating top-right sub-text in section headings; scoring/progress bars with filled background tracks as comparisons; scroll cues; `border-t`+`border-b` on every row of long lists/spec tables; decorative dots (zero by default).

---

## 11. Dial Definitions (Technical Reference)

* **DESIGN_VARIANCE 1-3 (Predictable):** symmetrical 12-col grid, equal paddings, centered. **4-7 (Offset):** `margin-top: -2rem` overlaps, varied aspect ratios, left-aligned headers over centered data. **8-10 (Asymmetric):** masonry, fractional grid units (`2fr 1fr 1fr`), massive empty zones (`padding-left: 20vw`). Levels 4-10 collapse to strict single-column (`w-full px-4 py-8`) below 768px.
* **MOTION_INTENSITY 1-3 (Static):** CSS `:hover`/`:active` states only. **4-7 (Fluid CSS):** `transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1)`, `animation-delay` cascades, transform/opacity focus. **8-10 (Choreography):** scroll-triggered reveals, parallax, scroll-driven animation with Motion hooks - never `window.addEventListener('scroll')`.
* **VISUAL_DENSITY 1-3 (Art Gallery):** huge gaps (`py-32` to `py-48`). **4-7 (Daily App):** standard spacing (`py-16` to `py-24`). **8-10 (Cockpit):** tight paddings, no card boxes, 1px separators, mandatory `font-mono` for numbers.

## 12. Context-Aware Proactivity

Tools, not defaults - none fire automatically; the design read calls for them.

* **Liquid Glass / Glassmorphism:** for premium consumer / Apple-adjacent / luxury / media-overlay vibes; wrong for dashboards, public-sector, "boring B2B". Beyond `backdrop-blur`: 1px inner border (`border-white/10`) + subtle inner shadow + solid-fill fallback under `prefers-reduced-transparency`.
* **Magnetic micro-physics:** when `MOTION_INTENSITY > 5` and the brief reads premium/playful/agency - exclusively with `useMotionValue`/`useTransform` outside the React render cycle, never `useState`.
* **Perpetual micro-interactions (pulse, typewriter, float, shimmer, carousel):** when `MOTION_INTENSITY > 5` AND the section benefits from motion - not every card needs an infinite loop.
* **Motion claimed, motion shown:** `MOTION_INTENSITY > 4` means the page actually moves (hero entries, scroll reveals, hover physics at minimum).

**Forbidden animation patterns:** `window.addEventListener("scroll")` (use `useScroll()`, ScrollTrigger, IntersectionObserver, or CSS scroll-driven animations); `window.scrollY` scroll-progress in React state (re-renders every frame); `requestAnimationFrame` loops touching React state (use motion values); `layout`/`layoutId` props on static content "for safety".

---

## 13. UI Library Selection

Curated picks when the task needs a component rather than custom code:

| Task | Library |
|---|---|
| Unstyled accessible components (dialogs, popovers, menus, selects) | [base-ui](https://base-ui.com) |
| Command menus (cmd-K palettes) | [cmdk](https://cmdk.paco.me) |
| Toasts / notifications | [sonner](https://sonner.emilkowal.ski) |
| OTP / verification-code inputs | [input-otp](https://input-otp.rodz.dev) |
| Customizable GUIs / control panels | [Leva](https://github.com/pmndrs/leva) |
| Spring/layout/enter-exit animation | [motion](https://motion.dev) (Framer Motion) |
| Animating numbers | [NumberFlow](https://number-flow.barvian.me) |
| Animated text components | [torph](https://torph.lochie.me/) |
| 3D globes | [Cobe](https://cobe.vercel.app) |
| Dynamic OG images / syntax highlighting | [Satori](https://github.com/vercel/satori) / [shiki](https://shiki.style) |
| Real-time / general charts | [Liveline](https://github.com/benjitaylor/liveline) / [recharts](https://recharts.org) |
| Drag and drop / virtualized lists | [dnd kit](https://dndkit.com) / [Virtuoso](https://virtuoso.dev) |
| State management / theme switching (no flash) | [zustand](https://zustand.docs.pmnd.rs) / [next-themes](https://github.com/pacocoursey/next-themes) |
| Conditional `className` strings / Tailwind variants | [clsx](https://github.com/lukeed/clsx) / [cva](https://cva.style) |

**Mismatches to catch:** hand-rolled or modal-library toasts -> sonner; div-based dropdown/dialog with manual focus handling -> base-ui; re-rendering text to animate a number -> NumberFlow; 1,000+ rows rendered directly -> Virtuoso; a `useState`-per-component props web -> zustand; template-literal ternaries three deep -> clsx (or cva if variant-shaped).

---

## 14. Redesign Protocol

This skill handles **greenfield builds AND redesigns**. Misclassifying the mode is the single biggest source of bad redesign output.

**14.A Detect the mode first.** Greenfield (no existing site / overhaul approved - dial baseline from §1), Redesign-Preserve (modernise without breaking the brand - audit, extract brand tokens, evolve gradually), Redesign-Overhaul (new visual language, greenfield for visuals, preserve content + IA). If ambiguous, ask once: *"Preserve the existing brand, or starting visually from scratch?"*

**14.B Audit before touching:** brand tokens (colors, type stack, logo treatment, radii); IA (page tree, primary nav, conversion paths); content blocks (working vs filler); patterns to preserve (signature interactions, recognisable hero, copy voice) and retire (AI-slop tells, broken layouts, dead links, stock imagery, perf traps); the existing site's dial reading (your starting point, not the baseline); SEO baseline (ranking pages, meta titles, structured data, OG cards - **SEO migration is the #1 redesign risk**).

**14.C Preservation rules:** don't change IA unless asked (slugs, anchor IDs, nav labels stable); extract brand colors before applying §4.2 (a brand that is purple stays purple); preserve copy voice; never regress accessibility wins (focus states, alt text, keyboard nav, contrast); respect analytics events (don't rename tracked buttons, fields, section IDs).

**14.D Modernisation levers (priority order):** 1. Typography refresh (biggest lift per risk) -> 2. Spacing & rhythm -> 3. Color recalibration (desaturate, unify neutrals, keep brand accent) -> 4. Motion layer -> 5. Hero/key-section recomposition -> 6. Full block replacement (only if unsalvageable).

**14.E What never changes silently (explicit approval required):** URL structure / route slugs, primary nav labels, form field names or order, brand logo or wordmark, existing legal / consent / cookie copy.

## 15. Progressive Enhancement

Every technique degrades gracefully - the experience without the enhancement must still be good:

```css
@supports (animation-timeline: scroll()) {
  .hero { animation-timeline: scroll(); }
}
```
```javascript
if ('gpu' in navigator) { /* WebGPU */ }
else if (canvas.getContext('webgl2')) { /* WebGL2 fallback */ }
```

**Advanced toolkit (when the brief calls for it):** View Transitions API (shared-element morphing), `@starting-style` (CSS-only entry from `display: none`), spring physics, scroll-driven animations (`animation-timeline: scroll()`, CSS-only), WebGL/WebGPU (fall back to WebGL2), `@property` (typed animatable custom properties), Web Animations API (JS-driven, CSS performance), Web Workers, OffscreenCanvas, WASM.

**Polish is the difference:** the gap between "cool" and "extraordinary" is the last 20% - the easing curve, the timing offset in a staggered reveal, the subtle secondary motion. Ship the version that feels inevitable.

## 16. Debugging Animations

* **Slow motion:** 2-5x duration or DevTools animation inspector to spot issues invisible at full speed.
* **Frame-by-frame** in Chrome DevTools (Animations panel) reveals timing issues between coordinated properties.
* **Real devices** for touch interactions (drawers, swipes) - USB + local dev server by IP + Safari remote devtools.
* **Review with fresh eyes the next day** - imperfections become visible; play in slow motion or frame by frame.

---

## 17. Component Principles (Building Loved Components)

1. **Developer experience first:** no hooks, no context, no complex setup - insert `<Toaster />` once, call `toast()` anywhere.
2. **Good defaults beat options:** beautiful out of the box; most users never customize.
3. **Naming creates identity:** distinctive beats generic-descriptive; sacrifice discoverability for memorability when appropriate.
4. **Handle edge cases invisibly:** pause timers when the tab hides, pseudo-elements between stacked toasts, pointer capture during drag - users never notice, and that is right.
5. **Transitions, not keyframes, for dynamic UI** (interruptible; keyframes restart on interruption).
6. Document so people can touch the product first.

**Cohesion:** match motion to the component's personality (playful = bouncier, dashboard = crisp and fast). **Asymmetric timing:** slow where the user is deciding (hold-to-delete: 2s linear), fast where the system responds (release: 200ms ease-out).

## 18. Apple Design Foundations (The Eight Principles)

1. **Purpose.** Make with intention; decide what *not* to build - spend the user's time/attention/trust budget only where it pays off.
2. **Agency.** Keep people in control; forgiveness with easy undo; confirmations only for genuinely destructive, irreversible actions.
3. **Responsibility.** Act in the user's interest - privacy asked at the right moment for only what's needed; anticipate misuse and harm.
4. **Familiarity.** Build on what people know; metaphors neither too literal nor too abstract; honor their physics; looks-the-same behaves-the-same.
5. **Flexibility.** Design for different contexts, devices, and full ability range; adapt to platform and situation.
6. **Simplicity, not minimalism.** Strip the unnecessary so the core shines; sometimes adding context simplifies.
7. **Craft.** Uncompromising detail builds trust - nothing random; every spacing, timing, alignment value is a defensible choice.
8. **Delight.** The result of getting the other seven right, not confetti on top.

**Tactical rules:** feedback in four kinds (status, completion, warning, error - validate inline, not on submit); wayfinding (every screen answers where am I / where can I go / how do I get out - never trap); proximity implies relationship, controls mirror what they change (if a label is needed to explain a control, the mapping is weak); direct specific labels beat vague umbrellas ("Progress" over "Home").

**Quick reference:**

| Need | Technique | Concrete value |
|---|---|---|
| Default UI spring | Critically damped, no overshoot | `damping 1.0`, `response 0.3-0.4` |
| Momentum / flick spring | Under-damped, slight bounce | `damping ~0.8`, `response 0.3-0.4` |
| Gesture -> spring velocity | Hand off release velocity | `gestureVelocity / (target - current)` if normalized |
| Flick landing point | Project momentum | `current + (v/1000) * d/(1-d)`, `d ~= 0.998` |
| Interrupt cleanly | Start from presentation (live) value | read the on-screen transform |
| Avoid reversal "brick wall" | Carry velocity through re-target | spring that blends velocity |
| Reversible transition / reverse vs commit | Mirror the easing / use velocity sign | inverse cubic-bezier / at release |
| 1:1 drag | Pointer Events + capture | respect the grab offset |
| Feedback | On pointer-down, continuous | never only at the end |
| Boundary | Rubber-band, don't hard-stop | progressive resistance |
| Translucent chrome / type tracking | `backdrop-filter` / size-specific | content scrolls under / tighten large text |
| Reduced motion | Cross-fade, not slide/spring | `@media (prefers-reduced-motion)` |

## 19. Reference Vocabulary

A vocabulary, not a library - pattern names to reach for when the design read calls for them:

* **Hero paradigms:** Asymmetric Split (text one side, asset other), Editorial Manifesto (large type, no asset), Video/Media Mask (type cut out over video), Kinetic-Type, Curtain-Reveal, Scroll-Pinned.
* **Navigation & menus:** Floating Pill Nav (default for tabs/nav - pill over blurred backdrop with nested accent tab), Mac OS Dock Magnification, Magnetic Button, Gooey Menu, Dynamic Island, Contextual Radial Menu, Floating Speed Dial, Mega Menu Reveal.
* **Layout & grids:** Bento Grid (asymmetric tiles, Apple Control Center), Masonry, Chroma Grid, Split-Screen Scroll, Sticky-Stack Sections.
* **Cards & containers:** Parallax Tilt Card, Spotlight Border Card, Glassmorphism Panel, Holographic Foil Card, Tinder Swipe Stack, Morphing Modal.
* **Scroll animations:** Sticky Scroll Stack, Horizontal Scroll Hijack, Locomotive/Sequence Scroll, Zoom Parallax, Scroll Progress Path, Liquid Swipe Transition.
* **Galleries & media:** Dome Gallery, Coverflow Carousel, Drag-to-Pan Grid, Accordion Image Slider, Hover Image Trail, Glitch Effect Image.
* **Typography & text:** Kinetic Marquee, Text Mask Reveal, Text Scramble, Circular Text Path, Gradient Stroke Animation, Kinetic Typography Grid.
* **Micro-interactions & effects:** Particle Explosion Button, Liquid Pull-to-Refresh, Skeleton Shimmer, Directional Hover-Aware Button, Ripple Click, Animated SVG Line Drawing, Mesh Gradient Background, Lens Blur Depth.
* **Animation library choice:** Motion (`motion/react`) default for UI/bento/state-change; GSAP + ScrollTrigger for full-page scrolltelling and hijacks; Three.js/WebGL for canvas backgrounds and 3D. Isolate GSAP/Three in dedicated leaf components with `useEffect` cleanup. **Never mix GSAP/Three with Motion in the same component tree** - they fight over the same frames.

---

## 20. Out of Scope

NOT for: dashboards / dense product UI / admin panels (use Fluent, Carbon, Atlassian, Polaris from §2.A); data tables (TanStack Table, AG Grid); multi-step forms/wizards; code editors (Monaco, CodeMirror); native mobile (Apple HIG / Material directly); realtime collab UIs (different problem class). If the brief is one of these, say so explicitly, point to the right tool, and apply only the marketing/about/landing parts where they fit.

## 21. Final Pre-Flight Check

Not optional. Run every box; if any fails, the output is not done. If a box cannot be honestly ticked, fix before delivering.

**Framing:**
- [ ] Brief inference declared (§0 one-liner); dial values explicit and reasoned from the brief
- [ ] Design system chosen from §2 if applicable, or aesthetic labeled honestly
- [ ] Redesign mode detected and audit performed (§14, if applicable)

**Consistency locks:**
- [ ] ONE theme for the whole page (no mid-page inversion); one accent color across all sections; one corner-radius system
- [ ] ZERO em-dashes anywhere (headlines, eyebrows, pills, body, quotes, attribution, captions, buttons, alt text)
- [ ] Serif, if used, is not Fraunces/Instrument_Serif; premium-consumer palette is not the banned beige+brass family
- [ ] Italic descender clearance (`leading-[1.1]` min + `pb-1` reserve for `y g j p q`)

**A11y & states:**
- [ ] Button, form, placeholder, focus-ring contrast all WCAG AA; no CTA label wraps 2+ lines at desktop; one label per intent
- [ ] Empty/loading/error states provided; reduced motion wrapped for everything `MOTION_INTENSITY > 3`; dark-mode tokens tested in both modes

**Layout:**
- [ ] Hero fits viewport (headline <= 2 lines, subtext <= 20 words AND <= 4 lines, CTA unfurled without scroll); top padding <= `pt-24`; stack <= 4 text elements; eyebrow count <= ceil(sectionCount/3)
- [ ] No split headers; zigzag cap respected (no 3+ consecutive image+text splits); >= 4 layout families across 8 sections; bento has rhythm AND exact cell count; logo wall UNDER hero with real SVG logos, no category labels
- [ ] Navigation single-line at desktop, height <= 80px; mobile collapse explicit (`w-full`, `px-4`, `max-w-7xl mx-auto`); viewport `min-h-[100dvh]`
- [ ] Real images used (gen-tool -> Picsum-seed -> explicit slots); no div-based fake screenshots; long lists (> 5) use the right UI component; quotes <= 3 lines with clean attribution

**Anti-slop (§10) - no:** pills/labels on images, photo-credit captions, version footers, micro-meta-sentences, hero-bottom decoration strips, floating top-right sub-text, filled-track scoring bars, locale/weather strips, scroll cues, hero version labels, section-numbering eyebrows, decorative dots, border-t+border-b on every row, 20-row data tables, fake-precise specs.

**Motion & code:**
- [ ] Every animation justified in one sentence; motion claimed = motion shown (MOTION_INTENSITY > 4 means visible movement); max one marquee per page
- [ ] No `window.addEventListener('scroll')`; `useEffect` animations have strict cleanup; motion isolated in memoized `'use client'` leaf components
- [ ] Icons from an allowed library only; cards omitted where spacing works; Core Web Vitals plausible (LCP < 2.5s, INP < 200ms, CLS < 0.1); one design system per project; no AI tells from §10

## 22. Review Checklist

When reviewing UI code:

| Issue | Fix |
|---|---|
| `transition: all` | Name exact properties (e.g. `transform 200ms ease-out`) |
| `scale(0)` entry | `scale(0.95)` + `opacity: 0` |
| `ease-in` on UI element | `ease-out` or strong custom curve (`cubic-bezier(0.23, 1, 0.32, 1)`) |
| `transform-origin: center` on popover | Trigger location or `var(--transform-origin)` (modals exempt) |
| Animation on keyboard action | Remove animation entirely |
| Duration > 300ms on UI | 150-250ms |
| Hover without media query | `@media (hover: hover) and (pointer: fine)` |
| Keyframes on rapidly-triggered element | CSS transitions for interruptibility |
| Framer Motion `x`/`y` under load | Full `transform` string for hardware acceleration |
| Same enter/exit speed | Exit faster than enter (enter 2s, exit 200ms) |
| Everything enters at once | 30-80ms stagger |
| Animating `width`/`height`/`margin`/`padding`/`top`/`left` | `transform` / `opacity` |
| Missing `prefers-reduced-motion` | Gentler variant, not zero |

## 23. Prototyping Variants

Explore directions with genuinely different versions behind a visual picker.

**Hard rules:** never touch production code during exploration (isolated prototype surface); variants diverge on a named axis stated in a phrase (layout, density, personality, motion, interaction model); every variant fully works (real interactions, product-shaped copy, no lorem ipsum, no dead buttons); clean up the prototype when a winner is promoted unless asked to keep it.

**Workflow:** 1. Scope (one thing per run, one-sentence restatement) -> 2. Recon (map stack, tokens, personality) -> 3. Choose directions (default 3, up to 5 when genuinely wide; named by direction - "Quiet", "Editorial", "Playful", "Dense", never "Option A/B/C") -> 4. Build the picker harness (isolated route or self-contained HTML, one variant at a time, full size, realistic context) -> 5. Verify (all variants render, console clean) and hand off - the choice belongs to the user -> 6. Promote on selection following existing conventions, then delete the prototype.

## 24. Default Site Packs

* **4-section:** Hero, Features, Social proof / testimonial, CTA.
* **8-section:** + Trust bar, Product showcase (after Features), Benefits / use cases (after showcase), Pricing (after Testimonials).
* **12-section:** additionally Feature grid and Product preview up front, Problem/solution and Workflow mid-page, Metrics/proof/integration before Testimonials, FAQ before CTA + footer.

---

## 25. CSS Implementation

Practical rules for writing modern, accessible, fast CSS. This section has the core rules and a decision guide. For details, syntax, support data, and gotchas, read the matching file in `references/css/`.

### 25.A How to Use
1. Apply the core rules below to every CSS task.
2. Use the decision guide to pick a technique.
3. Before you write non-trivial code in an area, read that area's reference file. Read `references/css/browser-support.md` before you ship any feature marked partial or experimental.

### 25.B Core Rules
1. Use native HTML and CSS before JavaScript: `<dialog>`, `popover`, `<details name>`, `:has()`, anchor positioning, scroll-driven animation, view transitions.
2. Structure the cascade with `@layer reset, base, components, utilities;`. Keep selectors to one class. Use `:where()` for resets. Do not use IDs for styling, and use `!important` only in utilities.
3. Choose Grid for two-dimensional layout and Flexbox for one-dimensional flow. Space items with `gap`, not child margins.
4. Prefer intrinsic layouts (`repeat(auto-fill, minmax(min(100%, 16rem), 1fr))`, flex wrap, `clamp()`) over breakpoints. Use container queries for components and media queries for page-level and preference features.
5. Use logical properties (`margin-inline`, `padding-block`, `inset-inline-start`, `inline-size`).
6. Size text in `rem` and fluid type with `clamp(min, rem + vi, max)`. Limit line length to about 65ch. Use unitless line-height.
7. Use `100dvh`/`100svh` instead of `100vh`, and `100%` or a full-bleed grid instead of `100vw`.
8. Store design tokens as custom properties with role-based names. Theme by swapping semantic tokens, not by overriding components.
9. Define colors in `oklch()`. Derive states with relative color syntax or `color-mix(in oklab, …)`. Set `color-scheme: light dark` and use `light-dark()` for themes.
10. Keep text contrast at 4.5:1 (3:1 for large text and UI parts). Never remove focus outlines without a `:focus-visible` replacement. Make targets at least 24×24px (44×44 for touch).
11. Keep DOM order equal to visual order. Do not use `order`, `row-reverse`, or `dense` to reorder interactive content.
12. Animate `transform` and `opacity` (and the individual `translate`/`rotate`/`scale` properties). Keep UI transitions at 150-300ms. Wrap movement in `@media (prefers-reduced-motion: no-preference)`.
13. Animate entry and exit of hidden elements with `@starting-style` + `transition-behavior: allow-discrete` (also transition `display` and `overlay`).
14. Register a custom property with `@property` before you animate it.
15. Reserve space for media and late content (`width`/`height` attributes, `aspect-ratio`, `contain-intrinsic-size`) to avoid CLS.
16. Give the LCP image `fetchpriority="high"` and never lazy-load it. Lazy-load everything below the fold.
17. Self-host subset WOFF2 fonts, preload at most two, set `font-display`, and add a metric-matched fallback.
18. Use `content-visibility: auto` with `contain-intrinsic-size: auto <size>` for long off-screen sections.
19. Put enhancements behind `@supports` or a value fallback (`height: 100vh; height: 100dvh;`). A missing feature must never hide content or block interaction.
20. Inline SVG icons with `currentColor`. Hide decorative SVG with `aria-hidden="true"`, and label meaningful SVG with `role="img"` + `<title>`.
21. Never insert untrusted strings with `innerHTML`. Pass dynamic values to CSS through custom properties (`el.style.setProperty('--x', v)`), and toggle state with attributes.
22. Gate hover effects with `@media (hover: hover)`, and give every hover interaction a focus and tap equivalent.

### 25.C Decision Guide
| Need | Use | Avoid |
|---|---|---|
| Card grid that wraps | `grid-template-columns: repeat(auto-fill, minmax(min(100%, 16rem), 1fr))` | Fixed breakpoints per column count |
| Align rows across sibling cards | `grid-template-rows: subgrid` | Fixed heights, JS equalizers |
| Masonry | `display: grid-lanes` in `@supports`, fallback grid/columns | JS masonry as the only path |
| Component adapts to its slot | Container queries + `cqi` units | Viewport media queries |
| Fluid type and spacing | `clamp(1rem, .9rem + .5vi, 1.25rem)` | Pure `vw` sizes |
| Full-height mobile section | `min-block-size: 100svh` / `100dvh` | `100vh` |
| Full-bleed row in content column | Named grid lines (`full`/`content`) | `100vw` + negative margins |
| Style a parent by its children | `:has()` | JS class toggling |
| Override third-party CSS | `@import url(x.css) layer(vendor)` | Specificity escalation, `!important` |
| Scope component styles | `@scope (.card) to (.slot)`, CSS Modules | Long descendant chains |
| Theming and dark mode | Semantic tokens + `color-scheme` + `light-dark()` | Duplicated component rules per theme |
| Hover and active colors | `oklch(from var(--c) calc(l - .08) c h)` / `color-mix()` | Hand-picked hex per state |
| Text color on a dynamic background | `contrast-color()` with an OKLCH fallback | Hard-coded white |
| Modal | `<dialog>` + `showModal()` | Checkbox hack, `:target`, custom traps |
| Menu, toast, tooltip | `popover` (+ `popover="hint"`) | z-index stacks + JS outside-click |
| Position popup next to trigger | Anchor positioning + `position-try-fallbacks` | JS coordinate math |
| Accordion | `<details name="group">` + `::details-content` | ARIA re-implementation |
| Auto-growing textarea | `field-sizing: content` | JS height syncing |
| Styled select | `appearance: base-select` | Div-based fake selects |
| Carousel | Scroll snap + `::scroll-button()` / `::scroll-marker` | JS-only sliders, autoplay without pause |
| Entry/exit animation | `@starting-style` + `allow-discrete` | `setTimeout` class juggling |
| Animate to `height: auto` | `interpolate-size: allow-keywords` or grid `0fr → 1fr` | Measuring height in JS |
| Scroll-linked effects | `animation-timeline: scroll()` / `view()` | Scroll event listeners |
| Page and state transitions | View Transitions API | Manual FLIP for whole pages |
| Spring or bounce easing | `linear()` | JS physics for simple UI |
| Gradient border with radius | `padding-box` / `border-box` background layers | `border-image` (ignores radius) |
| Non-rectangular shadow | `filter: drop-shadow()` | `box-shadow` on clipped shapes |
| Responsive custom shape | `clip-path: shape()` / `polygon()` with % | `path()` in px |
| Icons | Inline SVG `<symbol>`/`<use>` + `currentColor` | Icon fonts |
| Optical text centering | `text-box: trim-both cap alphabetic` | Magic padding offsets |
| Heading line breaks | `text-wrap: balance` (`pretty` for paragraphs) | Manual `<br>` |
| Long off-screen content | `content-visibility: auto` + `contain-intrinsic-size` | Rendering everything eagerly |
| Stagger by index | `sibling-index()` with `--i` fallback | Long `:nth-child` lists |
| Design tokens at scale | DTCG JSON → Style Dictionary → custom properties | Hard-coded values |
| Zero-runtime styling | Tailwind v4, CSS Modules, vanilla-extract | Runtime CSS-in-JS in server components |

### 25.D References
| File | Read when |
|---|---|
| [layout.md](references/css/layout.md) | Flexbox, Grid, subgrid, masonry, multi-column, sizing keywords, centering, positioning, stacking, overflow |
| [responsive.md](references/css/responsive.md) | Media, container (size, style, scroll-state) queries, fluid sizing, viewport units, responsive images, user preferences |
| [selectors-cascade.md](references/css/selectors-cascade.md) | Specificity, `@layer`, `@scope`, nesting, `:has()`, pseudo-classes and elements, resets |
| [custom-properties-math.md](references/css/custom-properties-math.md) | Variables, `@property`, `calc()` and math functions, `if()`, `@function`, typed `attr()`, `sibling-index()`, `random()` |
| [color.md](references/css/color.md) | OKLCH, wide gamut, relative color, `color-mix()`, dark mode, contrast, color fonts |
| [visual-effects.md](references/css/visual-effects.md) | Gradients, gradient borders, shadows, `corner-shape`, `clip-path`, `shape()`, masks, filters, blend modes, images |
| [typography.md](references/css/typography.md) | Font stacks, `@font-face`, loading, variable fonts, type scales, wrapping, `text-box`, decoration, long-form reading |
| [animation-motion.md](references/css/animation-motion.md) | Transitions, easing, keyframes, `@starting-style`, animating `auto`, scroll-driven, view transitions, 3D, motion paths, WAAPI/GSAP |
| [components-ui.md](references/css/components-ui.md) | Forms, customizable select, dialog, popover, anchor positioning, tooltips, accordions, carousels, cards, scrollbars |
| [svg.md](references/css/svg.md) | Embedding, icon systems, styling, stroke drawing, masks, filters, animation, SVG accessibility |
| [accessibility.md](references/css/accessibility.md) | Focus, hiding content, forms, ARIA, dialogs, landmarks, forced colors, text spacing, testing |
| [performance.md](references/css/performance.md) | CSS delivery, priority hints, containment, animation cost, images, fonts, CLS, INP |
| [architecture-tooling.md](references/css/architecture-tooling.md) | Methodologies, tokens, Tailwind, Sass, Lightning CSS, CSS Modules, CSS-in-JS, linting, WordPress `theme.json` |
| [frontend-js.md](references/css/frontend-js.md) | DOM, events, observers, CSS from JS, web components and shadow DOM styling, view transitions in JS, framework styling |
| [browser-support.md](references/css/browser-support.md) | Baseline, `@supports` patterns, support snapshot (Oct 2026), polyfills, browser quirks, testing |

### 25.E CSS Pre-Flight Checklist
- [ ] Works without the newest features (fallbacks in place, content visible).
- [ ] Keyboard path works, focus is visible, DOM order matches visual order.
- [ ] Contrast passes in light, dark, and forced-colors modes.
- [ ] Motion respects `prefers-reduced-motion`.
- [ ] Layout holds at 320px width and at 200% zoom.
- [ ] No CLS from images, fonts, or late content. The LCP image is not lazy-loaded.
- [ ] No hard-coded colors or spacing where tokens exist. Selectors stay flat.

## 26. Design Systems

Build a reusable, accessible, maintainable design system when starting/redoing a product, sharing a library across teams, or requiring dark mode + WCAG 2.1 AA built in.

**Workflow:** 1. Define principles (consistency, accessibility, scalability, DX) -> 2. Generate tokens (colors, typography, spacing, radius, shadows, breakpoints) -> 3. Set up theming -> 4. Build atomic components -> 5. Accessibility patterns -> 6. Document -> 7. Version and maintain.

**Tokens:** store as role-based custom properties or DTCG JSON in one version-controlled source of truth. Semantic tokens (`color.semantic.brand.primary`) reference primitives (`{color.primitive.blue.600}`); UI uses only semantic tokens so primitives can change without touching components. Full palette (50-950), modular type scale, 8-point spacing grid, radius/shadow tokens, standard breakpoints (see §25.C for the DTCG -> Style Dictionary pipeline).

**Theming:** semantic-token swap, not component overrides. CSS variables + `data-theme="dark"` on `<html>` (§25 rule 9), or ThemeProvider for styled-components/Emotion, or Tailwind `dark:` variant with `darkMode: 'class'`.

**Atomic architecture:** atoms (Button, Input, Icon) -> molecules (SearchBar, FormField) -> organisms (NavBar, CardGrid) -> templates (page skeletons) -> pages. Component best practices: sensible defaults; consistent prop names (`variant`, `size`, `disabled`, `loading`); composition (`<Card.Header>`) over boolean-prop explosions; polymorphic `as` prop.

**Accessibility (WCAG 2.1 AA):** 4.5:1 text / 3:1 large text and UI components; full keyboard reachability with visible `:focus-visible` indicators and focus traps in modals; `aria-label` on icon-only buttons, `aria-expanded`/`aria-controls` on toggles, `role="alert"` errors; semantic HTML in screen-reader paths; automated axe (`npm exec axe-cli`) + manual keyboard/screen-reader tests.

**Lifecycle:** design phase (audit inconsistencies, token file, Figma inventory) -> development (atoms first, unit + axe tests, document concurrently, `@storybook/addon-a11y`) -> adoption (migration guide, codemods via `jscodeshift`, team workshops) -> maintenance (semver, deprecation timelines, changelog, centrally-updated tokens).

**Pitfalls:** hard-coded values break theming (always reference tokens); inconsistent prop naming (adopt a convention); missing focus styles lock out keyboard users; unchecked dark-mode contrast fails WCAG; boolean-prop bloat (prefer slots/children); unversioned token files let teams diverge (version + tag them).

**Quick-start:** principles statement -> token file -> contrast verified both modes -> theming set up -> core atoms (Button, Input, Icon, Avatar, Badge) -> one molecule + one organism -> focus + ARIA on interactive elements -> Storybook stories + docs -> publish -> migration guide -> tag `v1.0.0`.

## Sub-skills

`design` is the single umbrella skill. Every other design skill is a sub-skill of this
one; read a sub-skill's `SKILL.md` (or its `references/`) only when the task needs it,
and always return to `design` for the shared workflow.

| Sub-skill | Use when |
|-----------|----------|
| [`mobile-design`](../mobile-design/SKILL.md) | Designing mobile or cross-platform interfaces: iOS/Android conventions, touch targets, performance budgets, React Native, Flutter, or responsive phone/tablet layouts. |
| [`brand-theming`](../brand-theming/SKILL.md) | Enforcing a specific brand's colors, typography, and visual identity across artifacts (decks, docs, reports, or UI). |
| [`figma`](../figma/SKILL.md) | Converting a Figma frame, node, or asset into production code with pixel-perfect parity (design-to-code). |
| [`ux-research`](../ux-research/SKILL.md) | Research-backed design decisions: personas, journey maps, usability testing, and design validation. |
| [`immersive-web`](../immersive-web/SKILL.md) | Building scroll-driven, parallax, and 3D web experiences: GSAP ScrollTrigger, Framer Motion, React Three Fiber, Three.js, or WebGL storytelling. |
| [references/visual-design-direction.md](references/visual-design-direction.md) | Provides a structured, opinionated visual design direction for web UI projects, guiding designers to create distinctive, premium, and non‑templated experiences through purposeful choices in typography, color, layout, motion, and 3D, with a clear workflow and checklist. |

## Related skills

Load these when the task spans more than this skill.

- [`frontend-development`](../frontend-development/SKILL.md) — Frontend Development skill for building modern React/Next.js applications with TypeScript, MUI, TanStack Query…
- [`web-accessibility`](../web-accessibility/SKILL.md) — Provides concise guidance for auditing and fixing web accessibility to meet WCAG 2.1 (POUR) and ARIA standards…
- [`web-performance`](../web-performance/SKILL.md) — Provides step‑by‑step guidance to measure, diagnose, and improve web performance, focusing on Core Web Vitals…
- [`motion-canvas`](../motion-canvas/SKILL.md) — Set up and troubleshoot Motion Canvas projects, write TypeScript animation scenes with generator functions, si…
