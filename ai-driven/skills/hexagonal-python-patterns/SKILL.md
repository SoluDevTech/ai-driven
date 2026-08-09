---
name: hexagonal-python-patterns
description: "FastAPI backend with hexagonal architecture, SOLID principles, and KISS. Project structure, config, dependencies, routes, use cases, entities, errors, logging, and ports patterns."
---

# Instructions: FastAPI Backend with Hexagonal Architecture

You are a Python/FastAPI expert. Create a backend following hexagonal architecture, SOLID principles, and KISS.

## 🏗️ Project Structure

```
├── .github/workflows/         # CI/CD (tests, linting, deploy)
├── src/
│   ├── main.py               # FastAPI app
│   ├── config.py             # Pydantic Settings
│   ├── dependencies.py       # Dependency injection
│   ├── domain/               # Business core
│   │   ├── entities/         # Business entities (Pydantic)
│   │   ├── ports/            # Interfaces (ABC)
|   │   |  ├── inbound/            # Interfaces for application use cases entry points(ABC)
|   │   |  ├── outbound/            # Interfaces for infrastructure implementation (ABC)
│   │   └── services/         # Business services (optional, required if use case logic start to be heavy)
│   │   └── errors/           # Redefined and centralised all errors types and messages
│   │   └── logging/          # Centralised all log messages
│   ├── application/
│   │   ├── requests/         # Input DTOs (Pydantic)
│   │   └── responses/        # FastAPI responses output DTOs (Pydantic)z
│   │   ├── use_cases/        # Application logic
│   │   └── routes/           # FastAPI routes
│   └── infrastructure/       # One folder = one implementation
│       ├── postgres/         # adapter.py + models.py
│       ├── mongodb/          # adapter.py + models.py
│       └── email/            # adapter.py
```

For per-layer file templates, load the relevant reference file below.

## Core principles

- **Domain stays pure**: entities hold invariants, no framework/infra imports inside `domain/`.
- **Application orchestrates**: use cases coordinate domain + ports; no direct infrastructure calls.
- **Infrastructure adapts**: one folder per concrete adapter (`postgres/`, `mongodb/`, `email/`).
- **Ports = ABCs**: interfaces in `domain/ports/` (`inbound/` for app entry points, `outbound/` for infra contracts).
- **Inbound/outbound split**: inbound ports invoked by routers/schedulers/consumers; outbound ports implemented by adapters.
- **Direct transformations**: convert at the adapter boundary inline; no `from_entity` / `to_entity` mapper helpers.
- **No Response DTOs for domain**: response/request DTOs live in `application/`; domain entities stay domain-shaped.
- **Centralized errors**: all error codes, messages, and custom exceptions in `domain/errors/`.
- **Centralized logging**: all log message enums in `domain/logging/`.
- **KISS**: no `__init__.py` unless re-export is genuinely needed; prefer flat, explicit imports.

## Workflow

1. **Pre-flight**: read the repo `AGENTS.md` for existing conventions and tooling.
2. **Scaffold structure** → `references/project-structure.md` — create the directory tree.
3. **Bootstrap app** → `references/main-config-dependencies.md` — `main.py`, `config.py`, `dependencies.py`.
4. **Wire routes/DTOs** → `references/routes-requests-responses.md` — `routes/`, `requests/`, `responses/`.
5. **Implement use cases** → `references/use-cases.md` — application logic + inbound ports.
6. **Define entities** → `references/entities.md` — `domain/entities/` Pydantic models.
7. **Centralize errors** → `references/errors.md` — error codes, messages, custom exceptions.
8. **Centralize logging** → `references/logging.md` — log message enums.
9. **Define ports** → `references/ports.md` — `domain/ports/inbound/` + `domain/ports/outbound/` ABCs.

## References

- `references/project-structure.md` — Directory tree and folder responsibilities.
- `references/main-config-dependencies.md` — `main.py`, `config.py`, `dependencies.py` templates (lifespan, settings, DI).
- `references/routes-requests-responses.md` — `routes/`, `requests/`, `responses/` templates (routers + DTOs).
- `references/use-cases.md` — `use_cases/` template (application logic + inbound port usage).
- `references/entities.md` — `domain/entities/` Pydantic entity templates.
- `references/errors.md` — Error codes, `ErrorMessage` enum, custom exceptions.
- `references/logging.md` — Log message `StrEnum` templates.
- `references/ports.md` — `domain/ports/` ABC interfaces (inbound/outbound).