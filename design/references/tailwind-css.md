# Tailwind CSS Design System (v4)

Create a production‑ready UI library using Tailwind CSS v4. The guide covers CSS‑first configuration, design tokens, container queries, dark mode, layout patterns, and performance rules.

---

## When to use
- Building a component library or design system.
- Defining reusable design tokens (colors, spacing, typography).
- Implementing responsive components with container queries.
- Adding dark‑mode support.
- Standardising UI patterns across a codebase.
- Migrating an existing Tailwind v3 project to v4.

---

## Architecture Overview
| Concept | What it means |
|---|---|
| **CSS‑first** | All configuration lives in CSS via the `@theme` directive. No `tailwind.config.js` is required. |
| **Oxide engine** | Rust‑based compiler, default in v4, ~10× faster than the old PostCSS pipeline. |
| **Native nesting** | Use standard CSS nesting (`&`) without a PostCSS plugin. |
| **CSS variables** | Every token is exposed as a `--*` variable for easy reuse. |

---

## CSS‑Based Theme Definition
```css
@theme {
  /* Semantic colors */
  --color-primary: oklch(0.7 0.15 250);
  --color-surface: oklch(0.98 0 0);
  --color-surface-dark: oklch(0.15 0 0);

  /* Spacing scale */
  --spacing-xs: 0.25rem;
  --spacing-sm: 0.5rem;
  --spacing-md: 1rem;
  --spacing-lg: 2rem;

  /* Typography */
  --font-sans: 'Inter', system-ui, sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
}
```
*Place the `@theme` block in a global CSS file that loads before any component styles.*

---

## Extending vs Overriding Tokens
- **Extend** – Add new values while keeping the default scale. Use `--spacing-xl: 3rem;` to add a larger step.
- **Override** – Replace the entire default set. Remove the original declaration and write a new one.
- **Semantic tokens** – Prefer purpose‑based names (`--color-primary`) over raw palette names (`--blue-500`).

---

## Container Queries (Native)
1. Mark a parent as a container: `@container;` (or `@container/card;` for a named container).
2. Apply breakpoint prefixes on children:
   - `@sm:` – applies when the container width ≥ 640 px.
   - `@md:`, `@lg:` … follow the same scale as viewport breakpoints.
3. Example:
```html
<div class="@container">
  <img class="w-full @md:w-1/2" src="..." />
  <p class="text-sm @lg:text-base">Responsive text</p>
</div>
```
*Use container queries for component‑level responsiveness; use viewport prefixes (`sm:`, `md:`) for page‑level layouts.*

---

## Responsive Design (Viewport Prefixes)
| Prefix | Min‑width | Typical device |
|---|---|---|
| (none) | 0 px | Mobile (base) |
| `sm:` | 640 px | Large phone / small tablet |
| `md:` | 768 px | Tablet |
| `lg:` | 1024 px | Laptop |
| `xl:` | 1280 px | Desktop |
| `2xl:` | 1536 px | Large desktop |

**Mobile‑first rule** – Write base styles without a prefix, then add larger‑screen overrides.
```html
<div class="w-full md:w-1/2 lg:w-1/3">...</div>
```

---

## Dark Mode
| Method | How it works | When to choose |
|---|---|---|
| `class` | Add `.dark` to a root element. | Manual toggle UI. |
| `media` | Uses `prefers-color-scheme`. | No user control needed. |
| `selector` (v4) | Custom selector like `.theme-dark`. | Complex theming scenarios. |

**Pattern example**
```html
<div class="bg-white dark:bg-zinc-900 text-zinc-900 dark:text-zinc-100">
  Content
</div>
```

---

## Layout Patterns
### Flexbox
| Pattern | Classes |
|---|---|
| Center (both axes) | `flex items-center justify-center` |
| Vertical stack | `flex flex-col gap-4` |
| Horizontal row | `flex gap-4` |
| Space between | `flex justify-between items-center` |
| Wrap grid | `flex flex-wrap gap-4` |

### Grid
| Pattern | Classes |
|---|---|
| Auto‑fit responsive | `grid grid-cols-[repeat(auto-fit,minmax(250px,1fr))]` |
| Asymmetric (Bento) | `grid grid-cols-3 grid-rows-2` + `col-span-2`, `row-span-2` as needed |
| Sidebar layout | `grid grid-cols-[auto_1fr]` |

*Prefer asymmetric/Bento layouts for richer visual hierarchy.*

---

## Color System & Tokens
- **OKLCH** is perceptually uniform; use it for base palette values.
- Token layers:
  1. **Primitive** – raw values (`--blue-500`).
  2. **Semantic** – purpose (`--color-primary`).
  3. **Component** – scoped (`--button-bg`).
- Reference tokens in utilities: `bg-[var(--color-primary)]`.

---

## Typography System
| Type | Recommended stack |
|---|---|
| Sans | `'Inter', system-ui, sans-serif` |
| Mono | `'JetBrains Mono', monospace` |
| Display | `'Outfit', 'Poppins', sans-serif` |

**Type scale**
```html
<p class="text-xs">Caption</p>
<p class="text-sm">Secondary</p>
<p class="text-base">Body</p>
<p class="text-lg">Lead</p>
<p class="text-xl">Heading</p>
```

---

## Animations & Transitions
| Class | Effect |
|---|---|
| `animate-spin` | Continuous rotation |
| `animate-ping` | Pulse that expands then fades |
| `animate-pulse` | Subtle opacity pulse |
| `animate-bounce` | Bouncing motion |

**Transition pattern**
```html
<button class="bg-primary text-white hover:bg-primary-dark transition-colors duration-150">Click</button>
```

---

## Component Extraction
| Signal | Extraction method |
|---|---|
| Same utility combo ≥ 3 times | Create a component (React/Vue) or a CSS class with `@apply`. |
| Complex state variants | Build a component with conditional classes. |
| Design‑system element | Document token usage and expose as a reusable component. |

**Static extraction example**
```css
/* components/button.css */
.btn-primary {
  @apply bg-primary text-white font-medium py-2 px-4 rounded-md hover:bg-primary-dark transition-colors;
}
```
Use `<button class="btn-primary">` in HTML.

---

## Anti‑Patterns
- **Avoid** arbitrary values; stick to the token scale.
- **Avoid** `!important`; resolve specificity with proper utility ordering.
- **Avoid** inline `style=` attributes; use Tailwind utilities.
- **Avoid** long duplicated class lists; extract a component.
- **Avoid** mixing v3 config with v4; fully migrate to CSS‑first.
- **Avoid** heavy `@apply` usage; prefer components for complex UI.

---

## Performance Principles
- Unused‑class purge is automatic in v4.
- Do **not** generate classes with template strings (e.g., `bg-${color}`) – they break purge.
- Keep the Oxide engine enabled (default) for fast builds.
- Cache the Tailwind build step in CI/CD pipelines.

---

## Checklist
- [ ] Define all design tokens in a single `@theme` block.
- [ ] Use semantic token names (`--color-primary`).
- [ ] Apply container queries for component‑level responsiveness.
- [ ] Choose a dark‑mode strategy (`class`, `media`, or custom selector).
- [ ] Build layout with Flexbox or Grid patterns, preferring asymmetric grids.
- [ ] Reference colors with `bg-[var(--color-primary)]` or similar.
- [ ] Use the type scale classes (`text-xs` … `text-xl`).
- [ ] Add transitions to interactive elements.
- [ ] Extract repeated utility combos into components or `@apply` classes.
- [ ] Verify no dynamic class strings exist.
- [ ] Test the final CSS bundle size and build time.
