---
name: frontend-development
description: "Build modern React and Next.js applications with TypeScript, MUI v7 components, TanStack Query and Router, and performance-focused patterns for components, routing, styling, data fetching, and bundle optimization. Use when creating React components, Next.js pages, TypeScript interfaces, MUI theming, sx prop styling, TanStack useSuspenseQuery, useQuery, useMutation, TanStack Router routes, server components, SSR hydration, responsive layouts, bundle analysis, re-render reduction, async waterfalls, or optimizing Core Web Vitals."
---

# Frontend Development

A practical guide for building, organizing, and optimizing React/Next.js applications using TypeScript, MUI v7, TanStack Query & Router, and modern performance patterns.

## When to Use
- Add a new component or page
- Implement a new feature (API, UI, state)
- Set up routing or lazy loading
- Apply styling with MUI
- Fetch data with `useSuspenseQuery`
- Optimize bundle size or runtime performance
- Enforce consistent file structure and TypeScript standards

---

## Project Setup
```bash
# Install dependencies
npm install
# Copy environment template
cp .env.example .env
# Start development server
npm run dev
# Run lint and tests
npm run lint
npm run test
```

## Import Aliases (vite/webpack)
| Alias | Resolves To |
| ----- | ----------- |
| `@/` | `src/` |
| `~types` | `src/types` |
| `~components` | `src/components` |
| `~features` | `src/features` |

Use them in imports, e.g. `import { apiClient } from '@/lib/apiClient'`.

---

## File Organization
```
src/
├─ components/          # Re‑usable UI pieces (SuspenseLoader, AppBar)
├─ features/            # Domain‑specific modules
│   └─ <feature>/
│       ├─ api/        # API service layer
│       ├─ components/ # Feature UI
│       ├─ hooks/      # Custom hooks
│       ├─ helpers/    # Utilities
│       └─ types/      # TypeScript types
├─ routes/              # TanStack Router file‑based routes
└─ lib/                 # Shared utilities (apiClient, etc.)
```

### New Feature Checklist
- Create `src/features/<name>/` with subfolders `api`, `components`, `hooks`, `helpers`, `types`.
- Add `api/<name>Api.ts` that exports typed request functions.
- Define TypeScript types in `types/`.
- Add a route file `src/routes/<name>/index.tsx` that lazy‑loads the feature component.
- Export a public API from `src/features/<name>/index.ts`.

---

## Component Creation Checklist
- Declare props with `interface Props { … }` and use `React.FC<Props>`.
- If the component is > 100 lines, move styles to `<Component>.styles.ts`.
- Lazy‑load heavy components with `React.lazy(() => import('./Heavy'))`.
- Wrap lazy components in `<Suspense fallback={<SuspenseLoader/>}>`.
- Use `useSuspenseQuery` for data fetching; avoid manual `isLoading` checks.
- Memoize event handlers with `useCallback` when passed to children.
- Export the component as a default export at the bottom of the file.
- Do **not** return early loading spinners; keep layout stable.
- Show user notifications with `useMuiSnackbar`.

### Minimal Component Template
```tsx
import React, { useState, useCallback } from 'react';
import { Box, Paper } from '@mui/material';
import { useSuspenseQuery } from '@tanstack/react-query';
import { featureApi } from '../api/featureApi';
import type { FeatureData } from '~types/feature';

interface MyComponentProps { id: number; onAction?: () => void; }

export const MyComponent: React.FC<MyComponentProps> = ({ id, onAction }) => {
  const { data } = useSuspenseQuery({
    queryKey: ['feature', id],
    queryFn: () => featureApi.getFeature(id),
  });

  const handleAction = useCallback(() => {
    onAction?.();
  }, [onAction]);

  return (
    <Box sx={{ p: 2 }}>
      <Paper sx={{ p: 3 }}>{/* render data */}</Paper>
    </Box>
  );
};

export default MyComponent;
```

---

## Routing (TanStack Router)
```tsx
import { createFileRoute } from '@tanstack/react-router';
import { lazy } from 'react';

const FeaturePage = lazy(() => import('~features/my-feature/components/FeaturePage'));

export const Route = createFileRoute('/my-feature/')({
  component: FeaturePage,
  loader: () => ({ crumb: 'My Feature' }),
});
```
- Place the file at `src/routes/my-feature/index.tsx`.
- Lazy‑load the feature component.
- Use `loader` to provide breadcrumb or meta data.

---

## Styling (MUI v7)
- Use the `sx` prop for most styling.
- Type the style object with `SxProps<Theme>`.
- Inline styles for < 100 lines; otherwise create `<Component>.styles.ts`.
```tsx
import { Box } from '@mui/material';
import type { SxProps, Theme } from '@mui/material';

const styles: Record<string, SxProps<Theme>> = {
  container: { p: 2, backgroundColor: theme => theme.palette.background.paper },
};

export const StyledBox = () => <Box sx={styles.container}>Content</Box>;
```
- Grid syntax (v7): `<Grid size={{ xs: 12, md: 6 }} />`.

---

## Data Fetching & State
### Primary Pattern: `useSuspenseQuery`
```tsx
const { data } = useSuspenseQuery({
  queryKey: ['posts', id],
  queryFn: () => postsApi.get(id),
});
```
- Works inside a `<Suspense>` boundary.
- Cache‑first strategy; no manual loading flags.

### Custom Hook Example (Toggle)
```tsx
export function useToggle(initial = false): [boolean, () => void] {
  const [value, setValue] = useState(initial);
  const toggle = useCallback(() => setValue(v => !v), []);
  return [value, toggle];
}
```

### Async Hook Example
```tsx
export function useQuery<T>(key: string, fetcher: () => Promise<T>, opts?: { onSuccess?: (d: T) => void; onError?: (e: Error) => void; enabled?: boolean }) {
  const [data, setData] = useState<T | null>(null);
  const [error, setError] = useState<Error | null>(null);
  const [loading, setLoading] = useState(false);

  const refetch = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const result = await fetcher();
      setData(result);
      opts?.onSuccess?.(result);
    } catch (e) {
      const err = e as Error;
      setError(err);
      opts?.onError?.(err);
    } finally {
      setLoading(false);
    }
  }, [fetcher, opts]);

  useEffect(() => {
    if (opts?.enabled !== false) refetch();
  }, [key, refetch, opts?.enabled]);

  return { data, error, loading, refetch };
}
```

---

## State Management Patterns
- **Context + Reducer** for shared mutable state.
- **Custom hooks** (`useToggle`, `useDebounce`) for isolated logic.
- **TanStack Query** for server state.

### Debounce Hook
```tsx
export function useDebounce<T>(value: T, delay: number): T {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const id = setTimeout(() => setDebounced(value), delay);
    return () => clearTimeout(id);
  }, [value, delay]);
  return debounced;
}
```

---

## Performance Optimization
- **Memoization**: `useMemo` for expensive calculations, `useCallback` for handlers, `React.memo` for pure components.
- **Code Splitting**: Lazy‑load heavy components with `React.lazy` and `<Suspense>`.
- **Virtualization**: Use `@tanstack/react-virtual` for long lists.
- **Bundle Analysis**: Run `npm run build && npx next-bundle-analyzer` (or any configured analyzer) to view size and apply recommendations.
- **Avoid Early Returns** for loading states; keep layout stable to prevent CLS.

---

## Error Handling
- Wrap the app with an **Error Boundary**.
```tsx
export class ErrorBoundary extends React.Component<{children: React.ReactNode}, {hasError: boolean; error: Error | null}> {
  state = {hasError: false, error: null};
  static getDerivedStateFromError(error: Error) { return {hasError: true, error}; }
  componentDidCatch(error: Error, info: React.ErrorInfo) { console.error(error, info); }
  render() {
    return this.state.hasError ? (
      <div className="error-fallback"><h2>Something went wrong</h2><p>{this.state.error?.message}</p></div>
    ) : this.props.children;
  }
}
```
- Use `useMuiSnackbar` for user‑visible error messages.

---

## Animation (Framer Motion)
```tsx
import { motion, AnimatePresence } from 'framer-motion';

export function AnimatedList({items}: {items: string[]}) {
  return (
    <AnimatePresence>
      {items.map(i => (
        <motion.div key={i} initial={{opacity:0, y:20}} animate={{opacity:1, y:0}} exit={{opacity:0, y:-20}} transition={{duration:0.3}}>
          {i}
        </motion.div>
      ))}
    </AnimatePresence>
  );
}
```
- Use similar patterns for modal transitions.

---

## Accessibility
- Provide keyboard navigation (arrow keys, Enter, Escape) for interactive widgets.
- Manage focus when opening/closing dialogs: save previous focus, move focus into the modal, restore on close.
- Use proper ARIA roles (`role="dialog"`, `aria-modal="true"`, `role="combobox"`).

---

## Checklist for New Feature
- [ ] Directory `src/features/<name>/` with required subfolders.
- [ ] TypeScript types defined and exported.
- [ ] API service (`api/<name>Api.ts`) with typed functions.
- [ ] Feature components use `React.FC`, lazy loading, and `SuspenseLoader`.
- [ ] Custom hooks placed in `hooks/` and exported.
- [ ] Route file created under `src/routes/<name>/index.tsx`.
- [ ] Styles follow inline vs separate rule.
- [ ] Performance: memoize, lazy load, avoid unnecessary re‑renders.
- [ ] Accessibility: keyboard support, focus management.
- [ ] Tests added (`*.test.tsx`) and lint passes.

---

## Common Commands
```bash
# Development
npm run dev               # Start dev server
npm run lint              # Lint code
npm run test              # Run unit/integration tests

# Build & Analyze
npm run build             # Production build (Next.js)
npx next-bundle-analyzer # View bundle size report

# Docker (optional)
docker build -t my-app .
docker compose up -d
```

---

## Resources
- **Component Patterns** – composition, compound components, render props.
- **Data Fetching** – `useSuspenseQuery` and API service layer.
- **File Organization** – feature‑first folder layout.
- **Styling Guide** – MUI `sx` usage and theme access.
- **Routing Guide** – TanStack Router file‑based routes.
- **Performance Guide** – memoization, virtualization, bundle analysis.
- **Accessibility Guide** – keyboard navigation and focus management.
- **Animation Guide** – Framer Motion patterns.

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/mui.md](references/mui.md) | Provides concise patterns for using Material‑UI v7 components, sx prop styling, theme integration, responsive design, and MUI‑specific hooks in React projects. |
| [references/react-patterns.md](references/react-patterns.md) | Provides production‑ready React patterns for component design, hooks, state selection, TypeScript typing, React 19 updates, composition, performance, error handling, UI states, routing, server components, and useEffect best practices. |
| [references/react-performance.md](references/react-performance.md) | Guidelines and workflow for optimizing React and Next.js performance. Use when writing, reviewing, or refactoring components, pages, or data‑fetching code to eliminate async waterfalls, shrink bundles, improve server‑side rendering, and reduce unnecessary re‑renders. |

## Related skills

Load these when the task spans more than this skill.

- [`nextjs`](../nextjs/SKILL.md) — Guidelines for building Next.js 14+ applications with the App Router. Includes component type decisions, data…
- [`typescript`](../typescript/SKILL.md) — Provides expert guidance for TypeScript projects, covering setup analysis, migration, monorepo configuration,…
- [`web-performance`](../web-performance/SKILL.md) — Provides step‑by‑step guidance to measure, diagnose, and improve web performance, focusing on Core Web Vitals…
- [`design-systems`](../design-systems/SKILL.md) — Creates a complete design system with design tokens, atomic component architecture, theming (including dark mo…
- [`api-integration`](../api-integration/SKILL.md) — Guides developers to integrate third‑party REST or GraphQL APIs securely and reliably. Includes authentication…
- [`astro`](../astro/SKILL.md) — Astro is a web framework for content‑heavy sites that ships zero JavaScript by default and hydrates interactiv…
- [`i18n-localization`](../i18n-localization/SKILL.md) — Guides developers to add internationalization (i18n) and localization (L10n) to web and Python projects, cover…
