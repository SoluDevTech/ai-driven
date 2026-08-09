# Project Structure

Reproduce this 3-layer layout. Domain is pure; application orchestrates; infrastructure adapts. Ports split into inbound (use case entry points) and outbound (infrastructure contracts).

```
├── .github/workflows/         # CI/CD (tests, linting, deploy)
├── src/
│   ├── main.ts               # NestJS bootstrap
│   ├── app.module.ts         # Root module
│   ├── config/               # Configuration
│   │   └── configuration.ts  # Environment validation (Zod)
│   ├── domain/               # Business core (pure TypeScript + Zod)
│   │   ├── entities/         # Business entities (classes with Zod schemas)
│   │   ├── ports/            # Interfaces (abstract classes)
│   │   │   ├── inbound/      # Interfaces for application use case entry points (abstract classes)
│   │   │   └── outbound/     # Interfaces for infrastructure implementation (abstract classes)
│   │   ├── services/         # Domain services (optional)
│   │   ├── errors/           # Redefined and centralised error types and messages
│   │   └── logging/         # Centralised log messages
│   ├── application/
│   │   ├── requests/         # Input DTOs (Zod schemas)
│   │   ├── responses/        # Output DTOs (Zod schemas)
│   │   ├── use-cases/        # Application logic (injectable services)
│   │   └── controllers/      # NestJS controllers (REST/GraphQL)
│   └── infrastructure/       # One folder = one implementation
│       ├── postgres/         # adapter.ts + entities/ + module.ts
│       ├── mongodb/          # adapter.ts + schemas/ + module.ts
│       └── email/           # adapter.ts + module.ts
└── test/
    ├── unit/                 # Unit tests
    ├── integration/          # Integration tests
    └── doubles/              # Test doubles (fakes)
```

## Dependency direction
| Layer | Can import | Cannot import | Contains |
|---|---|---|---|
| `domain/` | only stdlib + Zod | NestJS, TypeORM, Mongoose | entities, ports (inbound + outbound), services, errors, logging |
| `application/` | `domain/`, NestJS decorators (controllers only) | `infrastructure/` directly | use cases, controllers, request/response DTOs |
| `infrastructure/` | `domain/` ports, TypeORM/Mongoose/SDKs, NestJS modules | `application/` | one folder per adapter: `adapter.ts` + `entities/` or `schemas/` + `module.ts` |

## Inbound vs outbound ports
- **Inbound** (`domain/ports/inbound/`) — entry points for the application. Use cases implement these; controllers call them. Example: `CreateUserUseCase`.
- **Outbound** (`domain/ports/outbound/`) — contracts infrastructure must implement. Example: `UserRepository`, `EmailSender`. Adapters in `infrastructure/` implement these.

```typescript
// domain/ports/inbound/CreateUserUseCase.ts
export abstract class CreateUserUseCase {
  abstract execute(input: CreateUserInput): Promise<User>;
}

// domain/ports/outbound/UserRepository.ts
export abstract class UserRepository {
  abstract findById(id: string): Promise<User | null>;
  abstract save(user: User): Promise<void>;
}
```

## Injection tokens
Use `Symbol` tokens so application code never imports concrete adapters.

```typescript
// domain/ports/outbound/tokens.ts
export const USER_REPOSITORY = Symbol("USER_REPOSITORY");
export const EMAIL_SENDER = Symbol("EMAIL_SENDER");
```

## No barrel files
❌ Never use `index.ts` files for re-exporting dependencies across layers. Import directly from the source file.