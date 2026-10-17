# Typography

Read when setting fonts, font loading, type scales, line length, wrapping, decoration, text trimming, or long-form reading styles.

## Rules
- Set body `font-size` in `rem` (keep the browser default 16px as 1rem). Never set `html { font-size: 62.5% }` and then fight it everywhere.
- Use unitless `line-height` (1.4-1.6 for body, 1.1-1.25 for headings) so it scales with font size.
- Limit line length to about 45-75 characters: `max-inline-size: 65ch`.
- Use a fluid type scale with `clamp()` that includes `rem` in the middle value so zoom works.
- Use `text-wrap: balance` on headings and short blocks; use `text-wrap: pretty` on paragraphs to avoid orphans.
- Self-host WOFF2, subset it, preload only the one or two critical files, and set `font-display`.
- Use variable fonts when you need 3 or more weights/styles from one family.
- Use system font stacks when brand fonts are not required. They cost zero bytes.
- Set fallback metric overrides (`size-adjust`, `ascent-override`) to reduce layout shift when the web font swaps in.

## Font stacks
```css
--font-sans: system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
--font-serif: ui-serif, Georgia, Cambria, "Times New Roman", serif;
--font-mono: ui-monospace, "SF Mono", Menlo, Consolas, "Liberation Mono", monospace;
```

## `@font-face` and loading
```css
@font-face {
  font-family: "Inter";
  src: url("/fonts/inter-var.woff2") format("woff2-variations"), url("/fonts/inter-var.woff2") format("woff2");
  font-weight: 100 900;          /* range for variable fonts */
  font-style: normal;
  font-display: swap;
  unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+2000-206F;
}
@font-face {                      /* metric-matched fallback */
  font-family: "Inter Fallback";
  src: local("Arial");
  size-adjust: 107%; ascent-override: 90%; descent-override: 22%; line-gap-override: 0%;
}
body { font-family: "Inter", "Inter Fallback", var(--font-sans); }
```
```html
<link rel="preload" href="/fonts/inter-var.woff2" as="font" type="font/woff2" crossorigin>
```
- `font-display: swap` shows fallback text at once and swaps later (FOUT). `optional` uses the font only if it is ready almost at once, which gives no layout shift. Use it for non-critical fonts and repeat visits.
- `crossorigin` is required on font preloads, even for same-origin files.
- `unicode-range` splits a family into subsets that download only when glyphs are used.
- Third-party font CDNs add a connection and privacy cost. Self-host when you can.

## Variable fonts
```css
h1 { font-weight: 750; font-stretch: 85%; font-optical-sizing: auto; }
.fancy { font-variation-settings: "wght" 600, "SOFT" 100, "CASL" 1; }
```
- Use standard properties for registered axes: `wght` → `font-weight`, `wdth` → `font-stretch`, `slnt`/`ital` → `font-style`, `opsz` → `font-optical-sizing`.
- `font-variation-settings` is not inherited per axis: setting it on a child replaces all axes. Drive axes with custom properties: `font-variation-settings: "wght" var(--wght, 400), "GRAD" var(--grad, 0);`.
- Animate axes for hover effects and use `prefers-reduced-motion` to disable them.

## Fluid type scale
```css
:root {
  --step--1: clamp(.83rem, .8rem + .15vi, .9rem);
  --step-0:  clamp(1rem, .95rem + .25vi, 1.125rem);
  --step-1:  clamp(1.2rem, 1.1rem + .5vi, 1.5rem);
  --step-2:  clamp(1.44rem, 1.25rem + .9vi, 2rem);
  --step-3:  clamp(1.73rem, 1.4rem + 1.6vi, 2.75rem);
}
```
- Generate scales with tools like Utopia instead of tuning by hand.
- For component-relative type, use `cqi` inside a container: `font-size: clamp(1rem, 5cqi, 2rem)`.

## Wrapping and breaking
- `text-wrap: balance` evens line lengths. Browsers limit it to a few lines (Chrome ≤ 6, Firefox ≤ 10), so use it only for headings. Baseline 2024.
- `text-wrap: pretty` avoids single-word last lines. Chrome 117+, Safari 26 (Safari also improves rag and hyphenation). Safe as enhancement.
- `overflow-wrap: anywhere` (or `break-word`) stops long URLs from overflowing. `anywhere` also affects min-content size.
- `hyphens: auto` needs a correct `lang` attribute on the element or an ancestor. Tune with `hyphenate-limit-chars: 6 3 2` (support varies).
- `white-space: nowrap` + `overflow: hidden` + `text-overflow: ellipsis` truncates one line.
- Multi-line clamp: `display: -webkit-box; -webkit-box-orient: vertical; -webkit-line-clamp: 3; overflow: hidden;`. The standard `line-clamp` is coming.

## Spacing and the `lh` unit
- `lh` / `rlh` units equal the computed line-height. Use them for vertical rhythm: `margin-block: 1lh`.
- Space paragraphs with `p + p { margin-block-start: 1em; }` or flow layout with `gap`.
- `letter-spacing`: tighten large headings slightly (`-0.02em`), loosen all-caps labels (`0.05em`). Chrome 145 supports percentage values for `letter-spacing` and `word-spacing`.

## Text box trim
```css
.btn, .badge, h1 { text-box: trim-both cap alphabetic; }
```
- Removes the extra leading above cap height and below the baseline for true optical centering in buttons and tight layouts.
- Longhands: `text-box-trim` (`trim-start`, `trim-end`, `trim-both`) and `text-box-edge` (`cap`, `ex`, `text`, `alphabetic`).
- Chrome 133+, Safari 18.2+, Firefox 154 (now Baseline).

## Decoration
```css
a {
  text-decoration-line: underline;
  text-decoration-thickness: max(1px, .08em);
  text-underline-offset: .2em;
  text-decoration-skip-ink: auto;
  text-decoration-color: color-mix(in oklch, currentColor 50%, transparent);
}
a:hover { text-decoration-thickness: .15em; }
```
- Thickness snaps to device pixels. Chrome can round non-integer values down, so use `max(1px, …)`.
- Animate underlines with `background-size` on a gradient (`background: linear-gradient(currentColor 0 0) 0 100% / 0 2px no-repeat`) for multi-line support.

## Drop caps and features
- `initial-letter: 3` (Chrome 110+, Safari) gives a true drop cap aligned to lines. Fall back to `::first-letter { float: left; font-size: 3.2em; line-height: 1; }`.
- `font-variant-numeric: tabular-nums` for tables, timers, and prices that change. `oldstyle-nums` for body text.
- `font-variant-caps: all-small-caps` for abbreviations. `font-kerning: normal` is the default.
- Use `font-feature-settings: "ss01"` only for features without a high-level property. Named sets need `@font-feature-values` + `font-variant-alternates: styleset(name)`.
- `font-size-adjust: ex-height 0.5` (or `from-font`) keeps the x-height steady across fallbacks.

## Long-form reading
- Body 18-21px on desktop, line-height about 1.5-1.7, measure 60-70ch, generous paragraph spacing.
- Increase heading margins above more than below so headings group with their content.
- Style `blockquote`, `figure`/`figcaption`, `code`, `pre`, `kbd`, `mark`, and footnotes consistently.
- Make `pre` scroll: `overflow-x: auto; tab-size: 2;`. Keep code font size at about 0.9em.

## Experimental
- `text-fit` (Chrome 150) scales text to fit its line. `text-grow` is a Chrome prototype. Do not depend on either; use `cqi` units instead.
- `text-autospace` adds spacing between CJK and Latin text (Chrome, Safari).

## Gotchas
- `font-size` in `vw` only breaks zoom (WCAG 1.4.4). Always add `rem`.
- Faux bold and italic appear when the weight or style is not loaded. Load the real files or set `font-synthesis: none`.
- `text-transform: uppercase` changes how some screen readers read text. Prefer real case in the HTML for acronyms.
- Mobile Safari inflates text in landscape; set `-webkit-text-size-adjust: 100%` (and `text-size-adjust: 100%`).
- Icon fonts fail when fonts are blocked and confuse screen readers. Use inline SVG.
