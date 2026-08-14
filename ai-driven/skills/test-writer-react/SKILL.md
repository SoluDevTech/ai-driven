---
name: test-writer-react
description: Write unit and integration tests for React apps. Vitest, React Testing Library, MSW. Golden rule: real implementations for internal components (stores, hooks, providers), mocks only for outbound external adapters (APIs, SDKs), testcontainers for real-backend E2E. Use when testing a component, custom hook, or service/adapter layer.
---

# Test Writer — React

Write clear, maintainable tests for a React/TypeScript app with Vitest, React Testing Library, and MSW.

## Use this skill when
- Testing a component, custom hook, or service/adapter layer
- You need MSW handlers for the network boundary
- You're unsure whether to mock or use the real implementation

## Do not use this skill when
- The task is project structure → use `hexagonal-react-patterns`
- The task is async patterns design → use `async-react-patterns`
- The task is Python or NestJS testing → use `test-writer-python` / `test-writer-nestjs`

## 🎯 Golden Rule (non-negotiable)
- **Real implementations** for ALL internal components (hooks, context providers, stores, services, domain utilities)
- **Mocks** ONLY for outbound adapters toward external systems (REST APIs, third-party SDKs, analytics, storage)
- **Real infrastructure** via testcontainers for integration / E2E tests that need a real backend (Postgres, Redis, LocalStack) — see `references/testcontainers.md`

A stub/fake that diverges silently from the real implementation produces tests that pass but don't detect real regressions. Mocking only the network boundary keeps cost low and confidence high.

## 🎯 Workflow
1. **Ask for context** — which component, hook, or service needs testing?
2. **Read the source code** — understand props, state, side effects, external dependencies.
3. **Classify dependencies** — internal → real impl; external → mock via `vi.mock` + fixtures in `tests/fixtures/external.ts` or MSW handlers.
4. **Load templates** — `references/setup.md` (vitest config, custom render); `references/component-test.md`; `references/hook-test.md`; `references/msw.md` for API boundary; `references/testcontainers.md` for real-backend E2E.
5. **Write tests** — AAA pattern, query by role, explicit names, one logical behavior per test.
6. **Run** — `pnpm vitest` (see `references/commands.md`).

## 🛡️ Edge cases (mandatory coverage)
Every test suite MUST cover edge cases, not just the happy path. For each component / hook / service under test, include tests for:
- **Null / undefined props** — pass `null` or `undefined` to optional props, assert graceful rendering (no crash, shows fallback/empty state)
- **Empty / boundary values** — empty array `[]`, empty string `""`, `0`, single-item list, very long string (truncation/overflow), very large list (virtualization/pagination)
- **Loading / error / empty states** — assert the component renders loading skeleton, error message, and empty state correctly (not just the success state)
- **Async edge cases** — slow API response, network error, aborted request, race condition (fast response arrives after slow one), Suspense fallback
- **User interaction edge cases** — double-click submit (debounce/throttle), disabled button click, keyboard navigation, form submission with invalid data
- **MSW error handlers** — add MSW handlers returning 4xx / 5xx / network error / empty response, not just 200 happy path
- **Accessibility edge cases** — missing aria-label, no children, RTL languages, very long content

If the component/hook has validation logic or business rules, add at least one test per rule that violates it and asserts the correct error/fallback UI.

## What you never do
- Write a fake store, fake context, or fake hook to replace a real internal implementation
- Mock a React component under test or any component in its subtree
- Mock Zustand, React Query, or any other internal state manager
- Assert on internal implementation details (spy on a private function, check component state directly)
- Use `waitFor` polling as a workaround for missing `await` on user events
- Forget `userEvent.setup()` — never use the legacy `userEvent` without it

## Related skills
- `hexagonal-react-patterns` — project structure, layer rules, CVA variants
- `async-react-patterns` — async patterns (test the patterns you implement)

## References
- `references/setup.md` — vitest config, test structure, custom render with providers
- `references/component-test.md` — component test with real store + MSW for API
- `references/hook-test.md` — hook test with `renderHook`, `act`, `waitFor`
- `references/msw.md` — MSW server setup and per-test handlers
- `references/testcontainers.md` — real infrastructure for integration / E2E tests (Redis, Postgres, LocalStack)
- `references/commands.md` — vitest commands (run, watch, coverage, single test)