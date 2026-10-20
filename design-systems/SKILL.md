---
name: design-systems
description: "Builds a complete design system with design tokens, atomic component architecture, theming, dark mode, accessibility compliance, and documentation for web apps. Use when creating UI foundations, component libraries, token JSON, CSS variables, Tailwind or shadcn/ui components, design tokens, atoms, molecules, WCAG accessibility, dark mode themes, responsive components, or scalable product interfaces."
---

# Design System Starter

Create a reusable, accessible, and maintainable design system for web applications. The skill generates design tokens, defines an atomic component hierarchy, sets up theming (light/dark), enforces WCAG 2.1 AA standards, and provides documentation guidelines.

## When to use
- Starting a new product or redesigning an existing one.
- Need visual consistency across multiple teams or applications.
- Want to share a component library with developers and designers.
- Require built‑in dark‑mode support and accessibility compliance.

---

## Workflow Overview
1. **Define design principles** – consistency, accessibility, scalability, developer friendliness.
2. **Generate design tokens** – colors, typography, spacing, border radius, shadows, breakpoints.
3. **Set up theming** – light and dark mode using CSS variables or a ThemeProvider.
4. **Build atomic components** – atoms → molecules → organisms → templates → pages.
5. **Add accessibility patterns** – contrast, keyboard navigation, ARIA.
6. **Document components** – purpose, usage, props, variants, accessibility notes.
7. **Version and maintain** – semantic versioning, deprecation plan, changelog.

---

## Design Token Generation
You can generate a full token set with a small Python script. The script accepts a brand color, a style preset, and an export format.

```bash
# Example: generate a modern JSON token file from a brand blue
python design_token_generator.py "#3b82f6" modern json
```

**Supported styles**: `modern`, `classic`, `playful`.

**Supported formats**: `json`, `css`, `scss`.

The script creates:
- A full color palette (50‑950 scale).
- Semantic color tokens (brand, text, background, feedback).
- A typographic scale based on a modular 4‑step system.
- An 8‑point spacing grid.
- Border‑radius and shadow tokens.
- Responsive breakpoints (e.g., `sm`, `md`, `lg`, `xl`).

### Example Token JSON (excerpt)
```json
{
  "color": {
    "primitive": {
      "blue": {"50":"#eff6ff","100":"#dbeafe","200":"#bfdbfe","300":"#93c5fd","400":"#60a5fa","500":"#3b82f6","600":"#2563eb","700":"#1d4ed8","800":"#1e40af","900":"#1e3a8a"}
    },
    "semantic": {
      "brand": {"primary":"{color.primitive.blue.600}","hover":"{color.primitive.blue.700}"},
      "text": {"primary":"{color.primitive.gray.900}"},
      "background": {"primary":"{color.primitive.white}"},
      "feedback": {"success":"{color.primitive.green.600}"}
    }
  },
  "typography": {
    "fontFamily": {"sans":"'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"},
    "fontSize": {"xs":"0.75rem","sm":"0.875rem","base":"1rem","lg":"1.125rem","xl":"1.25rem"}
  },
  "spacing": {"1":"0.25rem","2":"0.5rem","3":"0.75rem","4":"1rem"},
  "borderRadius": {"sm":"0.125rem","base":"0.25rem","lg":"0.5rem"},
  "shadow": {"sm":"0 1px 3px 0 rgba(0,0,0,0.1)"},
  "breakpoint": {"sm":"640px","md":"768px","lg":"1024px","xl":"1280px"}
}
```

### Token Usage Guidelines
- Reference tokens via a consistent path, e.g., `color.semantic.brand.primary`.
- Use semantic tokens in UI code; change underlying primitives without touching components.
- Store tokens in a single source of truth (JSON, CSS variables, or SCSS map).
- Keep the token file version‑controlled.

---

## Theming & Dark Mode
Implement theming with either CSS variables or a JavaScript ThemeProvider.

### CSS Variable Approach
```css
:root {
  --color-bg-primary: #ffffff;
  --color-text-primary: #000000;
}
[data-theme="dark"] {
  --color-bg-primary: #1a1a1a;
  --color-text-primary: #ffffff;
}
```
Toggle the `data-theme` attribute on the `<html>` element to switch themes.

### Styled‑Components / Emotion ThemeProvider
```tsx
const lightTheme = {
  background: "#fff",
  text: "#000",
  ...tokens
};
const darkTheme = {
  background: "#000",
  text: "#fff",
  ...tokens
};

<ThemeProvider theme={isDark ? darkTheme : lightTheme}>
  <App />
</ThemeProvider>
```

### Tailwind CSS Dark Mode
```tsx
<div className="bg-white dark:bg-gray-900 text-gray-900 dark:text-white">
  Content
</div>
```
Enable `darkMode: 'class'` in `tailwind.config.js`.

---

## Atomic Component Architecture
Follow the Atomic Design methodology.

| Level | Description | Typical Size |
|------|-------------|--------------|
| **Atoms** | Primitive UI elements (Button, Input, Icon). | Single element |
| **Molecules** | Simple compositions of atoms (SearchBar, FormField). | 2‑4 atoms |
| **Organisms** | Complex UI blocks (NavBar, CardGrid). | Multiple molecules |
| **Templates** | Page‑level layout skeletons (Dashboard, Marketing). | Organisms + placeholders |
| **Pages** | Fully rendered pages with real content. | Complete UI |

### Example Atom – Button (TypeScript)
```tsx
interface ButtonProps {
  variant?: "primary" | "secondary" | "outline" | "ghost"; // default: primary
  size?: "sm" | "md" | "lg"; // default: md
  disabled?: boolean;
  loading?: boolean;
  icon?: React.ReactNode;
  as?: keyof JSX.IntrinsicElements; // polymorphic element
  children: React.ReactNode;
}

export const Button: React.FC<ButtonProps> = ({
  variant = "primary",
  size = "md",
  disabled,
  loading,
  icon,
  as: Component = "button",
  children,
  ...rest
}) => (
  <Component
    className={`btn ${variant} ${size}`}
    disabled={disabled || loading}
    {...rest}
  >
    {loading ? <Spinner /> : icon}
    {children}
  </Component>
);
```
**Best practices**
- Provide sensible defaults.
- Keep prop names consistent across components.
- Prefer composition (e.g., `<Card.Header>`) over many boolean props.
- Support polymorphic rendering via an `as` prop.

### Molecule – FormField
```tsx
interface FormFieldProps {
  label: string;
  name: string;
  error?: string;
  hint?: string;
  required?: boolean;
  children: React.ReactNode; // usually an Input
}

export const FormField: React.FC<FormFieldProps> = ({ label, name, error, hint, required, children }) => (
  <div className="form-field">
    <label htmlFor={name}>{label}{required && " *"}</label>
    {React.cloneElement(children as React.ReactElement, { id: name, name })}
    {hint && <small className="hint">{hint}</small>}
    {error && <small className="error" role="alert">{error}</small>}
  </div>
);
```

---

## Accessibility Guidelines (WCAG 2.1 AA)
1. **Color Contrast**
   - Normal text: minimum 4.5:1.
   - Large text (≥ 18 pt or ≥ 14 pt bold): minimum 3:1.
   - UI components: minimum 3:1.
   - Use tools like WebAIM Contrast Checker.
2. **Keyboard Navigation**
   - All interactive elements must be reachable via `Tab`.
   - Provide visible focus indicators (e.g., `outline: 2px solid var(--color-focus)`).
   - Manage focus inside modals with a focus trap.
3. **ARIA Practices**
   - `aria-label` for icon‑only buttons.
   - `aria-expanded` and `aria-controls` for toggles.
   - `role="alert"` for error messages.
4. **Screen Reader Support**
   - Use semantic HTML (`<button>`, `<nav>`, `<header>`).
   - Avoid using `<div>`/`<span>` for interactive elements.
   - Provide descriptive text for SVG icons.
5. **Testing**
   - Run automated axe checks (`npm exec axe-cli`).
   - Perform manual keyboard and screen‑reader tests.

---

## Documentation Standards
Create clear, versioned docs for each component.

### Component Doc Template
```
# ComponentName
**Purpose**: Brief description of what the component does.

## Import
```tsx
import { ComponentName } from "@my-design-system/components";
```

## Usage
```tsx
<ComponentName propA="value" />
```

## Props
| Prop | Type | Default | Description |
|------|------|---------|-------------|
| variant | "primary" \| "secondary" | "primary" | Visual style |
| size | "sm" \| "md" \| "lg" | "md" | Size of the component |
| ... | ... | ... | ... |

## Variants
- Primary (default)
- Secondary
- Outline

## Accessibility
- Keyboard focusable
- ARIA label required when icon‑only

## Examples
- Basic
- With icon
- Disabled state
```

Publish docs with Storybook, Docusaurus, or a similar tool. Include live code examples and accessibility notes.

---

## Design System Workflow Details
### 1. Design Phase
- Audit existing UI for inconsistencies.
- Define token categories (color, typography, spacing, radius, shadow, breakpoints).
- Build a component inventory in a design tool (Figma, Sketch).
- Create a shared token file and export to JSON/CSS.

### 2. Development Phase
- Install tooling: `npm i -D storybook @storybook/addon-a11y`.
- Add the token file to the repo.
- Implement atoms first, then compose upward.
- Write unit tests and axe accessibility tests for each component.
- Document components concurrently.

### 3. Adoption Phase
- Write a migration guide that maps old UI patterns to new components.
- Provide codemods (e.g., `jscodeshift`) to automate simple replacements.
- Conduct workshops for design and engineering teams.
- Collect feedback via issue tracker.

### 4. Maintenance Phase
- Follow semantic versioning (`MAJOR.MINOR.PATCH`).
- Deprecate components with a clear timeline.
- Keep a changelog.
- Monitor token usage across repositories; update tokens centrally.

---

## Common Pitfalls & How to Avoid Them
| Pitfall | Impact | Mitigation |
|---------|--------|------------|
| Hard‑coding colors or sizes | Breaks consistency, makes theming impossible | Always reference tokens (`var(--color-primary)` or `tokens.color.semantic.brand.primary`). |
| Inconsistent prop naming | Increases cognitive load for developers | Adopt a naming convention (e.g., `variant`, `size`, `disabled`). |
| Missing focus styles | Keyboard users cannot navigate | Add a visible `:focus-visible` style to every interactive element. |
| Ignoring contrast in dark mode | Fails WCAG compliance | Run contrast checks for both light and dark palettes. |
| Over‑configuring components with many boolean props | Leads to bloated APIs | Prefer composition (slots, children) over flags. |
| Not versioning token files | Teams may diverge on visual language | Store tokens in version control and tag releases. |

---

## Quick‑Start Checklist
- [ ] Write a design‑principles statement.
- [ ] Generate token file (`python design_token_generator.py <brand> modern json`).
- [ ] Verify contrast ratios for both light and dark palettes.
- [ ] Set up CSS variable theme or ThemeProvider.
- [ ] Implement core atoms (Button, Input, Icon, Avatar, Badge).
- [ ] Build at least one molecule and one organism.
- [ ] Add keyboard focus styles to all interactive elements.
- [ ] Include ARIA attributes where needed.
- [ ] Create Storybook stories for each component.
- [ ] Write component documentation using the template.
- [ ] Publish the token file and component library to a package registry.
- [ ] Draft a migration guide for existing codebases.
- [ ] Tag the initial release (e.g., `v1.0.0`).

---

## References (no external files required)
- WCAG 2.1 AA guidelines: https://www.w3.org/TR/WCAG21/
- Contrast checker: https://webaim.org/resources/contrastchecker/
- Axe accessibility CLI: `npm exec axe-cli`
- Atomic Design by Brad Frost.

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/shadcn-ui.md](references/shadcn-ui.md) | Manages shadcn/ui components and projects. Use when adding, styling, composing, or debugging shadcn/ui components; initializing projects; switching presets; or retrieving component documentation. Provides CLI workflows, styling rules, composition patterns, and project context integration. |
| [references/tailwind-css.md](references/tailwind-css.md) | Tailwind CSS v4 design‑system skill for building responsive, accessible UI components with CSS‑first configuration, design tokens, container queries, dark mode, and performance best practices. |

## Related skills

Load these when the task spans more than this skill.

- [`design`](../design/SKILL.md) — Unified frontend design skill covering the full lifecycle from brief inference to production. Combines anti-sl…
- [`frontend-development`](../frontend-development/SKILL.md) — Frontend Development skill for building modern React/Next.js applications with TypeScript, MUI, TanStack Query…
- [`web-accessibility`](../web-accessibility/SKILL.md) — Provides concise guidance for auditing and fixing web accessibility to meet WCAG 2.1 (POUR) and ARIA standards…
- [`brand-theming`](../brand-theming/SKILL.md) — Applies Anthropic’s official brand colors and typography to slides, documents, or other visual artifacts. Use…
- [`screenshot-feature-extractor`](../screenshot-feature-extractor/SKILL.md) — Extract product features from UI screenshots and generate a development task checklist. Use when you need to t…
- [`image-generation`](../image-generation/SKILL.md) — Generate or edit images using OpenAI (gpt-image-1.5) or OpenRouter (FLUX.2 Pro, Gemini 3 Pro) APIs. Use for ph…
- [`ux-research`](../ux-research/SKILL.md) — Provides a step‑by‑step workflow for senior UX researchers and designers to generate data‑driven personas, map…
