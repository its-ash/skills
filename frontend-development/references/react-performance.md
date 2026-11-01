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
| | `rendering-conditional-render` | Use explicit ternary (`cond ? <A/> : <B/>`) instead of `&&`. With `&&`, a `0` value renders as a text node. |
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

## Rule Examples

### Waterfalls
```ts
// Check cheap sync conditions before you await remote data
if (!id) return null;
const flag = await getFlag("show-page");
if (!flag) return null;

// Await only in the branch that uses the result
if (mode === "guest") return renderGuest();
const user = await getUser(id);

// Partial dependencies: start early, await late
const userP = getUser(id);
const postsP = getPosts(id);
const profile = await getProfile(id);
if (profile.private) return null;
const [u, posts] = await Promise.all([userP, postsP]);

// Nested fetches: one Promise.all per list
const enriched = await Promise.all(
  users.map(async (u) => ({ ...u, posts: await getPostsFor(u.id) })),
);
```

Server Components fetch in parallel when you split sibling awaits into child components:
```tsx
// Incorrect: sequential awaits in one component
export default async function Page() {
  const user = await getUser();
  const cart = await getCart();
  return <View user={user} cart={cart} />;
}

// Correct: React runs the children in parallel
export default async function Page() {
  return (
    <View>
      <UserSection />
      <CartSection />
    </View>
  );
}
```
Put `<Suspense>` near the data. Reserve space (skeleton or `min-height`) to prevent layout shift when content streams in.

### Bundle
- Next.js 13.5+ `optimizePackageImports` rewrites barrel imports for listed packages. Use direct imports for other packages.
- Keep dynamic import paths static so the bundler can analyze them:
```ts
// Incorrect
const mod = await import(`./pages/${name}`);
// Correct
const mod = name === "home" ? await import("./pages/home") : await import("./pages/about");
```
- Load third-party scripts with `next/script` and `strategy="afterInteractive"` or `"lazyOnload"`.

### Server
Each `"use server"` function is a public endpoint. Authenticate and authorize inside the action:
```ts
"use server";
export async function deleteUser(formData: FormData) {
  const session = await getSession();
  if (!session?.user) throw new Error("Unauthorized");
  const targetId = String(formData.get("id"));
  if (session.user.role !== "admin" && session.user.id !== targetId) throw new Error("Forbidden");
  await db.user.delete({ where: { id: targetId } });
}
```
```ts
import { cache } from "react";
// One DB query per request, also when 3 Server Components call getUser("1")
export const getUser = cache(async (id: string) => db.user.findUnique({ where: { id } }));

// Static I/O at module scope runs once at module load
const fontData = readFileSync(fontPath);

// after() runs work when the response is sent (Next.js 15)
import { after } from "next/server";
export async function GET() {
  const data = await getData();
  after(() => logAnalytics(data));
  return Response.json(data);
}
```
- Do not keep mutable module-level state in RSC/SSR. All requests share it, so users race. Use request-scoped storage (`headers()`, `cookies()`, async context).
- When one Server Component sends the same data to many Client Components, the data serializes once per consumer. Lift the Client Component and pass `children`.
- For data that does not change per request (config, lookup tables), use an LRU cache or `unstable_cache`.

### Client
- Add scroll listeners with `{ passive: true }`. The listener then cannot call `preventDefault()`.
- Share one global listener through a hook. Do not add one listener per component.
- Put a `version` field in `localStorage` data. Increase it when the schema changes, then migrate or discard old data. Keep payloads small: the API is synchronous and blocks the main thread.

### Re-render
```tsx
// Read state used only in callbacks at call time
const handler = () => doSomething(useStore.getState().count);

// Subscribe to derived booleans: re-render only when emptiness changes
const hasItems = useStore((s) => s.cart.length > 0);

// Hoist default non-primitive props: a new [] each render breaks memo
const EMPTY: Item[] = [];
<List items={items ?? EMPTY} />

// Primitive effect deps, not new objects
useEffect(() => {}, [id, name]);

// Defer expensive renders
const deferredQuery = useDeferredValue(query);
const results = useMemo(() => expensiveSearch(deferredQuery), [deferredQuery]);
```
- Do not define components inside components. Each render makes a new type, so React unmounts the children.
- Do not memoize simple primitives: `useMemo(() => x + 1, [x])` is only overhead.
- Split hooks that have independent dependencies.
- Use `useRef` for values that change often but must not cause a render (timestamps, last key, accumulators).

### Rendering
```css
.row { content-visibility: auto; contain-intrinsic-size: auto 80px; }
```
```tsx
// Only on known-divergent leaf nodes, never on a tree with children
<time suppressHydrationWarning>{new Date().toLocaleString()}</time>

// React DOM resource hints
import { preload, preconnect } from "react-dom";
preload("/api/critical", { as: "fetch" });
preconnect("https://api.example.com");
```
- Animate a `<div>` wrapper around an SVG, not the SVG. The wrapper transform uses the GPU; an SVG transform causes paint.
- Use React 19 `<Activity mode="visible|hidden">` for tabs and accordions. It keeps state mounted and is cheaper than unmount/remount.
- For values needed before hydration (theme, locale), use an inline `<script>` that sets `document.documentElement.dataset.*`.
- Use `requestIdleCallback` for non-critical work.

### Advanced
- Values from `useEffectEvent` are stable. Do not add them to effect deps.
- For module-level singletons (telemetry, logger), use a module-scope flag, not `useEffect`.
```tsx
function useLatest<T>(value: T) {
  const ref = useRef(value);
  ref.current = value;
  return ref;
}
```

### React Compiler
When the project uses React Compiler, the compiler memoizes automatically. Treat the manual `rerender-*` memoization rules as review-only and remove unnecessary `useMemo`/`useCallback`.

### Web Vitals mapping
| Metric | Most relevant categories |
|---|---|
| LCP | Waterfalls, Bundle Size, Resource Hints |
| INP | Re-render, Rendering, JavaScript |
| CLS | Rendering (Suspense placement, image dimensions) |
| TBT | Bundle Size, JavaScript, Defer Third-Party |

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
- **Interaction to Next Paint (INP)** – response latency of user interactions (replaced FID).
- **Cumulative Layout Shift (CLS)** – visual stability.
- **Bundle size** – size of the initial JavaScript payload.
- **Server response time (TTFB)** – time to first byte for SSR pages.
- **Component render time** – measured in the Profiler flamegraph.

## Resources
- [React Docs – Optimizing Performance](https://react.dev/learn/optimizing-performance)
- [Next.js Docs – Dynamic Imports](https://nextjs.org/docs/app/building-your-application/optimizing/dynamic-import)
- [SWR – React Hooks for Data Fetching](https://swr.vercel.app/)
- [Vercel Blog – Bundle Optimization](https://vercel.com/blog/how-we-optimized-package-imports-in-next-js)
- [Vercel Labs react-best-practices (MIT)](https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices) – source of the rule catalog
- [better‑all Library](https://github.com/shuding/better-all)
- [node‑lru‑cache](https://github.com/isaacs/node-lru-cache)
