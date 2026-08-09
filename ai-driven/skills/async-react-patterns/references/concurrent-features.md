# Concurrent Features

React concurrent rendering: `useTransition`, `useDeferredValue`, `startTransition`. Keep urgent updates responsive while expensive renders happen in the background.

## When to use what
- **`useTransition`** — you control the state update that triggers the expensive render (e.g. switching tabs, filtering a big list)
- **`useDeferredValue`** — you receive a value you can't control (e.g. a prop) and want to defer its render
- **`startTransition`** — imperative version of `useTransition` (rare; useful outside components)

## `useTransition`
Marks a state update as non-urgent. React can interrupt it to keep the UI responsive.

```tsx
import { useTransition } from "react";

function Tabs({ tabs }: { tabs: Tab[] }) {
  const [active, setActive] = useState(tabs[0].id);
  const [isPending, startTransition] = useTransition();

  return (
    <>
      {tabs.map((t) => (
        <button
          key={t.id}
          onClick={() =>
            startTransition(() => setActive(t.id))
          }
        >
          {t.label}
        </button>
      ))}
      {isPending && <Spinner />}
      <TabPanel id={active} />
    </>
  );
}
```

### Rules
- Use for updates that drive a heavy render (filtering 10k rows, big tree swap, route change)
- Don't wrap urgent updates (typing in an input, button hover)
- `isPending` lets you show a subtle pending state without blocking

## `useDeferredValue`
Defers re-rendering based on a value. Useful for search-as-you-type where the input must stay snappy but the results are heavy.

```tsx
function SearchResults({ query }: { query: string }) {
  const deferredQuery = useDeferredValue(query);
  const isStale = query !== deferredQuery;
  const results = useMemo(() => heavyFilter(deferredQuery), [deferredQuery]);

  return (
    <ul style={{ opacity: isStale ? 0.6 : 1 }}>
      {results.map((r) => <li key={r.id}>{r.name}</li>)}
    </ul>
  );
}
```

### `useTransition` vs `useDeferredValue`
| Situation | Use |
|---|---|
| You own the state setter | `useTransition` |
| Value arrives via props | `useDeferredValue` |
| You must show "pending" badge | `useTransition` (`isPending`) |
| You only want to dim stale results | `useDeferredValue` (compare `value !== deferred`) |

## `startTransition` (imperative)
Use outside components or when the state update is in an event handler you can't wrap in `useTransition`.

```tsx
import { startTransition } from "react";

// in a store, router hook, etc.
startTransition(() => {
  router.navigate("/new-route");
});
```

## Non-blocking sorting of large lists
```tsx
function BigTable({ rows, sortKey }: { rows: Row[]; sortKey: keyof Row }) {
  const deferredKey = useDeferredValue(sortKey);
  const sorted = useMemo(() => rows.slice().sort(by(deferredKey)), [rows, deferredKey]);
  return <table>{/* ... */}</table>;
}
```

## Concurrent rendering gotchas
- Transitions are interruptible — never assume a render will commit
- Side effects inside a transition should be idempotent
- Strict mode double-invokes transitions in dev to surface bugs
- `useDeferredValue` does not defer the first render, only subsequent ones

## When NOT to use
- Urgent feedback (button click, input value) — those must be synchronous
- Tiny renders — the overhead isn't worth it
- Animations — use CSS / `requestAnimationFrame` instead