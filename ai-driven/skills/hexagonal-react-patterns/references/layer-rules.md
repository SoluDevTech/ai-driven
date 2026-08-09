# Layer Rules

Detailed rules for each layer. Load this before writing code in a given layer.

## Domain Layer
- **Pure TypeScript**: no React imports, no JSX, no hooks, no components
- **Entities**: simple classes or interfaces representing business models
- **Ports**: interfaces defining contracts (repository, service)
- **Business logic**: pure functions in `lib/`
- **Validation**: use **Zod** for schema validation and type inference
  - Define schemas in domain entities
  - Use `z.infer<typeof schema>` for type extraction
  - Validate data at boundaries (API responses, user inputs)
- **No side effects**: domain must be testable without UI

```typescript
// domain/entities/User.ts
import { z } from "zod";

export const UserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  displayName: z.string().min(1).max(100),
  role: z.enum(["admin", "member", "viewer"]),
});

export type User = z.infer<typeof UserSchema>;

// domain/ports/UserRepository.ts
export interface UserRepository {
  findById(id: string): Promise<User | null>;
  save(user: User): Promise<void>;
}
```

## Application Layer
- **Custom hooks** for domain interaction:
  - `useUser()` to fetch/manage user
  - `useAuth()` for authentication logic
  - `useForm()` for form state management
- **Components**:
  - Small, focused components (<200 lines)
  - Single responsibility
  - Composable and reusable
- **Pages**: route-level components, compose smaller components
- **Providers**: Context providers for shared state

```typescript
// application/hooks/useUserProfile.ts
import { useQuery } from "@tanstack/react-query";
import type { UserRepository } from "@/domain/ports/UserRepository";

export function useUserProfile(repo: UserRepository, id: string) {
  return useQuery({
    queryKey: ["user", id],
    queryFn: () => repo.findById(id),
  });
}
```

### Component patterns
- **Presentational components**: pure UI, receive props, no business logic
- **Container components**: connect to domain via hooks, pass data to presentational
- **Compound components**: related components working together (using context)

### Props
- Destructure props in function signature
- Use `children` prop for composition
- Optional props with `?` and defaults with destructuring
- Avoid boolean props like `isActive`, prefer enums/unions

### State management
- Local state with `useState` for component-specific state
- `useReducer` for complex state logic
- Context + hooks for shared state (avoid prop drilling)
- External state management (Zustand, Jotai) for global state if needed

### Performance
- `React.memo` for expensive components (measure first)
- `useMemo` for expensive computations
- `useCallback` for stable function references
- Lazy loading with `React.lazy` and `Suspense`
- Virtual scrolling for long lists (react-window, @tanstack/react-virtual)

### Error handling
- Error boundaries for component errors
- Try-catch in async operations
- Loading and error states in hooks

### Styling
- Tailwind CSS (utility-first, recommended)
- Prefer named Tailwind primitives (`text-sm`, `h-6`, `rounded-sm`, `gap-3`) over arbitrary literals
- **Avoid arbitrary literals** (`min-h-[143px]`, `size-[41px]`, `h-[23px]`, `shadow-[…]`) unless the value has no token/primitive equivalent AND the exception is documented inline; recurring values must be promoted to the repo's token system
- Never hardcode colours — use the repo's design tokens (no `bg-[#hex]`, no `text-[#hex]`, no `#hex` in `style={}` or arbitrary classes); if a shade is missing, add a step to the ramp in the token file
- CSS Modules (scoped styles) or styled-components (CSS-in-JS) as alternatives
- Avoid inline styles (except dynamic values)

### Responsive Design
- **Mobile-first approach**: design for mobile, then scale up
- **Tailwind breakpoints**: `sm:`, `md:`, `lg:`, `xl:`, `2xl:` (use consistently)
- **Fluid typography**: use `clamp()` for responsive font sizes
- **Responsive images**:
  - `<picture>` for art direction
  - `srcset` and `sizes` for resolution switching
  - Lazy loading with `loading="lazy"`
- **Container queries**: `@container` for component-level responsiveness
- **Touch targets**: minimum 44x44px for interactive elements (mobile)
- **Breakpoint strategy**:
  - Mobile: < 640px (sm)
  - Tablet: 640px - 1024px (md, lg)
  - Desktop: > 1024px (xl, 2xl)
- **Layout patterns**: stack on mobile, grid/flex on desktop; hamburger on mobile, full nav on desktop
- **Performance**: avoid unnecessary re-renders on resize; use CSS media queries over JS when possible; debounce resize event handlers

## Infrastructure Layer
- **API clients**: implement domain ports
  - Axios, fetch, or GraphQL clients
  - Handle HTTP errors, retries, timeouts
  - Transform API responses to domain entities
- **Configuration**: environment variables, feature flags
- **Storage**: LocalStorage, SessionStorage, IndexedDB wrappers

```typescript
// infrastructure/api/ApiUserRepository.ts
import type { UserRepository, User } from "@/domain/ports/UserRepository";
import { UserSchema } from "@/domain/entities/User";

export class ApiUserRepository implements UserRepository {
  constructor(private baseUrl: string) {}

  async findById(id: string): Promise<User | null> {
    const res = await fetch(`${this.baseUrl}/users/${id}`);
    if (!res.ok) return null;
    return UserSchema.parse(await res.json());
  }

  async save(user: User): Promise<void> {
    await fetch(`${this.baseUrl}/users/${user.id}`, {
      method: "PUT",
      body: JSON.stringify(user),
    });
  }
}
```

## CVA variants
Styling variants belong in CVA files under `lib/ui/*-variants.ts` — never define a local `Record<Variant, string>` map inside a component when a `*-variants.ts` file already exists for that primitive; add the variant there instead.

```typescript
// lib/ui/badge-variants.ts
import { cva } from "class-variance-authority";

export const badgeVariants = cva("inline-flex items-center rounded-sm px-2", {
  variants: {
    tone: { neutral: "bg-muted", success: "bg-success", danger: "bg-danger" },
    size: { sm: "text-xs h-5", md: "text-sm h-6" },
  },
  defaultVariants: { tone: "neutral", size: "md" },
});

export type BadgeVariant = VariantProps<typeof badgeVariants>;
```

## Testing
**Golden rule** — real implementations for all internal components; mocks only for outbound adapters toward external systems.

- **Real implementations**: use the real component, hook, domain object, and in-app state for everything inside the app boundary
- **Mocks**: only for outbound adapters toward external systems (REST APIs, third-party SDKs, analytics, storage, browser APIs when the contract is external)
- **Why real**: a stub/fake that diverges silently from the real implementation produces tests that pass but don't detect real regressions. Mocking only the network/external boundary keeps the cost low and confidence high.

```tsx
// ✅ REAL IMPLEMENTATION — for ALL internal components
import { useUser } from "@/application/hooks/useUser";
import { renderWithClient } from "@/tests/utils";

test("shows user name after fetch", async () => {
  const repo = new InMemoryUserRepository([{ id: "1", displayName: "Ada" }]);
  renderWithClient(<UserProfile id="1" repo={repo} />);
  expect(await screen.findByRole("heading", { name: "Ada" })).toBeInTheDocument();
});
```

```tsx
// ✅ MOCK — ONLY for external outbound adapters
vi.mock("@/infrastructure/api/stripe-client", () => ({
  chargeCard: vi.fn().mockResolvedValue({ status: "succeeded" }),
}));

import { useCheckout } from "@/application/hooks/useCheckout";
test("completes checkout via Stripe", async () => {
  // Stripe is mocked; everything else uses real implementations
  const { result } = renderHook(() => useCheckout(), { wrapper });
  await act(async () => { result.current.submit(); });
  expect(stripeClient.chargeCard).toHaveBeenCalled();
});
```

### Internal in-memory adapters (allowed)
In-memory adapters for tests are **real implementations** of the domain port, not mocks. They must satisfy the same port contract.

```tsx
// tests/doubles/InMemoryUserRepository.ts — real implementation of UserRepository
export class InMemoryUserRepository implements UserRepository {
  private users = new Map<string, User>();
  async findById(id: string) { return this.users.get(id) ?? null; }
  async save(user: User) { this.users.set(user.id, user); }
}
```

### Test principles
- **Test behavior, not implementation** — query by accessible elements (`getByRole`, `getByLabelText`)
- **Avoid testing internal state** — assert on observable output
- **Mock external boundaries only** — REST APIs, SDKs, analytics
- **Coverage**: minimum 70% for critical business logic
- **Zod schemas** can be reused in tests for data validation