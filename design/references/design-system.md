# Design System: Generate and Audit

Extract a modern design system from an existing codebase, generate one from scratch, or audit a UI for visual consistency and modern craft. §26 (token workflow, theming, components) is below; this file also has the generate, audit, and slop-check procedures. Parent § map: [`design`](../SKILL.md).

## When to use

- A new project needs a modern design system.
- You audit an existing codebase for visual consistency or dated UI patterns.
- Before a redesign, to record what exists (see parent §14).
- The UI looks "off", dated, or inconsistent and you want concrete fixes.
- You review a PR that changes styling.

## 26. Design Systems

**Workflow:** principles -> tokens (oklch palette 50-950, tonal surface elevation, modular fluid type, 8pt spacing, one radius scale with concentric nesting, background-tinted shadows, breakpoints) -> `light-dark()` theming -> atomic modern components -> WCAG 2.2 AA a11y -> docs -> semver.

* **Tokens:** one versioned source; UI uses semantic tokens (`color.semantic.surface.card`, `color.semantic.border.subtle`, `color.semantic.accent.primary`) that reference `oklch()` primitives. Never pure `#000` or `#fff`.
* **Surface elevation:** define 4 tonal layers (`canvas`, `surface`, `surface-muted`, `surface-elevated`) plus `border-subtle` and `border-strong`. In dark mode, step surface lightness up slightly rather than relying on heavy drop shadows.
* **Theming:** set `color-scheme: light dark` and give semantic tokens `light-dark()` values; use `data-theme="light|dark"` on `<html>` only for a manual override. Tailwind 4: `@theme` tokens with `light-dark()`, never `dark:` scattered on every class.
* **Modern components:** atoms -> molecules -> organisms -> templates -> pages; props `variant`/`size`/`disabled`/`loading`; composition (`<Card.Header>`) over boolean props; polymorphic `as` / `render`. Enforce parent §7 craft: full-width square header, filled rounded tabs in a muted track, zero one-sided borders on cards/callouts/selection, no nested cards, filled checkbox/radio/switch, soft tonal badges.
* **A11y (WCAG 2.2 AA):** keyboard reach, `:focus-visible` not obscured by sticky chrome, targets 24px minimum (44px touch), native `<dialog>` for modals, `[popover]` + anchor positioning for menus/tooltips, `aria-label` on icon buttons, `aria-expanded`, `role="alert"`; axe-core + manual tests; Storybook 10 a11y addon; Playwright accessibility snapshots.
* **Pitfalls:** hard-coded hex values, inconsistent props, missing focus rings, unchecked dark contrast, unversioned tokens, one-sided accent borders on cards, underline-only tabs, `dark:` class sprawl.

## Mode 1: Generate

1. Scan CSS, Tailwind `@theme` blocks, and component styles for existing patterns.
2. Extract colors, typography, spacing, border radius, shadows, and breakpoints. Count each value and its uses. Merge near-duplicates (for example `#1a1a1a` and `#1b1b1b`).
3. Optional: study 3 reference sites for direction (see [visual-design-direction.md](visual-design-direction.md)). Use a browser tool only when one is available and the user agrees.
4. Propose a modern token set:
   - **Primitives:** `oklch()` neutral scale (50-950), one accent scale (< 80% saturation), semantic status hues (success, warning, danger, info).
   - **Semantic surfaces:** `canvas`, `surface`, `surface-muted`, `surface-elevated`, `border-subtle`, `border-strong`, `text-primary`, `text-muted`, `accent`, `accent-soft` (all via `light-dark()`).
   - **Type, spacing & shape:** fluid `clamp()` type scale, 8pt spacing, one radius scale (`--radius-sm/md/lg`) with concentric nesting math, subtle background-tinted layered shadows.
5. Write `DESIGN.md` with the rationale for each decision.
6. Make a self-contained `design-preview.html` (no dependencies) that shows each token, light and dark theme toggle (`data-theme`), and core modern components (filled segmented tabs, tonal cards without one-sided borders, buttons, inputs, filled checkboxes/radios/switches, tonal badges, native `<dialog>`).

Output files:

| File | Content |
| --- | --- |
| `design-tokens.json` | Primitive + semantic tokens in DTCG 2025 format (`$value`, `$type`); Style Dictionary 4/5 builds platform outputs |
| `tokens.css` | The same tokens as CSS custom properties, themed with `color-scheme: light dark` and `light-dark()` |
| `DESIGN.md` | Decisions, rationale, usage rules |
| `design-preview.html` | Interactive preview of tokens and modern components in light and dark mode |

```json
{
  "color": {
    "primitive": {
      "slate": {
        "50": { "$type": "color", "$value": "oklch(98.5% 0.004 250)" },
        "950": { "$type": "color", "$value": "oklch(14% 0.01 250)" }
      }
    },
    "semantic": {
      "surface": {
        "canvas": { "$type": "color", "$value": "{color.primitive.slate.50}" }
      }
    }
  }
}
```

The generated system must obey all parent mandatory rules: one accent, one gray family, one radius scale, concentric radius, uniform card padding on all sides, zero one-sided borders, filled rounded tabs, AA contrast.

## Mode 2: Visual audit

Give each dimension a score from 0 to 10. For each score, give specific examples and a fix with the exact `file:line`.

| # | Dimension | Question |
| --- | --- | --- |
| 1 | Color consistency | Does the code use `oklch()` semantic tokens, or random hex values? |
| 2 | Typography hierarchy | Is there a clear h1 > h2 > h3 > body > caption with `text-wrap: balance`/`pretty` and `tabular-nums`? |
| 3 | Spacing rhythm | Is there a constant scale (4/8/16px), or arbitrary values? |
| 4 | Modern component craft | Filled rounded tabs, tonal cards (no one-sided borders, no nested cards), concentric radius, filled checkboxes/radios? |
| 5 | Responsive behavior | Is the layout fluid with `@container` queries, or does it break at breakpoints? |
| 6 | Dark mode | Is it handled via `light-dark()` semantic tokens with proper surface elevation, or incomplete `dark:` hacks? |
| 7 | Animation | Does each animation have a purpose (parent §5.B), use `transform`/`opacity`, and respect reduced motion? |
| 8 | Accessibility | WCAG 2.2 AA contrast, `:focus-visible`, 24px/44px touch targets, native `<dialog>`/`popover`? |
| 9 | Information density | Is it clean and scannable for its dial (parent §1)? |
| 10 | Polish | Hover/active press states, layout-shaped skeletons, composed empty/error states, optical alignment? |

Report format:

```
| Dimension | Score | Example | Fix (file:line) |
|---|---|---|---|
| Color consistency | 4 | 23 unique hex values, 9 grays | Map to tokens: src/Button.tsx:12, src/Card.tsx:40 |
| Modern component craft | 5 | `border-l-4` on stat cards; underline tabs | Use full hairline + tonal surface; switch to filled segmented tabs: src/Stats.tsx:18 |
```

Useful scans:

```bash
rg -o '#[0-9a-fA-F]{3,8}\b' src | sort | uniq -c | sort -rn     # raw hex values
rg -o 'border-[ltbr]-[248]\b' src | sort | uniq -c               # one-sided accent borders
rg -o 'rounded(-[a-z0-9]+)?' src | sort | uniq -c               # radius consistency
rg -o '\bdark:[a-z0-9-]+' src | sort | uniq -c | sort -rn       # dark: class sprawl
rg -o '\b(p|m|gap)[trblxy]?-\[?[0-9.]+(px|rem)?\]?' src | sort | uniq -c
```

## Mode 3: AI slop & dated UI check

Examine the UI against the parent anti-default list (§0) and anti-slop list (§10). Common findings:

- One-sided accent borders (`border-l-4`, `border-t-4`) on cards, callouts, or selected items (parent §7).
- Underline-only or bare-text tabs instead of filled rounded segmented tabs (parent §7).
- Nested cards inside cards instead of inset muted surfaces or hairlines (parent §4.4).
- Gradients on everything; purple-to-blue defaults; neon glows.
- Glassmorphism cards with no purpose or missing `prefers-reduced-transparency` fallback.
- Rounded/floating pill top header when a full-width square header is required (parent §7).
- `dark:` utility sprawl instead of `light-dark()` semantic tokens.
- Too many scroll animations; `transition: all`; generic centered hero over a stock gradient.
- A default Inter/Roboto stack with no personality or typographic hierarchy.

Report each finding with `file:line` and the parent rule that it breaks.

## Related skills

- [`design`](../SKILL.md) - parent rules and § map.
- [`brand-theming`](brand-theming.md) - apply a fixed brand palette and fonts.
- [`make-interfaces-feel-better`](make-interfaces-feel-better.md) - polish details after the audit.
