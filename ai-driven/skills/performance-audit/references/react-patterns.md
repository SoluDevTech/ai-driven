# React Performance Patterns Reference

Scan for every category below. Each has detection signals and examples.

---

## 1. Unnecessary Re-renders

**Signals**:
- Component receives an object/array prop created inline (`<Comp style={{ color: 'red' }} />`)
- Parent re-renders pass new function references as props without `useCallback`
- Context value is a new object literal every render

```tsx
// ❌ New object every render → child always re-renders
<UserCard config={{ theme: 'dark', size: 'lg' }} />

// ✅
const config = useMemo(() => ({ theme: 'dark', size: 'lg' }), []);
<UserCard config={config} />
```

---

## 2. Missing `React.memo`

**Signals**:
- Pure functional component (same props → same output) without `React.memo`
- Child component re-renders whenever parent state changes, even with unchanged props
- Large list items rendered without memoization

```tsx
// ❌
const ListItem = ({ item }) => <div>{item.name}</div>;

// ✅
const ListItem = React.memo(({ item }) => <div>{item.name}</div>);
```

---

## 3. Missing `useMemo` on Expensive Computations

**Signals**:
- Heavy computation (sort, filter, reduce, map on large arrays) directly in render body
- Derived state recomputed on every render
- Complex object construction without memoization

```tsx
// ❌ Re-sorts on every render
const sorted = items.sort((a, b) => a.name.localeCompare(b.name));

// ✅
const sorted = useMemo(
  () => [...items].sort((a, b) => a.name.localeCompare(b.name)),
  [items]
);
```

---

## 4. Missing `useCallback` on Event Handlers

**Signals**:
- Event handler function defined inline inside component body
- Handler passed as prop to memoized child, breaking memoization
- Handler used as `useEffect` dependency — causes infinite loops

```tsx
// ❌ New function reference every render
const handleClick = () => dispatch(action);

// ✅
const handleClick = useCallback(() => dispatch(action), [dispatch, action]);
```

---

## 5. `useEffect` Anti-Patterns

**Signals**:
- Missing dependency array → runs every render
- Missing cleanup → subscriptions/timers leak across unmounts
- Infinite loop: state update inside effect without proper deps
- `async` function directly as effect callback (must wrap)
- Fetching data without abort/cleanup for stale responses

```tsx
// ❌ Missing cleanup
useEffect(() => {
  const id = setInterval(tick, 1000);
  // no return
}, []);

// ✅
useEffect(() => {
  const id = setInterval(tick, 1000);
  return () => clearInterval(id);
}, []);
```

```tsx
// ❌ async directly
useEffect(async () => {
  const data = await fetch(url);
}, [url]);

// ✅
useEffect(() => {
  let cancelled = false;
  (async () => {
    const data = await fetch(url);
    if (!cancelled) setData(data);
  })();
  return () => { cancelled = true; };
}, [url]);
```

---

## 6. Rendering Large Lists Without Virtualization

**Signals**:
- `.map()` rendering 100+ items directly into the DOM
- No `react-window`, `react-virtual`, or TanStack Virtual

```tsx
// ❌ Renders all 10,000 rows
{items.map(item => <Row key={item.id} item={item} />)}

// ✅ Render only visible rows
import { FixedSizeList } from 'react-window';
<FixedSizeList height={600} itemCount={items.length} itemSize={40}>
  {({ index, style }) => <Row style={style} item={items[index]} />}
</FixedSizeList>
```

---

## 7. Context Re-render Storm

**Signals**:
- Single large Context holding all global state
- Any state update triggers re-render of all consumers
- Multiple unrelated values in one Context

```tsx
// ❌ Any change re-renders all consumers
const AppContext = createContext({ user, cart, settings, theme });

// ✅ Split by domain + memoize value
const UserContext = createContext(null);
const CartContext = createContext(null);

// And in provider:
const value = useMemo(() => ({ user, setUser }), [user]);
```

---

## 8. State Colocation Issues

**Signals**:
- State lifted unnecessarily high, triggering broad re-renders
- Should be local state but lives in a global store
- Form state managed in parent instead of form component

---

## 9. Unkeyed or Badly Keyed Lists

**Signals**:
- Missing `key` prop on list items
- `key={index}` used with reorderable/mutable lists — causes reconciliation bugs and re-mounts

```tsx
// ❌ Index key on mutable list
{items.map((item, i) => <Item key={i} {...item} />)}

// ✅
{items.map(item => <Item key={item.id} {...item} />)}
```

---

## 10. Props Drilling Causing Over-Rendering

**Signals**:
- Prop threaded through 3+ component levels
- Intermediate components re-render solely to pass props down
- Better served by Context, Zustand, or composition

---

## 11. Images Without Lazy Loading / Optimization

**Signals**:
- `<img>` without `loading="lazy"` below the fold
- Large uncompressed images without `next/image` or `srcSet`
- No explicit `width`/`height` → causes layout shift (CLS)

```tsx
// ❌
<img src="/hero.png" />

// ✅ (vanilla)
<img src="/hero.png" loading="lazy" width={800} height={600} />
// ✅ (Next.js)
<Image src="/hero.png" width={800} height={600} alt="hero" />
```

---

## 12. Bundle Size Issues

**Signals**:
- Full library import when tree-shakeable: `import _ from 'lodash'` vs `import debounce from 'lodash/debounce'`
- `moment.js` still in use (replace with `date-fns` or `dayjs`)
- Large icon library imported entirely
- No dynamic imports for routes or heavy components

```tsx
// ❌ Loads entire lodash (~70kb)
import _ from 'lodash';

// ✅ Tree-shakeable
import debounce from 'lodash/debounce';

// ✅ Dynamic import for code splitting
const HeavyChart = lazy(() => import('./HeavyChart'));
```

---

## 13. Inline Object/Array Creation in JSX

**Signals**:
- Object/array literal directly in JSX prop
- New array created inline for `className` or `style`

```tsx
// ❌ Creates new array/object every render
<Component items={[1, 2, 3]} style={{ margin: 0 }} />

// ✅
const ITEMS = [1, 2, 3];
const STYLE = { margin: 0 };
<Component items={ITEMS} style={STYLE} />
```

---

## 14. Waterfall Data Fetching

**Signals**:
- Sequential `await fetch()` in component where parallel fetching would work
- Multiple `useEffect` hooks that trigger chained fetches
- No `Promise.all` or parallel query hooks (React Query `useQueries`)

```tsx
// ❌ Sequential — slow
const user = await fetchUser(id);
const posts = await fetchPosts(user.id);

// ✅ Parallel where possible
const [user, posts] = await Promise.all([fetchUser(id), fetchPosts(id)]);
```

---

## 15. Derived State Anti-Patterns

**Signals**:
- `useEffect` used to sync one state to another derived state — causes extra render cycle
- Derived value stored in state when it can be computed in render

```tsx
// ❌ Extra render + risk of stale state
const [doubled, setDoubled] = useState(count * 2);
useEffect(() => setDoubled(count * 2), [count]);

// ✅ Compute inline (or useMemo if expensive)
const doubled = count * 2;
```

---

## 16. Expensive Calculations in Render Without `useMemo`

**Signals**:
- Fibonacci, sorting, parsing, regex matching in render body without memoization
- JSON.parse / JSON.stringify in render

---

## 17. Component Defined Inside Component

**Signals**:
- Component function defined inside another component's render — creates a new component type every render, causing full unmount/remount

```tsx
// ❌ Inner re-defines on every render
function Parent() {
  const Child = () => <div>hi</div>; // ← NEW type every render
  return <Child />;
}

// ✅ Define outside
const Child = () => <div>hi</div>;
function Parent() {
  return <Child />;
}
```

---

## 18. Overuse of Global State for Local Concerns

**Signals**:
- Toast/modal open state in Redux/Zustand
- Form field values in global store
- Component-specific UI state shared globally

---

## 19. Missing Suspense / Error Boundaries

**Signals**:
- No `<Suspense>` around lazy-loaded components
- No error boundary → single component crash kills entire tree
- Waterfalling promises without Suspense-compatible data fetching

---

## 20. Server Component Leakage (Next.js App Router)

**Signals**:
- `"use client"` on a component that has no interactivity — pushes it to client bundle unnecessarily
- Large data-fetching component marked `"use client"` when it could be a Server Component
- Prop drilling from Server to Client component includes non-serializable values

---

## Profiling Tools to Recommend

- **React DevTools Profiler** — record render counts, flame graph per commit
- **React DevTools "Highlight updates"** — visualize which components re-render
- **why-did-you-render** library — console warnings on avoidable re-renders
- **Lighthouse** — bundle size, LCP, TBT, CLS
- **webpack-bundle-analyzer / vite-bundle-visualizer** — bundle composition
- **Performance tab (Chrome)** — main thread blocking, layout shifts

---

## Caching Strategies

### Server State Caching (React Query / SWR / RTK Query)

**When to cache**: Any data fetched from an API that doesn't need to be real-time. Applies to virtually all GET requests.

**Strong cache candidates**:
- Reference data (categories, config, user profile)
- Paginated lists with low mutation rate
- Detail views that are expensive to fetch
- Data shared across multiple components (single fetch, multiple consumers)

**React Query — canonical setup**:
```tsx
// Fetching with automatic cache + background revalidation
const { data: products } = useQuery({
  queryKey: ['products', { categoryId }],    // cache key — include all params
  queryFn: () => fetchProducts(categoryId),
  staleTime: 5 * 60 * 1000,                  // 5 min — no refetch while fresh
  gcTime: 10 * 60 * 1000,                    // 10 min — keep in memory after unmount
});

// Invalidation on mutation:
const { mutate: createProduct } = useMutation({
  mutationFn: (data) => api.post('/products', data),
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['products'] }); // bust all product queries
  },
});
```

**SWR equivalent**:
```tsx
const { data } = useSWR(`/products?category=${categoryId}`, fetcher, {
  dedupingInterval: 60_000,   // dedupe calls within 1 min
  revalidateOnFocus: false,   // don't refetch on tab focus (good for stable data)
});

// Invalidation:
mutate(`/products?category=${categoryId}`);  // bust specific key
mutate(key => key.startsWith('/products'), undefined, { revalidate: true }); // bust all /products
```

---

### Query Key Design

Bad keys cause stale data or redundant fetches. Always include all variables that affect the result:

```tsx
// ❌ Missing params — same key for different data
useQuery({ queryKey: ['products'], queryFn: () => fetchProducts(categoryId) })

// ✅ Key matches all dependencies
useQuery({ queryKey: ['products', categoryId, page, filters], queryFn: ... })

// ✅ Nested key structure for easy bulk invalidation
useQuery({ queryKey: ['products', 'list', { categoryId }], ... })
useQuery({ queryKey: ['products', 'detail', productId], ... })

// Bust all product queries (list + detail):
queryClient.invalidateQueries({ queryKey: ['products'] })
// Bust only detail:
queryClient.invalidateQueries({ queryKey: ['products', 'detail'] })
```

---

### Client-Side State Caching

**Persisting non-sensitive state across sessions** (Zustand persist, Redux Persist):
```tsx
import { persist } from 'zustand/middleware';

const useStore = create(persist(
  (set) => ({
    preferences: {},
    setPreferences: (p) => set({ preferences: p }),
  }),
  {
    name: 'user-preferences',       // localStorage key
    partialize: (state) => ({ preferences: state.preferences }), // only persist what's needed
  }
));
// Invalidation: call store.setState({ preferences: {} }) on logout
```

---

### HTTP Cache Headers (Next.js / SSR)

**Next.js App Router fetch caching**:
```tsx
// Static — cache indefinitely, revalidate via ISR
const data = await fetch('/api/config', { next: { revalidate: 3600 } });

// Per-request fresh (SSR, user-specific)
const data = await fetch('/api/user/profile', { cache: 'no-store' });

// Tag-based invalidation (Next.js 14+)
const data = await fetch('/api/products', { next: { tags: ['products'] } });

// Server action to bust:
import { revalidateTag } from 'next/cache';
revalidateTag('products');  // all fetches tagged 'products' re-fetch on next request
```

---

### Prefetching

Cache warming before the user needs the data:

```tsx
// React Query — prefetch on hover / intent
const handleMouseEnter = () => {
  queryClient.prefetchQuery({
    queryKey: ['product', productId],
    queryFn: () => fetchProduct(productId),
    staleTime: 5 * 60 * 1000,
  });
};

// Next.js — prefetch on route hover (automatic with <Link />)
// For manual: router.prefetch('/products/[id]')
```

---

### Invalidation Patterns

| Pattern | Use when | Implementation |
|---------|----------|----------------|
| **Mutation-triggered** | After create / update / delete | `queryClient.invalidateQueries({ queryKey: ['products'] })` in `onSuccess` |
| **Optimistic update** | Low-latency UX on mutations | `queryClient.setQueryData()` before server confirms, rollback `onError` |
| **TTL / staleTime** | Data acceptable to be slightly stale | `staleTime: 5 * 60 * 1000` in `useQuery` |
| **On focus / reconnect** | Real-time sensitive data | `refetchOnWindowFocus: true`, `refetchOnReconnect: true` |
| **Manual bust** | Admin actions, forced refresh | `queryClient.invalidateQueries()` or `mutate()` (SWR) |
| **Logout / user switch** | User-scoped data | `queryClient.clear()` — removes all cached data |

---

### Cache Coherence Warnings to Flag

- `staleTime: Infinity` on data that mutates — will never revalidate, users see stale data
- Missing `queryClient.invalidateQueries()` after a mutation — cache stays stale after write
- Invalidating too broadly (e.g., `queryClient.clear()` on every mutation) — negates caching benefit
- Caching user-specific data under a non-user-scoped key — data leaks across users if cache persists
- Using `localStorage` for API responses without an expiry mechanism — permanently stale on schema changes
- Optimistic updates without `onError` rollback — UI and server state diverge on failure