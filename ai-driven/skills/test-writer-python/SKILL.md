---
name: test-writer-python
description: "Write behavioral and integration tests for Python/FastAPI apps with pytest + pytest-asyncio. Golden rule: tests start from the router — httpx AsyncClient on the real FastAPI app, full hexagonal chain wired real (router → use case → port → repo), testcontainers for real infra, mocks only for outbound external adapters (email, Stripe, S3). Layout: tests/conftest.py, tests/fixtures/external.py, tests/behavioral/<feature>/test_<endpoint>.py, tests/unit/ (domain pur, scripts, consumers only). Trigger on: pytest, \"write tests\", \"add tests\", \"test the route/endpoint/use case/adapter\", or any testing task in a Python backend."
---

# Test Writer — Python

Write clear, maintainable tests for a Python/FastAPI hexagonal backend with pytest and pytest-asyncio.

## Use this skill when
- Testing a route, endpoint, use case, adapter, or async flow in a Python backend
- You need fixtures for external adapters (email, Stripe, S3)
- You're unsure whether to mock or use the real implementation

## Do not use this skill when
- The task is project structure → use `hexagonal-python-patterns`
- The task is async patterns design → use `async-python-patterns`
- The task is React or NestJS testing → use `test-writer-react` / `test-writer-nestjs`

## 🎯 Golden Rule (non-negotiable)
- **Test at the HIGHEST entry point available, in this strict order**:
  1. **Route exists → test from the route**: one HTTP request through the real FastAPI app (httpx `AsyncClient` + `ASGITransport`). Assert the HTTP response AND observable side effects (DB state, emitted events).
  2. **No route but a consumer/use case triggers the logic → test through that consumer/use case at the entry point**: publish a REAL message to the real broker (NATS/Kafka/RabbitMQ testcontainer) and wait for observable side effects — never call the consumer internals or the use case directly. A use case invoked ONLY by a consumer/cron is tested exactly the way production triggers it.
  3. **Pure domain with NO entry point at all (helpers, normalizers, validators called only from within tested chains) → `tests/unit/` direct table tests are allowed** — but when such a function is actually exercised by a use case/consumer chain, prefer asserting its effect through that chain over a direct call.
- The whole chain runs real: Router/Consumer → Use Case → Port → Repository.
- **A use case/service/adapter is NEVER the direct test subject** — it is covered through its entry point. If you find yourself instantiating a use case or adapter in a test while a route or consumer can trigger it, STOP and test through the entry point.
- **Real implementations** for ALL internal components (routers, consumers, use cases, services, ports, repositories, domain objects) — never mock or rewire an internal layer.
- **Mocks** ONLY for outbound adapters toward external systems (third-party APIs, email, S3, Stripe, payment gateways) — at the HTTP/network boundary (respx/MSW) or via `app.dependency_overrides` / fixtures in `tests/fixtures/external.py`.
- **Real infrastructure** via testcontainers (Postgres / Redis / Kafka / RabbitMQ / LocalStack) — Docker is a hard requirement — see `references/testcontainers.md`. If Docker is unavailable, fail fast with a clear error; never silently fall back.

## 🗂️ Test layout (non-negotiable)

```
tests/
├── conftest.py                          # real app + testcontainers + httpx AsyncClient + auth helpers
├── fixtures/
│   └── external.py                      # mocks for external adapters (configurable failures)
├── behavioral/
│   └── <feature>/
│       └── test_<endpoint>.py           # EVERYTHING over HTTP — all branches
└── unit/                                # ONLY: pure domain without HTTP entry, scripts, consumers
```

- `tests/behavioral/<feature>/test_<endpoint>.py` — one file per endpoint, all branches covered (happy path, validation, auth, conflicts, external failures). This is the default and the bulk of the suite.
- `tests/unit/` — reserved for pure domain logic with NO HTTP entry point, standalone scripts, and queue/cron consumers. Never put an endpoint test here.
- `tests/conftest.py` — the only place for global fixtures: real app factory, testcontainers infra, httpx client, auth helpers (login via the real API → reusable auth headers).

A fake/stub that diverges silently from the real implementation produces tests that pass but don't detect real regressions. Testing through the router exercises the exact wiring production uses (DI, middleware, validation, error mapping) — cost stays low and confidence high.

## 🎯 Workflow
1. **Ask for context** — which route/endpoint (feature) needs testing?
2. **Read the source code** — the router AND the whole chain it triggers (use case, ports, adapters, entities).
3. **Classify dependencies** — internal → real impl, wired exactly as in production; external → mock via `app.dependency_overrides` or fixtures in `tests/fixtures/external.py`.
4. **Load templates** — `references/router-test.md` (PRIMARY: behavioral test from the router, in `tests/behavioral/<feature>/test_<endpoint>.py`); `references/consumer-test.md` when the logic is triggered by a queue/cron consumer (real message → side effects); `references/conftest.md` for app/client/db fixtures and auth helpers; `references/testcontainers.md` for real infrastructure; `references/external-fixtures.md` for mock factories with configurable failures. `references/use-case-test.md` ONLY for logic with NO route and NO consumer (cron jobs, pure domain algorithms) — those tests live in `tests/unit/`.
5. **Write tests** — AAA pattern (Arrange, Act, Assert), explicit names, one logical behavior per test. Act = one HTTP request; Assert = status + body + side effects.
6. **Run** — `uv run pytest` (see `references/commands.md`).

## 🛡️ Edge cases (mandatory coverage)
Every test suite MUST cover edge cases, not just the happy path. For each route under test, include tests asserting the correct HTTP status + error body:
- **Validation** — missing required field, wrong type, schema failure, out-of-range enum, oversized payload → 422
- **Auth / permissions** — unauthenticated → 401, wrong role → 403, foreign resource → 404
- **Not found / conflicts** — unknown id → 404, already-exists → 409, already-deleted, duplicate creation
- **Empty / boundary values** — empty list, page 1 / page size boundary, offset equals total count, single-element collections
- **Concurrency / race conditions** — duplicate concurrent requests, idempotency key replay (when applicable)
- **External adapter failure** — outbound adapter raises, returns error, times out, returns empty → the route still responds correctly (no silent swallow, no 500)

If the feature under test has domain invariants or business rules, add at least one test per invariant that violates it via the API and asserts the correct error response.

## What you never do
- Test a use case in isolation when it is exposed via an HTTP route — test it from the router instead
- Test a use case, service, or infrastructure adapter DIRECTLY (instantiated in the test) when a route OR a consumer triggers it — go through the entry point (route = HTTP request; consumer = real published message)
- Mock internal components to force a use case/adapter into a testable state (e.g. patch `LLMClient`, a storage client, or any internal class) instead of mocking the external HTTP API it calls
- Place an endpoint test anywhere outside `tests/behavioral/<feature>/test_<endpoint>.py`
- Put a test with an HTTP entry point in `tests/unit/` — unit is for pure domain, scripts, and consumers only
- Write an `InMemoryXxxRepository` or any other fake for an internal implementation
- Mock a domain class, use case, domain object, or internal repository
- Rebuild a partial test app that omits or rewires real internal providers — use the real app factory with the full chain wired
- Write a test that verifies an internal interaction (spy on an internal method) rather than an observable behavior
- Mock something just to make a test pass

## Related skills
- `hexagonal-python-patterns` — project structure and layer rules
- `async-python-patterns` — async design patterns (test the patterns you implement)

## References
- `references/router-test.md` — behavioral test from the router (PRIMARY template)
- `references/consumer-test.md` — behavioral test through a consumer: real message published to the real broker, observable side effects only (SECONDARY template)
- `references/conftest.md` — pytest fixtures (app, httpx client, testcontainers PG session) and test structure
- `references/external-fixtures.md` — mock factories for external adapters (email, Stripe, S3)
- `references/testcontainers.md` — real infrastructure for tests (Postgres, Redis, Kafka, RabbitMQ, LocalStack)
- `references/use-case-test.md` — EXCEPTION: use case tested directly, only for non-HTTP non-consumer entry points (cron, pure domain) — lives in `tests/unit/`
- `references/commands.md` — pytest commands (run, watch, coverage, single test)
