# Data Fetching with TanStack Query

TanStack Query (React Query) v5 patterns: keys, prefetch, invalidation, mutations, optimistic updates. Default data library; SWR is similar.

## QueryClient setup
Create a single client and provide it at the app root.

```tsx
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 60_000,       // 1 min before refetch
      gcTime: 5 * 60_000,      // 5 min before garbage collect
      retry: (failureCount, error) =>
        error.status >= 500 && failureCount < 2,
      refetchOnWindowFocus: false,
    },
  },
});

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <Router />
    </QueryClientProvider>
  );
}
```

## Query keys (the source of truth)
Keys are arrays. Use a consistent hierarchy: `[entity, id, ...params]`.

```tsx
const userKeys = {
  all: ["users"] as const,
  detail: (id: string) => ["users", id] as const,
  list: (filters: UserFilters) => ["users", "list", filters] as const,
};

queryClient.invalidateQueries({ queryKey: userKeys.all });
queryClient.invalidateQueries({ queryKey: userKeys.detail("123") });
queryClient.removeQueries({ queryKey: userKeys.list({}) });
```

## Basic query
```tsx
function UserProfile({ id }: { id: string }) {
  const { data, isPending, error } = useQuery({
    queryKey: userKeys.detail(id),
    queryFn: () => userRepo.findById(id),
  });
  if (isPending) return <Skeleton />;
  if (error) return <ErrorState error={error} />;
  return <h1>{data.displayName}</h1>;
}
```

## Prefetch (router loaders, hover, ssr dehydration)
Prefetch seeds the cache before the component mounts.

```tsx
// route loader
async function loader({ params }: LoaderArgs) {
  await queryClient.prefetchQuery({
    queryKey: userKeys.detail(params.id),
    queryFn: () => userRepo.findById(params.id),
  });
  return {};
}

// hover prefetch
function UserLink({ id }: { id: string }) {
  return (
    <Link
      to={`/users/${id}`}
      onMouseEnter={() =>
        queryClient.prefetchQuery({
          queryKey: userKeys.detail(id),
          queryFn: () => userRepo.findById(id),
        })
      }
    >
      Open profile
    </Link>
  );
}
```

## Dehydrate / hydrate (SSR)
```tsx
import { dehydrate, HydrationBoundary } from "@tanstack/react-query";

// server
const state = dehydrate(queryClient);

// client
<HydrationBoundary state={state}>
  <UserProfile id={id} />
</HydrationBoundary>
```

## Mutations with invalidation
```tsx
const useRenameUser = (id: string) => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (name: string) => userRepo.rename(id, name),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: userKeys.detail(id) });
      qc.invalidateQueries({ queryKey: userKeys.all }); // any list
    },
  });
};
```

## Optimistic updates
Update the cache immediately, roll back on error.

```tsx
const useToggleLike = (postId: string) => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: () => postRepo.toggleLike(postId),
    onMutate: async () => {
      await qc.cancelQueries({ queryKey: postKeys.detail(postId) });
      const prev = qc.getQueryData<Post>(postKeys.detail(postId));
      qc.setQueryData<Post>(postKeys.detail(postId), (old) =>
        old ? { ...old, liked: !old.liked, likes: old.likes + (old.liked ? -1 : 1) } : old,
      );
      return { prev };
    },
    onError: (_err, _vars, ctx) => {
      qc.setQueryData(postKeys.detail(postId), ctx?.prev);
    },
    onSettled: () => {
      qc.invalidateQueries({ queryKey: postKeys.detail(postId) });
    },
  });
};
```

## Dependent / sequential queries
```tsx
const { data: user } = useQuery({ queryKey: userKeys.detail(id), queryFn: () => repo.findById(id) });
const { data: posts } = useQuery({
  queryKey: postKeys.byUser(user?.id ?? ""),
  queryFn: () => postRepo.listByUser(user!.id),
  enabled: !!user,
});
```

## Parallel queries
```tsx
const [user, settings] = useQueries({
  queries: [
    { queryKey: userKeys.detail(id), queryFn: () => repo.findById(id) },
    { queryKey: settingsKeys.detail(id), queryFn: () => settingsRepo.get(id) },
  ],
});
```

## Infinite / pagination
```tsx
const {
  data, fetchNextPage, hasNextPage, isFetchingNextPage,
} = useInfiniteQuery({
  queryKey: postKeys.feed(),
  queryFn: ({ pageParam }) => postRepo.feed({ cursor: pageParam, limit: 20 }),
  initialPageParam: 0,
  getNextPageParam: (last) => last.nextCursor ?? undefined,
});

const pages = data?.pages.flatMap((p) => p.items) ?? [];
```

## Abort signals
Pass the query's signal so cancelled queries abort the fetch.

```tsx
useQuery({
  queryKey: userKeys.detail(id),
  queryFn: ({ signal }) => fetch(`/api/users/${id}`, { signal }).then((r) => r.json()),
});
```