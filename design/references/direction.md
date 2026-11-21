# Design Direction: Brief, Defaults, Bias Correction

Sections §0, §3, §4, §11, §14, §20, §23, §24 of [`design`](../SKILL.md). §1 (dials) and §2 (system choice) are in SKILL.md. Run the [pre-flight](preflight.md) (§21) before you finish.

## 0. Brief Inference

Read before coding: **page kind**, **vibe words**, **references**, **audience** (picks the aesthetic, not your taste), **brand assets**, **quiet constraints** (a11y-first, public-sector, regulated, kids - these OVERRIDE aesthetics).

Output one line first: **"Reading this as: \<page kind> for \<audience>, with a \<vibe> language, leaning toward \<system/aesthetic>."** Ask at most one question, only if the read truly diverges.

* **Anti-default:** no AI-purple gradients, centered hero on dark mesh, three equal feature cards, generic glassmorphism, infinite micro-loops, Inter + slate-900, underline-only tabs, one-sided accent borders on cards.
* **Refinement preserves; redesign replaces** (keeps product truth, old look is anti-reference).
* **Mode from surface:** Persuade (marketing - earn attention), Operate (app UI - scanability first), Read (docs - comprehension), Experience (portfolio - artifact leads).

## 3. Default Architecture

* **Stack:** React 19.3 / Next.js 16.4 Server Components; React Compiler on, no manual `memo`; motion/scroll/pointer code only in `'use client'` leaves. Tailwind 4.3 CSS-first (`@theme` + `light-dark()`). Raw CSS -> §25 ([css-implementation.md](css-implementation.md)).
* **Animation:** Motion (`motion/react` v12) for springs/gestures/layout; CSS transitions and `@starting-style` first for simple states. **Fonts:** variable fonts via `next/font` or self-hosted (Fontsource) + `font-display: swap` + `size-adjust` fallback; never Google Fonts `<link>`.
* **State:** local first; global only vs prop-drilling. Never `useState` for continuous input - use `useMotionValue`/`useTransform`/`useScroll`.
* **Icons:** `@phosphor-icons/react` > `hugeicons-react` > `lucide-react` > Material Symbols > `@tabler/icons-react`. One family, global `strokeWidth`, never hand-rolled SVG. **No emoji** unless asked.
* **Layout:** breakpoints `640/768/1024/1280/1536` for pages; `@container` queries for components; subgrid for aligned rows; `max-w-7xl`; `min-h-dvh` never `h-screen`; Grid over `calc()` flex math.
* **Dependencies (mandatory):** check `package.json`; output install command if missing.

## 4. Bias Correction

### 4.1 Typography

* Display `text-4xl md:text-6xl tracking-tighter leading-none` with `text-wrap: balance`; body `text-base leading-relaxed max-w-[65ch]` with `text-wrap: pretty`.
* No Inter default (OK for neutral/public-sector) - use Geist, Outfit, Cabinet Grotesk, Satoshi, Plus Jakarta Sans. Pairs: Geist + Geist Mono, Satoshi + JetBrains Mono, Plus Jakarta Sans + JetBrains Mono.
* **Serif:** only when brand/editorial truly justifies (e.g., Newsreader, Source Serif 4). **Banned: Fraunces, Instrument_Serif.** Emphasis = italic/bold of the same font.
* **Italic descenders (mandatory):** `leading-[1.1]` min + `pb-1`.
* **Optical polish:** negative tracking at display sizes (`-0.02em` to `-0.04em`), unitless leading (`1.0-1.15` display, `1.5-1.6` body), `font-variant-numeric: tabular-nums` on all prices, KPIs, counters, and tables, `text-box: trim-both cap alphabetic` on buttons/badges. No `#000` text. Spacing in `rem`.

### 4.2 Color

* One accent (saturation < 80%), one neutral gray family (tinted subtly toward the accent hue or cool/warm neutral), no pure `#000`/`#fff`.
* Define colors in `oklch()` with `color-scheme: light dark` and `light-dark()`. Derive hover, active, subtle tint, and border states with relative color syntax (`oklch(from ...)`) or `color-mix()` rather than hand-picking hex values. **Lock (mandatory):** same accent on the whole page.
* **Surface elevation tokens:** define 3-4 distinct surface levels (`canvas`, `surface`, `surface-muted`, `surface-elevated`) plus `border-subtle` and `border-strong`. In dark mode, elevate by stepping surface lightness up slightly rather than relying on heavy drop shadows.
* **Lila rule:** no default purple/blue glow - neutral base + one sharp accent (Emerald, Electric Blue, Deep Rose, Burnt Orange, Cobalt, Amber) unless brand says purple.
* **Premium-consumer ban (mandatory):** no beige/cream + brass/oxblood + espresso. Rotate: Cold Luxury, Forest, Black and Tan, Cobalt + Cream, Terracotta + Slate, mono + one pop.

### 4.3 Layout

Anti-center: no centered hero when `VARIANCE > 4` (split, asymmetric, scroll-pinned) unless editorial/manifesto/launch.

### 4.4 Cards, Surfaces & Shape

* **When to use cards:** Only for real visual grouping or interactive hierarchy; otherwise use whitespace, tonal bands, or subtle `divide-y` hairlines. Banned at `DENSITY > 7`.
* **No one-sided borders (mandatory):** Never put a one-sided accent border (`border-l-4`, `border-t-4`, `border-l-2`, etc.) on cards, stat tiles, callouts, alerts, or list items. Use tonal surface fills, full-perimeter 1px hairline borders (`border border-border-subtle`), or an inline icon/badge for hierarchy.
* **No nested cards:** Never put cards inside cards. Use an inset muted surface (`bg-surface-muted`) or subtle hairline separator inside a card.
* **Depth & shadows:** Prefer crisp 1px hairline borders + subtle tonal surface contrast. When elevation is needed (interactive cards, popovers, dropdowns), use soft, multi-layer shadows tinted to the background - never heavy muddy gray drop shadows.
* **Shape lock (mandatory):** One consistent radius scale per project (`0` sharp, `8-16px` modern rounded, or pill). Apply concentric radius on nested containers (`outer radius = inner radius + padding`).
* **Card padding (mandatory):** Every card has uniform internal padding on all sides (min `p-4`; `p-5` or `p-6` at `DENSITY` 1-5).

### 4.5 Interactive States & Controls

* **Button hierarchy:** Clear tiers - Primary (solid accent fill, high-contrast text), Secondary (tonal surface fill + 1px hairline border), Ghost (transparent, tonal hover), Destructive (semantic red). Keep icons aligned with `gap-2` and `text-box: trim-both`.
* **Loading, empty, error:** Layout-shaped skeletons (no generic spinner dumps); composed empty states with icon + concise message + next action; inline/contextual errors with recovery path.
* **Press feedback:** `:active` = `scale-[0.98]` (150ms `--ease-out`) on pointer-down.
* **Contrast (mandatory):** CTAs, inputs, placeholders, focus rings, tonal badges, helper/error text pass WCAG 2.2 AA (4.5:1 text / 3:1 large & UI). No ghost buttons over photos without a scrim.
* **CTA (mandatory):** One line at desktop (1-3 words); one label per intent page-wide.

### 4.6 Forms & Data Display

* **Forms:** Label above, helper in markup, error below, `gap-2`. Never placeholder-as-label. Use `:user-invalid` so untouched fields never flash errors on load. Use `field-sizing: content` on textareas.
* **Filled selection controls:** Checked checkboxes and radios use solid accent fill + contrasting mark (`accent-color` or custom); switches use pill track + crisp thumb + `role="switch"`.
* **Tables & lists:** Clean rounded surface wrapper with subtle outer border, sticky tonal header, generous row height (`44-52px`), horizontal hairlines only (no heavy vertical gridlines or noisy zebra stripes), right-aligned `tabular-nums` for numbers, tonal row hover on interactive rows.

### 4.7 Layout Hard Rules

* **Hero:** Fits viewport; headline <= 2 lines, subtext <= 20 words / 4 lines, CTA visible; default `text-4xl md:text-5xl lg:text-6xl` (`7xl` only for 3-5 words); max `pt-24`; max 4 text elements (eyebrow/brand, headline, subtext, 1+1 CTAs). Logo wall goes under the hero.
* **Nav:** One line at desktop, 64-80px tall, full-width with square outer edges (`rounded-none`).
* **Bento (mandatory):** N items = N cells, varied rhythm, 2-3 cells with real visual variation.
* **Repetition:** Each layout family max twice; 8 sections need >= 4 families; max 2 consecutive image+text splits.
* **Eyebrows (mandatory):** <= `ceil(sections / 3)`, default none. **Split headers banned.**
* **Mobile collapse explicit per section:** `grid-cols-1`, remove rotation/overlap < 768px, floor `w-full px-4 py-8`.

### 4.8 Images

Order: image-gen tool -> `picsum.photos/seed/{seed}/{w}/{h}` / provided URLs -> labeled slots. Minimal sites still need real images. Serve AVIF first with WebP fallback, responsive `srcset`, `fetchpriority="high"` on the LCP image, native `loading="lazy"` below the fold (`next/image` or unpic). Give photos a subtle inset outline (`1px solid light-dark(rgb(0 0 0 / 0.08), rgb(255 255 255 / 0.1))`, `outline-offset: -1px`) so edges stay crisp. Logos via Simple Icons CDN, no category labels. **Banned:** div-based fake screenshots, decorative hand-rolled SVG, text + blob heroes.

### 4.9 Content Density

* Per section: headline <= 8 words, sub <= 25 words, one visual or CTA.
* No data dumps: top 3-5 + "View all". Lists > 5 -> grouped split, card grid, filled tabs, pills, carousel. No `border-b` spec tables.
* **Copy audit (mandatory):** Rewrite broken, vague, or LLM-sounding strings. Precise numbers must be real or labeled mock. One copy register.

### 4.10 Quotes

Max 3 lines; name + role (+ company); real typographic quotes.

### 4.11 Theme Lock

One theme per page, set at root with `color-scheme: light dark` and `light-dark()` tokens; no inverted sections (except a deliberate single theme switch). A manual toggle only changes `color-scheme` (via `data-theme="light|dark"` on `<html>`); it never duplicates color values in JS or scatters `dark:` classes on every element.

## 11. Dial Definitions

* **VARIANCE** 1-3 centered 12-col; 4-7 offsets, mixed ratios; 8-10 masonry, `2fr 1fr 1fr`, big empty zones. 4+ collapses to one column < 768px.
* **MOTION** 1-3 hover/active only; 4-7 CSS transitions + cascades; 8-10 scroll choreography via scroll-driven animations or Motion hooks.
* **DENSITY** 1-3 `py-32+`; 4-7 `py-16-24`; 8-10 tight, no cards, 1px rules, `font-mono` `tabular-nums` numbers.

## 14. Redesign Protocol

* **Mode:** Greenfield, Preserve (evolve brand), Overhaul (new visuals, keep content + IA). Ambiguous -> ask once.
* **Audit:** tokens, IA, content, patterns to keep/retire, current dials, SEO baseline (#1 risk).
* **Preserve:** IA, slugs, brand colors, voice, a11y wins, analytics IDs.
* **Levers in order:** type -> spacing -> color -> motion -> key sections -> block replacement.
* **Never change silently:** URLs, nav labels, form fields, logo, legal/consent copy.

## 20. Out of Scope

Dense enterprise admin suites (Fluent 2, Carbon, Polaris), heavy spreadsheet grids (TanStack Table, AG Grid), multi-step legal wizards, code editors (Monaco), native mobile (Apple HIG 2026 / Material 3 Expressive), realtime collab. Say so and apply only applicable UI/marketing parts.

## 23. Prototyping Variants

Isolated surface, never production code. 3-5 variants diverging on a named axis, named by direction ("Quiet", "Dense", never "Option A"), fully working. Picker harness -> verify -> user chooses -> promote -> delete prototype.

## 24. Default Site Packs

* **4:** Hero, Features, Social proof, CTA.
* **8:** + Trust bar, Showcase, Use cases, Pricing.
* **12:** + Feature grid, Preview, Problem/solution, Workflow, Metrics/integrations, FAQ.
