# Async Error Boundaries

Catch async errors once at a boundary, not in every component. Reset patterns and error serialization for streaming.

## Error boundary (React 18+)
Class components are the only way to catch render errors, including errors thrown inside a Suspense boundary's async content.

```tsx
import { Component, ReactNode } from "react";

type Props = { children: ReactNode; fallback: (error: Error, reset: () => void) => ReactNode; };
type State = { error: Error | null };

export class ErrorBoundary extends Component<Props, State> {
  state: State = { error: null };

  static getDerivedStateFromError(error: Error): State {
    return { error };
  }

  reset = () => this.setState({ error: null });

  componentDidCatch(error: Error, info: { componentStack: string }) {
    logError(error, info.componentStack);
  }

  render() {
    if (this.state.error) return this.props.fallback(this.state.error, this.reset);
    return this.props.children;
  }
}
```

## Using with Suspense
Wrap Suspense inside an ErrorBoundary so async errors (rejected promises, thrown in render) are caught.

```tsx
<ErrorBoundary fallback={(e, reset) => <ErrorState error={e} onRetry={reset} />}>
  <Suspense fallback={<Skeleton />}>
    <UserProfile id={id} />
  </Suspense>
</ErrorBoundary>
```

## Reset on route change
The boundary stays mounted; reset it when the route changes so a stale error doesn't persist.

```tsx
function RouteErrorBoundary({ routeKey, children }: { routeKey: string; children: ReactNode }) {
  const [error, setError] = useState<Error | null>(null);
  useEffect(() => setError(null), [routeKey]);
  if (error) return <ErrorState error={error} onRetry={() => setError(null)} />;
  return <ErrorBoundary fallback={(e) => { setError(e); return null; }}>{children}</ErrorBoundary>;
}
```

## Reset key (declarative reset)
Pass a `key` that changes when you want to reset. React remounts the boundary.

```tsx
<ErrorBoundary key={userId} fallback={...}>
  <Suspense fallback={<Skeleton />}><UserProfile id={userId} /></Suspense>
</ErrorBoundary>
```

## Recovering from async errors in hooks
Hooks can't catch errors thrown in `use()` or Suspense. Surface them via query state instead:

```tsx
function UserProfile({ id }: { id: string }) {
  const { data, error, refetch } = useQuery({
    queryKey: userKeys.detail(id),
    queryFn: () => userRepo.findById(id),
    retry: false,
  });
  if (error) return <ErrorState error={error as Error} onRetry={() => refetch()} />;
  if (!data) return <Skeleton />;
  return <h1>{data.displayName}</h1>;
}
```

## Error serialization for streaming
Errors thrown on the server must be serializable to reach the client. Throw plain `Error` instances with a `digest` for production.

```tsx
// server
export class HttpError extends Error {
  constructor(public status: number, message: string) {
    super(message);
    this.name = "HttpError";
  }
}
throw new HttpError(404, "User not found");

// next.js — exclude internal fields from the serialized payload
import { isHttpError } from "@/domain/errors";

export function handleError(error: unknown) {
  if (isHttpError(error)) {
    return { status: error.status, message: error.message };
  }
  return { status: 500, message: "Internal error" }; // never leak stack
}
```

## Error boundary placement
- **Route level** — one boundary per route catches most errors
- **Feature level** — wrap a fragile widget so the rest of the page survives
- **Root level** — last resort fallback page
- Don't put a boundary around every component; that makes UX inconsistent

## What error boundaries can NOT catch
- Event handlers (use try/catch)
- `setTimeout` / `setInterval` callbacks (use try/catch)
- Errors in `useEffect` cleanup (log separately)
- Server-side errors (handle on the server, serialize the message)

## Async error in event handlers
```tsx
async function handleSave() {
  try {
    await saveMutation.mutateAsync(form);
  } catch (error) {
    setFormError(error as Error);
  }
}
```