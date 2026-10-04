---
name: test-writer-nestjs
description: "Write behavioral and integration tests for NestJS hexagonal backends. Jest, ts-jest, Supertest on the real AppModule. Golden rule: tests start from the router — full chain wired real (controller → use case → port → repo), testcontainers for real infra, mocks only for outbound external adapters (email, Stripe, S3). Use when testing a route, controller, use case, service, or adapter in a NestJS app."
---

# Test Writer — NestJS

Write clear, maintainable tests for a NestJS hexagonal backend with Jest, ts-jest, and Supertest.

## Use this skill when
- Testing a route, controller, use case, service, or adapter in a NestJS app
- You need mock provider factories for external adapters
- You're unsure whether to mock or use the real implementation

## Do not use this skill when
- The task is project structure → use `hexagonal-nestjs-patterns`
- The task is async/RxJS design → use `async-nestjs-patterns`
- The task is Python or React testing → use `test-writer-python` / `test-writer-react`

## 🎯 Golden Rule (non-negotiable)
- **Test from the router** — the default test entry point is an HTTP request via Supertest against the REAL `AppModule` (never a rebuilt TestingModule that re-declares internal providers). Assert the HTTP response AND observable side effects (DB state, emitted events). The whole chain runs real: Controller → Use Case → Port → Repository.
- **Real implementations** for ALL internal components (controllers, use cases, services, ports, repositories, domain objects, TypeORM entities) — never mock or rewire an internal layer.
- **Mocks** ONLY for outbound adapters toward external systems (third-party APIs, email, S3, Stripe, payment gateways) — via `overrideProvider` on the adapter class only.
- **Real infrastructure** via testcontainers (Postgres / Redis / Kafka / RabbitMQ / LocalStack) — Docker is a hard requirement — see `references/testcontainers.md`. If Docker is unavailable, fail fast with a clear error; never silently fall back.

A stub that diverges silently from the real implementation produces tests that pass but don't detect real regressions. Testing through the real AppModule exercises the exact wiring production uses (guards, pipes, interceptors, exception filters, DI) — cost stays low and confidence high.

## 🎯 Workflow
1. **Ask for context** — which route/endpoint (feature) needs testing?
2. **Read the source code** — the controller AND the whole chain it triggers (use case, ports, adapters, entities).
3. **Classify dependencies** — internal → real impl (already wired in the AppModule); external → `overrideProvider` with factories from `test/fixtures/external.ts`.
4. **Load templates** — `references/router-test.md` (PRIMARY: behavioral test via Supertest on the real AppModule); `references/testcontainers.md` for real infrastructure; `references/setup.md` (jest config, fixtures); `references/use-case-test.md` + `references/repository-test.md` ONLY for logic not exposed via an HTTP route (cron, queue consumer, pure domain) or adapter-specific SQL.
5. **Write tests** — AAA pattern, explicit names, one logical behavior per test. Act = one Supertest request; Assert = status + body + persistence via the real repository.
6. **Run** — `npm run test` (see `references/commands.md`).

## 🛡️ Edge cases (mandatory coverage)
Every test suite MUST cover edge cases, not just the happy path. For each route under test, include tests asserting the correct HTTP status + error body:
- **Validation** — missing required field, wrong type, Zod schema failure, out-of-range enum, oversized payload → 400/422
- **Auth / permissions** — unauthenticated → 401, wrong role → 403, foreign resource → 404
- **Not found / conflicts** — unknown id → 404, already-exists → 409, already-deleted, duplicate creation
- **Empty / boundary values** — empty array, page 1 / page size boundary, offset equals total count, single-element collections
- **Concurrency / race conditions** — duplicate concurrent requests, idempotency key replay (when applicable)
- **External adapter failure** — outbound adapter throws, returns error, times out, returns empty → the route still responds correctly (no silent swallow, no 500)

If the feature under test has domain invariants or business rules, add at least one test per invariant that violates it via the API and asserts the correct error response.

## What you never do
- Test a use case in isolation when it is exposed via an HTTP route — test it from the router instead
- Rebuild a TestingModule that re-declares controllers/use cases/repositories of the real chain — import the real AppModule and `overrideProvider` ONLY external adapters
- Use `@nestjs/testing`'s `overrideProvider` on internal classes (use cases, services, repositories)
- Provide an `InMemoryXxxRepository` or any other fake for an internal implementation
- Mock a use case, domain service, domain object, or TypeORM repository with `jest.fn()`
- Assert on internal implementation details (spy on a private method); use `jest.spyOn` on internal components to verify they were called
- Mock something just to make a test pass

## Related skills
- `hexagonal-nestjs-patterns` — project structure, ports, Zod usage
- `async-nestjs-patterns` — async/RxJS/event/queue patterns (test the patterns you implement)

## References
- `references/router-test.md` — behavioral test from the router via Supertest on the real AppModule (PRIMARY template)
- `references/setup.md` — jest config, test structure, external fixtures factory file
- `references/testcontainers.md` — real infrastructure for tests (Postgres, Redis, Kafka, RabbitMQ, LocalStack)
- `references/use-case-test.md` — EXCEPTION: use case tested directly, only for non-HTTP entry points
- `references/repository-test.md` — EXCEPTION: adapter-specific behavior not observable through routes (raw SQL, JSONB queries)
- `references/commands.md` — jest commands (run, watch, coverage, e2e)
