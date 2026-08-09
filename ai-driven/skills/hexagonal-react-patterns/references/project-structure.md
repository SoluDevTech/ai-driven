# Project Structure

Reproduce this 3-layer layout. Each layer has a single responsibility and a single dependency direction: `application → domain ← infrastructure`.

```
├── src/
│   ├── application/          # Application layer (UI)
│   │   ├── components/       # React components (presentational + container)
│   │   ├── hooks/            # Custom React hooks (business logic consumption)
│   │   ├── pages/            # Page components (route-level)
│   │   └── providers/        # Context providers (state management)
│   ├── domain/               # Domain layer (business logic)
│   │   ├── entities/         # Domain entities (business models)
│   │   ├── ports/            # Interfaces/contracts (repositories, services)
│   │   ├── services/         # Domain utilities (pure functions)
│   │   ├── errors/           # Redefined and centralised error types and messages
│   │   └── logging/          # Centralised log messages
│   └── infrastructure/       # Infrastructure layer (external dependencies)
│       ├── api/              # API clients (HTTP, GraphQL)
│       ├── assets/           # Static assets (images, fonts, icons)
│       └── config/           # Configuration implementations
├── tests/
│   ├── unit/                 # Unit tests
│   └── doubles/              # Mock implementations (test doubles)
├── .github/workflows/        # CI/CD
├── package.json
├── tsconfig.json
├── biome.json                # Biome config (linter + formatter)
└── vite.config.ts            # or next.config.js
```

## What lives where

| Layer | Can import | Cannot import | Contains |
|---|---|---|---|
| `domain/` | only stdlib + Zod | React, JSX, hooks, components, API clients | entities, ports, pure services, errors, logging |
| `application/` | `domain/`, React, hooks, UI primitives | `infrastructure/` directly | components, hooks, pages, providers |
| `infrastructure/` | `domain/` ports, external SDKs, React only for config UI | `application/` | api clients, assets, config adapters |

## Naming inside each layer
- **Components** (application): `PascalCase.tsx` — `UserProfile.tsx`
- **Hooks** (application): `camelCase.ts` with `use` prefix — `useUserProfile.ts`
- **Ports** (domain): `PascalCase` interfaces — `UserRepository`, `EmailSender`
- **Entities** (domain): `PascalCase` classes or `type` — `User.ts`
- **Adapters** (infrastructure): `<Stack><Port>.ts` — `ApiUserRepository.ts`, `SmtpEmailSender.ts`
- **Tests**: `*.test.tsx` or `*.spec.tsx`

## No barrel files
❌ Never use `index.ts` files for re-exporting dependencies across layers. Import directly from the source file. Barrels hide the real dependency graph and break tree-shaking.