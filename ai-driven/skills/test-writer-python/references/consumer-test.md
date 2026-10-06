# Testing Through a Consumer — behavioral, at the message entry point (SECONDARY template)

> **When the logic has no HTTP route but a queue/cron consumer triggers it**, the test entry point is a REAL message published to the REAL broker (testcontainer). Never instantiate the consumer or the use case in the test. Everything behind the message runs exactly as in production (validate → extract → use case → ports → Postgres/MinIO/...); the ONLY intercepted boundary is outbound external HTTP APIs (respx).

## Decision order (reminder)
1. Route exists → `router-test.md` (HTTP request)
2. Consumer triggers it → **THIS template** (real published message)
3. Neither → `use-case-test.md` / pure domain (`tests/unit/`)

## Test structure
```
tests/behavioral/<feature>/test_<flow>.py   # one file per message flow, all branches
```

## Fixtures needed (in conftest.py)
- Session testcontainers: broker (NATS/Kafka/RabbitMQ), Postgres, cache, storage
- Real app wired BEFORE consumer start (env patched before first import)
- Real consumer started via the app lifespan — tests do NOT touch it
- Direct broker publish helper (e.g. JetStream `js.publish(subject, payload)`)
- DB seeding helper (superuser asyncpg/SQLAlchemy) for pre-state the producer normally creates
- Side-effects polling helper with a deadline (message processing is async)

## Behavioral test — AAA through the message entry point

```python
async def test_message_creates_candidate_and_marks_job_done(
    real_app, _real_app_lifespan, seed_job, llm_profile_extractor,
):
    # Arrange — seed the rows the producer guarantees + mock external APIs
    header = _header_dict()
    await seed_job(header["job_id"])
    payload = _encode_message(header, CV_PDF)

    # Act — ONE real message published to the REAL JetStream workqueue
    await _publish_and_wait_job(header["job_id"], payload, expected_status="done")

    # Assert — observable side effects ONLY (DB row, object in bucket, event published)
    ...  # SELECT from the real Postgres testcontainer, stat_object on real MinIO
```

## All branches, still from the message entry point

| Branch | How to trigger it (Arrange) | Assert (side effect) |
|---|---|---|
| Happy path | valid payload | status transition + persisted row |
| Validation failure | invalid/unparsable payload or bytes | status ERROR + `error_message` column + message acked |
| Idempotency / redelivery | publish the SAME message twice | no duplicate side effects (count rows) |
| External API failure | respx mock returns 500 | job ERROR with the STABLE user-facing message |
| External API transient failure then success | respx mock routed BY CONTENT (first call fails) | success — the flow survived |
| Retry/completeness logic | respx mock returns an INCOMPLETE payload first, completion on the schema-partial 2nd call | merged result on the persisted row |
| Best-effort sub-step failure | make the storage/external call raise | flow still completes, sub-step traced as None/warning |

## Mock routing rules (respx) — deterministic, never a fragile iterator
- Route BY CONTENT: the request body identifies the call (schema name, tool name) — immune to SDK-internal transport retries.
- NEVER `iter(...)` + `next()` response sequences: the OpenAI/Kafka SDKs retry internally and silently consume your queue, serving the wrong payload to the wrong attempt.
- Pop named routes in teardown so a stale mock never shadows the next test.

## What you never do (even here)
- Instantiate the consumer or the use case; call `consumer._decode_message`, `use_case.execute` directly
- Mock/patch internal classes (LLM client wrapper, storage client, cache) — mock the external HTTP API instead
- Assert on logs or internal calls instead of DB rows / object storage / published events
- Sleep-based waits without a deadline; poll observable state instead

## Reasoning example
> "MassImportProcessUseCase has no HTTP route — it is triggered by a JetStream workqueue consumer. I test it by seeding the job row (producer's guarantee), publishing a REAL length-prefixed message to the real NATS testcontainer, waiting for the `mass_import_jobs.status` transition via the real repository, then asserting the persisted candidate row and the uploaded MinIO object. OpenRouter is mocked at the HTTP boundary with respx, routed by schema name in the body."