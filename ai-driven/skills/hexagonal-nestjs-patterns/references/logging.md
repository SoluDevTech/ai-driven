# Logging — Mandatory Conventions

All log messages are centralized as constants in `src/domain/logging/`. Every log call MUST reference a message constant — inline strings and template literals in log calls are FORBIDDEN.

## Project structure

```
src/
└── domain/
    └── logging/
        ├── use-case-log-messages.ts    # UseCaseLogMessage
        ├── adapter-log-messages.ts    # AdapterLogMessage (postgres, email...)
        └── consumer-log-messages.ts   # ConsumerLogMessage (queue lifecycle)
```

One constants object per scope, one file per object. Add a NEW message FIRST, then write the call — never the other way around.

## Message constant template

```typescript
// src/domain/logging/use-case-log-messages.ts
export const UseCaseLogMessage = {
  CONFIRMATION_RECEIVED: 'Confirmation received for project %s, document %s (correlation %s)',
  FORWARDING_CREATE_TO_SCRAPPER: 'Forwarding CREATE to scrapper for project %s, document %s (correlation %s)',
  PROCESSING_COMPLETED: 'Processing completed for project %s in %d ms',
} as const

export type UseCaseLogMessage = (typeof UseCaseLogMessage)[keyof typeof UseCaseLogMessage]
```

Message templates use **lazy `%s`/`%d` placeholders** (util.format style) — arguments are passed at call time, never interpolated into the string.

## Call rules (checklist — every log call)

1. **Message constant only** — `this.logger.verbose(UseCaseLogMessage.CONFIRMATION_RECEIVED, projectId, documentId, correlationId)`. NEVER `logger.log('Received confirmation...')` or `` logger.log(`...${id}`) ``.
2. **Lazy formatting** — NestJS built-in loggers (and Pino/pino-pretty) support `util.format`-style variadic args. Pass arguments positionally; no template literals, no `.format()` on the message, no string concatenation.
3. **Errors** — inside `catch`, use `this.logger.error(UseCaseLogMessage.X, args, stack)` or rethrow through the exception filter. NEVER `logger.error(\`failed: ${e.message}\`)`.
4. **Where loggers live** — controllers, use cases, adapters (`infrastructure/`), consumers, schedulers, bootstrap. NEVER log inside `domain/entities/`, `domain/ports/`, or pure domain services.
5. **Business identifiers as arguments** — ids and correlation ids are `%s` arguments, never interpolated into the template, never logged as whole-payload dumps by default.
6. **One message = one constant** — a distinct event gets its own constant with a stable, greppable wording.
7. **Right level** — `verbose` for internals, `log` (info) for business milestones, `warn` for recoverable anomalies, `error` for failures.

## Anti-patterns → correct

```typescript
// ❌ FORBIDDEN — inline string
this.logger.log(`Confirmation received for project ${projectId}`)

// ❌ FORBIDDEN — template literal hides args from log aggregators
this.logger.log(`Forwarding CREATE for ${projectId}/${documentId}`)

// ❌ FORBIDDEN — error swallowed into a string
this.logger.error(`Kafka publish failed: ${error.message}`)

// ✅ CORRECT — message constant + lazy args
this.logger.log(UseCaseLogMessage.CONFIRMATION_RECEIVED, projectId, documentId, correlationId)

// ✅ CORRECT — error with message constant + stack trace
catch (error) {
  this.logger.error(ConsumerLogMessage.PROCESSING_FAILED, projectId, (error as Error).stack)
  throw error
}
```

## Why

- Grep/aggregate by message across services; constants keep wording stable and reviewed.
- Lazy args keep structured-data indexing possible and avoid formatting cost when the level is disabled.
- Centralizing in `domain/logging/` makes the audit surface (what is logged, at which level, with which ids) explicitly reviewable — see the code-reviewer checklist that audits log calls.