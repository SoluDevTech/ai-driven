# Checklist

Run end-to-end before declaring a task done. Each item must be checked.

## Architecture
- [ ] 3 distinct layers: domain / application / infrastructure
- [ ] Domain is pure TypeScript (no React dependencies)
- [ ] Application layer uses domain through custom hooks
- [ ] Infrastructure implements domain ports
- [ ] No `index.ts` barrel files re-exporting across layers

## SOLID & KISS
- [ ] SRP: one component/hook = one responsibility
- [ ] OCP: extend via new adapters, never modify ports
- [ ] LSP: all implementations respect their port's contract
- [ ] ISP: small, focused interfaces (no god interfaces)
- [ ] DIP: application depends on domain ports, not infrastructure
- [ ] Simple, flat structure (avoid deep nesting)
- [ ] Clear, descriptive naming (`useUserProfile` not `useData`)

## TypeScript
- [ ] Strict mode enabled
- [ ] All types explicit (no `any`)
- [ ] Interfaces for ports (domain contracts)
- [ ] Type guards for runtime checks
- [ ] Discriminated unions for state

## React
- [ ] Functional components only
- [ ] Custom hooks for business logic
- [ ] Proper state management (local → context → external)
- [ ] Error boundaries for error handling
- [ ] Performance optimization (measured, not premature)
- [ ] Responsive design (mobile-first, tested on real devices)
- [ ] Accessible (ARIA labels, keyboard navigation, semantic HTML)
- [ ] Touch targets minimum 44x44px on mobile

## Styling
- [ ] Reuse existing UI primitives; no reimplementing Badge/Card/Skeleton with raw elements
- [ ] Variants live in CVA `*-variants.ts` files, not local class maps
- [ ] No hardcoded colours — use repo design tokens
- [ ] No arbitrary Tailwind literals when a named primitive exists

## Domain
- [ ] No React imports in domain layer
- [ ] Zod schemas defined in entities
- [ ] Ports are interfaces, not classes
- [ ] No side effects in domain

## Testing
- [ ] Real implementations for all internal components (repositories, hooks, domain objects)
- [ ] Mocks ONLY for outbound adapters toward external systems (REST APIs, SDKs, analytics)
- [ ] Component tests with React Testing Library
- [ ] Test behavior, not implementation (query by role/label)
- [ ] In-memory adapters satisfy the domain port contract (they're real, not mocks)
- [ ] Coverage ≥ 70%

## DevOps
- [ ] GitHub Actions CI/CD (tests, linting, build)
- [ ] Biome for linting and formatting (or repo's configured linter)
- [ ] TypeScript compiler checks in CI
- [ ] Docker for deployment (optional)