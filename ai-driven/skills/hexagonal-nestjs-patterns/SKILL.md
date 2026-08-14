---
name: hexagonal-nestjs-patterns
description: NestJS/TypeScript backend with hexagonal architecture, SOLID, and KISS. Project structure, ports as abstract classes (inbound/outbound split), Zod entity/DTO validation, injection tokens, exception filters, Swagger via zod-openapi. Use when implementing or refactoring a NestJS backend following hexagonal architecture.
---

# NestJS Hexagonal Architecture Patterns

Build a NestJS/TypeScript backend following hexagonal architecture, SOLID, and KISS.

## Use this skill when
- Implementing or refactoring a NestJS backend with hexagonal architecture
- Scaffolding the 3-layer project structure (domain / application / infrastructure)
- Defining ports as abstract classes and wiring injection tokens
- Using Zod for entity + DTO validation with NestJS pipes
- Mapping domain exceptions to HTTP exceptions

## Do not use this skill when
- The task is async/concurrency/RxJS → use `async-nestjs-patterns`
- The task is Python/FastAPI → use `hexagonal-python-patterns`
- The task is performance profiling → use `performance-audit`

## 🛡️ Edge cases (mandatory handling)
Every use case, controller, service, and adapter MUST handle edge cases defensively, not just the happy path. During implementation, cover:
- **Null / undefined inputs** — validate at the port boundary via Zod; throw the correct domain exception, never let `null` / `undefined` propagate silently into business logic
- **Empty / boundary values** — empty array, empty string, `0`, negative numbers, `new Date(0)`, single-element collections; handle explicitly
- **Off-by-one boundaries** — pagination first/last page, offset equals total count, zero results
- **Invalid / malformed input** — Zod schema validation covers structure, but add domain-level `.refine()` / `.superRefine()` for business rules (invalid state transition, value out of business range)
- **Concurrency / race conditions** — duplicate creation, optimistic locking conflict, idempotency key replay; handle with proper exception or upsert
- **External adapter failure** — outbound adapter throws or times out; catch at the use case level, map to the correct domain exception via the exception filter, never silently swallow
- **State transitions** — already-exists, not-found, already-deleted, illegal transition; throw the correct mapped HTTP exception

If the feature has domain invariants, enforce them in the Zod entity schema and throw the matching domain exception when violated.

## 🎯 Core workflow
1. **Structure** — load `references/project-structure.md` and reproduce the layout.
2. **Layer rules** — load `references/layer-rules.md` before writing code in a given layer.
3. **Zod usage** — load `references/zod-usage.md` for entity/DTO/config validation.
4. **NestJS conventions** — load `references/nestjs-conventions.md` for DI, modules, guards, exception filters, Swagger.
5. **Checklist** — run `references/checklist.md` end-to-end before declaring done.
6. **Anti-patterns** — load `references/anti-patterns.md` to catch violations.

## 🎯 Core principles (summary)
- **Domain**: business core with Zod for entity validation — NO NestJS decorators, TypeORM, or Mongoose imports
- **Application**: orchestrates use cases, depends only on domain; thin controllers delegate to use cases
- **Infrastructure**: one folder per adapter (`postgres/`, `mongodb/`, `email/`), implements domain ports
- **Ports = abstract classes** (interfaces don't exist at runtime in TS)
- **Inbound ports** (use case entry points) vs **outbound ports** (infrastructure contracts)
- **Injection tokens** (symbols) for loose coupling between layers
- **SOLID**: SRP (1 class = 1 responsibility), OCP (extend via new adapters), LSP, ISP (no 20-method ports), DIP (use cases depend on ports, never adapters)
- **KISS**: direct transformations `new Class({ ...other })` or spread; **no** `fromEntity()` / `toEntity()` methods; **no** Response DTOs (return domain entities directly)

## 📦 Default stack
- Package manager: **pnpm**
- Runtime: Node.js + NestJS 10+
- Language: TypeScript 5.0+ (strict)
- Validation: Zod (entities, DTOs, config)
- ORM/ODM: TypeORM / Mongoose — only in `infrastructure/`, never in `domain/`
- Tests: Jest + ts-jest (real implementations for internals; mocks only for external adapters)
- Swagger: `@anatine/zod-openapi` for automatic OpenAPI docs

## References
- `references/project-structure.md` — the 3-layer directory tree (domain ports split inbound/outbound)
- `references/layer-rules.md` — domain + Zod, application DTOs, infrastructure adapter conventions
- `references/zod-usage.md` — Zod schemas for entities, DTOs, config; `z.infer`, `.refine()`, `.transform()`
- `references/nestjs-conventions.md` — DI, modules, guards, exception filters, Swagger, middleware
- `references/checklist.md` — architecture, SOLID, NestJS, DevOps checklists
- `references/anti-patterns.md` — "Absolutely Avoid" + critical reminders