# Suspense and Streaming

React 18+ Suspense, the `use()` hook (React 19), server components, and streaming SSR.

## Suspense basics
Wrap async children in `<Suspense>` with a `fallback`. React renders the fallback until the child resolves, then swaps.

```tsx
import { Suspense } from "react";

function ProfilePage({ userId }: { userId: string }) {
  return (
    <Suspense fallback={<UserSkeleton />}>
      <UserProfile userId={userId} />
    </Suspense>
  );
}
```

### Nested Suspense
Each boundary streams independently. Put boundaries close to the async content so the shell renders fast and slow sections stream in later.

```tsx
function Dashboard() {
  return (
    <>
      <Header />
      <Suspense fallback={<ChartSkeleton />}>
        <AsyncChart />
      </Suspense>
      <Suspense fallback={<FeedSkeleton />}>
        <AsyncFeed />
      </Suspense>
    </>
  );
}
```

## The `use()` hook (React 19)
`use()` reads a promise or context. Unlike hooks, it can be called conditionally. A promise passed to `use()` must come from a cache or owner component (uncached promises throw on every render).

```tsx
import { use } from "react";

function UserProfile({ userPromise }: { userPromise: Promise<User> }) {
  const user = use(userPromise);
  return <h1>{user.displayName}</h1>;
}

// Server component creates the promise; client component consumes it
async function Page({ id }: { id: string }) {
  const userPromise = fetchUser(id);
  return <Suspense fallback={<Skeleton />}><UserProfile userPromise={userPromise} /></Suspense>;
}
```

### Conditional use
```tsx
function MaybeUser({ data }: { data: Promise<User> | null }) {
  if (data) {
    const user = use(data);
    return <h1>{user.displayName}</h1>;
  }
  return <span>Not signed in</span>;
}
```

## Server components (Next.js App Router)
Server components fetch on the server and can be `async`. They pass promises to client components, which consume them with `use()` inside a Suspense boundary.

```tsx
// app/users/[id]/page.tsx — server component
import { Suspense } from "react";
import { fetchUser, fetchPosts } from "@/infrastructure/api";

export default async function Page({ params }: { params: { id: string } }) {
  const userPromise = fetchUser(params.id);
  const postsPromise = fetchPosts(params.id);
  return (
    <>
      <Suspense fallback={<UserSkeleton />}>
        <UserProfile userPromise={userPromise} />
      </Suspense>
      <Suspense fallback={<PostsSkeleton />}>
        <PostList postsPromise={postsPromise} />
      </Suspense>
    </>
  );
}

// UserProfile.tsx — client component
"use client";
import { use } from "react";

export function UserProfile({ userPromise }: { userPromise: Promise<User> }) {
  const user = use(userPromise);
  return <h1>{user.displayName}</h1>;
}
```

### When to use server vs client components
- **Server**: data fetching, static content, heavy imports, SEO
- **Client**: interactivity (onClick, useState, useEffect), browser APIs, animations

## Streaming SSR
Render the shell synchronously, stream deferred chunks as they resolve. Next.js does this automatically with `app/` directory + Suspense. For custom SSR:

```tsx
import { renderToPipeableStream } from "react-dom/server";

renderToPipeableStream(<App />, {
  bootstrapModules: ["/client.js"],
  onShellReady() {
    res.setHeader("content-type", "text/html");
    pipe(res); // flush shell immediately
  },
  onError(error) { log(error); },
});
```

### Progressive enhancement order
1. Flush critical HTML shell + inline CSS
2. Stream Suspense boundaries as they resolve
3. Hydrate on the client
4. Stream late data (analytics, recommendations) last

## React 18 fallback (no `use()`)
Use a custom hook with a discriminated union state:

```tsx
type State<T> =
  | { status: "loading" }
  | { status: "success"; data: T }
  | { status: "error"; error: Error };

function useAsync<T>(fn: () => Promise<T>, deps: unknown[]) {
  const [state, setState] = useState<State<T>>({ status: "loading" });
  useEffect(() => {
    let active = true;
    setState({ status: "loading" });
    fn().then(
      (data) => active && setState({ status: "success", data }),
      (error) => active && setState({ status: "error", error }),
    );
    return () => { active = false; };
  }, deps);
  return state;
}
```