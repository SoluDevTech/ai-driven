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
- **Test at the HIGHEST entry point available, in this strict order**:
  1. **Route exists → test from the route**: one HTTP request via Supertest against the REAL `AppModule` (never a rebuilt TestingModule that re-declares internal providers). Assert the HTTP response AND observable side effects (DB state, emitted events).
  2. **No route but a consumer/processor/scheduler triggers the logic → test through that entry point**: publish a REAL message to the real broker testcontainer (Bull queue job, Kafka/NATS message, cron tick) and wait for observable side effects — never invoke the processor/use case directly. A use case only reachable from a processor or cron is tested exactly the way production triggers it.
  3. **Pure domain with NO entry point at all → `test/unit/` direct tests allowed** — but when the function is actually exercised by a chain, prefer asserting its effect through that chain.
- The whole chain runs real: Controller/Processor → Use Case → Port → Repository.
- **A use case/service/adapter is NEVER the direct test subject** — it is covered through its entry point. If you find yourself instantiating a use case or service in a test while a route or processor can trigger it, STOP and test through the entry point.
- **Real implementations** for ALL internal components (controllers, processors, use cases, services, ports, repositories, domain objects, TypeORM entities) — never mock or rewire an internal layer.
- **Mocks** ONLY for outbound adapters toward external systems (third-party APIs, email, S3, Stripe, payment gateways) — via `overrideProvider` on the adapter class only.
- **Real infrastructure** via testcontainers (Postgres / Redis / Kafka / RabbitMQ / LocalStack) — Docker is a hard requirement — see `references/testcontainers.md`. If Docker is unavailable, fail fast with a clear error; never silently fall back.

A stub that diverges silently from the real implementation produces tests that pass but don't detect real regressions. Testing through the real AppModule exercises the exact wiring production uses (guards, pipes, interceptors, exception filters, DI) — cost stays low and confidence high.

## 🗂️ Test layout (non-negotiable)

```
test/
├── setup.ts                             # real AppModule + testcontainers + Supertest + auth helpers
├── fixtures/
│   └── external.ts                      # mocks for external adapters (configurable failures)
├── behavioral/
│   └── <feature>/
│       └── <endpoint>.spec.ts           # EVERYTHING over HTTP — all branches
└── unit/                                # ONLY: pure domain without HTTP entry, scripts, consumers
```

- `behavioral/<feature>/<endpoint>.spec.ts` — one Supertest-based file per endpoint, all branches covered (happy path, validation, auth, conflicts, external failures). This is the default and the bulk of the suite.
- `unit/` — pure domain logic with NO HTTP entry point, standalone scripts, and queue/cron consumers. Never put an endpoint test here.
- `setup.ts` — the only place for shared setup: real AppModule bootstrap, testcontainers infra, auth helpers (register/login via the real API → reusable auth headers).

## 🎯 Workflow
1. **Ask for context** — which route/endpoint (feature) needs testing?
2. **Read the source code** — the controller AND the whole chain it triggers (use case, ports, adapters, entities).
3. **Classify dependencies** — internal → real impl (already wired in the AppModule); external → `overrideProvider` with factories from `test/fixtures/external.ts`.
4. **Load templates** — `references/router-test.md` (PRIMARY: behavioral test via Supertest on the real AppModule, in `test/behavioral/<feature>/<endpoint>.spec.ts`); `references/processor-test.md` when the logic is triggered by a queue/processor/scheduler (real message/job → side effects); `references/testcontainers.md` for real infrastructure; `references/setup.md` (jest config, fixtures, auth helpers); `references/use-case-test.md` + `references/repository-test.md` ONLY for logic with NO route and NO processor (cron-internal, pure domain) or adapter-specific SQL — those tests live in `test/unit/`.
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
- Test a use case, service, or infrastructure adapter DIRECTLY (instantiated in the test) when a route OR a processor/scheduler triggers it — go through the entry point (route = Supertest request; processor = real published message/job)
- Mock internal components to force a use case/adapter into a testable state (e.g. override an internal `HttpService` wrapper used by an external adapter) instead of mocking the external API at the adapter boundary
- Place an endpoint test anywhere outside `test/behavioral/<feature>/<endpoint>.spec.ts`
- Put a test with an HTTP entry point in `test/unit/` — unit is for pure domain, scripts, and consumers only
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
- `references/processor-test.md` — behavioral test through a queue processor/consumer: real message or job published to the real broker, observable side effects only (SECONDARY template)
- `references/setup.md` — jest config, test structure (`test/behavioral/<feature>/`), external fixtures, auth helpers
- `references/testcontainers.md` — real infrastructure for tests (Postgres, Redis, Kafka, RabbitMQ, LocalStack)
- `references/use-case-test.md` — EXCEPTION: use case tested directly, only for logic with no route and no processor (lives in `test/unit/`)
- `references/repository-test.md` — EXCEPTION: adapter-specific behavior not observable through routes (raw SQL, JSONB queries; lives in `test/unit/`)
- `references/commands.md` — jest commands (run, watch, coverage, behavioral)
