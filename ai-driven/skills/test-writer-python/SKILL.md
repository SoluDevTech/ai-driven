---
name: test-writer-python
description: Write unit and integration tests for Python/FastAPI hexagonal apps. pytest + pytest-asyncio. Golden rule: real implementations for internal components, mocks only for outbound external adapters. Use when testing a use case, adapter, route, or async flow in a Python backend.
---

# Test Writer — Python

Write clear, maintainable tests for a Python/FastAPI hexagonal backend with pytest and pytest-asyncio.

## Use this skill when
- Testing a use case, adapter, route, or async flow in a Python backend
- You need fixtures for external adapters (email, Stripe, S3)
- You're unsure whether to mock or use the real implementation

## Do not use this skill when
- The task is project structure → use `hexagonal-python-patterns`
- The task is async patterns design → use `async-python-patterns`
- The task is React or NestJS testing → use `test-writer-react` / `test-writer-nestjs`

## 🎯 Golden Rule (non-negotiable)
- **Real implementations** for ALL internal components (repositories, services, use cases, domain objects)
- **Mocks** ONLY for outbound adapters toward external systems (third-party APIs, email, S3, Stripe, payment gateways)
- **Real infrastructure** via testcontainers for integration tests against real Postgres / Redis / Kafka / RabbitMQ / LocalStack — see `references/testcontainers.md`

A fake/stub that diverges silently from the real implementation produces tests that pass but don't detect real regressions. Mocking only the external boundary keeps cost low and confidence high.

## 🎯 Workflow
1. **Ask for context** — which use case or component needs testing?
2. **Read the source code** — understand the interface and expected behavior.
3. **Classify dependencies** — internal → real impl; external → mock via fixtures.
4. **Load templates** — `references/conftest.md` for db session fixtures; `references/use-case-test.md` for the AAA pattern; `references/external-fixtures.md` for mock factories; `references/testcontainers.md` for integration tests against real infrastructure.
5. **Write tests** — AAA pattern (Arrange, Act, Assert), explicit names, one logical assert per test.
6. **Run** — `uv run pytest` (see `references/commands.md`).

## 🛡️ Edge cases (mandatory coverage)
Every test suite MUST cover edge cases, not just the happy path. For each use case / adapter / route under test, include tests for:
- **Null / None / undefined inputs** — pass `None` where a value is expected, assert the correct error is raised
- **Empty / boundary values** — empty list `[]`, empty string `""`, `0`, negative numbers, `datetime.min` / `datetime.max`, single-element collections
- **Off-by-one boundaries** — first/last index, page 1, page size boundary, offset equals total count
- **Invalid / malformed input** — wrong type, schema validation failure, out-of-range enum value, oversized payload
- **Concurrency / race conditions** — duplicate concurrent requests, idempotency key replay (when applicable)
- **External adapter failure** — outbound adapter raises, returns error, times out, returns empty — assert the use case handles it gracefully (no silent swallow)
- **State transitions** — already-exists, not-found, already-deleted, duplicate creation

If the feature under test has domain invariants or business rules, add at least one test per invariant that violates it and asserts the correct domain error.

## What you never do
- Write an `InMemoryXxxRepository` or any other fake for an internal implementation
- Mock a domain class, use case, or domain object
- Mock an internal repository
- Write a test that verifies an internal interaction (spy on an internal method) rather than an observable behavior
- Mock something just to make a test pass

## Related skills
- `hexagonal-python-patterns` — project structure and layer rules
- `async-python-patterns` — async design patterns (test the patterns you implement)

## References
- `references/conftest.md` — pytest fixtures (in-memory SQLite session) and test structure
- `references/use-case-test.md` — testing a use case with real repo + mocked external, AAA pattern
- `references/external-fixtures.md` — mock factories for external adapters (email, Stripe, S3)
- `references/testcontainers.md` — real infrastructure for integration tests (Postgres, Redis, Kafka, RabbitMQ, LocalStack)
- `references/commands.md` — pytest commands (run, watch, coverage, single test)