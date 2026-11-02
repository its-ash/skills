# Design Direction: Brief, Defaults, Bias Correction

Sections §0, §3, §4, §11, §14, §20, §23, §24 of [`design`](../SKILL.md). §1 (dials) and §2 (system choice) are in SKILL.md. Run the [pre-flight](preflight.md) (§21) before you finish.

## 0. Brief Inference

Read before coding: **page kind**, **vibe words**, **references**, **audience** (picks the aesthetic, not your taste), **brand assets**, **quiet constraints** (a11y-first, public-sector, regulated, kids - these OVERRIDE aesthetics).

Output one line first: **"Reading this as: \<page kind> for \<audience>, with a \<vibe> language, leaning toward \<system/aesthetic>."** Ask at most one question, only if the read truly diverges.

* **Anti-default:** no AI-purple gradients, centered hero on dark mesh, three equal feature cards, generic glassmorphism, infinite micro-loops, Inter + slate-900.
* **Refinement preserves; redesign replaces** (keeps product truth, old look is anti-reference).
* **Mode from surface:** Persuade (marketing - earn attention), Operate (app UI - scanability first), Read (docs - comprehension), Experience (portfolio - artifact leads).

## 3. Default Architecture

* **Stack:** React/Next.js Server Components; motion/scroll/pointer code only in `'use client'` leaves. Tailwind v4. Raw CSS -> §25 ([css-implementation.md](css-implementation.md)).
* **Animation:** Motion (`motion/react`). **Fonts:** `next/font` or self-hosted + `font-display: swap`; never Google Fonts `<link>`.
* **State:** local first; global only vs prop-drilling. Never `useState` for continuous input - use `useMotionValue`/`useTransform`/`useScroll`.
* **Icons:** `@phosphor-icons/react` > `hugeicons-react` > `@radix-ui/react-icons` > `@tabler/icons-react` (`lucide-react` only if present). One family, global `strokeWidth`, never hand-rolled SVG. **No emoji** unless asked.
* **Layout:** breakpoints `640/768/1024/1280/1536`; `max-w-7xl`; `min-h-[100dvh]` never `h-screen`; Grid over `calc()` flex math.
* **Dependencies (mandatory):** check `package.json`; output install command if missing.

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

## 11. Dial Definitions

* **VARIANCE** 1-3 centered 12-col; 4-7 offsets, mixed ratios; 8-10 masonry, `2fr 1fr 1fr`, big empty zones. 4+ collapses to one column < 768px.
* **MOTION** 1-3 hover/active only; 4-7 CSS transitions + cascades; 8-10 scroll choreography via Motion hooks.
* **DENSITY** 1-3 `py-32+`; 4-7 `py-16-24`; 8-10 tight, no cards, 1px rules, `font-mono` numbers.

## 14. Redesign Protocol

* **Mode:** Greenfield, Preserve (evolve brand), Overhaul (new visuals, keep content + IA). Ambiguous -> ask once.
* **Audit:** tokens, IA, content, patterns to keep/retire, current dials, SEO baseline (#1 risk).
* **Preserve:** IA, slugs, brand colors, voice, a11y wins, analytics IDs.
* **Levers in order:** type -> spacing -> color -> motion -> key sections -> block replacement.
* **Never change silently:** URLs, nav labels, form fields, logo, legal/consent copy.

## 20. Out of Scope

Dense dashboards/admin (Fluent, Carbon, Polaris), data tables (TanStack Table, AG Grid), wizards, code editors (Monaco), native mobile (HIG/Material), realtime collab. Say so and apply only marketing parts.

## 23. Prototyping Variants

Isolated surface, never production code. 3-5 variants diverging on a named axis, named by direction ("Quiet", "Dense", never "Option A"), fully working. Picker harness -> verify -> user chooses -> promote -> delete prototype.

## 24. Default Site Packs

* **4:** Hero, Features, Social proof, CTA.
* **8:** + Trust bar, Showcase, Use cases, Pricing.
* **12:** + Feature grid, Preview, Problem/solution, Workflow, Metrics/integrations, FAQ.
