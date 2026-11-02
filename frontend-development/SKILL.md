---
name: frontend-development
description: "Build React and Next.js apps with TypeScript, MUI v7, TanStack Query and Router, and performance patterns. Use when creating React components, Next.js pages, MUI theming, sx styling, useSuspenseQuery, useMutation, TanStack Router routes, server components, SSR hydration, bundle analysis, re-render reduction, async waterfalls, Core Web Vitals, React Native/Expo, Vue 3, Pinia, Nuxt 4, Angular signals, Vite, or Turbopack. Sub-skills: mui, react-patterns, react-performance, nextjs, astro, d3-visualization, progressive-web-app, react-native, vue, nuxt, ui-to-vue, angular, vite."
---

# Frontend Development
Build, organize, and tune React/Next.js apps with TypeScript, MUI v7, and TanStack Query/Router.

## Core rules
- Organize by feature: `src/features/<name>/{api,components,hooks,helpers,types}` + `index.ts` public API.
- Use import aliases (`@/`, `~types`, `~components`, `~features`); no deep relative paths.
- Type props with `interface`; type MUI style objects with `SxProps<Theme>`.
- Fetch server data with `useSuspenseQuery` inside `<Suspense>`. No manual `isLoading` flags.
- Do not early-return loading spinners. Keep layout stable (prevents CLS).
- Lazy-load heavy components and route pages with `React.lazy` + `<Suspense fallback={<SuspenseLoader/>}>`.
- Style with `sx`. Move styles to `<Component>.styles.ts` when the component passes 100 lines.
- MUI v7 Grid: `<Grid size={{ xs: 12, md: 6 }} />`.
- Sort a copy: `useMemo(() => [...items].sort(fn), [items])`. `Array.prototype.sort` mutates.
- Virtualize long lists with `@tanstack/react-virtual`.
- Wrap the app in an Error Boundary. Show user-visible errors with `useMuiSnackbar`.
- Give interactive widgets keyboard support, focus management, and correct ARIA roles.
- Add `*.test.tsx` for new features; lint must pass.

## Decisions
| Situation | Do | Avoid |
|---|---|---|
| Server state | TanStack Query | `useEffect` + `useState` fetch |
| Shared mutable client state | Context + `useReducer` | Prop drilling across many levels |
| Isolated reusable logic | Custom hook (`useDebounce`, `useToggle`) | Copy logic between components |
| No data library allowed | Ref-based fallback hook (hooks-and-ui) | Inline fetcher in effect deps (infinite loop) |
| Expensive calc / handler to child / pure child | `useMemo` / `useCallback` / `React.memo` | Memo everything by default |
| Simple form | Validate on submit, `Record<field, string>` errors | Silent submit failure |
| Complex form | React Hook Form or TanStack Form + Zod | Hand-rolled nested validation |
| Large bundle | `npm run build && npx next-bundle-analyzer`, split code | Barrel imports of heavy libs |

| Stack | Read |
|---|---|
| Next.js App Router, server actions, Turbopack | nextjs |
| Content site, zero JS default | astro |
| Mobile (Expo) | react-native |
| Vue 3 / Nuxt 4 / Angular | vue / nuxt / angular |

## Load on demand
| Need | Read |
|---|---|
| Setup, aliases, file layout, feature and component checklists, component template, TanStack route, MUI styling basics | [references/project-conventions.md](references/project-conventions.md) |
| useDebounce, fallback async hook, Error Boundary, Framer Motion, forms, accessibility | [references/hooks-and-ui.md](references/hooks-and-ui.md) |
| MUI v7 components, sx, theme, responsive, MUI hooks | [references/mui.md](references/mui.md) |
| Component design, hooks, state selection, React 19, composition, UI states, useEffect rules | [references/react-patterns.md](references/react-patterns.md) |
| Waterfalls, bundle size, SSR, re-renders, Web Vitals | [references/react-performance.md](references/react-performance.md) |
| Next.js 14+ App Router, caching, route handlers, server actions, metadata, Supabase auth, Next 16 `proxy.ts` | [references/nextjs.md](references/nextjs.md) |
| Astro islands, content collections, SSG/SSR | [references/astro.md](references/astro.md) |
| D3 charts: scales, axes, transitions, zoom, force, maps | [references/d3-visualization.md](references/d3-visualization.md) |
| PWA manifest, service worker cache, install, offline, push | [references/progressive-web-app.md](references/progressive-web-app.md) |
| React Native / Expo Router, FlashList, NativeWind, secure storage | [references/react-native.md](references/react-native.md) |
| Vue 3 Composition API, Pinia, Vue Router | [references/vue.md](references/vue.md) |
| Nuxt 4 hydration, `useFetch`/`useAsyncData`, route rules | [references/nuxt.md](references/nuxt.md) |
| Screenshots to Vue 3 components (Vant, Element Plus, Ant Design Vue) | [references/ui-to-vue.md](references/ui-to-vue.md) |
| Angular signals, forms, DI, routing, SSR, testing (detail in `references/angular/`) | [references/angular.md](references/angular.md) |
| `vite.config.ts`, plugins, HMR, env, proxy, library mode | [references/vite.md](references/vite.md) |

## Related skills
- [`typescript`](../typescript/SKILL.md) — types, tsconfig, Zod schemas
- [`design`](../design/SKILL.md) — visual design, layout, motion, CSS
- [`web-performance`](../web-quality-audit/references/web-performance.md) — measure and fix Core Web Vitals
- [`i18n-localization`](../i18n-localization/SKILL.md) — translations, locale formatting, RTL
- [`swift-ios`](../swift-ios/SKILL.md) — native iOS with SwiftUI
