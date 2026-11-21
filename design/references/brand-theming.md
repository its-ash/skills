> **Parent skill:** [`design`](../SKILL.md). This is a sub-skill; follow `design` for the shared workflow and load this only when the task needs it.

# Brand Theming

Apply a brand's official visual identity consistently across web UI, HTML pages, slide decks, and documents. Translates brand guidelines into modern `oklch()` + `light-dark()` semantic tokens while enforcing WCAG 2.2 AA contrast and clean component craft.

## When to Use
- An existing brand style guide must be applied consistently across web apps, landing pages, PDFs, or slide decks.
- You need to map brand colors and fonts into modern semantic CSS tokens without breaking light/dark mode or accessibility.
- You want a repeatable token dictionary shared between web code and presentation/document generators.

## Workflow
1. **Audit brand inputs:** Collect the brand's primary accent, neutral base, typography (display, body, mono), logo rules, and corner-radius personality.
2. **Convert to semantic tokens:** Convert raw brand hex values into `oklch()` primitives and map them to semantic roles (`canvas`, `surface`, `surface-muted`, `border-subtle`, `foreground`, `muted-foreground`, `accent`, `accent-soft`). Never hard-code raw hex inside components.
3. **Adapt for light & dark mode:** Use `color-scheme: light dark` and `light-dark()`. In dark mode, lift surface lightness slightly for elevation and slightly reduce accent chroma so text and buttons stay comfortable and legible.
4. **Apply typography:** Load brand variable fonts via `next/font` or self-hosted WOFF2 with metric-matched fallbacks (`size-adjust`). Keep body line-height `1.5-1.6` (web) or `1.2-1.35` (decks).
5. **Validate contrast (WCAG 2.2 AA):** Verify >= 4.5:1 for normal text and >= 3:1 for large text and UI controls in both light and dark modes. Adjust lightness in `oklch()` if a brand color fails contrast on text.
6. **Preserve modern UI craft:** Follow parent [`design`](../SKILL.md) §7 rules even under brand theming (full-width square header, filled rounded tabs, tonal cards with full-perimeter hairlines and zero one-sided borders, filled checkboxes/radios).

## Web Implementation Pattern (`oklch()` + `light-dark()`)

```css
:root {
  color-scheme: light dark;

  /* Brand primitives (example: warm editorial brand) */
  --brand-ink: oklch(18% 0.008 85);
  --brand-paper: oklch(98% 0.008 85);
  --brand-accent-light: oklch(62% 0.14 38);
  --brand-accent-dark: oklch(72% 0.13 38);

  /* Semantic tokens consumed by UI */
  --color-canvas: light-dark(var(--brand-paper), oklch(14% 0.008 85));
  --color-surface: light-dark(oklch(99.3% 0.004 85), oklch(18% 0.008 85));
  --color-surface-muted: light-dark(oklch(94% 0.01 85), oklch(22% 0.01 85));
  --color-foreground: light-dark(var(--brand-ink), oklch(94% 0.006 85));
  --color-muted-foreground: light-dark(oklch(45% 0.01 85), oklch(68% 0.01 85));
  --color-border-subtle: light-dark(oklch(18% 0.008 85 / 0.1), oklch(94% 0.006 85 / 0.12));
  --color-accent: light-dark(var(--brand-accent-light), var(--brand-accent-dark));
  --color-accent-soft: color-mix(in oklch, var(--color-accent) 12%, transparent);
}
```

## Slide Decks & Documents (`python-pptx`)

When styling decks or PDFs from the same brand token dictionary, keep a single source of truth for palette and font roles:

```python
from pptx import Presentation
from pptx.dml.color import RGBColor

BRAND = {
    "dark": RGBColor(0x14, 0x14, 0x13),
    "light": RGBColor(0xFA, 0xF9, 0xF5),
    "muted": RGBColor(0x6E, 0x6C, 0x65),
    "accent": RGBColor(0xD9, 0x77, 0x57),
}

prs = Presentation("input.pptx")
for slide in prs.slides:
    for shape in slide.shapes:
        if shape.has_text_frame:
            for paragraph in shape.text_frame.paragraphs:
                size = paragraph.font.size.pt if paragraph.font.size else 14
                paragraph.font.name = "Brand Display" if size >= 24 else "Brand Body"
                paragraph.font.color.rgb = BRAND["dark"]
prs.save("output.pptx")
```

## Rules & Pitfalls
- **Restraint with brand accents:** Keep accent fills to <= 20-30% of visual area; neutral tonal surfaces carry the layout. Never combine two saturated accents on the same element.
- **No pure `#000` / `#fff`:** Even on monochrome brands, use soft off-white and deep charcoal for lower glare.
- **Missing fonts:** Always specify metric-matched fallbacks on web and verify system font availability before exporting PPTX/PDF.
- **Brand vs. readability:** If an official brand accent fails 4.5:1 contrast for text, keep the exact brand color for logos/large graphics and use an `oklch()` lightness-adjusted token for body/button text.

## Checklist
- [ ] Brand palette converted to `oklch()` + `light-dark()` semantic tokens.
- [ ] Single brand accent locked; neutral tonal surface hierarchy defined.
- [ ] Fonts loaded with fallbacks and clear heading/body hierarchy.
- [ ] WCAG 2.2 AA contrast verified (>= 4.5:1 text, >= 3:1 UI) in both light and dark modes.
- [ ] Parent `design` modern component rules respected (filled tabs, zero one-sided card borders, full-width square header).

## Related skills

- [`design`](../SKILL.md) - Unified parent design skill covering brief inference, modern UI craft, and pre-flight checks.
- [`design-system`](design-system.md) - Generate full DTCG tokens and interactive previews.
