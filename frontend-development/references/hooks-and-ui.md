# Hooks, Errors, Animation, Forms, Accessibility

## State placement
| State | Tool |
|---|---|
| Server data | TanStack Query (`useSuspenseQuery` inside `<Suspense>`, cache-first) |
| Shared mutable client state | Context + `useReducer` |
| Isolated logic | Custom hook (`useToggle`, `useDebounce`) |

## useDebounce
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

## Fallback async hook (no library allowed)
Prefer TanStack Query. Use this only when you cannot add a library.
Keep `fetcher` and `opts` in refs so `refetch` stays stable when callers pass inline functions or object literals. Without refs, each render makes a new `refetch`, the effect runs again after each state update, and the fetch loops forever.
```tsx
export function useQuery<T>(key: string, fetcher: () => Promise<T>, opts?: { onSuccess?: (d: T) => void; onError?: (e: Error) => void; enabled?: boolean }) {
  const [data, setData] = useState<T | null>(null);
  const [error, setError] = useState<Error | null>(null);
  const [loading, setLoading] = useState(false);
  const fetcherRef = useRef(fetcher);
  const optsRef = useRef(opts);
  useEffect(() => { fetcherRef.current = fetcher; optsRef.current = opts; });

  const refetch = useCallback(async () => {
    setLoading(true); setError(null);
    try {
      const res = await fetcherRef.current();
      setData(res); optsRef.current?.onSuccess?.(res);
    } catch (e) {
      const err = e as Error;
      setError(err); optsRef.current?.onError?.(err);
    } finally { setLoading(false); }
  }, []);

  const enabled = opts?.enabled !== false;
  useEffect(() => { if (enabled) refetch(); }, [key, enabled, refetch]);
  return { data, error, loading, refetch };
}
```

## Error boundary (wrap the app)
Placement and recovery rules: [react-patterns.md](react-patterns.md#7-error-handling).
```tsx
export class ErrorBoundary extends React.Component<{ children: React.ReactNode }, { hasError: boolean; error: Error | null }> {
  state = { hasError: false, error: null };
  static getDerivedStateFromError(error: Error) { return { hasError: true, error }; }
  componentDidCatch(error: Error, info: React.ErrorInfo) { console.error(error, info); }
  render() {
    return this.state.hasError ? (
      <div className="error-fallback">
        <h2>Something went wrong</h2>
        <p>{this.state.error?.message}</p>
        <button onClick={() => this.setState({ hasError: false, error: null })}>Try again</button>
      </div>
    ) : this.props.children;
  }
}
```

## Animation (Framer Motion)
```tsx
<AnimatePresence>
  {items.map(i => (
    <motion.div key={i} initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -20 }} transition={{ duration: 0.3 }}>{i}</motion.div>
  ))}
</AnimatePresence>
```
- Modal: overlay animates `opacity`; panel animates `opacity`, `scale: 0.9 → 1`, `y: 20 → 0`; both in one `<AnimatePresence>`.

## Forms
- Validate on submit. Keep errors in `Record<field, string>`; show each next to its field.
- Trim strings before the empty check. Enforce max lengths.
- Wrap submit in `try/catch`; show the failure to the user.
- Complex forms: React Hook Form or TanStack Form + Zod ([zod](../../typescript/references/zod.md)).

## Accessibility
- Keyboard: arrow keys, Enter, Escape on interactive widgets.
- Dialog focus: save previous focus, move focus into the modal, restore on close.
- ARIA: `role="dialog"`, `aria-modal="true"`, `role="combobox"`.
