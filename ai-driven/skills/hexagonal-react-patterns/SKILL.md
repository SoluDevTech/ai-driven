---
name: hexagonal-react-patterns
description: React/TypeScript frontend with hexagonal architecture, SOLID, and KISS. Project structure, layer rules (domain pure-TS, application/hooks, infrastructure/adapters), ports, CVA variants, Zod-in-domain, and full checklists. Use when implementing or refactoring a React app following hexagonal architecture.
---

# React Hexagonal Architecture Patterns

Build a React/TypeScript frontend following hexagonal architecture, SOLID, and KISS.

## Use this skill when
- Implementing or refactoring a React app with hexagonal architecture
- Scaffolding project structure (domain / application / infrastructure)
- Defining domain ports, entities, and adapters
- Applying SOLID/KISS rules to React component design

## Do not use this skill when
- The task is purely async/concurrency → use `async-react-patterns`
- The task is generic UI/design polish → use OpenDesign MCP
- The task is React performance tuning → use `performance-audit`

## 🔍 Pre-flight (mandatory)
Before writing any code, **read the target repository's `AGENTS.md` first** — it overrides the generic stack below on conflict (eslint+prettier vs Biome, vitest vs Bun test, design tokens vs raw hex). Do not assume the generic stack applies.

## ♻️ Reuse-first (mandatory)
Before creating a new component, **scout what already exists** and reuse/extend it.
- Browse `src/application/components/ui/` (Card, Badge, Skeleton, Button, …) and existing feature folders before introducing any new styled element.
- If an existing primitive *almost* fits, **extend it** (add a prop, a variant) rather than duplicating it with a custom span/div.
- Styling variants belong in CVA files under `lib/ui/*-variants.ts` — **never** define a local `Record<Variant, string>` map inside a component when a `*-variants.ts` file already exists; add the variant there instead.
- ❌ Do not reimplement an existing UI primitive (e.g. a Badge with raw `<span>`s + a local class map) — use/enrich the real one.

## 🛡️ Edge cases (mandatory handling)
Every component, hook, and adapter MUST handle edge cases defensively, not just the happy path. During implementation, cover:
- **Null / undefined props** — optional props default safely; render fallback / empty state, never crash on `null` or `undefined`
- **Empty / boundary values** — empty array `[]`, empty string `""`, `0`, single-item list, very long string (truncation/overflow), very large list (virtualization/pagination); handle with explicit empty state UI
- **Loading / error / empty states** — every async component must handle all three: loading skeleton, error message + retry, empty state — not just the success state
- **Async edge cases** — slow response, network error, aborted request, race condition (stale closure, outdated response arriving after newer one); use AbortController and TanStack Query's stale-ness handling
- **User interaction edge cases** — double-click submit (disable button or debounce), disabled state, keyboard navigation, form submission with invalid data (Zod validation feedback)
- **External adapter failure** — API client throws or times out; catch in the hook/adapter, surface error state to the component, never let it crash the tree
- **Accessibility edge cases** — missing aria-label fallbacks, empty children, RTL languages, very long content overflow

If the component/hook has validation logic or business rules, enforce them with Zod schemas and render the correct error/fallback UI when violated.

## 🎯 Core workflow
1. **Pre-flight** — read repo `AGENTS.md`; confirm stack, tokens, test runner, linter.
2. **Reuse-first scan** — survey existing components/hooks before creating new ones.
3. **Structure** — load `references/project-structure.md` and reproduce the 3-layer layout.
4. **Per-layer rules** — load `references/layer-rules.md` before writing code in a given layer.
5. **Code rules** — load `references/code-rules.md` for TS/React conventions, naming, file patterns.
6. **Checklist** — before declaring done, run `references/checklist.md` end-to-end.
7. **Anti-patterns** — load `references/anti-patterns.md` to catch violations before review.

## 🎯 Core principles (summary)
- **Domain**: Pure TypeScript, ZERO React/UI dependencies (no JSX, no hooks, no components)
- **Application**: UI layer, consumes domain through hooks, can use React freely
- **Infrastructure**: External adapters (API clients, storage), implements domain ports
- **SOLID**: SRP (one component/hook = one responsibility), OCP (extend via adapters), LSP, ISP (small ports), DIP (app depends on ports, not adapters)
- **KISS**: simple flat structure, direct prop passing, pure functions, minimal state, clear naming (`useUserProfile` not `useData`)

## 📦 Default stack (overridable by repo AGENTS.md)
- Runtime: Bun · Build: Vite or Next.js · Language: TypeScript (strict)
- Styling: Tailwind CSS · State: React Context + hooks (Zustand/Jotai only if needed)
- Forms: React Hook Form + Zod · Validation: Zod · Data fetching: TanStack Query
- Testing: Bun test + React Testing Library (default) — vitest for eslint+prettier stacks
- Linting/Formatting: Biome (default) — eslint + prettier if repo AGENTS.md says so

## References
- `references/project-structure.md` — the 3-layer directory tree and what lives where
- `references/layer-rules.md` — domain / application / infrastructure rules, Zod-in-domain, CVA variants
- `references/code-rules.md` — TypeScript best practices, React patterns, naming, responsive design
- `references/checklist.md` — architecture, SOLID, React, testing, DevOps checklists
- `references/anti-patterns.md` — "Absolutely Avoid" list + critical reminders