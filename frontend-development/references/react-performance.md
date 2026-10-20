# React Performance Optimization

Provide a concise set of rules, patterns, and a profiling workflow to make React and Next.js applications fast and responsive.

## When to Use
- Writing a new component or Next.js page.
- Refactoring existing UI for speed.
- Reviewing code for performance regressions.
- Adding data‑fetching logic (client or server).
- Debugging slow renders, long load times, or large bundles.

## Workflow
1. **Profile baseline** – Open React DevTools Profiler or browser performance tab. Record the interaction that feels slow.
2. **Identify hotspots** – Look for components > 16 ms or frequent re‑renders.
3. **Classify the issue** – Is it async waterfall, bundle size, server‑side fetch, re‑render, or rendering cost?
4. **Apply the most critical rule** from the relevant category.
5. **Re‑measure** – Record again, compare flamegraphs and key metrics.
6. **Iterate** – Continue until the target metric improves.

## Critical Categories & Rules
| Category | Rule | Action |
|---|---|---|
| **Eliminating Waterfalls** (CRITICAL) | `async-defer-await` | Move `await` into the branch where the result is used. |
| | `async-parallel` | Run independent promises with `Promise.all`. |
| | `async-dependencies` | Use `better-all` (or similar) to start dependent promises early and await later. |
| | `async-api-routes` | Start async work at the top of API routes, await just before the response. |
| | `async-suspense-boundaries` | Wrap data‑heavy sections in `<Suspense>` to stream content. |
| **Bundle Size Optimization** (CRITICAL) | `bundle-barrel-imports` | Import directly from source files; avoid barrel imports that pull the whole library. |
| | `bundle-dynamic-imports` | Use `next/dynamic` or `import()` for heavy components. |
| | `bundle-defer-third-party` | Load analytics, logging, or other non‑essential scripts after hydration. |
| | `bundle-conditional` | Load a module only when a feature flag or user action enables it. |
| | `bundle-preload` | Preload resources on hover/focus to improve perceived speed. |
| **Server‑Side Performance** (HIGH) | `server-cache-react` | Wrap per‑request data fetches with `React.cache()` for deduplication. |
| | `server-cache-lru` | Use an LRU cache (e.g., `node-lru-cache`) for cross‑request caching. |
| | `server-serialization` | Send only the data needed by the client component; avoid large objects. |
| | `server-parallel-fetching` | Compose components so their data fetches run in parallel. |
| | `server-after-nonblocking` | Use `after()` to run non‑blocking work after the response is sent. |
| **Client‑Side Data Fetching** (MEDIUM‑HIGH) | `client-swr-dedup` | Use **SWR** for automatic request deduplication and caching. |
| | `client-event-listeners` | Attach global listeners once; reuse the same function reference. |
| **Re‑render Optimization** (MEDIUM) | `rerender-defer-reads` | Subscribe only to state needed for the current render; read other state inside callbacks. |
| | `rerender-memo` | Extract expensive sub‑trees into `memo`‑wrapped components. |
| | `rerender-dependencies` | Keep effect dependency arrays primitive (strings, numbers). |
| | `rerender-derived-state` | Store derived booleans instead of raw values to avoid unnecessary updates. |
| | `rerender-functional-setstate` | Use functional `setState` when the new value depends on the previous one. |
| | `rerender-lazy-state-init` | Pass a function to `useState` for expensive initial values. |
| | `rerender-transitions` | Wrap non‑urgent UI updates in `startTransition`. |
| **Rendering Performance** (MEDIUM) | `rendering-content-visibility` | Apply `content-visibility: auto` to long lists. |
| | `rendering-hoist-jsx` | Move static JSX outside the component function. |
| | `rendering-svg-precision` | Reduce coordinate precision in SVG paths. |
| | `rendering-hydration-no-flicker` | Inline critical data for client‑only components to avoid hydration flash. |
| | `rendering-conditional-render` | Use explicit ternary (`cond ? <A/> : <B/>`) instead of `&&` for clearer rendering paths. |
| **JavaScript Performance** (LOW‑MEDIUM) | `js-batch-dom-css` | Batch DOM or style changes; use class toggles instead of many style writes. |
| | `js-index-maps` | Build a `Map` for repeated lookups instead of `Array.find`. |
| | `js-cache-property-access` | Cache object properties in a local variable inside loops. |
| | `js-cache-function-results` | Store expensive function results in a module‑level `Map`. |
| | `js-cache-storage` | Read `localStorage`/`sessionStorage` once and reuse the value. |
| | `js-combine-iterations` | Merge multiple `filter`/`map` passes into a single loop. |
| | `js-early-exit` | Return early from functions to avoid unnecessary work. |
| | `js-hoist-regexp` | Define `RegExp` objects outside render loops. |
| | `js-min-max-loop` | Use a simple loop to find min/max instead of sorting. |
| | `js-set-map-lookups` | Prefer `Set`/`Map` for O(1) existence checks. |
| | `js-tosorted-immutable` | Use `Array.prototype.toSorted` for immutable sorting. |
| **Advanced Patterns** (LOW) | `advanced-event-handler-refs` | Store event handlers in a `ref` to avoid re‑creation on each render. |
| | `advanced-use-latest` | Use a custom `useLatest` hook to keep a stable reference to the latest callback. |

## Common Code Patterns
### Parallel data fetching
```tsx
const [user, posts, comments] = await Promise.all([
  fetchUser(),
  fetchPosts(),
  fetchComments()
]);
```
### Direct imports (avoid barrel)
```tsx
// ❌ pulls whole library
import { Check } from 'lucide-react';
// ✅ pulls only needed icon
import Check from 'lucide-react/dist/esm/icons/check';
```
### Dynamic component loading (Next.js)
```tsx
import dynamic from 'next/dynamic';

const MonacoEditor = dynamic(() => import('./monaco-editor'), { ssr: false });
```
### Isolate ticking state
```tsx
function Clock() {
  const [tick, setTick] = useState(0);
  useEffect(() => {
    const id = setInterval(() => setTick(t => t + 1), 1000);
    return () => clearInterval(id);
  }, []);
  return <span>{tick}s</span>;
}

function Dashboard({ items }) {
  return (
    <>
      <Clock />
      <ExpensiveList items={items} />
    </>
  );
}
```
### Stabilize callbacks with `useCallback` + `memo`
```tsx
const Row = memo(({ item, onClick }) => (
  <li onClick={() => onClick(item.id)}>{item.name}</li>
));

function List({ items }) {
  const handleClick = useCallback(id => console.log(id), []);
  return items.map(item => (
    <Row key={item.id} item={item} onClick={handleClick} />
  ));
}
```
### Memoize derived data
```tsx
function Summary({ orders }) {
  const total = useMemo(() =>
    orders.reduce((sum, o) => sum + o.amount, 0),
    [orders]
  );
  return <p>Total: {total}</p>;
}
```

## Checklist
- [ ] Profile baseline with React DevTools Profiler.
- [ ] Verify async operations are parallelized (`Promise.all`).
- [ ] Replace barrel imports with direct paths.
- [ ] Lazy‑load heavy components via `next/dynamic` or `import()`. 
- [ ] Add `React.cache` or LRU cache for server data.
- [ ] Use SWR for client data fetching and deduplication.
- [ ] Memoize pure sub‑trees (`memo`).
- [ ] Stabilize callbacks with `useCallback` and values with `useMemo`.
- [ ] Move ticking or rapidly changing state into child components.
- [ ] Apply `content-visibility: auto` to long lists.
- [ ] Batch DOM or CSS changes; hoist RegExp and static objects.
- [ ] Re‑measure and confirm improvement.

## Common Pitfalls to Avoid
- Importing whole libraries through barrel files.
- Sequential `await` for independent requests.
- Re‑rendering large lists on every timer tick.
- Creating new handler functions on each render.
- Performing heavy calculations directly in render.
- Loading analytics or tracking scripts in the critical path.
- Mutating arrays with `.sort()`; prefer immutable `toSorted`.
- Defining `RegExp` or large objects inside component bodies.

## Metrics to Track
- **Time to Interactive (TTI)** – when the page becomes fully usable.
- **Largest Contentful Paint (LCP)** – when the main visual element appears.
- **First Input Delay (FID)** – latency of the first user interaction.
- **Cumulative Layout Shift (CLS)** – visual stability.
- **Bundle size** – size of the initial JavaScript payload.
- **Server response time (TTFB)** – time to first byte for SSR pages.
- **Component render time** – measured in the Profiler flamegraph.

## Resources
- [React Docs – Optimizing Performance](https://react.dev/learn/optimizing-performance)
- [Next.js Docs – Dynamic Imports](https://nextjs.org/docs/app/building-your-application/optimizing/dynamic-import)
- [SWR – React Hooks for Data Fetching](https://swr.vercel.app/)
- [Vercel Blog – Bundle Optimization](https://vercel.com/blog/how-we-optimized-package-imports-in-next-js)
- [better‑all Library](https://github.com/shuding/better-all)
- [node‑lru‑cache](https://github.com/isaacs/node-lru-cache)
