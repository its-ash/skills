---
name: design
description: Unified frontend design skill covering the full lifecycle from brief inference to production. Combines anti-slop content discipline, accessibility, motion mechanics, typography, performance, layout composition (hero discipline, section rhythm, grid mechanics, responsive collapse), animation decision frameworks, spring physics, gesture interactions, component craftsmanship, Apple-inspired fluid interface principles, progressive enhancement, and design-system selection. Auto-invoke for any website design, redesign, landing page, dashboard, product UI, app shell, component build, animation, or frontend UI work (new project or existing).
---

# Design

A single unified skill that encodes everything needed to build interfaces that feel right.

## Core Philosophy

### Taste is trained, not innate

Good taste is not personal preference. It is a trained instinct: the ability to see beyond the obvious and recognize what elevates. Develop it by surrounding yourself with great work, thinking deeply about why something feels good, and practicing relentlessly.

### Unseen details compound

Most details users never consciously notice. That is the point. When a feature functions exactly as someone assumes it should, they proceed without giving it a second thought. That is the goal.

### Beauty is leverage

People select tools based on the overall experience, not just functionality. Good defaults and good animations are real differentiators. Beauty is underutilized in software. Use it as leverage to stand out.

---

## 0. Brief Inference (Read the Room Before Anything Else)

Before touching code or tweaking dials, **infer what the user actually wants**. Most LLM design output is bad because the model jumps to a default aesthetic instead of reading the room.

### 0.A Read these signals first

1. **Page kind** - landing (SaaS / consumer / agency / event), portfolio (dev / designer / creative studio), redesign (preserve vs overhaul), editorial / blog, dashboard, product UI, app shell, component, settings.
2. **Vibe words** the user used - "minimalist", "calm", "Linear-style", "Awwwards", "brutalist", "premium consumer", "Apple-y", "playful", "serious B2B", "editorial", "agency-y", "glassy", "dark tech".
3. **Reference signals** - URLs they linked, screenshots they pasted, products they named, brands they're competing with.
4. **Audience** - B2B procurement panel vs. design-conscious consumer vs. recruiter scanning a portfolio. The audience picks the aesthetic, not your taste.
5. **Brand assets that already exist** - logo, color, type, photography. For redesigns, these are starting material, not optional input.
6. **Quiet constraints** - accessibility-first audiences, public-sector, regulated industries, trust-first commerce, kids' products. These constraints OVERRIDE aesthetic preference.

### 0.B Output a one-line "Design Read" before generating

Before any code, state in one line: **"Reading this as: \<page kind> for \<audience>, with a \<vibe> language, leaning toward \<design system or aesthetic family>."**

### 0.C If the brief is ambiguous, ask one question

Ask exactly **one** clarifying question - never a multi-question dump - and only when the design read genuinely diverges. If you can confidently infer from context, **do not ask**. Just declare the design read and proceed.

### 0.D Anti-Default Discipline

Do not default to: AI-purple gradients, centered hero over dark mesh, three equal feature cards, generic glassmorphism on everything, infinite-loop micro-animations everywhere, Inter + slate-900. These are the LLM defaults. Reach past them deliberately based on the design read.

**Refinement preserves; redesign replaces.** Refinement keeps the incumbent identity, behavior, copy, and everything outside scope - ask before replacing factual copy or adding claims. Redesign keeps product truth and function but treats the old look as anti-reference.

---

## 1. The Three Dials (Core Configuration)

After the design read, set three dials. Every layout, motion, and density decision is gated by these.

* **`DESIGN_VARIANCE: 8`** - 1 = Perfect Symmetry, 10 = Artsy Chaos
* **`MOTION_INTENSITY: 6`** - 1 = Static, 10 = Cinematic / Physics
* **`VISUAL_DENSITY: 4`** - 1 = Art Gallery / Airy, 10 = Cockpit / Packed Data

**Baseline:** `8 / 6 / 4`. Use these unless the design read overrides them.

### 1.A Dial Inference (design read -> dial values)

| Signal | VARIANCE | MOTION | DENSITY |
|---|---|---|---|
| "minimalist / clean / calm / editorial / Linear-style" | 5-6 | 3-4 | 2-3 |
| "premium consumer / Apple-y / luxury / brand" | 7-8 | 5-7 | 3-4 |
| "playful / wild / Dribbble / Awwwards / experimental / agency" | 9-10 | 8-10 | 3-4 |
| "landing page / portfolio / marketing site (default)" | 7-9 | 6-8 | 3-5 |
| "trust-first / public-sector / regulated / accessibility-critical" | 3-4 | 2-3 | 4-5 |
| "redesign - preserve" | match existing | +1 | match existing |
| "redesign - overhaul" | +2 | +2 | match existing |

### 1.B Use-Case Presets

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

Unless the design read picks a real design system (Section 2.A), these are the defaults:

### 3.A Stack

* **Framework:** React or Next.js. Default to Server Components (RSC). Wrap providers in `"use client"`. Any component using Motion, scroll listeners, or pointer physics MUST be an isolated leaf with `'use client'`.
* **Styling:** Tailwind v4 (default). Tailwind v3 only if the existing project demands it. For v4: use `@tailwindcss/postcss` or the Vite plugin, not the `tailwindcss` plugin in `postcss.config.js`.
* **Animation:** Motion (formerly Framer Motion). Import from `motion/react`.
* **Fonts:** Always use `next/font` (Next.js) or self-host with `@font-face` + `font-display: swap`. Never link Google Fonts via `<link>` in production.

### 3.B State

* Local `useState` / `useReducer` for isolated UI.
* Global state ONLY for deep prop-drilling avoidance - Zustand, Jotai, or React context.
* **NEVER** use `useState` to track continuous values driven by user input (mouse position, scroll progress, pointer physics, magnetic hover). Use Motion's `useMotionValue` / `useTransform` / `useScroll`.

### 3.C Icons

* **Allowed (priority order):** `@phosphor-icons/react`, `hugeicons-react`, `@radix-ui/react-icons`, `@tabler/icons-react`.
* **Discouraged:** `lucide-react`. Acceptable only when explicitly requested or already in the project.
* **NEVER hand-roll SVG icons.** If a glyph is missing, install a second library or compose from primitives.
* **One family per project.** Do not mix icon libraries. Standardize `strokeWidth` globally (e.g. `1.5` or `2.0`).

### 3.D Emoji Policy

Discouraged by default in code, markup, and visible text. Replace symbols with icon-library glyphs. **Override:** allow only when the user explicitly asks for a playful / chat-style / social-native vibe - and even then use sparingly.

### 3.E Responsiveness & Layout Mechanics

* Standardize breakpoints (`sm 640`, `md 768`, `lg 1024`, `xl 1280`, `2xl 1536`).
* Contain page layouts using `max-w-[1400px] mx-auto` or `max-w-7xl`.
* **Viewport Stability:** NEVER use `h-screen` for full-height Hero sections. ALWAYS use `min-h-[100dvh]` to prevent layout jumping on mobile (iOS Safari address bar).
* **Grid over Flex-Math:** NEVER use complex flexbox percentage math (`w-[calc(33%-1rem)]`). ALWAYS use CSS Grid (`grid grid-cols-1 md:grid-cols-3 gap-6`).

### 3.F Dependency Verification (mandatory)

Before importing ANY 3rd-party library, check `package.json`. If the package is missing, output the install command first. **Never** assume a library exists.

---

## 4. Design Engineering Directives (Bias Correction)

LLMs default to cliches. Override these defaults proactively. Each rule has a context-aware override path.

### 4.1 Typography

* **Display / Headlines:** Default `text-4xl md:text-6xl tracking-tighter leading-none`.
* **Body / Paragraphs:** Default `text-base text-gray-600 leading-relaxed max-w-[65ch]`.
* **Sans font choice:**
  * **Discouraged as default:** `Inter`. Pick `Geist`, `Outfit`, `Cabinet Grotesk`, `Satoshi`, or a brand-appropriate serif first.
  * **Override:** Inter is acceptable when the user explicitly asks for a neutral / standard / Linear-style feel, or for public-sector / accessibility-first sites.
* **Pairings to know:** `Geist` + `Geist Mono`, `Satoshi` + `JetBrains Mono`, `Cabinet Grotesk` + `Inter Tight`, `GT America` + `IBM Plex Mono`.
* **SERIF DISCIPLINE (VERY DISCOURAGED AS DEFAULT):**
  * Serif is **very discouraged as the default font.** "It feels creative / premium / editorial" is NOT a reason to reach for serif.
  * Serif is only acceptable when: the brand brief literally names a serif font, OR the aesthetic family is genuinely editorial / luxury / publication / heritage / vintage AND you can articulate why this specific serif fits.
  * **Specifically BANNED as defaults:** `Fraunces` and `Instrument_Serif` (the two LLM-favorite display serifs).
  * If justified (rare), rotate from this pool, do NOT reuse the same serif across consecutive projects: PP Editorial New, GT Sectra Display, Cardinal Grotesque, Reckless Neue, Tiempos Headline, Recoleta, Cormorant Garamond, Playfair Display, EB Garamond, IvyPresto, Migra, Editorial Old, Saol Display.
* **EMPHASIS RULE:** When you want to emphasize a word within a headline, use **italic or bold of the SAME font**. Do NOT inject a random serif word into a sans headline. Mixed-family emphasis is amateur.
* **ITALIC DESCENDER CLEARANCE (mandatory):** When italic is used in display type and the word contains a descender letter (`y g j p q`), `leading-[1]` or `leading-none` will clip the descender. Use `leading-[1.1]` minimum and add `pb-1` or `mb-1` reserve.
* **Tracking is size-specific.** Large display text wants negative letter-spacing (`-0.02em` to `-0.04em` as it grows); body text stays near `0` or slightly positive at small sizes. One fixed `letter-spacing` value across all sizes is wrong.
* **Leading tracks size inversely.** Tight leading (`1.0-1.1`) on large display headings, looser (`1.5-1.6`) on body copy.
* **Build hierarchy from weight + size + leading together**, not size alone.
* Never absolute black (`#000`) for body text - use off-black/charcoal for legibility and warmth.
* **Respect the user's text-size setting** (Dynamic Type). Scale layout with the text - spacing in `rem`/`em`, not fixed `px`.

### 4.2 Color Calibration

* Max 1 accent color. Saturation < 80% by default.
* **THE LILA RULE:** The "AI Purple / Blue glow" aesthetic is discouraged as a default. No automatic purple button glows, no random neon gradients. Use neutral bases (Zinc / Slate / Stone) with high-contrast singular accents (Emerald, Electric Blue, Deep Rose, Burnt Orange, etc.).
* **Override:** if the brand or brief explicitly asks for purple / violet / lila, embrace it. But execute with intent: consistent palette, harmonised neutrals, restrained gradients.
* **One palette per project.** Do not fluctuate between warm and cool grays within the same project.
* **COLOR CONSISTENCY LOCK (mandatory):** Once an accent color is chosen for a page, it is used on the WHOLE page. A warm-grey site does not suddenly get a blue CTA in section 7. Pick one accent, lock it, audit every component before shipping.
* **No pure `#000000` and no pure `#ffffff`** - use off-black and off-white. Pure values kill depth.
* **PREMIUM-CONSUMER PALETTE BAN (mandatory):** For premium-consumer briefs (cookware, wellness, artisan, luxury), the LLM default is warm beige/cream + brass/clay/oxblood/ochre + espresso/ink dark text. This palette is BANNED as the default reach. Default alternatives (rotate, do not reuse): Cold Luxury (silver-grey + chrome), Forest (deep green + bone + amber), Black and Tan (off-black + warm tan), Cobalt + Cream, Terracotta + Slate, Olive + Brick + Paper, Pure monochrome + single saturated pop.

### 4.3 Layout Diversification

* **ANTI-CENTER BIAS:** Centered Hero / H1 sections are avoided when `DESIGN_VARIANCE > 4`. Force "Split Screen" (50/50), "Left-aligned content / right-aligned asset", "Asymmetric white-space", or scroll-pinned structures.
* **Override:** centered hero is OK for editorial / manifesto / launch-announcement briefs where the message itself is the design.

### 4.4 Materiality, Shadows, Cards

* Use cards ONLY when elevation communicates real hierarchy. Otherwise group with `border-t`, `divide-y`, or negative space.
* When a shadow is used, tint it to the background hue. No pure-black drop shadows on light backgrounds.
* For `VISUAL_DENSITY > 7`: generic card containers are banned. Data metrics breathe in plain layout.
* **SHAPE CONSISTENCY LOCK (mandatory):** Pick ONE corner-radius scale for the page and stick to it. Options: all-sharp (radius 0), all-soft (radius 12-16px), all-pill (full radius for interactive). Mixed systems are allowed only when there is a documented rule and that rule is followed everywhere.

### 4.5 Interactive UI States

LLMs default to "static successful state only." Always implement full cycles:

* **Loading:** Skeletal loaders matching the final layout's shape. Avoid generic circular spinners.
* **Empty States:** Beautifully composed; indicate how to populate.
* **Error States:** Clear, inline (forms), or contextual (toasts only for transient).
* **Tactile Feedback:** On `:active`, use `-translate-y-[1px]` or `scale-[0.98]` to simulate a physical push. Triggered on pointer-down, not on release.
* **BUTTON CONTRAST CHECK (mandatory, a11y):** Every CTA text is readable against its background. White button + white text, `bg-white` CTA with `text-white` label, transparent button against the page background with no border -> all banned. Audit every CTA: WCAG AA min (4.5:1 for body, 3:1 for large text 18px+). Same rule applies to ghost buttons over photographic backgrounds (use a backdrop, scrim, or stroke).
* **CTA BUTTON WRAP BAN (mandatory):** Button text MUST fit on one line at desktop. If a label wraps to 2 or 3 lines, shorten it (3 words max for primary CTAs, ideally 1-2) OR widen the button. Do not artificially constrain `max-width` on CTAs.
* **NO DUPLICATE CTA INTENT (mandatory):** Two CTAs with the same intent on one page is a failure. Pick ONE label per intent and use it everywhere on the page (nav, hero, footer).
* **FORM CONTRAST CHECK (mandatory, a11y):** Form inputs, placeholder text, focus rings, helper text, and error text all pass WCAG AA contrast against the section background.

### 4.6 Data & Form Patterns

* Label ABOVE input. Helper text optional but present in markup. Error text BELOW input. Standard `gap-2` for input blocks.
* No placeholder-as-label. Ever.

### 4.7 Layout Discipline (Hard Rules)

* **Hero MUST fit in the initial viewport.** Headline max 2 lines on desktop, subtext max **20 words** AND max 3-4 lines, CTAs visible without scroll. If copy is too long: reduce font scale OR cut copy. Never let the hero overflow and force scroll to find the CTA.
* **Hero font-scale discipline.** Plan font size and image size *together*. If the hero asset is large and the headline is more than 6 words, do not start at `text-7xl/text-8xl`. Default sensible range: `text-4xl md:text-5xl lg:text-6xl` for most heroes; `text-6xl md:text-7xl` only when the headline is 3-5 words. A 4-line hero headline is always a font-size error, never a copy-length error.
* **HERO TOP PADDING CAP (mandatory):** Hero top padding max `pt-24` (~6rem) at desktop. More than that means the hero content floats halfway down the viewport and reads as a layout bug.
* **HERO STACK DISCIPLINE (max 4 text elements).** The hero is a single moment, not a feature list. Allowed text elements, max 4: (1) Eyebrow OR brand strip OR neither - pick zero or one, (2) Headline, (3) Subtext, (4) CTAs (1 primary + max 1 secondary). BANNED in the hero: tiny taglines below CTAs, trust micro-strips, pricing teasers, feature bullet lists, social-proof avatar rows.
* **"Used by" / "Trusted by" logo wall belongs UNDER the hero, never inside it.**
* **Navigation MUST render on a single line on desktop.** If items don't fit at `lg` (1024px), condense labels, drop secondary items, or move to a hamburger. A two-line nav at desktop is broken design.
* **Navigation height cap: 80px max desktop, default 64-72px.**
* **Bento grids MUST have rhythm, not one-sided repetition.** Do not stack 6 left-image / right-text rows. Vary the composition.
* **BENTO CELL COUNT RULE (mandatory):** A bento grid has EXACTLY as many cells as you have content for. 3 items -> 3 cells. 5 items -> 5 cells. If your grid has an empty cell in the middle or at the end, you planned wrong. Re-shape the grid; do not paste a blank tile.
* **Section-Layout-Repetition Ban.** Once a layout family is used for a section, it can appear at most once more on the page. An 8-section landing page needs at least 4 distinct layout families.
* **ZIGZAG ALTERNATION CAP (mandatory).** Alternating left-image/right-text then left-text/right-image zigzag = banal. Max 2 sections in a row with this pattern. The 3rd consecutive image+text split is a failure. Break the pattern with a full-width section, a vertical-stack section, a bento grid, a marquee, or a different layout family.
* **EYEBROW RESTRAINT (mandatory, the #1 violated rule).** An "eyebrow" is the small uppercase wide-tracked label above a section headline. Max 1 eyebrow per 3 sections (hero counts as 1). Mechanical check: count `uppercase tracking` instances across sections; if it exceeds `ceil(sectionCount / 3)`, cut some. Default to no eyebrow - the section's position on the page already categorizes it.
* **SPLIT-HEADER BAN (mandatory).** "Left big headline + right small explainer paragraph" as a section header is **banned by default**. Sections should have ONE focused message. If you genuinely need both a headline and an explainer, stack them vertically (headline on top, body below, max-width 65ch).
* **Bento Background Diversity (mandatory).** At least 2-3 cells in any multi-cell grid need real visual variation (image, gradient, pattern, tinted background). An all-white-card grid with only typography inside reads as the AI default.
* **Mobile collapse must be explicit per section.** For every multi-column layout, declare the `<768px` fallback in the same component. No "it'll work, Tailwind handles it" assumptions.

### 4.8 Image & Visual Asset Strategy

**Priority order for visual assets:**
1. **Image-generation tool first.** If ANY image-gen tool is available, use it to create section-specific assets at the right aspect ratio.
2. **Real web images second.** Use `https://picsum.photos/seed/{descriptive-seed}/{w}/{h}` for placeholders, actual stock or brand URLs when provided, open-license sources if explicitly allowed.
3. **Last resort: tell the user.** Leave clearly-labeled placeholder slots and tell the user exactly what's missing and where.

* **Even minimalist sites need real images.** A pure-text page is not minimalism. It is incomplete work.
* **Real company logos for social proof.** Use actual SVG marks (Simple Icons CDN: `https://cdn.simpleicons.org/{slug}`, devicon for tech-stack logos). For invented brand names, generate a simple monogram SVG rather than plain text wordmarks.
* **LOGO-ONLY rule (mandatory):** logo wall = logos and nothing else. Do NOT print industry / category labels below each logo.
* **Hand-rolled decorative SVG illustrations are strongly discouraged** except for simple geometric marks the user explicitly requested.
* **Div-based fake screenshots are banned.** Fake dashboards, fake terminal windows, fake task lists built from `<div>` rectangles are an obvious tell. Use a real screenshot, a generated image, a real component preview, or none at all.
* **Hero needs a real visual.** Text + gradient blob is not a hero - it's a placeholder.

### 4.9 Content Density

Landing pages live on the **first impression**, not the full read. Cut ruthlessly.

* **Default content shape per section:** short headline (<= 8 words) + short sub-paragraph (<= 25 words) + one visual asset OR one CTA. Anything more must be justified.
* **No data-dump sections.** A 20-row publication table, a 30-row award list, a giant pricing matrix = wrong layout. Use: Top 3-5 highlights + "View full list" link, Marquee / carousel, Different page entirely if the data is the product.
* **Long lists need a different UI component, not a longer list.** Default `<ul>` with bullets / `divide-y` rows is the lazy choice. If you have > 5 items, reach for: 2-column split with grouped items, Card grid, Tabs / accordion, Horizontal scroll-snap pills, Carousel, Marquee.
* **Spec sheets specifically:** A long product specification table with `border-b` on every row is the AI default. Banned. Concrete alternatives: 2-col card grid, Scroll-snap horizontal pills, Grouped chunks, Featured-vs-rest.
* **COPY SELF-AUDIT (mandatory before ship):** Re-read every visible string on the page. Flag any string that is grammatically broken, has unclear referents, sounds like AI hallucination, or reads like an LLM trying to sound thoughtful. Rewrite every flagged string.
* **Fake-precise numbers are flagged.** Numbers like `92%`, `4.1x`, `48k` either come from real data (fine), are explicitly labeled as mock (fine), or are AI-invented spec aesthetics (banned).
* **One copy register per page.** Don't mix technical mono, editorial prose, and marketing punch in the same composition unless the brand voice explicitly calls for it.

### 4.10 Quotes & Testimonials

* **Max 3 lines** of quote body. Never 6. If the original quote is longer, cut it.
* Attribution: name + role + (optionally) company. Never name only.
* Quote marks: use real typographic quotes or none at all. Not straight ASCII.

### 4.11 Page Theme Lock (Light / Dark Mode Consistency)

The page has ONE theme. Sections do not invert.

* If the page is dark mode, ALL sections are dark mode. No light-mode section sandwiched between dark sections (or vice versa).
* Exception: if the brief explicitly calls for a "Color Block Story" or "Theme Switch on Scroll" device AND that is a deliberate composition (one full theme switch with a strong transition, not random alternation).
* When using a design system with built-in theming, set the theme ONCE in `layout.tsx` or the page root. Do not let individual sections override.
* Respect `prefers-color-scheme`. Default to system preference unless the brand insists on one mode.

---

## 5. The Animation Decision Framework

Before writing any animation code, answer these questions in order:

### 5.A Should this animate at all?

**Ask:** How often will users see this animation?

| Frequency | Decision |
|---|---|
| 100+ times/day (keyboard shortcuts, command palette toggle) | **No animation. Ever.** Stop here. |
| Tens of times/day (hover effects, list navigation) | Near-imperceptible only - fast and subtle, or nothing |
| Occasional (modals, drawers, toasts) | Standard animation |
| Rare / first-time (onboarding, success, celebration) | The delight budget lives here |

**Never animate keyboard-initiated actions.** Raycast has no open/close animation. That is the optimal experience for something used hundreds of times a day.

### 5.B What is the purpose?

Name it in one of these words before continuing:

- **Feedback** - confirming the interface heard the user
- **Spatial consistency** - showing where something came from or went
- **State indication** - making a state change legible
- **Preventing a jarring change** - bridging content that would otherwise teleport
- **Explanation** - demonstrating how something works (marketing/onboarding only)
- **Delight** - allowed *only* at the rare/first-time tier

Can't name it? Don't build it. "It looks cool" on a frequently-seen element is a reason to stop.

Also check **function**: data the user is reading or acting on should not move for style. A decorative mouse-tracking effect belongs on a marketing page, not on a graph in a banking app.

### 5.C What easing should it use?

| Situation | Easing |
|---|---|
| Entering or exiting | `ease-out` |
| Moving / morphing on screen | `ease-in-out` |
| Hover / color change | `ease` |
| Constant motion (marquee, progress) | `linear` |
| Default | `ease-out` |

**Never `ease-in` on UI.** It starts slow, delaying the exact moment the user watches most. `ease-out` at 200ms *feels* faster than `ease-in` at 200ms.

Built-in CSS easings are too weak. Use these:

```css
--ease-out: cubic-bezier(0.23, 1, 0.32, 1);        /* strong ease-out for UI */
--ease-in-out: cubic-bezier(0.77, 0, 0.175, 1);    /* strong ease-in-out */
--ease-drawer: cubic-bezier(0.32, 0.72, 0, 1);     /* iOS-like drawer curve */
```

### 5.D How fast should it be?

| Element | Duration |
|---|---|
| Button press feedback | 100-160ms |
| Tooltips, small popovers | 125-200ms |
| Dropdowns, selects | 150-250ms |
| Modals, drawers | 200-500ms |
| Marketing / explanatory | Can be longer |

**Rule: UI animations should stay under 300ms.** A 180ms dropdown feels more responsive than a 400ms one. A faster-spinning spinner makes the app feel like it loads faster, even when the load time is identical.

### 5.E Pick the tool - cheapest that works

| Need | Tool |
|---|---|
| Hover, press, color, a state toggle | **CSS transition** |
| Entry animation on mount, no JS state | **CSS `@starting-style`** |
| Predetermined motion that must stay smooth under load | **CSS animation** (runs off main thread) |
| Programmatic control with CSS performance, no library | **WAAPI** (`element.animate()`) |
| Springs, layout animations, exit animations, gesture-driven values | **Motion** (`motion.dev`) |

CSS animations beat JS under load - they run off the main thread, while `requestAnimationFrame`-based animation drops frames while the browser loads. Use CSS for predetermined motion, JS for dynamic and interruptible motion.

---

## 6. Motion Mechanics (Applies to Every Theme and Layout)

### 6.A Core Principles

* **Animate only `transform` and `opacity`.** They skip layout/paint and run on the compositor. Never animate `width`, `height`, `top`, `left`, `margin`, `padding` (accordions tolerate `height` only because there's no transform equivalent). `clip-path` is the sanctioned fourth property.
* **Never `scale(0)` on entrance.** Start from `scale(0.9-0.97)` + `opacity: 0` - nothing in the real world appears from nothing.
* **Never `ease-in` on UI.** Use `ease-out` for enter/exit, `ease-in-out` for on-screen movement, `linear` only for constant motion.
* **UI animations stay under 300ms.** See duration table in Section 5.D.
* **Springs for anything gesture-driven or interruptible** (drag, momentum, reversible transitions) - they carry velocity through interruption; CSS keyframes restart from zero and can't be smoothly grabbed mid-flight.
* **Always animate from the current on-screen value**, never the target value, when interrupting - read the live transform, don't jump.
* **Symmetric enter/exit paths.** Something that slides in from the right dismisses to the right. `transform-origin` anchors to the trigger element for popovers/menus/tooltips (modals are exempt - they're not trigger-anchored).
* **Stagger, don't mass-mount.** Lists and grids enter with a 30-80ms cascade delay, never all at once.
* **Gate hover on real pointers:** `@media (hover: hover) and (pointer: fine)` - touch fires false hover states on tap otherwise.
* **Frequency gates whether it animates at all:** 100+ times/day actions get zero animation; occasional actions get standard animation; rare/first-time moments are where a delight budget is spent.
* **Exit faster than entrance.** Asymmetric timing: slow where the user is deciding, fast where the system is responding.
* **MOTION MUST BE MOTIVATED (mandatory).** Before adding any animation, ask: "what does this animation communicate?" Valid: hierarchy, storytelling, feedback, state transition. Invalid: "it looked cool". Each animation needs a reason you can articulate in one sentence.
* **MARQUEE MAX-ONE-PER-PAGE (mandatory).** Horizontal scrolling text marquees are appropriate at most ONCE per page.

### 6.B Spring Physics (Apple-Inspired)

Apple deliberately replaced the physics triplet (mass/stiffness/damping) with two designer-friendly parameters:

- **Damping ratio** - controls overshoot. `1.0` = critically damped, no bounce, smooth settle. `< 1.0` = overshoots and oscillates. Lower = bouncier.
- **Response** - how quickly the value reaches the target, in seconds. Lower = snappier. This is not "duration" - a spring has no fixed duration; its settle time emerges from the parameters.

**Defaults:**
- Start most UI at **damping `1.0`** (critically damped) - graceful and non-distracting.
- Add bounce (**damping ~`0.8`**) **only when the gesture itself carried momentum** (a flick, a throw, a drag release). Overshoot on a menu that just faded in feels wrong; overshoot on a card you flicked feels right.

**Concrete values:**

| Interaction | Damping | Response |
|---|---|---|
| Move / reposition | `1.0` | `0.4` |
| Rotation | `0.8` | `0.4` |
| Drawer / sheet | `0.8` | `0.3` |

**Web mapping (Motion / Framer Motion):**

```js
// Critically damped default (no overshoot)
animate(el, { y: 0 }, { type: 'spring', bounce: 0, duration: 0.4 });

// Momentum interaction - a little bounce
animate(el, { y: target }, { type: 'spring', bounce: 0.2, duration: 0.4 });
```

Keep bounce at 0.1-0.3, and avoid bounce in most UI - reserve it for drag-to-dismiss and playful interactions.

### 6.C Velocity Handoff (The Seam Between Drag and Animation)

When a gesture ends, the animation must **continue at the finger's exact velocity**, so there's no visible seam between dragging and animating.

Pass the pointer's release velocity as the spring's initial velocity. Some spring APIs want **relative** velocity - normalize it by the remaining distance to the target:

```
relativeVelocity = gestureVelocity / (targetValue - currentValue)
```

### 6.D Momentum Projection

Don't snap to the nearest boundary from the release point. Use velocity to **project the resting position** - exactly like scroll deceleration - then snap to the target nearest that projected point.

```js
function project(initialVelocity, decelerationRate = 0.998) {
  return (initialVelocity / 1000) * decelerationRate / (1 - decelerationRate);
}
const projectedEndpoint = currentPosition + project(releaseVelocity);
const target = nearestSnapPoint(projectedEndpoint);
animateSpringTo(target, { velocity: releaseVelocity });
```

### 6.E Interruptibility (The Single Most Important Principle)

Every animation must be interruptible and redirectable at any moment. A user must be able to grab a moving element mid-flight and reverse it without waiting for the animation to finish.

- **Never lock out input during a transition.**
- **Always animate from the *presentation* (current) value, never the target value.** On interrupt, read the element's live on-screen transform and start the new animation from there.
- **Avoid CSS transitions and `@keyframes` for anything gesture-driven** - they can't be smoothly grabbed and reversed mid-flight. Springs animate from the current value by default.
- **When a gesture reverses, blend velocity - don't hard-cut it.**
- **Decompose 2D motion into independent X and Y springs.** A single spring on a 2D distance desyncs when X and Y have different velocities.

### 6.F Spatial Consistency

> "If something disappears one way, we expect it to emerge from where it came."

- **Enter and exit along the same path.** A panel that slides in from the right must dismiss to the right.
- **Anchor interactions to their source.** A menu, popover, or sheet should originate from the element that triggered it - set `transform-origin` to the trigger.
- **Mirror the easing on reversible transitions** so the outbound path matches the return path (use inverse cubic-bezier control points).

### 6.G Rubber-Banding (Soft Boundaries)

At an edge, resist progressively instead of stopping hard. A hard stop reads as "frozen"; continuous resistance reads as "responsive, but there's nothing more here." Apply damping that increases the further past the boundary the user drags.

```js
function rubberband(overshoot, dimension, constant = 0.55) {
  return (overshoot * dimension * constant) / (dimension + constant * Math.abs(overshoot));
}
```

### 6.H Materials & Depth

- Build nav/toolbars/sheets as translucent layers (`backdrop-filter: blur()` + semi-transparent background) with content scrolling underneath.
- Material weight encodes hierarchy: darker/heavier materials separate structural regions; lighter materials draw attention to interactive elements.
- **Never stack a light translucent surface on another** - legibility collapses.
- Vibrancy keeps text legible over changing backgrounds: use higher-contrast, slightly heavier weight, and a small letter-spacing bump over blurred surfaces.
- Scroll edge effects, not hard dividers: fade a small blur/gradient mask where content meets floating chrome.
- Materialize, don't just fade: for glass/blur surfaces, animate blur radius and scale together on enter/exit.

---

## 7. Component Building Principles

### Buttons must feel responsive

Add `transform: scale(0.97)` on `:active`. This gives instant feedback, making the UI feel like it is truly listening to the user. Trigger on pointer-down, not release.

```css
.button {
  transition: transform 160ms ease-out;
}
.button:active {
  transform: scale(0.97);
}
```

This applies to any pressable element. The scale should be subtle (0.95-0.98).

### Never animate from scale(0)

Nothing in the real world disappears and reappears completely. Start from `scale(0.9)` or higher, combined with opacity.

```css
/* Bad */
.entering { transform: scale(0); }

/* Good */
.entering { transform: scale(0.95); opacity: 0; }
```

### Make popovers origin-aware

Popovers should scale in from their trigger, not from center. **Exception: modals.** Modals should keep `transform-origin: center` because they are not anchored to a specific trigger.

```css
.popover {
  transform-origin: var(--transform-origin);
}
```

### Tooltips: skip delay on subsequent hovers

Tooltips should delay before appearing to prevent accidental activation. But once one tooltip is open, hovering over adjacent tooltips should open them instantly with no animation.

### Use CSS transitions over keyframes for interruptible UI

CSS transitions can be interrupted and retargeted mid-animation. Keyframes restart from zero. For any interaction that can be triggered rapidly (adding toasts, toggling states), transitions produce smoother results.

### Use blur to mask imperfect transitions

When a crossfade between two states feels off despite trying different easings and durations, add subtle `filter: blur(2px)` during the transition. Blur bridges the visual gap by blending the two states together. Keep blur under 20px - heavy blur is expensive, especially in Safari.

### Animate enter states with @starting-style

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

This replaces the React pattern of using `useEffect` to set `mounted: true`. Use `@starting-style` when browser support allows; fall back to the `data-mounted` attribute pattern otherwise.

### clip-path for animation

`clip-path` is one of the most powerful animation tools in CSS. The `inset()` shape defines a rectangular clipping region:

```css
/* Hold-to-delete: slow press, fast release */
.overlay {
  clip-path: inset(0 100% 0 0);
  transition: clip-path 200ms ease-out;
}
.button:active .overlay {
  clip-path: inset(0 0 0 0);
  transition: clip-path 2s linear;
}
```

### Gesture and Drag Interactions

* **Momentum-based dismissal:** Don't require dragging past a threshold. Calculate velocity: `Math.abs(dragDistance) / elapsedTime`. If velocity exceeds ~0.11, dismiss regardless of distance. A quick flick should be enough.
* **Damping at boundaries:** When a user drags past the natural boundary, apply damping. The more they drag, the less the element moves.
* **Pointer capture for drag:** Once dragging starts, set the element to capture all pointer events so dragging continues even if the pointer leaves the element bounds.
* **Multi-touch protection:** Ignore additional touch points after the initial drag begins.
* **Friction instead of hard stops:** Allow dragging past boundaries with increasing friction. It feels more natural than hitting an invisible wall.

### Stagger Animations

When multiple elements enter together, stagger their appearance. Keep stagger delays short (30-80ms between items). Long delays make the interface feel slow. Stagger is decorative - never block interaction while stagger animations are playing.

```css
.item { opacity: 0; transform: translateY(8px); animation: fadeIn 300ms ease-out forwards; }
.item:nth-child(1) { animation-delay: 0ms; }
.item:nth-child(2) { animation-delay: 50ms; }
.item:nth-child(3) { animation-delay: 100ms; }
```

### CSS Transform Mastery

* **translateY with percentages:** Percentage values in `translate()` are relative to the element's own size. `translateY(100%)` moves an element by its own height, regardless of actual dimensions.
* **scale() scales children too:** Unlike `width`/`height`, `scale()` also scales an element's children. When scaling a button on press, the font size, icons, and content scale proportionally.
* **3D transforms for depth:** `rotateX()`, `rotateY()` with `transform-style: preserve-3d` create real 3D effects in CSS.
* **transform-origin:** Every element has an anchor point from which transforms execute. Set it to match where the trigger lives for origin-aware interactions.

---

## 8. Performance Guardrails

### Only animate transform and opacity

These properties skip layout and paint, running on the GPU. Animating `padding`, `margin`, `height`, or `width` triggers all three rendering steps.

### CSS variables are inheritable

Changing a CSS variable on a parent recalculates styles for all children. Update `transform` directly on the element instead.

```js
// Bad: triggers recalc on all children
element.style.setProperty('--swipe-amount', `${distance}px`);

// Good: only affects this element
element.style.transform = `translateY(${distance}px)`;
```

### Framer Motion hardware acceleration caveat

Framer Motion's shorthand properties (`x`, `y`, `scale`) are NOT hardware-accelerated. They use `requestAnimationFrame` on the main thread. For hardware acceleration, use the full `transform` string:

```jsx
// NOT hardware accelerated (drops frames under load)
<motion.div animate={{ x: 100 }} />

// Hardware accelerated (stays smooth)
<motion.div animate={{ transform: "translateX(100px)" }} />
```

### CSS animations beat JS under load

CSS animations run off the main thread. When the browser is busy loading a new page, Framer Motion animations drop frames. CSS animations remain smooth. Use CSS for predetermined animations; JS for dynamic, interruptible ones.

### Use WAAPI for programmatic CSS animations

The Web Animations API gives you JavaScript control with CSS performance. Hardware-accelerated, interruptible, and no library needed.

```js
element.animate([{ clipPath: 'inset(0 0 100% 0)' }, { clipPath: 'inset(0 0 0 0)' }], {
  duration: 1000,
  fill: 'forwards',
  easing: 'cubic-bezier(0.77, 0, 0.175, 1)',
});
```

### Additional guardrails

* `backdrop-blur` only on fixed/sticky elements (navbars, overlays) - never on scrolling containers or large content areas; it forces continuous GPU repaints.
* Scroll-driven reveals use `IntersectionObserver`, never `window.addEventListener('scroll')`.
* `will-change: transform` sparingly, only on elements actively animating.
* No arbitrary `z-[9999]` - reserve z-index tiers strictly for sticky nav, modals, overlays, tooltips.
* `min-h-[100dvh]`, never `h-screen`, for full-height sections - prevents iOS Safari address-bar layout jumps.
* Apply grain / noise filters EXCLUSIVELY to fixed, `pointer-events-none` pseudo-elements. NEVER on scrolling containers - continuous GPU repaints destroy mobile FPS.
* Lazy-initialize heavy resources (WebGL contexts, WASM modules) only when near viewport.
* Pause off-screen rendering. Kill what you can't see.
* Test on real mid-range devices, not just your development machine.

### Core Web Vitals Targets

* **LCP** < 2.5s. Hero image must be preloaded.
* **INP** < 200ms. Heavy work off main thread.
* **CLS** < 0.1. Reserve space for images, fonts, embeds.

---

## 9. Accessibility

### Contrast

WCAG AA minimum - 4.5:1 for body text, 3:1 for large text (18px+/bold 14px+). Audit every button, especially white-on-white, transparent-on-photo, and ghost buttons - add a scrim, stroke, or backdrop when text sits over imagery.

### Forms

Label above input, helper text present, error text below input. No placeholder-as-label, ever. Placeholder and helper text must also pass AA contrast.

### Reduced motion (`prefers-reduced-motion: reduce`)

Replace slides/springs/parallax with short opacity cross-fades. Drop elastic/overshoot. This means *gentler*, not *zero* - keep transitions that aid comprehension.

```css
@media (prefers-reduced-motion: reduce) {
  .element { transition: opacity 200ms ease; transform: none !important; }
}
```

Reduced motion means fewer and gentler animations, not zero. Keep opacity and color transitions that aid comprehension. Remove movement and position animations.

### Reduced transparency (`prefers-reduced-transparency: reduce`)

Raise translucent-surface background opacity and drop blur.

```css
@media (prefers-reduced-transparency: reduce) {
  .surface { background: white; backdrop-filter: none; }
}
```

### Reduced contrast preference (`prefers-contrast: more`)

Near-solid backgrounds with a defined, contrasting border.

### Additional accessibility

* Respect the user's text-size setting: layout spacing in `rem`/`em`, not fixed `px`, so scaled text doesn't break layout.
* Avoid full-viewport moving backgrounds and slow looping oscillations near 0.2Hz (one cycle per 5s) - both are known vestibular triggers.
* Touch targets minimum 44x44px.
* Avoid abrupt brightness jumps; ease dark <-> light theme changes.
* Make large moving objects semi-transparent while they travel, and fade big surfaces out during a large reposition and back in once settled.

### Touch device hover states

```css
@media (hover: hover) and (pointer: fine) {
  .element:hover {
    transform: scale(1.05);
  }
}
```

Touch devices trigger hover on tap, causing false positives. Gate hover animations behind this media query.

---

## 10. Anti-Slop Content Discipline

* **No AI copywriting cliches:** "Elevate", "Seamless", "Unleash", "Next-Gen", "Game-changer", "Delve", "Revolutionize". Write plain, specific language.
* **No generic placeholders:** "John Doe", "Acme Corp", "Lorem Ipsum". Use realistic, contextual content.
* **No emojis** in code, markup, or UI text by default. Override only when the user explicitly asks for a playful/social-native vibe, and use sparingly even then.
* **One label per intent.** Two CTAs meaning the same thing is a failure.
* **Dependency verification is mandatory.** Before importing any third-party library, check it's actually installed/available.

### AI Tells (Forbidden Patterns)

**Visual & CSS:**
* NO neon / outer glows by default. Use inner borders or subtle tinted shadows.
* NO pure black (`#000000`). Off-black, zinc-950, or charcoal.
* NO oversaturated accents. Desaturate to blend with neutrals.
* NO excessive gradient text for large headers.
* NO custom mouse cursors. Outdated, accessibility-hostile, perf-hostile.

**Typography:**
* AVOID Inter as default.
* NO oversized H1s that just scream. Control hierarchy with weight + color, not raw scale.
* Serif for editorial / luxury / publication. Not for dashboards.

**Layout & Spacing:**
* Mathematically perfect padding and margins. No floating elements with awkward gaps.
* NO 3-column equal feature cards. Use 2-column zig-zag, asymmetric grid, scroll-pinned, or horizontal-scroll alternative.

**Content & Data ("Jane Doe" Effect):**
* NO generic names. "John Doe", "Sarah Chan" -> use creative, realistic, locale-appropriate names.
* NO generic avatars. No SVG "egg" or Lucide user icons.
* NO fake-perfect numbers. Avoid `99.99%`, `50%`. Use organic, messy data.
* NO startup-slop brand names. "Acme", "Nexus", "SmartFlow" -> invent contextual, premium names.
* NO filler verbs. Concrete verbs only.

**External Resources & Components:**
* NO hand-rolled SVG icons. Use Phosphor / HugeIcons / Radix / Tabler.
* NO div-based fake screenshots.
* NO broken Unsplash links. Use `picsum.photos/seed/...`.
* shadcn/ui: NEVER in default state. Customize radii, colors, shadows, typography.

**Production-Test Tells (banned outright):**
* NO version labels in the hero (`V0.6`, `BETA`, `ALPHA`) unless the brief is explicitly about a product launch.
* NO section-number eyebrows (`00 / INDEX`, `001 - Capabilities`).
* NO `01 / 4`-style pagination on images or bento tiles.
* NO "Index of Work, 2018 - 2026"-style range labels.
* The middle-dot (`-`) is rationed. Maximum 1 per line in metadata strips.
* NO decorative colored status dots on every list/nav/badge.
* NO em-dash (`---`) anywhere on the page. Use the regular hyphen (`-`). This rule is non-negotiable.
* NO `<br>`-broken-and-italicized headlines as a default "design move."
* NO vertical rotated text unless explicitly agency / Awwwards / experimental AND it serves a real composition purpose.
* NO crosshair / hairline grid lines as decoration.
* NO fake product UI in the hero (fake task list, fake terminal, fake dashboard built from styled divs).
* NO "Quietly in use at" / "Quietly trusted by" social-proof headers.
* NO "From the field" / "Field notes" / "Currently on the bench" style poetic labels.
* NO weather / locale strips ("LIS 14:23 - 18 C") unless brief is explicitly about a place.
* NO micro-meta-sentences under eyebrows.
* NO generic step labels ("Stage 1 / Stage 2", "Phase 01 / Phase 02").
* NO pills/labels overlaid on images.
* NO photo-credit captions as decoration.
* NO version footers on marketing pages.
* NO decoration text strip at hero bottom (`BRAND. MOTION. SPATIAL.`).
* NO floating top-right sub-text in section headings.
* NO scoring/progress bars with filled background tracks as comparison visuals.
* NO locale / city-name / time / weather strips unless brief is genuinely globally-distributed.
* NO scroll cues (`Scroll`, `scroll to explore`).
* NO `border-t` + `border-b` on every row of a long list / spec table.
* ZERO decorative status dots by default.

---

## 11. Dial Definitions (Technical Reference)

### DESIGN_VARIANCE (Level 1-10)

* **1-3 (Predictable):** Symmetrical CSS Grid (12-col, equal fr-units), equal paddings, centered alignment.
* **4-7 (Offset):** `margin-top: -2rem` overlaps, varied image aspect ratios (4:3 next to 16:9), left-aligned headers over center-aligned data.
* **8-10 (Asymmetric):** Masonry layouts, CSS Grid with fractional units (`grid-template-columns: 2fr 1fr 1fr`), massive empty zones (`padding-left: 20vw`).
* **MOBILE OVERRIDE:** For levels 4-10, asymmetric layouts above `md:` MUST collapse to strict single-column (`w-full`, `px-4`, `py-8`) on viewports `< 768px`.

### MOTION_INTENSITY (Level 1-10)

* **1-3 (Static):** No automatic animations. CSS `:hover` and `:active` states only. `prefers-reduced-motion` is the default mode anyway.
* **4-7 (Fluid CSS):** `transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1)`. `animation-delay` cascades for load-ins. Focus on `transform` and `opacity`.
* **8-10 (Advanced Choreography):** Complex scroll-triggered reveals, parallax, scroll-driven animation. Use Motion hooks. **NEVER use `window.addEventListener('scroll')`**.

### VISUAL_DENSITY (Level 1-10)

* **1-3 (Art Gallery):** Lots of white space. Huge section gaps (`py-32` to `py-48`). Expensive, clean.
* **4-7 (Daily App):** Standard web app spacing (`py-16` to `py-24`).
* **8-10 (Cockpit):** Tight paddings. No card boxes; 1px lines separate data. Mandatory: `font-mono` for all numbers.

---

## 12. Context-Aware Proactivity

These are tools, not defaults. Use them when the design read calls for them. **None of these fire automatically.**

* **Liquid Glass / Glassmorphism:** Appropriate for premium consumer, Apple-adjacent, luxury brand, or media-overlay vibes. Inappropriate for dashboards, public-sector, or "boring B2B." When used, go beyond `backdrop-blur`: add a 1px inner border (`border-white/10`) and a subtle inner shadow. Provide a solid-fill fallback under `prefers-reduced-transparency`.
* **Magnetic Micro-physics:** Use when `MOTION_INTENSITY > 5` AND the brief reads premium / playful / agency. Implement EXCLUSIVELY with Motion's `useMotionValue` / `useTransform` outside the React render cycle. Never `useState`.
* **Perpetual Micro-Interactions (Pulse, Typewriter, Float, Shimmer, Carousel):** Use when `MOTION_INTENSITY > 5` AND the section actively benefits from motion. **Not every card needs an infinite loop.** If a section is informational, leave it still.
* **"Motion claimed, motion shown."** If `MOTION_INTENSITY > 4`, the page must actually move: entry transitions on hero, scroll-reveal on key sections, hover physics on CTAs, at minimum.

### Forbidden Animation Patterns

* **`window.addEventListener("scroll", ...)`** is banned. Use Motion's `useScroll()`, GSAP's `ScrollTrigger`, `IntersectionObserver`, or CSS `scroll-driven animations`.
* **Custom scroll progress calculations using `window.scrollY`** in React state. Re-renders on every frame.
* **`requestAnimationFrame` loops that touch React state.** Use motion values (`useMotionValue` + `useTransform`) instead.
* **Use Motion's `layout` and `layoutId` props** for visible state changes. Do not wrap static content in `layout` props "for safety."

---

## 13. UI Library Selection

When a task needs a component rather than custom code, use these curated, taste-driven picks:

### UI Components & Primitives

| Task | Library |
|---|---|
| Unstyled, accessible UI components (dialogs, popovers, menus, selects...) | [base-ui](https://base-ui.com) |
| Command menus (cmd-K palettes) | [cmdk](https://cmdk.paco.me) |
| Toasts / notifications | [sonner](https://sonner.emilkowal.ski) |
| One-time password / verification code inputs | [input-otp](https://input-otp.rodz.dev) |
| Customizable GUIs / control panels | [Leva](https://github.com/pmndrs/leva) |

### Motion & Visuals

| Task | Library |
|---|---|
| General-purpose animation (springs, layout animations, enter/exit) | [motion](https://motion.dev) (Framer Motion) |
| Animating numbers (counters, prices, stats) | [NumberFlow](https://number-flow.barvian.me) |
| Animated text components | [torph](https://torph.lochie.me/) |
| 3D globes | [Cobe](https://cobe.vercel.app) |
| Dynamic OG images | [Satori](https://github.com/vercel/satori) |
| Syntax highlighting | [shiki](https://shiki.style) |

### Charts

| Task | Library |
|---|---|
| Real-time / streaming charts | [Liveline](https://github.com/benjitaylor/liveline) |
| General charts (static or interactive) | [recharts](https://recharts.org) |

### Interaction & Performance

| Task | Library |
|---|---|
| Drag and drop | [dnd kit](https://dndkit.com) |
| Virtualization (long lists, large tables) | [Virtuoso](https://virtuoso.dev) |

### State & Styling

| Task | Library |
|---|---|
| State management | [zustand](https://zustand.docs.pmnd.rs) |
| Constructing `className` strings conditionally | [clsx](https://github.com/lukeed/clsx) |
| Type-safe, variant-driven styling for Tailwind | [cva](https://cva.style) |
| Theme switching / dark mode (no flash on load) | [next-themes](https://github.com/pacocoursey/next-themes) |

**Common mismatches to catch:**
* Toasts built by hand or with a modal library -> sonner
* A `<div>`-based dropdown/dialog with manual focus handling -> base-ui
* Animating a number by re-rendering text -> NumberFlow
* Rendering a 1,000+ row list directly -> Virtuoso
* A `useState`-per-component web of props for shared state -> zustand
* Template-literal className ternaries three conditions deep -> clsx (or cva if variant-shaped)

---

## 14. Redesign Protocol

This skill handles **greenfield builds AND redesigns**. Misclassifying the mode is the single biggest source of bad redesign output.

### 14.A Detect the Mode (first action)

* **Greenfield** - no existing site, or full overhaul approved. Dial baseline from Section 1.
* **Redesign - Preserve** - modernise without breaking the brand. Audit first, extract brand tokens, evolve gradually.
* **Redesign - Overhaul** - new visual language on top of existing content. Treat as greenfield for visuals; preserve content and IA.

If ambiguous, ask **once**: *"Should this redesign preserve the existing brand, or are we starting visually from scratch?"*

### 14.B Audit Before Touching

Document the current state before proposing changes:

* **Brand tokens** - primary / accent colors, type stack, logo treatment, radii.
* **Information architecture** - page tree, primary nav, key conversion paths.
* **Content blocks** - what exists, what's doing work, what's filler.
* **Patterns to preserve** - signature interactions, recognisable hero, copy voice.
* **Patterns to retire** - AI-slop tells, broken layouts, dead links, generic stock imagery, perf traps.
* **Dial reading of the existing site** - infer current `DESIGN_VARIANCE` / `MOTION_INTENSITY` / `VISUAL_DENSITY`. That's your starting point, not the baseline.
* **SEO baseline** - current ranking pages, meta titles, structured data, OG cards. **SEO migration is the #1 redesign risk.**

### 14.C Preservation Rules

* **Do not change information architecture** unless asked. Keep page slugs, anchor IDs, primary nav labels stable.
* **Extract brand colors before applying Section 4.2.** A brand that is already purple stays purple.
* **Preserve copy voice** unless asked for a rewrite. Visual modernisation is not content rewrite.
* **Honor existing accessibility wins.** Do not regress focus states, alt text, keyboard nav, contrast.
* **Respect existing analytics events.** Do not rename buttons, form fields, section IDs that downstream tracking depends on.

### 14.D Modernisation Levers (priority order)

1. **Typography refresh** - biggest visual lift per unit of risk.
2. **Spacing & rhythm** - increase section padding, fix vertical rhythm.
3. **Color recalibration** - desaturate, unify neutrals, keep brand accent.
4. **Motion layer** - add `MOTION_INTENSITY`-appropriate micro-interactions.
5. **Hero & key-section recomposition** - restructure top-of-funnel.
6. **Full block replacement** - only when the existing block is unsalvageable.

### 14.E What Never Changes Silently

Never modify without explicit user approval: URL structure / route slugs, primary nav labels, form field names or order, brand logo or wordmark, existing legal / consent / cookie copy.

---

## 15. Progressive Enhancement

Every technique must degrade gracefully. The experience without the enhancement must still be good.

```css
@supports (animation-timeline: scroll()) {
  .hero { animation-timeline: scroll(); }
}
```

```javascript
if ('gpu' in navigator) { /* WebGPU */ }
else if (canvas.getContext('webgl2')) { /* WebGL2 fallback */ }
/* CSS-only fallback must still look good */
```

### Advanced Toolkit (use when the brief calls for it)

* **View Transitions API** - shared element morphing between states. List item expanding into a detail page. Button morphing into a dialog.
* **`@starting-style`** - animate elements from `display: none` to visible with CSS only.
* **Spring physics** - natural motion with mass, tension, and damping.
* **Scroll-driven animations** (`animation-timeline: scroll()`) - CSS-only, no JS. Parallax, progress bars, reveal sequences.
* **WebGL / WebGPU** - shader effects, post-processing, particle systems. Always fall back to WebGL2.
* **`@property`** - register custom CSS properties with types, enabling animation of gradients, colors, and complex values.
* **Web Animations API** - JavaScript-driven animations with CSS performance. Composable, cancellable, reversible.
* **Web Workers** - move computation off the main thread.
* **OffscreenCanvas** - render in a Worker thread. Main thread stays free.
* **WASM** - near-native performance for computation-heavy features.

### Polish is the difference

The gap between "cool" and "extraordinary" is in the last 20% of refinement: the easing curve on a spring animation, the timing offset in a staggered reveal, the subtle secondary motion that makes a transition feel physical. Don't ship the first version that works; ship the version that feels inevitable.

---

## 16. Debugging Animations

### Slow motion testing

Play animations at reduced speed to spot issues invisible at full speed. Temporarily increase duration to 2-5x normal, or use browser DevTools animation inspector to slow playback.

### Frame-by-frame inspection

Step through animations frame by frame in Chrome DevTools (Animations panel). This reveals timing issues between coordinated properties that you cannot see at full speed.

### Test on real devices

For touch interactions (drawers, swipe gestures), test on physical devices. Connect your phone via USB, visit your local dev server by IP address, and use Safari's remote devtools.

### Review your work the next day

Review animations with fresh eyes. You notice imperfections the next day that you missed during development. Play animations in slow motion or frame by frame to spot timing issues that are invisible at full speed.

---

## 17. Component Principles (Building Loved Components)

These principles apply to any component:

1. **Developer experience is key.** No hooks, no context, no complex setup. Insert `<Toaster />` once, call `toast()` from anywhere. The less friction to adopt, the more people will use it.
2. **Good defaults matter more than options.** Ship beautiful out of the box. Most users never customize. The default easing, timing, and visual design should be excellent.
3. **Naming creates identity.** A distinctive name feels more elegant than a generic descriptive one. Sacrifice discoverability for memorability when appropriate.
4. **Handle edge cases invisibly.** Pause toast timers when the tab is hidden. Fill gaps between stacked toasts with pseudo-elements to maintain hover state. Capture pointer events during drag. Users never notice these, and that is exactly right.
5. **Use transitions, not keyframes, for dynamic UI.** Toasts are added rapidly. Keyframes restart from zero on interruption. Transitions retarget smoothly.
6. **Build a great documentation site.** Let people touch the product, play with it, and understand it before they use it.

### Cohesion matters

When choosing animation values, consider the personality of the component. A playful component can be bouncier. A professional dashboard should be crisp and fast. Match the motion to the mood.

### Asymmetric enter/exit timing

Pressing should be slow when it needs to be deliberate (hold-to-delete: 2s linear), but release should always be snappy (200ms ease-out). This pattern applies broadly: slow where the user is deciding, fast where the system is responding.

```css
/* Release: fast */
.overlay { transition: clip-path 200ms ease-out; }

/* Press: slow and deliberate */
.button:active .overlay { transition: clip-path 2s linear; }
```

---

## 18. Apple Design Foundations (The Eight Principles)

The motion and craft above serve Apple's eight design principles. Use these as the names you reason with:

1. **Purpose.** Make with intention; decide what *not* to build. Every feature asks for the user's time, attention, and trust - spend that budget only where it pays off.
2. **Agency.** Keep people in control: offer choices, don't force a single path. Back it with forgiveness - easy undo for slips, a confirmation dialog only for genuinely destructive, irreversible actions.
3. **Responsibility.** Act in the user's interest. Privacy: ask at the right moment, only for what's needed, transparently. Safety: anticipate misuse and harm.
4. **Familiarity.** Build on what people already know. Use metaphors that are neither too literal nor too abstract, and honor their physics. Be consistent: things that look the same must behave the same.
5. **Flexibility.** Design for different contexts, devices, and the full range of abilities. Adapt to the platform and to the situation. Design inclusively.
6. **Simplicity - not minimalism.** Strip the unnecessary so the core purpose shines. Be concise and clear. Every element earns its place; sometimes *adding* context simplifies.
7. **Craft.** Uncompromising attention to detail builds trust. Beautiful typography, colors that adapt to light/dark, clear iconography, and responsive animations. Nothing is random - every spacing, timing, and alignment value is a deliberate choice you can defend.
8. **Delight.** The result of getting the other seven right, not confetti tacked on top. Decide the emotion you want people to feel and reinforce it in every decision.

### Tactical rules that serve these:

* **Feedback comes in four kinds:** status, completion, warning, error. Confirm meaningful actions, expose ongoing status, warn before problems, validate inline (not on submit).
* **Wayfinding.** Every screen should answer: Where am I? Where can I go? What's there? How do I get out? Never trap the user.
* **Grouping & mapping.** Proximity implies relationship; place a control near what it affects and arrange controls to mirror what they change. If you need a label to explain a control, the mapping is weak.
* **Direct, specific labels beat safe generic ones.** Name nav items for their contents ("Progress", "Library"), not vague umbrellas ("Home"). Specificity creates predictability.

### Quick Reference

| Need | Technique | Concrete value |
|---|---|---|
| Default UI spring | Critically damped, no overshoot | `damping 1.0`, `response 0.3-0.4` |
| Momentum / flick spring | Under-damped, slight bounce | `damping ~0.8`, `response 0.3-0.4` |
| Gesture -> spring velocity | Hand off release velocity | `gestureVelocity / (target - current)` if normalized |
| Flick landing point | Project momentum | `current + (v/1000) * d/(1-d)`, `d ~= 0.998` |
| Interrupt cleanly | Start from presentation (live) value | read the on-screen transform |
| Avoid reversal "brick wall" | Carry velocity through re-target | spring that blends velocity |
| Reversible transition | Mirror the easing curve | inverse cubic-bezier |
| Decide reverse vs. commit | Use velocity **sign**, not position | at release |
| 1:1 drag | Pointer Events + capture | respect the grab offset |
| Feedback | On pointer-down, continuous | never only at the end |
| Boundary | Rubber-band, don't hard-stop | progressive resistance |
| Translucent chrome | `backdrop-filter` layer | content scrolls under |
| Type tracking | Size-specific, never fixed | tighten large text (`-0.02em`), body near `0` |
| Reduced motion | Cross-fade, not slide/spring | `@media (prefers-reduced-motion)` |

---

## 19. Reference Vocabulary

This is a vocabulary, not a library. Know these pattern names to communicate about them, design with them in mind, and reach for them when the design read calls for them.

### Hero Paradigms
* **Asymmetric Split Hero** - Text on one side, asset on the other, generous white space.
* **Editorial Manifesto Hero** - Large type, no asset, almost-poster.
* **Video / Media Mask Hero** - Type cut out as mask over video background.
* **Kinetic-Type Hero** - Animated typography as the primary visual.
* **Curtain-Reveal Hero** - Hero parts on scroll like a curtain.
* **Scroll-Pinned Hero** - Hero stays pinned while content scrolls behind.

### Navigation & Menus
* **Mac OS Dock Magnification** - Edge nav, icons scale fluidly on hover.
* **Magnetic Button** - Pulls toward cursor.
* **Gooey Menu** - Sub-items detach like viscous liquid.
* **Dynamic Island** - Morphing pill for status / alerts.
* **Contextual Radial Menu** - Circular menu expanding at click point.
* **Floating Speed Dial** - FAB springing into curved secondary actions.
* **Mega Menu Reveal** - Full-screen dropdown, stagger-fade content.

### Layout & Grids
* **Bento Grid** - Asymmetric tile grouping (Apple Control Center).
* **Masonry Layout** - Staggered grid, no fixed row height.
* **Chroma Grid** - Borders / tiles with subtle animating gradients.
* **Split-Screen Scroll** - Two halves sliding in opposite directions.
* **Sticky-Stack Sections** - Sections that pin and stack on scroll.

### Cards & Containers
* **Parallax Tilt Card** - 3D tilt tracking mouse coordinates.
* **Spotlight Border Card** - Borders illuminate under cursor.
* **Glassmorphism Panel** - Frosted glass with inner refraction.
* **Holographic Foil Card** - Iridescent rainbow shift on hover.
* **Tinder Swipe Stack** - Physical card stack, swipe-away.
* **Morphing Modal** - Button expands into its own dialog.

### Scroll Animations
* **Sticky Scroll Stack** - Cards stick and physically stack.
* **Horizontal Scroll Hijack** - Vertical scroll -> horizontal pan.
* **Locomotive / Sequence Scroll** - Video / 3D sequence tied to scrollbar.
* **Zoom Parallax** - Central background image zooming on scroll.
* **Scroll Progress Path** - SVG line drawing along scroll.
* **Liquid Swipe Transition** - Page transition like viscous liquid.

### Galleries & Media
* **Dome Gallery** - 3D panoramic gallery.
* **Coverflow Carousel** - 3D carousel with angled edges.
* **Drag-to-Pan Grid** - Boundless draggable canvas.
* **Accordion Image Slider** - Narrow strips expanding on hover.
* **Hover Image Trail** - Mouse leaves popping image trail.
* **Glitch Effect Image** - RGB-channel shift on hover.

### Typography & Text
* **Kinetic Marquee** - Endless text bands reversing on scroll.
* **Text Mask Reveal** - Massive type as transparent window to video.
* **Text Scramble Effect** - Matrix-style decoding on load / hover.
* **Circular Text Path** - Text curving along spinning circle.
* **Gradient Stroke Animation** - Outlined text with running gradient.
* **Kinetic Typography Grid** - Letters dodging the cursor.

### Micro-Interactions & Effects
* **Particle Explosion Button** - CTA shatters into particles on success.
* **Liquid Pull-to-Refresh** - Reload indicator like detaching droplets.
* **Skeleton Shimmer** - Shifting light reflection across placeholders.
* **Directional Hover-Aware Button** - Fill enters from cursor's exact side.
* **Ripple Click Effect** - Wave from click coordinates.
* **Animated SVG Line Drawing** - Vectors drawing themselves in real time.
* **Mesh Gradient Background** - Organic lava-lamp blobs.
* **Lens Blur Depth** - Background UI blurred to focus foreground action.

### Animation Library Choice
* **Motion (`motion/react`)** - default for UI / Bento / state-change motion.
* **GSAP + ScrollTrigger** - for full-page scrolltelling and scroll hijacks. Isolate in dedicated leaf components with `useEffect` cleanup.
* **Three.js / WebGL** - for canvas backgrounds and 3D scenes. Same isolation rule.
* **NEVER mix GSAP / Three.js with Motion in the same component tree.** They fight over the same frames.

---

## 20. Out of Scope

This skill is NOT for:
* Dashboards / dense product UI / admin panels (use Fluent, Carbon, Atlassian, or Polaris from Section 2.A).
* Data tables (use TanStack Table or AG Grid).
* Multi-step forms / wizards (use Form-specific patterns).
* Code editors (use Monaco / CodeMirror with their official skinning).
* Native mobile (use Apple HIG / Material directly).
* Realtime collab UIs (presence, cursors, OT-aware - different problem class).

If the brief is one of the above, **say so explicitly**, point to the right tool, and only apply this skill's marketing-page / about-page / landing-page parts to the surfaces where they apply.

---

## 21. Final Pre-Flight Check

Run this matrix before outputting code. This is the last filter.

**THIS IS NOT OPTIONAL. Run every box. If any box fails, the output is not done.**

- [ ] **Brief inference** declared (Section 0.B one-liner)?
- [ ] **Dial values** explicit and reasoned from the brief, not silently using baseline?
- [ ] **Design system** chosen from Section 2 if applicable, or aesthetic labeled honestly?
- [ ] **Redesign mode** detected and audit performed (if applicable, Section 14)?
- [ ] **ZERO em-dashes (`---`) anywhere on the page.** Headlines, eyebrows, pills, body, quotes, attribution, captions, buttons, alt text. Zero.
- [ ] **Page Theme Lock**: ONE theme for the whole page. No section flips to inverted mode mid-page?
- [ ] **Color Consistency Lock**: one accent color used identically across all sections?
- [ ] **Shape Consistency Lock**: one corner-radius system applied consistently?
- [ ] **Button Contrast Check**: every CTA text is readable against its background (WCAG AA 4.5:1)?
- [ ] **CTA Button Wrap**: no CTA label wraps to 2+ lines at desktop?
- [ ] **Form Contrast Check**: form inputs, placeholders, focus rings, labels all pass WCAG AA?
- [ ] **Serif discipline**: if a serif is used, it is NOT Fraunces or Instrument_Serif?
- [ ] **Premium-consumer palette check**: if the brief is premium-consumer, the palette is NOT the AI-default beige+brass family?
- [ ] **Italic descender clearance**: every italic word with `y g j p q` has `leading-[1.1]` min + `pb-1` reserve?
- [ ] **Hero fits the viewport**: headline <= 2 lines, subtext <= 20 words AND <= 4 lines, CTA visible without scroll?
- [ ] **Hero top padding**: max `pt-24` at desktop?
- [ ] **Hero stack discipline**: max 4 text elements in hero?
- [ ] **EYEBROW COUNT (mechanical)**: count instances of `uppercase tracking` micro-labels. Count <= ceil(sectionCount / 3)?
- [ ] **Split-Header Ban**: no "left big headline + right small explainer paragraph" as a section header?
- [ ] **Zigzag Alternation Cap**: no 3+ consecutive sections with the same image+text-split layout?
- [ ] **No Duplicate CTA Intent**: no two CTAs with the same intent?
- [ ] **Logo wall = logo only**: no industry / category labels printed below logos?
- [ ] **Bento Background Diversity**: at least 2-3 bento cells have real visual variation?
- [ ] **"Used by / Trusted by" logo wall** lives UNDER the hero, uses REAL SVG logos, NOT plain text wordmarks?
- [ ] **Copy Self-Audit**: every visible string re-read, no grammatically-broken or AI-hallucinated phrases?
- [ ] **Motion motivated**: every animation can be justified in one sentence?
- [ ] **Marquee max-one-per-page**: no two horizontal marquees on the same page?
- [ ] **Navigation on ONE line** at desktop, height <= 80px?
- [ ] **Section-Layout-Repetition** check: no two sections share the same layout family (at least 4 different families across 8 sections)?
- [ ] **Bento has rhythm AND exact cell count** (N items -> N cells, no empty cells)?
- [ ] **Long lists use the right UI component** (not default `<ul>` with `divide-y` for > 5 items)?
- [ ] **Real images used** (gen-tool first, then Picsum-seed, then explicit placeholder slots) - NO div-based fake screenshots?
- [ ] **No pills/labels overlaid on images**?
- [ ] **No photo-credit captions as decoration**?
- [ ] **No version footers** on marketing pages?
- [ ] **No micro-meta-sentences** under eyebrows?
- [ ] **No decoration text strip at hero bottom**?
- [ ] **No floating top-right sub-text** in section headings?
- [ ] **No scoring/progress bars with filled background tracks** as comparison visuals?
- [ ] **No locale / city-name / time / weather strips** unless brief is genuinely globally-distributed?
- [ ] **No scroll cues**?
- [ ] **No version labels in hero** unless the brief is a launch?
- [ ] **No section-numbering eyebrows**?
- [ ] **No decorative dots** (zero by default, only for real semantic state)?
- [ ] **No `border-t` + `border-b` on every row** of long lists / spec tables?
- [ ] **Content density** sane: no 20-row data tables, no fake-precise specs without justification?
- [ ] **Quotes <= 3 lines** of body, attribution clean (no em-dash)?
- [ ] **Motion claimed = motion shown**: if `MOTION_INTENSITY > 4`, page actually animates?
- [ ] **No `window.addEventListener('scroll')`** - using Motion `useScroll()` / ScrollTrigger / IntersectionObserver / CSS scroll-driven animations only?
- [ ] **Reduced motion** wrapped for everything `MOTION_INTENSITY > 3`?
- [ ] **Dark mode** tokens defined and tested in both modes?
- [ ] **Mobile collapse** explicit (`w-full`, `px-4`, `max-w-7xl mx-auto`) for high-variance layouts?
- [ ] **Viewport stability**: `min-h-[100dvh]`, never `h-screen`?
- [ ] **`useEffect` animations** have strict cleanup functions?
- [ ] **Empty / loading / error** states provided?
- [ ] **Cards omitted** in favor of spacing where possible?
- [ ] **Icons** from an allowed library only, no hand-rolled SVG paths?
- [ ] **Motion** isolated in client-leaf components with `'use client'` at the top, memoized?
- [ ] **No AI Tells** from Section 10 (Inter as default, AI-purple, three-equal cards, Jane Doe, Acme, "Quietly in use at")?
- [ ] **Core Web Vitals** plausibly hit (LCP < 2.5s, INP < 200ms, CLS < 0.1)?
- [ ] **One design system** per project (no Material + shadcn mixed)?

If a single checkbox cannot be honestly ticked, the page is not done. Fix it before delivering.

---

## 22. Review Checklist

When reviewing UI code, check for:

| Issue | Fix |
|---|---|
| `transition: all` | Specify exact properties: `transition: transform 200ms ease-out` |
| `scale(0)` entry animation | Start from `scale(0.95)` with `opacity: 0` |
| `ease-in` on UI element | Switch to `ease-out` or custom curve |
| `transform-origin: center` on popover | Set to trigger location or use `var(--transform-origin)` (modals exempt) |
| Animation on keyboard action | Remove animation entirely |
| Duration > 300ms on UI element | Reduce to 150-250ms |
| Hover animation without media query | Add `@media (hover: hover) and (pointer: fine)` |
| Keyframes on rapidly-triggered element | Use CSS transitions for interruptibility |
| Framer Motion `x`/`y` props under load | Use `transform: "translateX()"` for hardware acceleration |
| Same enter/exit transition speed | Make exit faster than enter (e.g., enter 2s, exit 200ms) |
| Elements all appear at once | Add stagger delay (30-80ms between items) |

### Never Ship

| Never | Instead |
|---|---|
| `transition: all` | Name the exact properties |
| `transform: scale(0)` entrance | `scale(0.95)` + `opacity: 0` |
| `ease-in` on a UI element | `ease-out` or a strong custom curve |
| Built-in `ease-out` on a deliberate animation | `cubic-bezier(0.23, 1, 0.32, 1)` |
| Animation on a keyboard shortcut or 100+/day action | No animation |
| UI duration over 300ms with no reason | 150-250ms |
| `transform-origin: center` on a trigger-anchored popover | `var(--transform-origin)` (modals exempt) |
| Keyframes on toasts, toggles, rapidly-triggered elements | CSS transitions |
| Animating `width`/`height`/`margin`/`padding`/`top`/`left` | `transform` / `opacity` |
| Motion `x`/`y`/`scale` props under load | Full `transform` string |
| Ungated `:hover` motion | `@media (hover: hover) and (pointer: fine)` |
| Missing `prefers-reduced-motion` | Gentler variant, not zero |
| Everything entering at once | 30-80ms stagger |

---

## 23. Prototyping Variants

When exploring design directions, build several genuinely different versions behind a visual picker.

### Hard Rules

1. **Never touch production code during exploration.** Everything lives in an isolated prototype surface.
2. **Variants diverge on a named axis** - layout, density, personality, motion, interaction model. Before building, state each variant's axis in a phrase.
3. **Every variant fully works.** Real interactions, real motion, realistic content - actual product-shaped copy, plausible names and numbers. No lorem ipsum, no dead buttons.
4. **Clean up after the choice.** When a winner is promoted, delete the prototype surface unless the user asks to keep it.

### Workflow

1. **Scope** - One thing per run. Restate the brief in one sentence.
2. **Recon** - Map the stack, tokens, personality, and context the variants must stand on.
3. **Choose directions** - Default 3 variants; up to 5 when the design space is genuinely wide. Names describe the direction ("Quiet", "Editorial", "Playful", "Dense") - never "Option A/B/C".
4. **Build the picker harness** - An isolated route or self-contained HTML file. One variant at a time, full size, in realistic surrounding context.
5. **Verify and hand off** - Run the harness, confirm every variant renders, console is clean. Present the set and stop - the choice belongs to the user.
6. **Promote on selection** - Integrate the chosen variant following the project's existing conventions, then delete the prototype surface.

---

## 24. Default Site Packs

### 4-section pack
1. Hero
2. Features
3. Social proof / testimonial
4. CTA

### 8-section pack
1. Hero
2. Trust bar
3. Features
4. Product showcase
5. Benefits / use cases
6. Testimonials
7. Pricing
8. CTA

### 12-section pack
1. Hero
2. Trust bar
3. Feature grid
4. Product preview
5. Problem / solution
6. Benefits
7. Workflow
8. Metrics / proof / integration
9. Testimonials
10. Pricing
11. FAQ
12. CTA + footer