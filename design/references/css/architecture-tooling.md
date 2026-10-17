# Architecture and Tooling

Read when organizing CSS at scale: methodologies, design tokens, design systems, utility CSS / Tailwind, Sass, PostCSS / Lightning CSS, CSS-in-JS, CSS Modules, linting, and build setup.

## Rules
- Pick one primary approach per codebase (utility-first, component CSS with BEM/Modules, or CSS-in-JS) and document it. Mixing styles without rules causes specificity wars.
- Control the cascade with `@layer` (reset → base → components → utilities). Keep specificity flat (single class) inside layers.
- Store design decisions as tokens in custom properties. Use primitive tokens (`--blue-600`), semantic tokens (`--color-action`), and component tokens (`--btn-bg`). Components consume semantic or component tokens only.
- Prefer native CSS over preprocessor features when targets allow: custom properties, nesting, `color-mix()`, `@layer`, `@scope`, math functions.
- Use zero-runtime styling (CSS Modules, vanilla-extract, Tailwind, Panda, StyleX) for performance. Runtime CSS-in-JS (styled-components, Emotion) adds JS cost and conflicts with React Server Components.
- Lint with Stylelint (`stylelint-config-standard`) and format with Prettier. Fail CI on errors.
- Target browsers through one `browserslist` config shared by Lightning CSS / Autoprefixer / Babel.

## Methodologies
- **BEM**: `.block`, `.block__element`, `.block--modifier`. Flat single-class selectors, no nesting by DOM. Good with plain CSS and Sass (`&__element`). Native CSS nesting cannot build `&__element`.
- **Utility-first / Atomic** (Tailwind, Atomizer): one class per declaration. CSS size stays flat as the app grows. Extract components in your framework, not with many `@apply` rules.
- **CUBE CSS**: Composition (layout primitives), Utility, Block, Exception (`[data-state]`). Lean on the cascade instead of fighting it.
- **Layout primitives** (Every Layout): Stack, Cluster, Sidebar, Switcher, Grid, Center, and Cover components built with intrinsic CSS and no media queries.
- **ITCSS** ordering (settings → tools → generic → elements → objects → components → utilities) maps directly to `@layer`.
- State with attributes, not classes, when ARIA already holds it: `[aria-expanded="true"]`, `[data-state="open"]`.

## Design tokens
```css
@layer tokens {
  :root {
    --blue-600: oklch(55% .2 260);
    --color-action: var(--blue-600);
    --space-1: .25rem; --space-2: .5rem; --space-4: 1rem;
    --radius-m: .5rem;
    --shadow-1: 0 1px 2px oklch(0% 0 0 / .12);
  }
}
.btn { --btn-bg: var(--color-action); background: var(--btn-bg); }
```
- Keep the source of truth in a format like the W3C Design Tokens (DTCG) JSON, and generate CSS, iOS, and Android outputs with Style Dictionary or a similar tool.
- Theming: swap semantic tokens under `[data-theme]` or with `light-dark()`. Never theme by overriding component internals.
- Make tokens visible in docs (Storybook) and in DevTools-friendly names.

## Tailwind CSS
- v4: CSS-first config. Import with `@import "tailwindcss";`, define tokens in `@theme { --color-brand: …; }`, add custom utilities with `@utility`, and variants with `@custom-variant`.
- Output uses native cascade layers (`theme, base, components, utilities`). Unlayered custom CSS beats all Tailwind utilities.
- v3 (legacy): `@tailwind base; @tailwind components; @tailwind utilities;` + `tailwind.config.js`.
- Class names must appear whole in source for detection. `bg-${color}-500` built at runtime is not generated. Map values to full class strings.
- Use `!` (important modifier: `bg-red-500!` in v4, `!bg-red-500` in v3) only as a last resort.
- Merge conflicting classes in components with `tailwind-merge`, and organize variants with `cva` or `tailwind-variants`.
- `@apply` is fine for third-party markup you cannot add classes to. Do not rebuild BEM with it.

## Sass
- Use the module system: `@use "tokens" as t;` and `@forward`. `@import` is deprecated.
- Configurable libraries: `$radius: 4px !default;`, then `@use "lib" with ($radius: 8px);`.
- Mixins for repeated declaration groups with parameters, `@content` for wrappers (media queries). Placeholder `%selectors` + `@extend` can produce surprising selector bloat; prefer mixins.
- Use `math.div()` instead of `/`. Use `@each`/`@for` loops for generated utilities, and keep the output small.
- Sass variables are compile-time. Use CSS custom properties for anything that changes at runtime (themes, states).

## PostCSS and Lightning CSS
- Lightning CSS (Rust) handles prefixing, nesting lowering, color-function fallbacks, minification, and CSS Modules much faster than PostCSS chains. Vite supports it with `css.transformer: 'lightningcss'`.
- Keep PostCSS for plugins you need (Tailwind v3, `postcss-preset-env` drafts, custom-media). Do not lower features the target browsers already support.

## CSS Modules and scoping
- CSS Modules (`.module.css`) hash class names per file. Compose with `composes: base from "./base.module.css";`.
- Framework scoping: Vue `<style scoped>`, Svelte component styles, and Astro scoped styles (`:where(.astro-xyz)` keeps specificity low). Use `:global()` sparingly.
- Native `@scope` covers many scoping needs without build tools.

## CSS-in-JS
- Zero-runtime (vanilla-extract, Linaria, Panda, StyleX) compiles to static CSS with typed tokens (`createTheme`, `style`, `recipe`, Sprinkles atomic props).
- Runtime libraries generate styles in the browser. If used, avoid creating styled components inside render and prefer CSS variables for dynamic values.

## Web components
- Styles inside shadow DOM are fully scoped. Theme through inherited custom properties and `::part()`.
- Share styles across many components with constructable stylesheets (`adoptedStyleSheets`).
- Use light DOM (no shadow root) when the component must accept global styles or utility classes.

## Linting and hygiene
- Stylelint rules worth enforcing: `selector-max-id: 0`, `selector-max-specificity`, `declaration-no-important`, `color-no-hex` or token-only colors (via plugins), `selector-class-pattern` for naming, `no-descending-specificity`.
- Find unused CSS with DevTools Coverage, PurgeCSS reports, or the CSS Stats / Project Wallace dashboards.
- Track CSS size budgets in CI.
- Visual regression tests (Playwright `toHaveScreenshot`, Chromatic) catch cascade regressions.

## WordPress and CMS themes
- Block themes: put tokens in `theme.json` (`settings.color.palette`, `settings.typography.fontSizes` with `fluid`, `settings.spacing`, `settings.custom`). WordPress outputs them as `--wp--preset--*` custom properties.
- Style hierarchy: core defaults → theme `theme.json` → style variations (`/styles/*.json`) → user Global Styles.
- Prefer `theme.json` `styles.elements` / `styles.blocks` over custom CSS that fights the editor.

## Gotchas
- Unlayered third-party CSS overrides all your layers. Import it into a layer: `@import url(lib.css) layer(vendor);`.
- Runtime CSS-in-JS can inject styles in a different order on server and client and cause hydration flashes.
- Barrel files and circular imports in large design-system packages slow builds and defeat tree-shaking.
- Purge tools remove classes only referenced in CMS content or JSON. Safelist them.
- Over-abstraction: a utility for every one-off value creates a second, worse CSS language. Use arbitrary values or inline styles for true one-offs.
