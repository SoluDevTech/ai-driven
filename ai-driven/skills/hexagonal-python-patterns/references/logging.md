# Logging — Mandatory Conventions

All log messages are centralized as `StrEnum` members in `src/domain/logging/`. Every `logger.*()` call MUST reference an enum member — inline strings and f-strings in log calls are FORBIDDEN.

## Project structure

```
src/
└── domain/
    └── logging/
        ├── use_case_log_messages.py    # UseCaseLogMessage
        ├── adapter_log_messages.py    # AdapterLogMessage (postgres, kafka, email...)
        ├── kafka_log_messages.py      # KafkaLogMessage (consumer/producer lifecycle)
        └── scheduler_log_messages.py  # SchedulerLogMessage (cron lifecycle)
```

One enum per scope, one file per enum. Add a NEW member to the relevant enum FIRST, then write the call — never the other way around.

## Enum template

```python
# src/domain/logging/use_case_log_messages.py
from enum import StrEnum


class UseCaseLogMessage(StrEnum):
    """Log messages emitted by application use cases."""

    CONFIRMATION_RECEIVED = "Confirmation received for project %s, document %s (correlation %s)"
    FORWARDING_CREATE_TO_SCRAPPER = "Forwarding CREATE to scrapper for project %s, document %s (correlation %s)"
    PROCESSING_COMPLETED = "Processing completed for project %s in %.3fs"
```

Format strings use **lazy `%s` placeholders** — the enum member is the message template, arguments are passed at call time.

## Call rules (checklist — every log call)

1. **Enum member only** — `logger.info(UseCaseLogMessage.CONFIRMATION_RECEIVED, a, b, c)`. NEVER `logger.info("Received confirmation...")` or `logger.info(f"...")`.
2. **Lazy formatting** — pass arguments positionally; no f-string, no `%` formatting at the call site, no `.format()`.
3. **`logger.exception(...)` for errors** — inside `except` blocks, always `logger.exception(AdapterLogMessage.X, args)` (logs message + traceback). NEVER `logger.error(str(e))` or `logger.error(f"...{e}")`.
4. **Where loggers live** — use cases, adapters (`infrastructure/`), routes, consumers, schedulers, `main.py`. NEVER log inside `domain/entities/` or `domain/ports/` (pure business core).
5. **Business identifiers as arguments** — project id, document id, correlation id are `%s` arguments, never interpolated into the message template, never logged as whole payload dumps by default.
6. **One message = one member** — a distinct event gets its own enum member with a stable, greppable wording. Don't reuse a generic member with ad-hoc meaning.
7. **Right level** — `debug` for verbose internals, `info` for business milestones, `warning` for recoverable anomalies, `exception` for failures inside except blocks.

## Anti-patterns → correct

```python
# ❌ FORBIDDEN — inline string
logger.info(f"Confirmation received for project {project_id}")

# ❌ FORBIDDEN — f-string hides the args from log aggregators
logger.info(f"Forwarding CREATE for {project_id}/{document_id}")

# ❌ FORBIDDEN — error swallowed into a string
logger.error(f"Kafka publish failed: {exc}")

# ✅ CORRECT — enum member + lazy args
logger.info(UseCaseLogMessage.CONFIRMATION_RECEIVED, project_id, document_id, correlation_id)

# ✅ CORRECT — exception logs message + traceback
try:
    await self._publisher.publish(create_message)
except PublishError:
    logger.exception(AdapterLogMessage.PUBLISH_FAILED, project_id, document_id)
    raise
```

## Why

- Grep/aggregate by message across services; enum members keep wording stable and reviewed.
- Lazy `%s` args keep structured-data indexing possible and avoid formatting cost when the level is disabled.
- Centralizing in `domain/logging/` makes the audit surface (what is logged, at which level, with which ids) explicitly reviewable — see the code-reviewer checklist that audits log calls.