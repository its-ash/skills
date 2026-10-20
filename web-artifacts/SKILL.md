---
name: web-artifacts
description: "Creates complex Claude.ai HTML artifacts using React, TypeScript, Vite, Tailwind CSS, and shadcn/ui, then bundles the app into a single self-contained HTML file for sharing in conversations. Use when building interactive web demos, dashboards, widgets, prototypes, or shareable HTML apps with .tsx components, npm run build, Vite bundling, Tailwind styling, shadcn/ui components, React hooks, and TypeScript errors."
---

# Web Artifacts Builder
Create powerful, multi‑component Claude.ai artifacts with modern frontend tools. Use this skill when you need state management, routing, or shadcn/ui components. Do not use it for simple single‑file HTML or JSX artifacts.

## When to use
- The artifact requires React components, TypeScript, or Tailwind styling.
- You need reusable UI elements from shadcn/ui or Radix.
- The final output must be a single HTML file that can be pasted into a Claude conversation.

## Workflow
1. **Create a new project**
   ```bash
   mkdir <project-name>
   cd <project-name>
   npm init -y
   npm install react react-dom
   npm install -D vite @vitejs/plugin-react-swc
   npm install -D typescript @types/react @types/react-dom
   npx vite init
   ```
   - Add a `tsconfig.json` that enables JSX with React.
   - Set Vite's `alias` to `@/` pointing to `src/`.
2. **Add Tailwind CSS**
   ```bash
   npm install -D tailwindcss@latest postcss autoprefixer
   npx tailwindcss init -p
   ```
   - In `tailwind.config.cjs` set `content` to `['./index.html', './src/**/*.{js,ts,jsx,tsx}']`.
   - Add Tailwind directives to `src/index.css`:
   ```css
   @tailwind base;
   @tailwind components;
   @tailwind utilities;
   ```
3. **Install shadcn/ui**
   ```bash
   npx shadcn-ui@latest init
   npx shadcn-ui@latest add <component>
   ```
   - Choose the default Tailwind preset when prompted.
   - The command adds component files under `src/components/` and updates Tailwind config.
4. **Develop the artifact**
   - Write React components in `src/`.
   - Use Tailwind classes for styling.
   - Import shadcn/ui components as needed.
   - Keep layout simple; avoid excessive centered layouts, purple gradients, uniform rounded corners, and the Inter font.
5. **Bundle into a single HTML file**
   ```bash
   npm install -D parcel @parcel/config-default parcel-resolver-tspaths html-inline
   npx parcel build index.html --no-source-maps --dist-dir dist
   npx html-inline dist/index.html > bundle.html
   ```
   - Ensure `index.html` references the built script (`<script type="module" src="/src/main.tsx"></script>`).
   - The `parcel` command respects the `@/` alias via `parcel-resolver-tspaths`.
   - `html-inline` inlines CSS, JS, and assets, producing a self‑contained `bundle.html`.
6. **Share the artifact**
   - Attach `bundle.html` to the Claude conversation.
7. **Optional testing**
   - Use Playwright or Puppeteer to open `bundle.html` locally and verify UI behavior.
   - Run tests only if the user requests them or if you encounter issues.

## Design & Style Guidelines
- Use Tailwind utility classes for spacing and typography.
- Prefer responsive design; test on multiple viewport widths.
- Avoid UI patterns that look like “AI slop”:
  - No full‑width centered containers unless required.
  - No purple gradient backgrounds.
  - Vary corner radii; do not apply the same radius to every element.
  - Use system fonts or Tailwind’s default font stack instead of Inter.

## Common Development Tasks
| Task | Command / Code |
|------|----------------|
| Add a new shadcn/ui component | `npx shadcn-ui@latest add <component>` |
| Run development server | `npx vite` |
| Lint TypeScript | `npx tsc --noEmit` |
| Format with Prettier (if installed) | `npx prettier --write .` |

## Pitfalls & Mitigations
- **Missing `index.html`** – The bundling step fails. Ensure an `index.html` exists at the project root and includes a script tag for the entry point.
- **Path alias errors** – Verify `tsconfig.json` `paths` and `.parcelrc` alias settings match.
- **Large bundle size** – Remove unused shadcn/ui components and unused Tailwind utilities. Use `purge` in Tailwind config.
- **Runtime errors after bundling** – Open `bundle.html` in a browser console to inspect errors. Common causes are mismatched import paths or missing assets.

## Checklist
- [ ] Initialized React + TypeScript project with Vite.
- [ ] Configured Tailwind CSS and added `src/index.css`.
- [ ] Installed shadcn/ui and added required components.
- [ ] Set up `@/` path alias in `tsconfig.json` and `.parcelrc`.
- [ ] Developed UI without prohibited design patterns.
- [ ] Bundled with Parcel and inlined assets using `html-inline`.
- [ ] Verified `bundle.html` loads correctly in a browser.
- [ ] Shared `bundle.html` with the user.
- [ ] Performed optional testing if requested.

## Related skills

Load these when the task spans more than this skill.

- [`frontend-development`](../frontend-development/SKILL.md) — Frontend Development skill for building modern React/Next.js applications with TypeScript, MUI, TanStack Query…
- [`react-state-management`](../react-state-management/SKILL.md) — A concise guide for choosing and implementing React state management solutions—Redux Toolkit, Zustand, Jotai,…
- [`typescript`](../typescript/SKILL.md) — Provides expert guidance for TypeScript projects, covering setup analysis, migration, monorepo configuration,…
- [`design-systems`](../design-systems/SKILL.md) — Creates a complete design system with design tokens, atomic component architecture, theming (including dark mo…
- [`javascript`](../javascript/SKILL.md) — A concise reference of core JavaScript concepts—primitives, type coercion, scope, closures, this, event loop,…
- [`image-enhancer`](../image-enhancer/SKILL.md) — Enhances image resolution, sharpness, and reduces compression artifacts for screenshots, photos, and graphics.…
- [`brand-theming`](../brand-theming/SKILL.md) — Applies Anthropic’s official brand colors and typography to slides, documents, or other visual artifacts. Use…
