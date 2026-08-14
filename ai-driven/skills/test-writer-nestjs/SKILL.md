---
name: test-writer-nestjs
description: Write unit and integration tests for NestJS hexagonal backends. Jest, ts-jest, Supertest. Golden rule: real implementations for internal components (real TypeORM + SQLite in-memory), mocks only for outbound external adapters (email, Stripe, S3). Use when testing a use case, controller, service, or adapter in a NestJS app.
---

# Test Writer — NestJS

Write clear, maintainable tests for a NestJS hexagonal backend with Jest, ts-jest, and Supertest.

## Use this skill when
- Testing a use case, controller, service, or adapter in a NestJS app
- You need mock provider factories for external adapters
- You're unsure whether to mock or use the real implementation

## Do not use this skill when
- The task is project structure → use `hexagonal-nestjs-patterns`
- The task is async/RxJS design → use `async-nestjs-patterns`
- The task is Python or React testing → use `test-writer-python` / `test-writer-react`

## 🎯 Golden Rule (non-negotiable)
- **Real implementations** for ALL internal components (repositories, services, use cases, domain objects, TypeORM entities)
- **Mocks** ONLY for outbound adapters toward external systems (third-party APIs, email, S3, Stripe, payment gateways)
- **Real infrastructure** via testcontainers for integration tests against real Postgres / Redis / Kafka / RabbitMQ / LocalStack — see `references/testcontainers.md`

A stub that diverges silently from the real implementation produces tests that pass but don't detect real regressions. Mocking only the external boundary keeps cost low and confidence high.

## 🎯 Workflow
1. **Ask for context** — which use case, controller, or adapter needs testing?
2. **Read the source code** — understand the interface, DTOs, dependencies, expected behavior.
3. **Classify dependencies** — internal → real impl via `Test.createTestingModule`; external → mock via provider factories in `test/fixtures/external.ts`.
4. **Load templates** — `references/setup.md` (jest config, fixtures file); `references/use-case-test.md`; `references/controller-test.md`; `references/repository-test.md`; `references/testcontainers.md` for integration tests against real infrastructure.
5. **Write tests** — AAA pattern, explicit names, one logical behavior per test.
6. **Run** — `npm run test` (see `references/commands.md`).

## 🛡️ Edge cases (mandatory coverage)
Every test suite MUST cover edge cases, not just the happy path. For each use case / controller / service / adapter under test, include tests for:
- **Null / undefined inputs** — pass `null` / `undefined` where a value is expected, assert the correct exception is thrown
- **Empty / boundary values** — empty array `[]`, empty string `""`, `0`, negative numbers, `new Date(0)`, single-element collections
- **Off-by-one boundaries** — first/last index, page 1, page size boundary, offset equals total count
- **Invalid / malformed input** — wrong type, Zod schema validation failure, out-of-range enum value, oversized payload, missing required field
- **Concurrency / race conditions** — duplicate concurrent requests, idempotency key replay (when applicable)
- **External adapter failure** — outbound adapter throws, returns error, times out, returns empty — assert the use case handles it gracefully (no silent swallow)
- **State transitions** — already-exists, not-found, already-deleted, duplicate creation

If the feature under test has domain invariants or business rules, add at least one test per invariant that violates it and asserts the correct domain error.

## What you never do
- Provide an `InMemoryXxxRepository` or any other fake for an internal implementation
- Mock a use case, domain service, or domain object
- Mock a TypeORM repository with `jest.fn()` — use SQLite in-memory instead
- Assert on internal implementation details (spy on a private method)
- Use `jest.spyOn` on internal components to verify they were called
- Mock something just to make a test pass
- Use `@nestjs/testing`'s `overrideProvider` on internal classes

## Related skills
- `hexagonal-nestjs-patterns` — project structure, ports, Zod usage
- `async-nestjs-patterns` — async/RxJS/event/queue patterns (test the patterns you implement)

## References
- `references/setup.md` — jest config, test structure, external fixtures factory file
- `references/use-case-test.md` — use case test with real TypeORM + SQLite in-memory + mocked email
- `references/controller-test.md` — HTTP integration test with Supertest
- `references/repository-test.md` — adapter test against in-memory SQLite
- `references/testcontainers.md` — real infrastructure for integration tests (Postgres, Redis, Kafka, RabbitMQ, LocalStack)
- `references/commands.md` — jest commands (run, watch, coverage, e2e)