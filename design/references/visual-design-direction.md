# Visual Design Direction

Create a unique, high‑quality visual identity for a web UI. Use this skill when a client rejects generic or templated designs and wants a distinct, premium look that reflects the product’s subject, audience, and brand personality.

---

## When to Use
- The brief explicitly asks for a “distinct visual identity”, “premium look”, “not generic”, or references award‑winning sites (Awwwards, FWA) or luxury brands.
- The project is a public‑facing website, landing page, portfolio, or marketing site (not an internal admin dashboard).
- You need guidance on typography, color, layout, motion, or 3D that avoids AI‑generated clichés.

---

## Workflow
1. **Clarify Subject & Audience**
   - Identify the product’s industry, primary user, and core purpose.
   - Write a one‑sentence summary and get client confirmation.
2. **Research Reference Sites**
   - Find at least **five** real‑world examples (mix of leaders and niche sites).
   - Record for each: primary font, secondary font, palette (hex), structural DNA (see catalog), and one signature interaction.
3. **Define Design Tokens**
   - **Palette**: 4‑6 named colors (e.g., `--color-primary`, `--color-bg`).
   - **Typography**: Choose a display font (serif or distinctive sans) and a neutral body font. Define scale with `clamp()`.
   - **Spacing**: Base unit (8 px) and exponential scale.
   - **Borders & Shadows**: Radius tokens and subtle shadow values.
4. **Select a Primary Structural Concept** (pick **one** from the catalog; it becomes the site’s DNA).
5. **Create a Compact Design Plan**
   - **Color**: list hex values.
   - **Type**: fonts and roles.
   - **Layout**: one‑sentence description + ASCII wireframe.
   - **Principles**: 3‑4 high‑level rules that make the design unique.
6. **Validate Against the Brief**
   - Ensure no element reads like a generic default (see blacklist).
   - Explain any revisions made to avoid clichés.
7. **Implement**
   - Apply tokens globally first (CSS variables, Tailwind config, theme object).
   - Style components (navbar, hero, cards) one at a time, preserving existing functionality.
8. **Self‑Critique & Iterate**
   - Take screenshots, compare to reference sites, and remove any non‑essential decoration.
   - Keep only **one** bold focal element; mute everything else.

---

## Design Principles
### Typography
- Use **one distinctive display font** for headlines (e.g., Playfair Display, Fraunces, Instrument Serif) and a **refined neutral body font** (e.g., Inter Tight, IBM Plex Sans).
- Set a fluid type scale with `clamp()`:
  ```css
  h1 { font-size: clamp(2.5rem, 8vw, 6rem); }
  p  { font-size: clamp(1rem, 1.2vw, 1.125rem); }
  ```
- Apply dramatic weight contrast (900 headline vs 300 body).
- Limit line length to **≤ 80 ch** (serif can be a few chars longer). Use `text-wrap: balance` on headings.
- Avoid: single‑word accent, all‑caps labels, uniform size hierarchy.

### Color
- Start from **black & white**; add color only when it serves meaning.
- Choose **one dominant hue** with a clear emotional purpose.
- Use off‑whites (`#FAFAF8`) and warm greys (`#F5F0EB`) for light themes; deep near‑black (`#0D0D0D`) for dark themes.
- Apply color sparingly – a single accent (e.g., red link) is more powerful than a rainbow palette.
- Avoid: purple‑blue gradients, SaaS starter‑kit gray‑white‑accent combos, neon on dark.

### Layout & Structural DNA
Pick **one** primary structure from the catalog and commit to it:
- **Index Manuscript** – single long column, editorial rhythm.
- **Sticky Horizontal Diorama** – vertical scroll with a horizontally‑panning scene.
- **Two‑Pane Permanent Split** – fixed pane + scrolling pane.
- **Slide Sequence** – full‑viewport slides with snap scrolling.
- **Staged Object on a Plinth** – central 3D/hero object, marginalia orbiting.
- **Pinned Narrative (Scrollytelling)** – pinned section with progressive states.
- **Horizontal Navigation**, **Sidebar + Column**, **Chapter Gates**, **Ledger / Registry**, **Collage / Grid‑Breaker**, **Single Object, No Chrome**, **Product UI Slate**, **Dashboard Tile Grid**, **Conversation Timeline**.

**Layout Rules**
- Break grids intentionally: mix full‑width sections with narrow text columns.
- Use generous whitespace (`≥ 8rem` between sections).
- Overlap elements (text over images, bleed images beyond containers).
- Keep max‑width for paragraphs at **45–75 ch**.
- Avoid symmetric grids, uniform cards, and centered‑only layouts.

### Motion
- Use **one orchestrated reveal** per page (e.g., hero animation on load).
- Animate only in response to user actions (expand, confirm) or to highlight a focal element.
- Keep duration **150‑300 ms**; use `ease-out` for subtlety.
- Avoid: scroll‑fade‑up on every section, identical hover scales, loading spinners when skeletons suffice.

### 3D & Premium Differentiators
- Include a **single, purposeful 3D scene** (e.g., from Spline) that directly represents the product.
- Do **not** build main visuals from primitive boxes or cylinders.
- Use 3D for atmosphere only (particle fields, subtle background) if the main hero is 2D.

---

## Blacklist of Common AI Clichés (Never Use)
- Warm cream background with terracotta accent.
- Near‑black background with acid‑green accent.
- SaaS‑card kit: identical rounded cards, soft grey shadow, gradient washes.
- All‑caps eyebrow labels above every heading.
- Uniform font families (Inter, Poppins, Montserrat) for everything.
- Predictable hero → three‑column grid → testimonial → CTA → footer.
- Rounded rectangles with box‑shadows as primary UI element.
- Generic blob or geometric background shapes.
- Purple‑to‑blue gradients, neon accents, opacity overlays.

---

## Restraint & Self‑Critique Checklist
- **Boldness**: Choose **one** element to be the visual hero; mute the rest.
- **Responsiveness**: Verify layout at 375 px, 768 px, 1024 px, 1440 px.
- **Accessibility**: Contrast ≥ 4.5:1, focus rings visible, `prefers-reduced-motion` respected.
- **Performance**: Optimize images (WebP, `srcset`), lazy‑load below‑the‑fold content.
- **Code Hygiene**: Avoid selector specificity wars; keep CSS modular.
- **Consistency**: Use the same token names across all files.
- **Iteration**: Capture screenshots after each major change; compare to reference sites.

---

## Quick Reference Checklist
- [ ] Subject & audience defined and approved.
- [ ] Five reference sites researched; notes recorded.
- [ ] Design tokens (colors, fonts, spacing, radius, shadow) documented.
- [ ] Primary structural concept selected and justified.
- [ ] Typography: distinct display + neutral body, fluid scale, line length ≤ 80 ch.
- [ ] Color palette: black/white base, one dominant hue, sparing accents.
- [ ] Layout: intentional grid breaks, generous whitespace, max‑width for text.
- [ ] Motion: single orchestrated reveal + action‑driven animations only.
- [ ] 3D: one purposeful scene, no primitive geometry.
- [ ] Blacklist items verified absent.
- [ ] Accessibility checks passed (contrast, focus, reduced‑motion).
- [ ] Responsive breakpoints tested.
- [ ] Final design reviewed against brief; any generic defaults replaced.

---

## Example Design Plan (Template)
```
Design Tokens
-------------
Colors:
  --color-bg:        #0A0A0F
  --color-surface:   #13131A
  --color-primary:   #7C3AED
  --color-primary‑hover: #6D28D9
  --color-muted:     #8888AA
  --color-text:      #FFFFFF

Typography:
  --font-display: 'Playfair Display', serif;
  --font-body:    'Inter Tight', sans-serif;
  --type-scale:   12/14/16/20/24/32/48px;
  --weight-display: 900;
  --weight-body:    300;

Spacing:
  --unit: 8px;
  --space-1: 4px;
  --space-2: 8px;
  --space-3: 16px;
  --space-4: 32px;
  --space-5: 64px;

Borders & Shadows:
  --radius-sm: 6px;
  --radius-md: 12px;
  --shadow: 0 4px 24px rgba(0,0,0,0.4);

Structural Concept: Sticky Horizontal Diorama – a vertically scrolling page where a horizontal scene pans in sync with scroll.

Layout Principle: Full‑width hero, then 60/40 split with text on left, image on right, followed by asymmetric sections that break the grid.

Principles:
  1. One bold focal scene (the diorama).
  2. Sparse color – only the primary hue on CTA and highlights.
  3. Fluid typography with dramatic headline weight.
  4. Motion limited to scroll‑driven scene and subtle hover feedback.
```

Replace the placeholders with values derived from your research and brief.

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
| Loading | Stable structure and progress; cancel where supported |
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
- Keep tokens in CSS variables so the direction stays the same across all states.
- Give grids, toolbars, tiles, counters, and fixed-format controls stable dimensions. They must not move when labels change or hover states show.
- Make sure long labels wrap or resize on mobile and desktop. They must not overflow.

### Product UI anti-patterns
- Cards inside cards.
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
- Fix failures, then do the affected checks again after structural changes.
- Report untested work and known limits. Do not make up evidence.

---

## Final Note
Treat every visual decision as a response to the brief, not as a default template. When in doubt, ask the client: *“Does this choice feel specific to your brand, or could it belong to any site?”* Only proceed when the answer is **specific**.
