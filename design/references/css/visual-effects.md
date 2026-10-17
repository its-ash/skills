# Visual Effects

Read when working with gradients, shadows, borders, outlines, corner shapes, filters, blend modes, masks, clip-path, shapes, backgrounds, or image fitting.

## Rules
- Prefer CSS effects over image assets: gradients, masks, `clip-path`, and `shape()` scale and theme freely.
- Use `box-shadow` for rectangular or rounded boxes. Use `filter: drop-shadow()` for shapes with transparency (PNG, SVG, clipped elements).
- Do not animate `box-shadow`, `filter: blur()`, or `backdrop-filter` on large areas. Fade a pseudo-element's `opacity` that holds the final shadow.
- Masks: opaque areas show, transparent areas hide. Luminance masks (`mask-mode: luminance`) use white to show and black to hide.
- `clip-path` also clips `box-shadow` and outlines. Put the shadow on a wrapper with `filter: drop-shadow()`.
- Use `isolation: isolate` on the parent to limit `mix-blend-mode` to a group.
- Register gradient stops and angles with `@property` to animate gradients.
- Reserve `backdrop-filter` for small surfaces (headers, popovers). Give it a semi-transparent background and an opaque fallback.

## Gradients
```css
background: linear-gradient(135deg, var(--a), var(--b));
background: linear-gradient(in oklch, oklch(70% .2 30), oklch(70% .2 250)); /* vivid midpoints */
background: radial-gradient(circle at 30% 20%, #fff3, transparent 60%);
background: conic-gradient(from 90deg at 50% 50%, red, yellow, lime, aqua, blue, magenta, red);
background: repeating-linear-gradient(45deg, #0000 0 10px, #0001 10px 20px);       /* stripes */
background: repeating-conic-gradient(#ccc 0 25%, #fff 0 50%) 0 0 / 2rem 2rem;      /* checkerboard */
```
- Hard stops: repeat a position (`red 50%, blue 50%`) or use `0` as the second stop (`red 50%, blue 0`).
- Two-position stops: `red 0 25%`.
- Gradients are images: they need `background-size`, `-position`, and `-repeat` per layer for patterns.
- Interpolate in `oklab`/`oklch` to avoid gray "dead zones".
- Gradient text:
```css
.gradient-text { background: linear-gradient(90deg, var(--a), var(--b)); background-clip: text; color: transparent; }
```

## Gradient borders
```css
/* 1. Two backgrounds (works with border-radius) */
.box {
  border: 3px solid transparent;
  background: linear-gradient(var(--surface) 0 0) padding-box,
              linear-gradient(135deg, var(--a), var(--b)) border-box;
}
/* 2. background-clip: border-area (Safari 18.2+, Chrome 150+) */
.box { border: 3px solid transparent; background: linear-gradient(135deg, var(--a), var(--b)) border-area; }
/* 3. Mask on a pseudo-element: transparent center */
.box { position: relative; }
.box::before {
  content: ""; position: absolute; inset: 0; padding: 3px; border-radius: inherit;
  background: linear-gradient(135deg, var(--a), var(--b));
  mask: linear-gradient(#000 0 0) content-box exclude, linear-gradient(#000 0 0);
  pointer-events: none;
}
```
- `border-image` with a gradient ignores `border-radius`.

## Shadows
- Layer shadows for realism: `box-shadow: 0 1px 2px #0002, 0 4px 8px #0002, 0 16px 32px #0002;`.
- Inner: `inset 0 2px 4px #0003`. Spread-only "outline": `0 0 0 3px var(--ring)`.
- Gradient or colored glow: blurred pseudo-element behind the element (`inset: 0; background: <gradient>; filter: blur(16px); z-index: -1`).
- Text: `text-shadow` for legibility on images, layered for 3D text. Use `-webkit-text-stroke` for outlined text.

## Borders, outlines, corners
- `outline` does not take space and follows `border-radius` in all modern browsers. Use it for focus rings.
- `box-decoration-break: clone` repeats padding, border, and radius on each line of wrapped inline elements.
- `corner-shape` (Chrome 139+) changes rounded corners: `round`, `squircle`, `bevel`, `scoop`, `notch`, `square`, `superellipse(n)`. It needs `border-radius` to set corner size. `superellipse(infinity)` equals `square`, and `superellipse(-infinity)` equals `notch`. Chrome only; the fallback is normal rounding.
- `border-shape` (Chrome 147) lets the border follow any `clip-path`-style shape while keeping shadow and outline. Experimental.

## Clip-path and shapes
```css
.hex { clip-path: polygon(25% 0, 75% 0, 100% 50%, 75% 100%, 25% 100%, 0 50%); }
.reveal { clip-path: inset(0 100% 0 0); transition: clip-path .5s; }
.reveal.in { clip-path: inset(0); }
.circle { clip-path: circle(40% at 50% 50%); }
.blob { clip-path: shape(from 0% 50%, curve to 100% 50% with 50% -20%, curve to 0% 50% with 50% 120%, close); }
```
- `polygon()` and `inset()` animate when the point count matches.
- `path()` uses pixels and does not scale. `shape()` takes `%` and other units and is responsive (Chrome 135+, Safari 18.4+, Firefox 148).
- `rect()` and `xywh()` are simpler inset forms.
- `shape-outside` wraps text around a float: `float: left; shape-outside: circle(50%); shape-margin: 1rem;`. It works only on floats. It accepts images (alpha channel) with `shape-image-threshold`. Chrome 149 adds `path()` and `shape()` support.

## Masks
```css
.fade-bottom { mask: linear-gradient(#000 70%, #0000); }
.scroll-fade { mask: linear-gradient(to right, #0000, #000 2rem calc(100% - 2rem), #0000); }
.icon-mask   { background: currentColor; mask: url(icon.svg) center / contain no-repeat; } /* recolorable icon */
.zigzag      { --s: 1rem; mask: conic-gradient(from -45deg at bottom, #0000, #000 1deg 89deg, #0000 90deg) 50% / var(--s) 100%; }
```
- `mask-composite`: `add`, `subtract`, `intersect`, `exclude`.
- Unprefixed `mask` is Baseline since late 2023. Keep `-webkit-mask` only for old Safari.
- Decorative edges (wavy, scalloped, torn) are repeated radial/conic gradients in `mask` or `clip-path: shape()`.

## Filters and blending
- `filter`: `blur()`, `brightness()`, `contrast()`, `grayscale()`, `hue-rotate()`, `invert()`, `saturate()`, `sepia()`, `opacity()`, `drop-shadow()`, `url(#svg-filter)`. Order matters.
- `backdrop-filter: blur(12px) saturate(1.5)` blurs what is behind the element. A parent with `backdrop-filter` becomes a containing block for fixed children.
- `mix-blend-mode`: `multiply` (darken, remove white), `screen` (lighten, remove black), `difference` (auto-contrast text over changing backgrounds), `overlay`, `color`, `luminosity`.
- `background-blend-mode` blends layers within one element: duotone = grayscale image + color layer + `multiply`/`screen`.
- Gooey effect: `filter: blur(10px) contrast(20)` on a container with a solid background, or an SVG `feGaussianBlur` + `feColorMatrix` filter.

## Backgrounds
- Multiple layers: comma-separated; the first layer is on top.
- `background-attachment: fixed` is ignored on iOS and repaints on scroll. Use a fixed pseudo-element or scroll-driven animation.
- `background-clip: text` for gradient text. `background-origin` / `background-clip` per layer.
- Put an image under a dark overlay: `background: linear-gradient(#0008, #0008), url(photo.jpg) center / cover;`.

## Images
- `object-fit: cover | contain`, `object-position: 50% 20%` for focal points in fixed-ratio boxes.
- `object-view-box: inset(10% 20%)` crops and zooms replaced elements like an SVG viewBox (Chromium only).
- `image-rendering: pixelated` for pixel art. `crisp-edges` is in Chrome 149.
- `aspect-ratio` + `object-fit: cover` gives uniform card thumbnails from mixed image sizes.

## Gotchas
- `clip-path` and `mask` create a stacking context and clip hit-testing to the visible area.
- `filter` (any value other than `none`) creates a containing block for fixed/absolute descendants.
- `background-clip: text` needs `color: transparent` and fails on text with `text-shadow` behind it.
- Gradients with `transparent` in old Safari interpolated through gray; use the same color at zero alpha when you target old engines.
- Sub-pixel gradient stops render differently across browsers. Do not rely on rendering bugs for noise textures; use SVG `feTurbulence`.
