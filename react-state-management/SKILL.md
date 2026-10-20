---
name: react-state-management
description: "This skill guides selection and implementation of React state management libraries including Redux Toolkit, Zustand, Jotai, and TanStack Query for global client state, atomic atoms, and server-state synchronization in TypeScript React applications. Use when you need to choose between Redux Toolkit, Zustand, Jotai, or TanStack Query, implement global store, create atoms, manage server state caching, handle optimistic updates, persist state with middleware, migrate legacy Redux code, configure devtools, structure feature slices, or decide on state architecture for React TypeScript projects."
---

# React State Management

Guide to modern React state management patterns. Covers local, global, server, URL, and form state. Shows when to pick Redux Toolkit, Zustand, Jotai, or TanStack Query and provides ready‑to‑copy TypeScript snippets.

## When to Use
- You need a shared store across many components (global state).
- You want fine‑grained atomic updates without boilerplate (Jotai).
- Your app has heavy data fetching, caching, and optimistic UI (TanStack Query).
- You prefer a minimal API and optional persistence (Zustand).
- You are migrating a legacy Redux codebase to Redux Toolkit.

---

## Core Concepts
| Category | Typical Data | Recommended Library |
|----------|--------------|----------------------|
| Local UI state | toggle, input value | `useState`, `useReducer` |
| Global client state | auth, theme, cart | **Redux Toolkit**, **Zustand**, **Jotai** |
| Server state (remote data) | API results, pagination | **TanStack Query** (React Query) |
| URL state | route params, search | React Router, `nuqs` |
| Form state | validation, errors | React Hook Form, Formik |

### Selection Criteria
```
if (app size ≤ medium && state is simple) → Zustand or Jotai
if (app size is large OR state logic is complex) → Redux Toolkit
if (data comes from a server and needs caching) → TanStack Query
if you need atomic, independent pieces of state → Jotai
```

---

## Quick Starts
### 1. Zustand (minimal API, optional persistence)
```typescript
// src/store/useStore.ts
import { create } from 'zustand';
import { devtools, persist, subscribeWithSelector } from 'zustand/middleware';

interface AppState {
  user: User | null;
  theme: 'light' | 'dark';
  setUser: (user: User | null) => void;
  toggleTheme: () => void;
}

export const useStore = create<AppState>()(
  devtools(
    persist(
      subscribeWithSelector((set) => ({
        user: null,
        theme: 'light',
        setUser: (user) => set({ user }),
        toggleTheme: () =>
          set((s) => ({ theme: s.theme === 'light' ? 'dark' : 'light' })),
      })),
      { name: 'app-storage' }
    )
  )
);
```
**Selective subscription** (prevents unnecessary re‑renders):
```tsx
const theme = useStore((s) => s.theme); // component re‑renders only when theme changes
```
**Subscribe outside React** (e.g., logging):
```ts
useStore.subscribe(
  (s) => s.user?.id,
  (id) => console.log('User changed:', id)
);
```
---
### 2. Redux Toolkit (scalable, TypeScript‑first)
```typescript
// src/store/index.ts
import { configureStore } from '@reduxjs/toolkit';
import userReducer from './slices/userSlice';
import cartReducer from './slices/cartSlice';

export const store = configureStore({
  reducer: { user: userReducer, cart: cartReducer },
  middleware: (gdm) => gdm({ serializableCheck: false }),
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

export const useAppDispatch = () => useDispatch<AppDispatch>();
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;
```
```typescript
// src/store/slices/userSlice.ts
import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';

interface User { id: string; email: string; name: string; }
interface UserState { current: User | null; status: 'idle'|'loading'|'succeeded'|'failed'; error: string | null; }

const initialState: UserState = { current: null, status: 'idle', error: null };

export const fetchUser = createAsyncThunk('user/fetch', async (id: string) => {
  const res = await fetch(`/api/users/${id}`);
  if (!res.ok) throw new Error('Failed to fetch');
  return (await res.json()) as User;
});

const userSlice = createSlice({
  name: 'user',
  initialState,
  reducers: {
    setUser: (state, action: PayloadAction<User>) => { state.current = action.payload; state.status = 'succeeded'; },
    clearUser: (state) => { state.current = null; state.status = 'idle'; },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchUser.pending, (s) => { s.status = 'loading'; s.error = null; })
      .addCase(fetchUser.fulfilled, (s, a) => { s.status = 'succeeded'; s.current = a.payload; })
      .addCase(fetchUser.rejected, (s, a) => { s.status = 'failed'; s.error = a.error.message ?? 'Error'; });
  },
});

export const { setUser, clearUser } = userSlice.actions;
export default userSlice.reducer;
```
---
### 3. Jotai (atomic, derived, persisted atoms)
```typescript
// src/atoms/userAtoms.ts
import { atom } from 'jotai';
import { atomWithStorage } from 'jotai/utils';

export const userAtom = atom<User | null>(null);
export const isAuthAtom = atom((get) => !!get(userAtom));
export const themeAtom = atomWithStorage<'light'|'dark'>('theme', 'light');

// Async atom – suspends until data resolves
export const profileAtom = atom(async (get) => {
  const user = get(userAtom);
  if (!user) return null;
  const res = await fetch(`/api/users/${user.id}/profile`);
  return res.json();
});

// Write‑only action atom
export const logoutAtom = atom(null, (get, set) => {
  set(userAtom, null);
  set(themeAtom, 'light');
});
```
```tsx
function Profile() {
  const [user] = useAtom(userAtom);
  const [profile] = useAtom(profileAtom); // Suspense‑compatible
  const [, logout] = useAtom(logoutAtom);
  return (
    <Suspense fallback={<div>Loading…</div>}>
      <div>{user?.name}</div>
      <pre>{JSON.stringify(profile, null, 2)}</pre>
      <button onClick={logout}>Logout</button>
    </Suspense>
  );
}
```
---
### 4. TanStack Query (server state, caching, optimistic UI)
```typescript
// src/hooks/useUsers.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

export const userKeys = {
  all: ['users'] as const,
  list: (filters: UserFilters) => [...userKeys.all, 'list', filters] as const,
  detail: (id: string) => [...userKeys.all, 'detail', id] as const,
};

export function useUsers(filters: UserFilters) {
  return useQuery({
    queryKey: userKeys.list(filters),
    queryFn: () => fetchUsers(filters),
    staleTime: 5 * 60 * 1000, // 5 min
    gcTime: 30 * 60 * 1000,   // 30 min
  });
}

export function useUpdateUser() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: updateUser,
    onMutate: async (newUser) => {
      await qc.cancelQueries({ queryKey: userKeys.detail(newUser.id) });
      const previous = qc.getQueryData(userKeys.detail(newUser.id));
      qc.setQueryData(userKeys.detail(newUser.id), newUser);
      return { previous };
    },
    onError: (err, newUser, ctx) => {
      if (ctx?.previous) qc.setQueryData(userKeys.detail(newUser.id), ctx.previous);
    },
    onSettled: (data, err, vars) => {
      qc.invalidateQueries({ queryKey: userKeys.detail(vars.id) });
    },
  });
}
```
**Provider (app root)**
```tsx
// src/AppProviders.tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useState } from 'react';

export default function AppProviders({ children }: { children: React.ReactNode }) {
  const [client] = useState(() => new QueryClient({
    defaultOptions: { queries: { staleTime: 60_000, refetchOnWindowFocus: false } },
  }));
  return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
}
```
**Next.js App Router (SSR hydration)**
```tsx
// app/posts/page.tsx (Server Component)
import { QueryClient, dehydrate, HydrationBoundary } from '@tanstack/react-query';
import PostsList from './PostsList';

export default async function PostsPage() {
  const qc = new QueryClient();
  await qc.prefetchQuery({ queryKey: ['posts'], queryFn: fetchPosts });
  return (
    <HydrationBoundary state={dehydrate(qc)}>
      <PostsList />
    </HydrationBoundary>
  );
}
```
---

## Combining Client & Server State
```tsx
// src/store/uiStore.ts (Zustand for UI flags)
import { create } from 'zustand';
interface UIState { sidebarOpen: boolean; toggleSidebar: () => void; }
export const useUIStore = create<UIState>((set) => ({
  sidebarOpen: true,
  toggleSidebar: () => set((s) => ({ sidebarOpen: !s.sidebarOpen })),
}));
```
```tsx
// src/pages/Dashboard.tsx
function Dashboard() {
  const { sidebarOpen, toggleSidebar } = useUIStore();
  const { data: users, isLoading } = useUsers({ active: true });
  const { data: stats } = useStats(); // another TanStack Query hook

  if (isLoading) return <div>Loading…</div>;
  return (
    <div className={sidebarOpen ? 'with-sidebar' : ''}>
      <Sidebar open={sidebarOpen} onToggle={toggleSidebar} />
      <main>
        <StatsCards stats={stats} />
        <UserTable users={users} />
      </main>
    </div>
  );
}
```
Use Zustand (or Jotai) for UI‑only state that never comes from the server. Keep remote data in TanStack Query.

---

## Best Practices
### Do's
- **Co‑locate state**: define a store or atom close to the components that use it.
- **Use selectors** (`useStore(state => state.foo)`) to avoid whole‑store re‑renders.
- **Normalize server data** (flat objects, IDs) before storing in the cache.
- **Type everything**: declare interfaces for store slices, query results, and mutation payloads.
- **Separate concerns**: client UI state → Zustand/Jotai; server data → TanStack Query.
- **Persist only what is needed** (e.g., theme, auth token) using `persist` middleware or `atomWithStorage`.
- **Create query‑key factories** to prevent misspellings.
- **Wrap `useQuery` / `useMutation` in custom hooks**; UI components should only call the hook.

### Don'ts
- **Don’t globalize everything** – keep transient UI in component state.
- **Don’t duplicate server data** – let TanStack Query be the source of truth.
- **Don’t mutate state directly** – use Immer (Redux Toolkit) or immutable updates (`set(state => ({…}))`).
- **Don’t store derived values** – compute them with selectors, derived atoms, or `useMemo`.
- **Don’t mix paradigms** – pick one primary solution per category to avoid confusion.

---

## Migration Guide: Legacy Redux → Redux Toolkit
```diff
- // legacy action creator
- const ADD_TODO = 'ADD_TODO';
- export const addTodo = (text) => ({ type: ADD_TODO, payload: text });
-
- // legacy reducer
- function todos(state = [], action) {
-   switch (action.type) {
-     case ADD_TODO:
-       return [...state, { text: action.payload, completed: false }];
-     default:
-       return state;
-   }
- }
+ // RTK slice – Immer handles immutability
+ const todosSlice = createSlice({
+   name: 'todos',
+   initialState: [] as Todo[],
+   reducers: {
+     addTodo: (state, action: PayloadAction<string>) => {
+       state.push({ text: action.payload, completed: false });
+     },
+   },
+ });
+ export const { addTodo } = todosSlice.actions;
+ export default todosSlice.reducer;
```
Replace `combineReducers` with the `reducer` map in `configureStore`. Remove manual `store.subscribe` boilerplate; RTK includes devtools and thunk middleware by default.

---

## Checklist
- [ ] Identify state category (local, global, server, URL, form).
- [ ] Choose a primary library per category.
- [ ] Define TypeScript interfaces for state and API payloads.
- [ ] Implement store/atom with selective selectors.
- [ ] Wrap data fetching in a custom `useQuery` hook.
- [ ] Add mutation hooks with proper `onMutate`, `onError`, `onSettled` for optimistic updates.
- [ ] Configure a global `QueryClient` provider.
- [ ] Persist only necessary values (theme, auth token).
- [ ] Write unit tests for store logic and query hooks.
- [ ] Verify that components re‑render only on needed state changes (use React DevTools Profiler).
- [ ] For Next.js, ensure server‑side prefetch and hydration work without duplicate network calls.

---

## Resources
- Redux Toolkit Docs: https://redux-toolkit.js.org/
- Zustand GitHub: https://github.com/pmndrs/zustand
- Jotai Docs: https://jotai.org/
- TanStack Query Docs: https://tanstack.com/query

## Related skills

Load these when the task spans more than this skill.

- [`typescript`](../typescript/SKILL.md) — Provides expert guidance for TypeScript projects, covering setup analysis, migration, monorepo configuration,…
- [`frontend-development`](../frontend-development/SKILL.md) — Frontend Development skill for building modern React/Next.js applications with TypeScript, MUI, TanStack Query…
- [`nextjs`](../nextjs/SKILL.md) — Guidelines for building Next.js 14+ applications with the App Router. Includes component type decisions, data…
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — A concise guide to unit‑testing patterns for JavaScript/TypeScript (Jest) and Python (pytest). Use when writin…
- [`react-native-expo`](../react-native-expo/SKILL.md) — Provides production‑ready patterns for building React Native apps with Expo (architecture, navigation, state,…
- [`zod`](../zod/SKILL.md) — Provides concise guidance for defining, parsing, and integrating Zod schemas in TypeScript projects, including…
- [`javascript`](../javascript/SKILL.md) — A concise reference of core JavaScript concepts—primitives, type coercion, scope, closures, this, event loop,…
