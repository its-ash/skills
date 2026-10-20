# React Patterns

Guidelines and code snippets for building maintainable, type‑safe, and performant React applications. Use this skill when writing new components, custom hooks, routing, server components, or when you need to decide how to handle loading, error, and UI states.

---

## When to use
- Creating or refactoring React components with TypeScript.
- Designing custom hooks or deciding where to place state.
- Using React 19 features (useActionState, use(), server components).
- Implementing UI patterns for loading, error, empty, and button states.
- Adding type‑safe routing with TanStack Router or React Router.
- Optimising render performance or avoiding unnecessary effects.

---

## 1. Component Design Principles
- **One responsibility per component** – keep it small and focused.
- **Props down, events up** – pass data via props, notify parent via callbacks.
- **Composition over inheritance** – use children, context, or render props.
- **Component Types**
  | Type | Typical Use | State |
  |------|-------------|-------|
  | Server | Data fetching, static rendering | None |
  | Client | Interactivity, UI events | `useState`, effects |
  | Presentational | Pure UI, no logic | Props only |
  | Container | Data fetching, heavy state | `useState`, `useReducer`, context |

---

## 2. Hook Patterns
### When to extract a custom hook
| Pattern | Extract when |
|--------|--------------|
| `useLocalStorage` | Same storage logic appears in multiple components |
| `useDebounce` | Multiple debounced values |
| `useFetch` | Repeated data‑fetching logic |
| `useForm` | Complex form state management |

### Hook Rules
- Call hooks only at the top level of a component or another hook.
- Preserve the same call order on every render.
- Name custom hooks with a `use` prefix.
- Clean up side effects in the return function of `useEffect`.
- Type custom hooks explicitly; return tuples with `as const`.

**Example – Typed toggle hook**
```tsx
function useToggle(initial = false) {
  const [value, setValue] = useState(initial);
  const toggle = () => setValue(v => !v);
  return [value, toggle] as const; // tuple typing
}
```

---

## 3. State Management Selection
| Complexity | Recommended solution |
|------------|----------------------|
| Simple local | `useState` or `useReducer` |
| Shared between few components | React Context |
| Server‑derived data | React Query, SWR |
| Complex global | Zustand, Redux Toolkit |

### Placement guide
| Scope | Where to store |
|------|----------------|
| Single component | `useState` |
| Parent‑child chain | Lift state to the nearest common ancestor |
| Sub‑tree | Context provider |
| Entire app | Global store (Zustand/RTK) |

---

## 4. React 19 Updates
- **`useActionState`** – replaces `useFormState` for form submissions.
- **`use()`** – unwraps a promise or async resource inside render; component suspends until resolved.
- **`useOptimistic`** – helper for optimistic UI updates (similar to React Query’s `optimisticUpdates`).
- **Ref as regular prop** – `forwardRef` is deprecated. Pass `ref` like any other prop.

**Ref‑as‑prop example**
```tsx
type ButtonProps = {
  ref?: React.Ref<HTMLButtonElement>;
} & React.ComponentPropsWithoutRef<'button'>;

function Button({ ref, children, ...rest }: ButtonProps) {
  return (
    <button ref={ref} {...rest}>
      {children}
    </button>
  );
}
```

---

## 5. Composition Patterns
### Compound Components
- Parent creates a Context.
- Children consume the Context.
- Allows flexible slot‑based composition (e.g., Tabs, Accordion).

### Render Props vs Hooks
| Need | Prefer |
|------|--------|
| Reusable logic | Custom hook |
| Render flexibility | Render prop |
| Cross‑cutting concerns | Higher‑order component |

---

## 6. Performance Principles
| Signal | Action |
|--------|--------|
| Slow renders observed in DevTools | Profile first, then optimise |
| Large lists | Use virtualization (e.g., `react-window`) |
| Expensive calculation | Wrap with `useMemo` |
| Stable callbacks needed | Wrap with `useCallback` |

**Optimization order**
1. Verify the slowdown with React Profiler.
2. Identify the bottleneck.
3. Apply the smallest targeted fix.
4. Re‑measure.

---

## 7. Error Handling
### Error Boundary Placement
| Scope | Where to place |
|------|----------------|
| Whole app | Root component |
| Feature / route | Around the route component |
| Individual risky component | Directly wrap it |

### Recovery pattern
- Show a fallback UI.
- Log the error (e.g., to Sentry).
- Offer a retry button.
- Preserve any user input that is still valid.

**ErrorState component**
```tsx
interface ErrorStateProps {
  error: Error;
  onRetry?: () => void;
  title?: string;
}

const ErrorState = ({ error, onRetry, title }: ErrorStateProps) => (
  <div className="error-state">
    <h3>{title ?? 'Something went wrong'}</h3>
    <p>{error.message}</p>
    {onRetry && <button onClick={onRetry}>Try again</button>}
  </div>
);
```

---

## 8. TypeScript Patterns
### Props typing
```tsx
type ButtonProps = {
  variant: 'primary' | 'secondary';
} & React.ComponentPropsWithoutRef<'button'>;
```
- Use `React.ComponentPropsWithoutRef` to inherit native attributes.
- For children, use `React.ReactNode`.
- For a single element prop, use `React.ReactElement`.
- Discriminated unions for variant‑specific props.

### Generic components
```tsx
type Column<T> = {
  key: keyof T;
  header: string;
  render?: (value: T[keyof T], item: T) => React.ReactNode;
};

type TableProps<T> = {
  data: T[];
  columns: Column<T>[];
  keyExtractor: (item: T) => string | number;
};

function Table<T>({ data, columns, keyExtractor }: TableProps<T>) {
  return (
    <table>
      <thead>
        <tr>{columns.map(c => <th key={String(c.key)}>{c.header}</th>)}</tr>
      </thead>
      <tbody>
        {data.map(item => (
          <tr key={keyExtractor(item)}>
            {columns.map(c => (
              <td key={String(c.key)}>
                {c.render ? c.render(item[c.key], item) : String(item[c.key])}
              </td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
}
```
- Constrain generics with `extends` when a property is required (e.g., `T extends { id: string | number }`).

### Event handler typing
```tsx
function handleClick(e: React.MouseEvent<HTMLButtonElement>) {
  e.currentTarget.disabled = true;
}
function handleChange(e: React.ChangeEvent<HTMLInputElement>) {
  console.log(e.target.value);
}
```
- Never use `any` for events; always pick the specific React event type.

---

## 9. UI State Patterns (Loading, Error, Empty, Buttons)
### Loading – "Golden Rule"
> Show a loading indicator **only** when there is no data to display.
```tsx
const { data, loading, error } = useGetItemsQuery();

if (error) return <ErrorState error={error} onRetry={refetch} />;
if (loading && !data) return <LoadingState />;
if (!data?.items.length) return <EmptyState />;
return <ItemList items={data.items} />;
```
- Use skeletons for known shapes; spinners for unknown or modal actions.

### Button loading & disable
```tsx
<Button
  onClick={handleSubmit}
  isLoading={isSubmitting}
  disabled={!isValid || isSubmitting}
>
  Submit
</Button>
```
- Disable triggers while an async operation is pending to prevent double clicks.

### Empty state requirement
Every list component must render an explicit empty state.
```tsx
<FlatList
  data={items}
  ListEmptyComponent={<EmptyState title="No items yet" />}
/>
```
- Provide contextual messaging (search‑no‑results vs. brand‑new collection).

---

## 10. Server Components & Server Actions (React 19)
- Server components can be `async` and return JSX directly.
- Use `use server` directive for server‑only functions (mutations).
- Pass promises from server to client and unwrap with `use()`.
```tsx
// Server component
export default async function UserPage({ params }: { params: { id: string } }) {
  const user = await fetchUser(params.id);
  return <div>{user.name}</div>;
}

// Server action
'use server';
export async function updateUser(id: string, formData: FormData) {
  await db.user.update({ where: { id }, data: { ...formData } });
  revalidatePath(`/users/${id}`);
}

// Client component using the action
'use client';
import { useActionState } from 'react';
import { updateUser } from '@/actions/user';

function UserForm({ userId }: { userId: string }) {
  const [state, formAction, isPending] = useActionState(
    (prev, fd) => updateUser(userId, fd),
    {}
  );
  return <form action={formAction}>/* fields */</form>;
}
```
- Never `await` a promise that will be passed to `use()`; let the server component hand it off.

---

## 11. Type‑Safe Routing
### TanStack Router (v2+)
```tsx
import { createRoute } from '@tanstack/react-router';
import { z } from 'zod';

const userRoute = createRoute({
  path: '/users/$userId',
  component: UserPage,
  loader: async ({ params }) => ({ user: await fetchUser(params.userId) }),
  validateSearch: z.object({
    tab: z.enum(['profile', 'settings']).optional(),
    page: z.number().int().positive().default(1),
  }),
});

function UserPage() {
  const { user } = useLoaderData({ from: userRoute.id });
  const { tab, page } = useSearch({ from: userRoute.id });
  const { userId } = useParams({ from: userRoute.id });
  // user, tab, page, userId are fully typed
}
```
### React Router v7 (Framework Mode)
```tsx
import type { Route } from './+types/user';

export async function loader({ params }: Route.LoaderArgs) {
  return { user: await fetchUser(params.userId) };
}

export default function UserPage({ loaderData }: Route.ComponentProps) {
  const { user } = loaderData; // typed from loader
  return <h1>{user.name}</h1>;
}
```
- Keep server and client code in separate files (`.server.tsx` vs `.client.tsx`) to avoid mixing contexts.

---

## 12. useEffect Best Practices
### When you **don’t** need an effect
- Deriving data for render – compute directly or use `useMemo`.
- Resetting state on prop change – use the `key` prop on the component.
- Responding to user events – handle in the event callback.
- Notifying parent of a change – call the parent callback directly.

### When you **do** need an effect
- Synchronising with external APIs, non‑React widgets, or browser APIs.
- Subscribing to external stores – prefer `useSyncExternalStore` when possible.
- Running analytics or logging on mount/unmount.
- Fetching data that requires cleanup (abort controller, unsubscribe).

### Decision tree (quick reference)
```
Need to respond to something?
├─ User interaction → use event handler
├─ Component appears on screen → useEffect (external sync, analytics)
├─ Props/state change → calculate during render (or useMemo)
└─ Reset state on prop change → use key prop
```
### Common anti‑patterns
- Storing derived state in `useState` + `useEffect`.
- Using `useEffect` for every expensive calculation.
- Forgetting cleanup for subscriptions or timers.
- Triggering state updates inside an effect without proper dependency list.

---

## 13. Anti‑Patterns Summary
| ❌ Do not | ✅ Do |
|----------|------|
| Prop drill deep levels | Use Context or a state‑management library |
| Giant monolithic components | Split into small, focused components |
| Use `useEffect` for simple derived values | Compute directly or with `useMemo` |
| Premature optimisation | Profile first, then optimise |
| Use array index as `key` in lists | Use stable unique IDs |
| Forward ref in React 19 | Pass `ref` as a normal prop |
| Swallow errors silently | Surface errors with UI and logging |
| Mix server and client code in the same file | Separate `.server.tsx` and `.client.tsx` |

---

## 14. Checklist for a New Component
- [ ] Component follows single‑responsibility principle.
- [ ] Props are typed with `ComponentPropsWithoutRef` and `ReactNode` for children.
- [ ] State placed at the correct scope (local, context, or global store).
- [ ] Custom hooks extracted when logic is reused.
- [ ] All async UI states are covered:
  - Loading indicator only when no data.
  - Error state displayed with retry option.
  - Empty state for collections.
  - Buttons disabled and show loading during operations.
- [ ] Error boundaries added at appropriate level.
- [ ] Performance: use `useMemo`/`useCallback` only after profiling.
- [ ] No unnecessary `useEffect`; alternatives used where possible.
- [ ] React 19 patterns applied (ref as prop, `useActionState`, `use()`).
- [ ] Server components kept separate from client components.
- [ ] Routing is type‑safe (TanStack or React Router).
- [ ] Tests cover unit (hooks), integration (component behavior), and E2E (user flows).

---

## 15. References (official docs & community)
- React Docs – Hooks, Server Components, `use()`.
- React Query / SWR – Server state handling.
- TanStack Router – Type‑safe route definitions.
- React Router v7 – Framework mode loaders/actions.
- Zustand / Redux Toolkit – Global state.
- React Profiler – Performance diagnostics.
