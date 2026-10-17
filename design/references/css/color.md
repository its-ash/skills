# Color

Read when choosing color spaces, building palettes and themes, implementing dark mode, mixing or deriving colors, or checking contrast.

## Rules
- Define palettes in `oklch()`. Lightness is perceptually even, so tone scales and hover states are predictable.
- Derive variants with relative color syntax or `color-mix()`. Do not hand-pick a hex value for every state.
- Name tokens by role (`--color-surface`, `--color-text`, `--color-accent`) and map roles to a scale (`--blue-500`).
- Set `color-scheme: light dark` on `:root` to get dark form controls and scrollbars and to enable `light-dark()`.
- Resolve the stored theme before first paint (inline script in `<head>` or server-side class) to avoid a flash of the wrong theme.
- Check text contrast: WCAG AA is 4.5:1 for body text and 3:1 for large text and UI parts.
- Use `display-p3` or high-chroma OKLCH only with an sRGB-safe fallback, or accept gamut mapping.

## Color spaces
- `oklch(L C H / A)`: L 0-1 or %, C about 0-0.37, H degrees. Best for palettes and scales.
- `oklab()`: best interpolation space for gradients and mixing (no hue drift through gray).
- `hsl()`: lightness is not perceptual (yellow at 50% looks much lighter than blue at 50%). Avoid it for accessible scales.
- `color(display-p3 r g b)`: wide-gamut colors. Detect with `@media (color-gamut: p3)`.
- Baseline since 2023 for `oklch`, `oklab`, `lab`, `lch`, `color()`.

## Relative color syntax
```css
:root { --brand: oklch(62% .19 256); }
.btn       { background: var(--brand); }
.btn:hover { background: oklch(from var(--brand) calc(l - .08) c h); }
.btn-soft  { background: oklch(from var(--brand) l c h / 15%); }
.btn-comp  { background: oklch(from var(--brand) l c calc(h + 180)); }
.on-brand  { color: oklch(from var(--brand) .98 .02 h); }
```
- Channel keywords match the target function: `r g b` for `rgb()`, `l c h` for `oklch()`, `alpha` for opacity.
- Baseline since 2024 (Firefox 128, Safari 18).

## `color-mix()`
```css
--accent-hover: color-mix(in oklab, var(--accent), black 15%);
--accent-tint:  color-mix(in oklch, var(--accent) 20%, white);
--overlay:      color-mix(in srgb, var(--accent) 40%, transparent);
```
- Percentages that are missing are filled in so the total is 100%. If they add to less than 100%, the result becomes transparent in proportion.
- Polar spaces take a hue method: `in oklch longer hue`.
- Baseline since 2023.

## Dark mode and theming
```css
:root {
  color-scheme: light dark;
  --surface: light-dark(oklch(99% 0 0), oklch(18% .01 260));
  --text:    light-dark(oklch(20% .02 260), oklch(93% .01 260));
}
:root[data-theme="light"] { color-scheme: light; }
:root[data-theme="dark"]  { color-scheme: dark; }
body { background: var(--surface); color: var(--text); }
```
- `light-dark()` follows the used `color-scheme`, so a `data-theme` attribute can force one mode. Baseline since 2024. It accepts only colors; image support (`light-dark(url(a), url(b))`) is new (Chrome 148, Firefox 150).
- Model: "system" by default, then a user override stored in `localStorage` or a cookie.
- System colors (`Canvas`, `CanvasText`, `LinkText`, `ButtonFace`, `AccentColor`) follow `color-scheme` and forced-colors mode.
- Dark palettes: do not just invert. Lower chroma, raise surface lightness slightly for elevation, and avoid pure `#000` behind pure `#fff` text.
- Tie browser chrome: `<meta name="theme-color" content="…" media="(prefers-color-scheme: dark)">`.
- Swap images: `<picture><source srcset="dark.png" media="(prefers-color-scheme: dark)"><img …></picture>`.
- SVG favicons can embed `@media (prefers-color-scheme: dark)` in a `<style>` block.

## Contrast helpers
- `contrast-color(var(--bg))` returns black or white, whichever contrasts more. Baseline (Firefox 146, Chrome 147, Safari 26). It does not guarantee WCAG for mid-tone backgrounds, so test.
- OKLCH fallback: `color: oklch(from var(--bg) clamp(0, (l - .62) * -infinity, 1) 0 0);` gives white on dark and black on light (threshold about 0.6-0.7 L).
- `prefers-contrast: more` → strengthen borders and text. `forced-colors: active` → use system colors and borders.

## Animating color
- Colors transition natively. A custom property holding a color needs `@property { syntax: "<color>"; }` to interpolate.
- Gradients cannot transition directly. Register stop colors or positions with `@property` and animate those.
- Interpolate gradients in OKLAB/OKLCH for cleaner midpoints: `linear-gradient(in oklch, blue, yellow)`.

## Color fonts
- COLRv1 fonts: choose a palette with `font-palette: dark;` or define one:
```css
@font-palette-values --brand { font-family: "Bungee Spice"; override-colors: 0 var(--accent), 1 white; }
h1 { font-palette: --brand; }
```

## Gotchas
- High-chroma OKLCH values can fall outside sRGB and get gamut-mapped. Check them on sRGB screens.
- `currentColor` resolves at use time, which is handy for icons and borders that follow text color.
- `opacity` fades the whole element including children. Use an alpha color for the background only.
- Transparent in gradients interpolates as transparent black in old engines. Modern browsers use premultiplied alpha, so `transparent` is safe.
- `color-mix()` with a percentage from a variable needs a valid `<percentage>`; a unitless number fails.
