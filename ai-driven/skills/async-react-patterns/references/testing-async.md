# Testing Async Components

React Testing Library patterns for async: `waitFor`, `act`, fake timers, testing Suspense, testing TanStack Query.

## Setup
```tsx
import { render, screen } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

function renderWithClient(ui: ReactNode) {
  const qc = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 } },
  });
  return render(<QueryClientProvider client={qc}>{ui}</QueryClient>);
}
```

## `waitFor` — poll for an async change
```tsx
test("shows user name after fetch", async () => {
  const repo = fakeUserRepo({ findById: async () => ({ id: "1", displayName: "Ada" }) });
  renderWithClient(<UserProfile id="1" repo={repo} />);
  expect(await screen.findByRole("heading", { name: "Ada" })).toBeInTheDocument();
});
```

Prefer `findBy*` queries (they wait by default) over manual `waitFor`.

## `findBy` vs `waitFor`
- `findByText` / `findByRole` — wait for one element to appear (most common)
- `waitFor(() => expect(...))` — wait for a custom assertion or absence

```tsx
test("shows error state on failure", async () => {
  renderWithClient(<UserProfile id="x" repo={failingRepo} />);
  await waitFor(() => expect(screen.getByText(/not found/i)).toBeInTheDocument());
});
```

## `act` — when not to use it
React Testing Library wraps events and `waitFor` in `act` for you. Use `act` directly only when:
- Triggering state updates outside the test's event helpers
- Resolving a promise you created manually

```tsx
test("manual act", async () => {
  let resolve: (v: User) => void;
  const promise = new Promise<User>((r) => { resolve = r; });
  renderWithClient(<UserProfile userPromise={promise} />);
  await act(async () => { resolve!({ id: "1", displayName: "Ada" }); });
  expect(screen.getByText("Ada")).toBeInTheDocument();
});
```

## Fake timers + `act`
```tsx
import { advanceTimersByTimeAsync } from "@testing-library/react";

beforeEach(() => { useFakeTimers(); });
afterEach(() => { useRealTimers(); });

test("refreshes every minute", async () => {
  renderWithClient(<LiveClock />);
  expect(screen.getByText("00:00")).toBeInTheDocument();
  await advanceTimersByTimeAsync(60_000);
  expect(await screen.findByText("00:01")).toBeInTheDocument();
});
```

## Testing Suspense
Render with a Suspense boundary; assert the fallback appears, then the resolved content.

```tsx
test("suspense fallback then content", async () => {
  let resolve: (v: User) => void;
  const promise = new Promise<User>((r) => { resolve = r; });

  render(
    <ErrorBoundary fallback={() => <span>error</span>}>
      <Suspense fallback={<span>loading</span>}>
        <UserProfile userPromise={promise} />
      </Suspense>
    </ErrorBoundary>,
  );

  expect(screen.getByText("loading")).toBeInTheDocument();
  await act(async () => { resolve!({ id: "1", displayName: "Ada" }); });
  expect(screen.getByText("Ada")).toBeInTheDocument();
});
```

## Testing error boundaries
```tsx
test("boundary catches async error", async () => {
  const promise = Promise.reject(new Error("boom"));
  render(
    <ErrorBoundary fallback={(e, reset) => <span>{e.message}</span>}>
      <Suspense fallback={<span>loading</span>}>
        <UserProfile userPromise={promise} />
      </Suspense>
    </ErrorBoundary>,
  );
  expect(await screen.findByText("boom")).toBeInTheDocument();
});
```

## Testing TanStack Query
```tsx
test("invalidates on mutation", async () => {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  const repo = fakeUserRepo({
    findById: async () => ({ id: "1", displayName: "Ada" }),
    rename: async (id, name) => { /* updates store */ },
  });

  render(
    <QueryClientProvider client={qc}>
      <UserProfile id="1" repo={repo} />
      <RenameButton id="1" repo={repo} />
    </QueryClientProvider>,
  );

  expect(await screen.findByText("Ada")).toBeInTheDocument();
  fireEvent.click(screen.getByRole("button", { name: /rename/i }));
  expect(await screen.findByText("Ada Lovelace")).toBeInTheDocument();
});
```

## Avoiding flakiness
- Always `await` async assertions
- Don't use real timers for time-based tests
- Reset `QueryClient` per test (`gcTime: 0`, `retry: false`)
- Don't assert on absence without `waitFor` (`await waitFor(() => expect(screen.queryByText("loading")).toBeNull())`)
- Wrap manual promise resolution in `act`