# Visual Design Direction

Create a distinct, modern visual identity for a web UI. Use this sub-skill when a brief rejects generic templates and wants a refined, intentional look that reflects the product's subject, audience, and brand personality. All parent [`design`](../SKILL.md) rules (§0-§10) stay in force.

---

## When to Use
- The brief asks for a "distinct visual identity", "modern premium look", "not generic", or references award-winning sites (Awwwards, FWA) or craft-led products (Linear, Stripe, Vercel, Raycast).
- The project is a public-facing website, landing page, portfolio, marketing site, or a product UI that needs an opinionated visual direction.
- You need guidance on typography, color, layout, motion, or 3D that avoids dated patterns and AI-generated clichés.

---

## Workflow
1. **Clarify Subject & Audience**
   - Identify the product's industry, primary user, and core purpose.
   - Output the one-line design read (parent §0) and declare the three dials (parent §1).
2. **Research Reference Sites**
   - Study 3-5 real-world examples (mix of category leaders and niche craft sites).
   - Record for each: primary font, secondary font, palette (`oklch` / hex), structural DNA (see catalog), and one signature interaction.
3. **Define Modern Design Tokens**
   - **Palette (`oklch()` + `light-dark()`):** tonal surface elevation (`canvas`, `surface`, `surface-muted`, `surface-elevated`), hairline borders (`border-subtle`, `border-strong`), one neutral gray family, and one sharp accent (saturation < 80%). Never pure `#000` or `#fff`.
   - **Typography:** Choose a distinctive display/UI sans (Geist, Satoshi, Cabinet Grotesk, Plus Jakarta Sans, Outfit) + crisp mono (Geist Mono, JetBrains Mono), or an editorial serif (Newsreader, Source Serif 4) only when the brand truly justifies it. Define a fluid scale with `clamp()`.
   - **Spacing & Shape:** 8px base unit, one coherent radius scale with concentric nesting (`outer = inner + padding`), and subtle background-tinted layered shadows.
4. **Select a Primary Structural Concept** (pick **one** from the catalog; it becomes the site's DNA).
5. **Create a Compact Design Plan**
   - **Color:** `oklch()` + `light-dark()` semantic tokens.
   - **Type:** fonts and roles.
   - **Layout:** one-sentence description + ASCII wireframe.
   - **Principles:** 3-4 high-level rules that make the design specific.
6. **Validate Against the Brief & Blacklist**
   - Ensure no element reads like a dated or AI-default template (see blacklist).
   - Explain any revisions made to avoid clichés.
7. **Implement**
   - Apply tokens globally first (CSS custom properties or Tailwind v4 CSS-first `@theme`).
   - Style components (full-width square header, hero, filled segmented tabs, tonal cards without one-sided borders) one at a time, preserving existing functionality.
8. **Self-Critique & Iterate**
   - Inspect rendered views across breakpoints, compare to reference sites, and remove non-essential decoration.
   - Keep only **one** bold focal element per viewport; mute everything else.

---

## Design Principles

### Typography
- Use **one distinctive primary font** (e.g., Geist, Satoshi, Cabinet Grotesk, Plus Jakarta Sans, Outfit) paired with a crisp monospace (Geist Mono, JetBrains Mono) for metadata, code, and KPIs.
- Use serif (e.g., Newsreader, Source Serif 4) only when editorial or brand identity truly justifies it. **Never use banned serifs (Fraunces, Instrument Serif).**
- Set a fluid type scale with `clamp()` that includes `rem` so zoom works:
  ```css
  h1 { font-size: clamp(2.25rem, 1.5rem + 3.5vw, 4.5rem); text-wrap: balance; }
  p  { font-size: clamp(1rem, 0.95rem + 0.25vw, 1.125rem); text-wrap: pretty; }
  ```
- Apply clear weight and tracking contrast (tight display tracking `-0.03em`, relaxed body leading `1.5-1.6`).
- Limit line length to **45-75ch** (`max-inline-size: 65ch`). Use `tabular-nums` for changing numbers and `text-box: trim-both cap alphabetic` for optical button/badge centering.
- Avoid: all-caps eyebrow labels above every heading, uniform size hierarchy, faux bold/italic.

### Color
- Start from a **refined neutral surface hierarchy**; add color only when it communicates hierarchy, state, or action.
- Define all tokens in `oklch()` with `color-scheme: light dark` and `light-dark()`.
- Use soft off-whites (`oklch(98.5% 0.004 250)`) for light canvases and deep rich charcoal (`oklch(13.5% 0.01 250)`) for dark canvases — never pure `#fff` or `#000`.
- Choose **one dominant accent** (saturation < 80%) with clear emotional purpose; derive hover/soft/border states via `oklch(from ...)` or `color-mix()`.
- Avoid: default purple-to-blue gradients, neon on dark, SaaS starter-kit gray-white-accent combos.

### Layout & Structural DNA
Pick **one** primary structure from the catalog and commit to it:
- **Index Manuscript** - single long column, editorial rhythm.
- **Sticky Horizontal Diorama** - vertical scroll with a horizontally-panning scene.
- **Two-Pane Permanent Split** - fixed pane + scrolling pane.
- **Slide Sequence** - full-viewport slides with snap scrolling.
- **Staged Object on a Plinth** - central 3D/hero object, marginalia orbiting.
- **Pinned Narrative (Scrollytelling)** - pinned section with progressive states.
- **Bento Grid**, **Sidebar + Column**, **Chapter Gates**, **Ledger / Registry**, **Collage / Grid-Breaker**, **Single Object, No Chrome**, **Product UI Slate**, **Dashboard Tile Grid**, **Conversation Timeline**.

**Layout Rules**
- Break grids intentionally on marketing/editorial pages: mix full-width sections with narrow text columns.
- Use generous whitespace (`>= 6-8rem` between marketing sections; tighter 8pt rhythm in product UI).
- Keep paragraphs at **45-75ch**.
- Avoid symmetric 3-card feature rows, uniform card walls, and centered-only layouts when `VARIANCE > 4`.

### Motion
- Use **one orchestrated reveal** per page (e.g., hero animation on load).
- Animate only in response to user actions (expand, confirm, switch) or to highlight a focal element.
- Keep UI durations **150-250ms**; use `--ease-out` (`cubic-bezier(0.23, 1, 0.32, 1)`); exit faster than enter.
- Avoid: scroll-fade-up on every section, identical hover scales, `transition: all`, loading spinners when layout-shaped skeletons suffice.

### 3D & Premium Differentiators
- Include a **single, purposeful 3D scene** (Three.js / R3F / Spline) that directly represents the product.
- Do **not** build main visuals from primitive boxes or cylinders.
- Use 3D for atmosphere only if the main hero is 2D, and lazy-init with off-screen pause.

---

## Blacklist of Dated Patterns & AI Clichés (Never Use)
- **One-sided accent borders** (`border-l-4`, `border-t-4`) on cards, stat tiles, callouts, alerts, or selected items.
- **Underline-only or bare-text tabs** (always use filled rounded tabs inside a muted track).
- **Nested cards inside cards** (use inset muted surfaces or hairlines instead).
- Warm cream background with terracotta/brass/oxblood cliché, or near-black with acid-green neon.
- Purple-to-blue gradients, glowing orbs, neon accents, or gradient text headers.
- SaaS-card kit: identical rounded cards, heavy muddy grey box-shadows, gradient washes.
- All-caps eyebrow labels above every heading (`01 / FEATURES`).
- Uniform Inter/Poppins/Montserrat defaults for everything, or banned serifs (Fraunces, Instrument Serif).
- Predictable hero -> three-column grid -> testimonial -> CTA -> footer.
- Generic blob or geometric background shapes, div-based fake screenshots, decorative pulsing status dots.

---

## Restraint & Self-Critique Checklist
- **Boldness**: Choose **one** element to be the visual hero; mute the rest.
- **Modern craft**: Filled rounded tabs, tonal cards with full-perimeter 1px hairlines, zero one-sided borders, concentric radius.
- **Responsiveness**: Verify layout at 375px, 768px, 1024px, 1440px.
- **Accessibility**: WCAG 2.2 AA contrast >= 4.5:1, `:focus-visible` rings, `prefers-reduced-motion` cross-fade.
- **Performance**: AVIF first with WebP fallback, responsive `srcset`, `fetchpriority="high"` on LCP, lazy-load below the fold.
- **Code Hygiene**: Semantic tokens via `oklch()` + `light-dark()`, flat selectors, Tailwind v4 `@theme`.
- **Iteration**: Inspect rendered views after each major change; compare to reference sites.

---

## Example Design Plan (Modern Template)
```css
/* Design Tokens (oklch + light-dark, single accent, tonal surfaces) */
:root {
  color-scheme: light dark;
  --color-canvas:          light-dark(oklch(98.5% 0.004 245), oklch(13% 0.01 245));
  --color-surface:         light-dark(oklch(99.5% 0.002 245), oklch(17% 0.01 245));
  --color-surface-muted:   light-dark(oklch(95.5% 0.006 245), oklch(21% 0.012 245));
  --color-border-subtle:   light-dark(oklch(18% 0.015 245 / 0.09), oklch(94% 0.006 245 / 0.1));
  --color-text:            light-dark(oklch(18% 0.015 245), oklch(94% 0.006 245));
  --color-text-muted:      light-dark(oklch(46% 0.015 245), oklch(68% 0.01 245));
  --color-accent:          light-dark(oklch(55% 0.17 160), oklch(68% 0.15 160)); /* Emerald */
  --color-accent-soft:     color-mix(in oklch, var(--color-accent) 12%, transparent);

  --font-display:          "Satoshi", system-ui, sans-serif;
  --font-body:             "Geist", system-ui, sans-serif;
  --font-mono:             "JetBrains Mono", ui-monospace, monospace;

  --radius-control:        0.5rem;
  --radius-track:          0.75rem;
  --radius-card:           1rem;
  --shadow-card:           0 1px 2px oklch(15% 0.01 245 / 0.06), 0 8px 24px oklch(15% 0.01 245 / 0.04);
}
```
```text
Structural Concept: Two-Pane Permanent Split (fixed context rail + fluid content canvas).
Component Craft: Full-width square header, filled segmented tabs, tonal cards with 1px full-perimeter hairlines (zero one-sided borders), concentric radii.
Principles:
  1. One bold focal artifact per viewport.
  2. Neutral tonal hierarchy with one restrained emerald accent for primary actions.
  3. Fluid typography with tight display tracking and tabular numerals on metrics.
  4. Purposeful micro-transitions (< 250ms ease-out) and @starting-style entrances.
```

Replace the example values with tokens derived from your research and brief.

---

## Product UI Direction (apps, tools, dashboards)

Use this section when the surface is a product UI that people use repeatedly, not a marketing site. The parent `design` rules (§0-§10) stay in force.

### Set the direction before you code
1. **Purpose:** the job that the interface does.
2. **Audience:** who repeats this workflow, and what they must scan first.
3. **Tone:** one explicit word (utilitarian, editorial, industrial, technical, calm, dense, playful).
4. **Memorable detail:** one design idea that makes the result feel intentional.
5. **Constraints:** framework, accessibility, performance, responsiveness, existing design system.

Match the direction to the domain. An operations tool is usually dense, quiet, and scannable. Do not put a landing-page composition on a tool for daily use.

### Evidence contract
Before you build, record the product surface, the user job, the primary action, the hierarchy, the target viewports, and the reference observation behind each important choice. Make each constraint checkable. A palette alone is not evidence.

For each relevant content state, record the trigger, the visible feedback, and the safe next action:

| State | Check |
| --- | --- |
| Loading | Stable layout-shaped skeleton and progress; cancel where supported |
| Empty | Explain the missing data and give a useful next action |
| Error | Specific failure and a recovery path |
| Partial | Show the available data and mark the unavailable parts |
| Success | Confirm completion and show the next action or undo |
| Permission | Explain the access boundary and a safe request or return path |

If a state does not apply, record the reason. If you cannot test a state, report it as untested, not as "not applicable".

### Build from the contract
- Make the first screen the usable experience, unless the user asks for marketing copy.
- Use the project components, tokens, icon library, and routing patterns before you add a new visual system.
- Use real or generated assets when the interface depends on images, products, places, people, charts, or media.
- Use contextual type and spacing, not generic oversized hero text.
- Keep tokens in CSS variables (`oklch()` + `light-dark()`) so the direction stays consistent across all states and themes.
- Give grids, toolbars, tiles, counters, and fixed-format controls stable dimensions (`tabular-nums`). They must not jump when labels change or hover states show.
- Make sure long labels wrap or resize cleanly on mobile and desktop without overflowing.

### Product UI anti-patterns
- Cards inside cards.
- One-sided accent borders (`border-l-4`, `border-t-4`) on cards, alerts, or selected rows.
- Underline-only tabs instead of filled segmented tabs.
- The primary product, tool, or workflow hidden behind generic marketing sections.
- A new dependency only for a visual flourish.
- Text inside the UI that describes features when the controls can show them.
- Motion that hides slow responses.

### Rendered finish gate
Examine the rendered interface at each target viewport from the contract. Source inspection alone cannot pass this gate.
- Check keyboard navigation, visible focus, labels, contrast, reduced motion, and touch targets.
- Check narrow and wide layouts with long content.
- Exercise each applicable content state, including partial data.
- Keep screenshots or browser-test artifacts in the workspace and record what each one shows.
- Fix failures, then re-verify affected checks after structural changes.
- Report untested work and known limits. Do not make up evidence.

---

## Final Note
Treat every visual decision as a response to the brief, not as a default template. When in doubt, ask: *"Does this choice feel specific, modern, and purposeful for this product, or could it belong to any generic template?"* Only proceed when the answer is **specific**.
