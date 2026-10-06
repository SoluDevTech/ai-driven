# Testing Through a Processor — behavioral, at the message/job entry point (SECONDARY template)

> **When the logic has no HTTP route but a queue processor, messaging consumer, or scheduler triggers it**, the test entry point is a REAL message or job in the REAL broker (testcontainer). Never instantiate the processor or the use case. Everything behind the message runs exactly as in production (guards → use case → ports → repositories); the ONLY mocked boundary is outbound external adapters (email, Stripe, S3, third-party APIs).

## Decision order (reminder)
1. Route exists → `router-test.md` (Supertest request)
2. Processor/consumer/scheduler triggers it → **THIS template** (real published message or enqueued job)
3. Neither → `use-case-test.md` / `repository-test.md` / pure domain (`test/unit/`)

## Test structure
```
test/behavioral/<feature>/<flow>.spec.ts   # one file per message flow, all branches
```

## Setup (test/setup.ts)
- Session testcontainers: broker (Bull/Redis, Kafka, RabbitMQ), Postgres
- Real AppModule bootstrapped — consumers/processors registered by production wiring (module `OnModuleInit`, Bull workers, etc.)
- Publish helper for the real broker/queue (e.g. `queue.add(...)`, producer client)
- DB seeding + side-effect polling helpers with deadlines (processing is async)

## Behavioral test — AAA through the message entry point

```typescript
it('creates the order and publishes the event', async () => {
  // Arrange — seed pre-state + mock external adapters via overrideProvider
  await seedOrderRow(orderId);

  // Act — ONE real job/message in the REAL broker
  await orderQueue.add('process', { orderId });

  // Assert — observable side effects ONLY (wait with deadline)
  await waitFor(async () => {
    const row = await orderRepo.findById(orderId);
    expect(row?.status).toBe('PROCESSED');
  });
  expect(externalAdapterMock.send).toHaveBeenCalledTimes(1);
});
```

## All branches, still from the message entry point

| Branch | How to trigger it (Arrange) | Assert (side effect) |
|---|---|---|
| Happy path | valid job/message | status transition + persisted row + external adapter called |
| Validation failure | invalid payload / poisoned message | job failed, stable error persisted, message not re-consumed forever |
| Idempotency / redelivery | enqueue the SAME job twice | no duplicate side effects (count rows) |
| External adapter failure | overrideProvider throws | job failed/staged for retry per policy, DB state intact |
| Partial failure isolation | one outbound adapter throws mid-flow | flow continues per spec (best-effort steps traced), observable state matches |

## What you never do (even here)
- Instantiate the processor/use case or call `processor.handleJob()` directly
- `overrideProvider` on internal use cases/services/repositories to "get a handle" on the chain
- Assert on internal calls (`jest.spyOn` on an internal service) instead of DB rows / published events
- Unbounded waits without deadline; poll observable state instead

## Reasoning example
> "ProcessOrderUseCase has no HTTP route — a Bull processor consumes it. I test by seeding the order row, enqueueing a REAL job on the REAL Bull queue backed by the Redis testcontainer, waiting for the status transition via the real repository, and asserting the Stripe mock received the charge call. Stripe is external → overrideProvider; everything internal runs real."