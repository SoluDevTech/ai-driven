# Code Rules

TypeScript and React best practices. Load before writing code.

## TypeScript Best Practices
- **TypeScript strict mode** enabled (`strict: true` in tsconfig)
- **Explicit types** everywhere (no `any`, use `unknown` if needed)
- **Interface for objects**, `type` for unions/intersections
- **Enums** or **const assertions** for constants
- **Generic types** for reusable components/hooks
- **Type guards** for runtime type checking
- **Discriminated unions** for state management
- **Utility types**: `Partial`, `Pick`, `Omit`, `Record`, etc.
- **No implicit any**: all function parameters and return types typed

```typescript
// Discriminated union for async state
type AsyncState<T> =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: T }
  | { status: "error"; error: Error };

// Type guard
function isSuccess<T>(s: AsyncState<T>): s is Extract<AsyncState<T>, { status: "success" }> {
  return s.status === "success";
}
```

## React Best Practices
- **Functional components only** (no class components)
- **TypeScript with React**: use `React.FC` sparingly, prefer explicit prop types
- **Hooks rules**:
  - Custom hooks start with `use` prefix
  - Only call hooks at top level (no conditionals)
  - Extract complex logic into custom hooks
  - Use `useMemo` and `useCallback` for optimization (not prematurely)

## File Naming Conventions
- Components: `PascalCase.tsx` (e.g., `UserProfile.tsx`)
- Hooks: `camelCase.ts` (e.g., `useUserProfile.ts`)
- Utilities: `camelCase.ts` (e.g., `formatDate.ts`)
- Types: `PascalCase.ts` or `types.ts` (e.g., `User.ts` or `user.types.ts`)
- Tests: `*.test.tsx` or `*.spec.tsx`

## Discriminated union state example

```typescript
type FetchState<T> =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: T }
  | { status: "error"; error: string };

function useFetch<T>(fn: () => Promise<T>): FetchState<T> {
  const [state, setState] = useState<FetchState<T>>({ status: "idle" });
  useEffect(() => {
    setState({ status: "loading" });
    fn()
      .then((data) => setState({ status: "success", data }))
      .catch((error) => setState({ status: "error", error: String(error) }));
  }, []);
  return state;
}
```

## Generic reusable hook example

```typescript
function useLocalStorage<T>(key: string, initial: T) {
  const [value, setValue] = useState<T>(() => {
    const stored = localStorage.getItem(key);
    return stored ? (JSON.parse(stored) as T) : initial;
  });
  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(value));
  }, [key, value]);
  return [value, setValue] as const;
}
```