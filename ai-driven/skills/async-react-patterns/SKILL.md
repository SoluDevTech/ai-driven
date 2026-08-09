---
name: async-react-patterns
description: React/TypeScript asynchronous patterns: Suspense, the use() hook, server components, streaming SSR, TanStack Query data fetching, concurrent features (useTransition, useDeferredValue), async error boundaries, and testing async components. Use when implementing async data flow, loading states, streaming, or background data work in a React app.
---

# Async React Patterns

Implement async data flow, loading states, streaming, and background work in a React/TypeScript frontend.

## Use this skill when
- Implementing Suspense boundaries, streaming SSR, or server components
- Wiring TanStack Query (React Query) for data fetching, caching, invalidation
- Using concurrent features (`useTransition`, `useDeferredValue`, `use()`)
- Handling async errors with error boundaries
- Testing async components and hooks

## Do not use this skill when
- The task is project structure / hexagonal layers → use `hexagonal-react-patterns`
- The task is generic performance profiling → use `performance-audit`
- The task is Node/NestJS async → use `async-nestjs-patterns`
- The task is Python async → use `async-python-patterns`

## 🔍 Pre-flight (mandatory)
Read the target repo's `AGENTS.md` to confirm: React version (18 vs 19), RSC framework (Next.js vs Vite SPA), data-fetching lib (TanStack Query vs SWR vs native fetch), and test runner.

## 🎯 Core workflow
1. **Pre-flight** — confirm React version + framework + data lib from repo `AGENTS.md`.
2. **Pick the data pattern** — server components vs client fetching vs streaming. Load `references/suspense-and-streaming.md`.
3. **Data fetching** — TanStack Query setup, keys, prefetch, invalidation, mutations. Load `references/data-fetching.md`.
4. **Concurrent UI** — `useTransition`, `useDeferredValue`, `use()`. Load `references/concurrent-features.md` when the UI needs non-blocking updates.
5. **Error handling** — async error boundaries, reset, error serialization. Load `references/error-boundaries.md`.
6. **Testing** — waitFor, act, fake timers, testing Suspense. Load `references/testing-async.md`.

## 🎯 Core principles (summary)
- **Loading state is a first-class citizen** — model it explicitly (discriminated unions, Suspense, query status)
- **Streaming over blocking** — render shells fast, stream deferred content
- **Server components by default** — fetch on the server when possible; client components only for interactivity
- **Cache and invalidate, don't refetch blindly** — TanStack Query keys are the source of truth
- **Concurrent rendering** — never block the main thread; use `startTransition` for non-urgent updates
- **Errors are boundaries** — catch once at a boundary, not in every component

## 📦 Default stack (overridable by repo AGENTS.md)
- Data fetching: TanStack Query v5 (default), SWR, or native fetch
- Server components: Next.js App Router (when SSR framework)
- Testing: Bun test + React Testing Library (default), vitest for eslint+prettier stacks
- React 19+ features (`use()`, Actions, `useFormState`) when the repo is on React 19; React 18 fallbacks otherwise

## References
- `references/suspense-and-streaming.md` — Suspense boundaries, `use()` hook, server components, streaming SSR
- `references/data-fetching.md` — TanStack Query: keys, prefetch, invalidation, mutations, optimistic updates
- `references/concurrent-features.md` — `useTransition`, `useDeferredValue`, concurrent rendering, `startTransition`
- `references/error-boundaries.md` — async error boundaries, reset patterns, error serialization
- `references/testing-async.md` — testing async components, waitFor, act, fake timers, testing Suspense