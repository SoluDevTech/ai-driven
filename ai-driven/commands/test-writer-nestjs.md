---
description: "Write behavioral and integration tests for NestJS hexagonal backends. Jest, ts-jest, Supertest on the real AppModule. Golden rule: tests start from the router with the full chain wired real (controller → use case → port → repo), testcontainers for real infra, mocks only for outbound external adapters (email, Stripe, S3). Use when testing a route, controller, use case, service, or adapter in a NestJS app."
subtask: true
---

Load the skill named "test-writer-nestjs" using the `skill` tool, then apply it to the following task:

$ARGUMENTS

