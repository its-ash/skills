# Design System: Generate and Audit

Extract a design system from an existing codebase, or audit a UI for visual consistency. §26 (token workflow, theming, components) is below; this file also has the generate, audit, and slop-check procedures. Parent § map: [`design`](../SKILL.md).

## When to use

- A new project needs a design system.
- You audit an existing codebase for visual consistency.
- Before a redesign, to record what exists (see parent §14).
- The UI looks "off" and you cannot find the cause.
- You review a PR that changes styling.

## 26. Design Systems

**Workflow:** principles -> tokens (palette 50-950, modular type, 8pt spacing, radius, shadows, breakpoints) -> theming -> atomic components -> a11y -> docs -> semver.

* **Tokens:** one versioned source; UI uses semantic tokens (`color.semantic.brand.primary`) that reference primitives.
* **Theming:** set `color-scheme: light dark` and give semantic tokens `light-dark()` values; use `data-theme` on `<html>` only for a manual override. Tailwind 4: `@theme` tokens, not `dark:` on each class.
* **Components:** atoms -> molecules -> organisms -> templates -> pages; props `variant`/`size`/`disabled`/`loading`; composition (`<Card.Header>`) over boolean props; polymorphic `as`.
* **A11y (WCAG 2.2 AA):** keyboard reach, `:focus-visible` not obscured, targets 24px minimum, native `<dialog>` for modals, `aria-label` on icon buttons, `aria-expanded`, `role="alert"`; axe-core + manual tests; Storybook 10 a11y addon; Playwright accessibility snapshots.
* **Pitfalls:** hard-coded values, inconsistent props, missing focus, unchecked dark contrast, unversioned tokens.

## Mode 1: Generate

1. Scan CSS, Tailwind `@theme` blocks, and CSS-in-JS for existing patterns.
2. Extract colors, typography, spacing, border radius, shadows, and breakpoints. Count each value and its uses. Merge near-duplicates (for example `#1a1a1a` and `#1b1b1b`).
3. Optional: study 3 reference sites for direction (see [visual-design-direction.md](visual-design-direction.md)). Use a browser tool only when one is available and the user agrees.
4. Propose a token set: primitives (palette 50-950, type scale, 8pt spacing, one radius scale, shadows) and semantic tokens that reference the primitives.
5. Write `DESIGN.md` with the rationale for each decision.
6. Make a self-contained `design-preview.html` (no dependencies) that shows each token, light and dark theme, and the core components.

Output files:

| File | Content |
| --- | --- |
| `design-tokens.json` | Primitive + semantic tokens in DTCG 2025 format (`$value`, `$type`); Style Dictionary 4/5 builds platform outputs |
| `tokens.css` | The same tokens as CSS custom properties, themed with `data-theme` or `light-dark()` |
| `DESIGN.md` | Decisions, rationale, usage rules |
| `design-preview.html` | Interactive preview of tokens and components |

```json
{
  "color": {
    "primitive": { "slate": { "50": { "$type": "color", "$value": "oklch(98% 0.01 250)" } } },
    "semantic": { "surface": { "default": { "$value": "{color.primitive.slate.50}" } } }
  }
}
```

The generated system must obey the parent mandatory rules: one accent, one gray family, one radius scale, card padding on all sides, AA contrast.

## Mode 2: Visual audit

Give each dimension a score from 0 to 10. For each score, give specific examples and a fix with the exact `file:line`.

| # | Dimension | Question |
| --- | --- | --- |
| 1 | Color consistency | Does the code use the palette, or random hex values? |
| 2 | Typography hierarchy | Is there a clear h1 > h2 > h3 > body > caption? |
| 3 | Spacing rhythm | Is there a constant scale (4/8/16px), or arbitrary values? |
| 4 | Component consistency | Do similar elements look similar? |
| 5 | Responsive behavior | Is the layout fluid, or does it break at breakpoints? |
| 6 | Dark mode | Is it complete, or only partly done? |
| 7 | Animation | Does each animation have a purpose (parent §5.B)? |
| 8 | Accessibility | Contrast ratios, focus states, touch targets |
| 9 | Information density | Is it cluttered or clean for its dial (parent §1)? |
| 10 | Polish | Hover states, transitions, loading states, empty states |

Report format:

```
| Dimension | Score | Example | Fix (file:line) |
|---|---|---|---|
| Color consistency | 4 | 23 unique hex values, 9 grays | Map to tokens: src/Button.tsx:12, src/Card.tsx:40 |
```

Useful scans:

```bash
rg -o '#[0-9a-fA-F]{3,8}\b' src | sort | uniq -c | sort -rn   # hex values
rg -o 'rounded(-[a-z0-9]+)?' src | sort | uniq -c              # radius usage
rg -o '\b(p|m|gap)[trblxy]?-\[?[0-9.]+(px|rem)?\]?' src | sort | uniq -c
```

## Mode 3: AI slop check

Examine the UI against the parent anti-default list (§0) and anti-slop list (§10). Common findings:

- Gradients on everything; purple-to-blue defaults.
- Glassmorphism cards with no purpose.
- Rounded corners on elements that must be square (the header must be square, parent §7).
- Too many scroll animations.
- Generic centered hero over a stock gradient.
- A default sans-serif stack with no personality.

Report each finding with `file:line` and the parent rule that it breaks.

## Related skills

- [`design`](../SKILL.md) - parent rules and § map.
- [`brand-theming`](brand-theming.md) - apply a fixed brand palette and fonts.
- [`make-interfaces-feel-better`](make-interfaces-feel-better.md) - polish details after the audit.
