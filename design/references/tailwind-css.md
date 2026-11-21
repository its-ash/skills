# Tailwind CSS Design System (v4.3+)

Build a modern, production-ready UI system using Tailwind CSS v4.3+. Uses CSS-first `@theme` tokens, `oklch()` + `light-dark()` theming (no `dark:` sprawl), native container queries, and modern component patterns aligned with [`design`](../SKILL.md).

---

## When to use
- Building a modern component library or design system in Tailwind v4.
- Defining reusable semantic tokens (surfaces, borders, colors, spacing, typography, radii).
- Implementing responsive components with native container queries.
- Setting up zero-JS-duplication dark mode with `color-scheme` and `light-dark()`.
- Migrating a legacy Tailwind v3 (`tailwind.config.js`) project to v4 CSS-first.

---

## Architecture Overview
| Concept | What it means |
|---|---|
| **CSS-first (`@theme`)** | All design tokens live in CSS via `@theme`. No `tailwind.config.js`. |
| **Oxide engine** | Rust-based compiler, default in v4, ~10x faster with automatic content detection. |
| **Native `light-dark()`** | Semantic color tokens adapt to light/dark automatically without scattering `dark:` classes on every element. |
| **Native nesting & `@container`** | Standard CSS nesting and built-in container queries with zero plugins. |

---

## CSS-First Theme Definition (`@theme` + `light-dark()`)

Define primitive and semantic tokens in your global CSS file. Tokens declared inside `@theme` automatically generate Tailwind utility classes (`bg-canvas`, `bg-surface`, `text-foreground`, `border-border-subtle`, `bg-accent`, `rounded-card`).

```css
@import "tailwindcss";

:root {
  color-scheme: light dark;
}

:root[data-theme="light"] { color-scheme: light; }
:root[data-theme="dark"]  { color-scheme: dark; }

@theme {
  /* Tonal surface elevation (never pure #000 or #fff) */
  --color-canvas: light-dark(oklch(98.5% 0.004 250), oklch(13.5% 0.01 250));
  --color-surface: light-dark(oklch(99.5% 0.002 250), oklch(17.5% 0.01 250));
  --color-surface-muted: light-dark(oklch(95.5% 0.006 250), oklch(21.5% 0.012 250));
  --color-surface-elevated: light-dark(oklch(100% 0 0 / 0.96), oklch(23.5% 0.012 250));

  /* Text */
  --color-foreground: light-dark(oklch(18% 0.015 250), oklch(94% 0.006 250));
  --color-muted-foreground: light-dark(oklch(46% 0.015 250), oklch(68% 0.01 250));

  /* Hairline borders */
  --color-border-subtle: light-dark(oklch(18% 0.015 250 / 0.09), oklch(94% 0.006 250 / 0.1));
  --color-border-strong: light-dark(oklch(18% 0.015 250 / 0.18), oklch(94% 0.006 250 / 0.2));

  /* Single brand accent (saturation < 80%) */
  --color-accent: light-dark(oklch(55% 0.18 250), oklch(68% 0.16 250));
  --color-accent-foreground: oklch(98% 0.005 250);
  --color-accent-soft: color-mix(in oklch, var(--color-accent) 12%, transparent);

  /* Status */
  --color-success: light-dark(oklch(54% 0.15 155), oklch(70% 0.14 155));
  --color-danger: light-dark(oklch(56% 0.19 25), oklch(68% 0.17 25));

  /* One coherent radius scale (concentric: card = inner + p-1/p-2) */
  --radius-control: 0.5rem;   /* 8px: buttons, inputs, active tabs */
  --radius-track: 0.75rem;    /* 12px: tab track (8px + 4px padding) */
  --radius-card: 1rem;        /* 16px: cards, panels, dialogs */

  /* Typography (distinctive sans + crisp mono, no default Inter) */
  --font-sans: "Geist", system-ui, sans-serif;
  --font-mono: "JetBrains Mono", ui-monospace, monospace;

  /* Easing */
  --ease-out-expo: cubic-bezier(0.23, 1, 0.32, 1);
}
```

Use semantic utilities directly — never `bg-[var(--color-accent)]` when `@theme` already generates `bg-accent`.

---

## Dark Mode (Semantic Tokens First)

- **Preferred (v4 modern):** Set `color-scheme: light dark` on `:root` and use `light-dark()` inside `@theme`. Every surface, border, and text token switches automatically. A manual theme toggle only updates `document.documentElement.dataset.theme = 'light' | 'dark'`.
- **Avoid:** Repeating `bg-white dark:bg-zinc-900 text-zinc-900 dark:text-zinc-100 border-zinc-200 dark:border-zinc-800` on every element. Use `bg-surface text-foreground border-border-subtle` once.

---

## Modern Component Patterns in Tailwind v4

### Filled Segmented Tabs (never underline-only)
```html
<div role="tablist" class="inline-flex items-center gap-1 rounded-track bg-surface-muted p-1 border border-border-subtle">
  <button
    role="tab"
    aria-selected="true"
    class="rounded-control bg-surface px-3.5 py-1.5 text-sm font-medium text-foreground shadow-xs transition-[background-color,color,box-shadow] duration-150"
  >
    Overview
  </button>
  <button
    role="tab"
    aria-selected="false"
    class="rounded-control px-3.5 py-1.5 text-sm font-medium text-muted-foreground hover:text-foreground transition-colors duration-150"
  >
    Activity
  </button>
</div>
```

### Tonal Card (no one-sided border, no nested cards)
```html
<article class="rounded-card bg-surface border border-border-subtle p-5 shadow-xs">
  <div class="flex items-start justify-between gap-4">
    <h3 class="text-base font-semibold tracking-tight text-foreground">Monthly revenue</h3>
    <span class="rounded-full bg-accent-soft px-2.5 py-0.5 text-xs font-medium text-accent">
      +12.4%
    </span>
  </div>
  <p class="mt-2 text-2xl font-semibold tracking-tight tabular-nums text-foreground">$48,290</p>
  <p class="mt-1 text-sm text-muted-foreground">Compared to previous 30 days</p>
</article>
```

### Full-Width Square Header
```html
<header class="sticky top-0 z-50 w-full rounded-none border-b border-border-subtle bg-surface/85 backdrop-blur-md">
  <div class="mx-auto flex h-16 max-w-7xl items-center justify-between px-4 sm:px-6">
    <!-- brand + nav items with filled hover/active states -->
  </div>
</header>
```

---

## Container Queries (Native)
1. Mark a parent as a container: `@container` (or `@container/card` for a named container).
2. Apply container prefixes on children (`@sm:`, `@md:`, `@lg:`).
```html
<div class="@container rounded-card bg-surface border border-border-subtle p-5">
  <div class="flex flex-col gap-4 @md:flex-row @md:items-center">
    <img class="aspect-video w-full rounded-control object-cover @md:w-48" src="..." alt="..." />
    <div class="min-w-0 flex-1">
      <h3 class="text-base font-semibold text-foreground text-balance">Adaptive card</h3>
      <p class="mt-1 text-sm text-muted-foreground text-pretty">Layout adapts to the card slot, not the viewport.</p>
    </div>
  </div>
</div>
```
*Use container queries for component-level responsiveness; use viewport prefixes (`sm:`, `md:`, `lg:`) for page-level layouts.*

---

## Layout & Spacing Rules
- **Mobile-first:** Base styles target mobile; layer `sm:` (640px), `md:` (768px), `lg:` (1024px), `xl:` (1280px), `2xl:` (1536px).
- **Use `gap-*`, not `space-x-*` / `space-y-*`:** `flex flex-col gap-4` is cleaner and works with wrapping and RTL.
- **Equal dimensions:** Use `size-10`, not `w-10 h-10`.
- **Viewport height:** Use `min-h-dvh`, never `h-screen`.
- **Intrinsic grids:** `grid grid-cols-[repeat(auto-fill,minmax(min(100%,18rem),1fr))] gap-4`.
- **Dynamic numbers:** Always add `tabular-nums` to KPIs, prices, counters, and table figures.

---

## Transitions & Motion
- **Never `transition-all`.** Name the exact properties: `transition-[transform,background-color,box-shadow] duration-150`.
- **Press feedback:** `active:scale-[0.98]`.
- **Reduced motion:** Pair non-essential movement with `motion-safe:` / `motion-reduce:transition-opacity motion-reduce:transform-none`.
- **Avoid gratuitous animations:** Do not use `animate-bounce` or `animate-ping` on UI chrome or status dots. Use subtle skeletons for loading states.

---

## Anti-Patterns
- **Avoid** `dark:` class sprawl when `light-dark()` tokens solve theming cleanly at the root.
- **Avoid** one-sided accent borders (`border-l-4`, `border-t-4`) on cards or callouts.
- **Avoid** underline-only tabs (`border-b-2 border-primary`) — use filled rounded tabs.
- **Avoid** raw hex/Tailwind palette classes (`bg-blue-500`, `text-gray-600`) in components; use semantic tokens (`bg-accent`, `text-muted-foreground`).
- **Avoid** dynamic class string interpolation (`bg-${color}`) — it breaks static extraction.
- **Avoid** heavy `@apply`; extract reusable UI into components instead.
- **Avoid** `tailwind.config.js` in v4 projects; migrate fully to CSS-first `@theme`.

---

## Checklist
- [ ] All semantic tokens defined in a single `@theme` block using `oklch()` and `light-dark()`.
- [ ] Zero `dark:` color sprawl; theme toggle only switches `color-scheme` via `data-theme`.
- [ ] Native Tailwind v4 semantic utilities used (`bg-surface`, `text-foreground`, `border-border-subtle`).
- [ ] Filled rounded tabs, tonal cards (no one-sided borders, no nested cards), full-width square header.
- [ ] Container queries (`@container`) used for component responsiveness; `gap-*` and `size-*` used consistently.
- [ ] Named transition properties (`transition-[...]`), `active:scale-[0.98]`, and `motion-reduce:` handled.
- [ ] No dynamic class string interpolation and no legacy `tailwind.config.js`.
