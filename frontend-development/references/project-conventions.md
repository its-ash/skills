# React Project Conventions (Vite/Next + MUI + TanStack)

## Setup and commands
```bash
npm install && cp .env.example .env
npm run dev | npm run lint | npm run test
npm run build && npx next-bundle-analyzer   # bundle size report
docker build -t my-app . && docker compose up -d   # optional
```

## Import aliases
| Alias | Resolves to |
|---|---|
| `@/` | `src/` |
| `~types` | `src/types` |
| `~components` | `src/components` |
| `~features` | `src/features` |

## File layout
```
src/
├─ components/   # shared UI (SuspenseLoader, AppBar)
├─ features/<feature>/
│   ├─ api/ components/ hooks/ helpers/ types/
│   └─ index.ts  # public API
├─ routes/       # TanStack Router file routes
└─ lib/          # shared utils (apiClient)
```

## New feature checklist
- [ ] `src/features/<name>/` with `api`, `components`, `hooks`, `helpers`, `types`.
- [ ] `api/<name>Api.ts` exports typed request functions.
- [ ] Types in `types/`, exported.
- [ ] Route `src/routes/<name>/index.tsx` lazy-loads the feature component.
- [ ] Public API in `src/features/<name>/index.ts`.
- [ ] Hooks in `hooks/`, exported.
- [ ] Styles follow the inline-vs-file rule.
- [ ] Memoize, lazy-load, no needless re-renders.
- [ ] Keyboard support and focus management.
- [ ] `*.test.tsx` added; lint passes.

## Component checklist
- Props: `interface Props { … }` + `React.FC<Props>`.
- Component > 100 lines: move styles to `<Component>.styles.ts`.
- Heavy component: `React.lazy(() => import('./Heavy'))` inside `<Suspense fallback={<SuspenseLoader/>}>`.
- Data: `useSuspenseQuery`; no manual `isLoading` checks; no early-return spinners (keeps layout stable, prevents CLS).
- `useCallback` for handlers passed to children.
- Default export at file bottom.
- User notifications and visible errors: `useMuiSnackbar`.

```tsx
import React, { useCallback } from 'react';
import { Box, Paper } from '@mui/material';
import { useSuspenseQuery } from '@tanstack/react-query';
import { featureApi } from '../api/featureApi';

interface MyComponentProps { id: number; onAction?: () => void; }

export const MyComponent: React.FC<MyComponentProps> = ({ id, onAction }) => {
  const { data } = useSuspenseQuery({ queryKey: ['feature', id], queryFn: () => featureApi.getFeature(id) });
  const handleAction = useCallback(() => onAction?.(), [onAction]);
  return <Box sx={{ p: 2 }}><Paper sx={{ p: 3 }}>{/* render data */}</Paper></Box>;
};

export default MyComponent;
```

## Routing (TanStack Router)
File: `src/routes/my-feature/index.tsx`. Use `loader` for breadcrumb or meta data.
```tsx
import { createFileRoute } from '@tanstack/react-router';
import { lazy } from 'react';

const FeaturePage = lazy(() => import('~features/my-feature/components/FeaturePage'));

export const Route = createFileRoute('/my-feature/')({
  component: FeaturePage,
  loader: () => ({ crumb: 'My Feature' }),
});
```

## Styling (MUI v7)
- Use `sx`; type style objects as `Record<string, SxProps<Theme>>`.
- Inline when < 100 lines; else `<Component>.styles.ts`.
- Grid v7: `<Grid size={{ xs: 12, md: 6 }} />`.
- Full MUI patterns: [mui.md](mui.md).
