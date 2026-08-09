# Checklist

Run end-to-end before declaring a task done. Each item must be checked.

## Architecture
- [ ] 3 layers: domain / application / infrastructure
- [ ] Domain independent (only Zod allowed for validation)
- [ ] Use cases depend on ports, not adapters
- [ ] Ports split into `inbound/` (use case entry) and `outbound/` (infra contracts)
- [ ] Infrastructure: one folder per adapter (`adapter.ts` + `entities/`/`schemas/` + `module.ts`)
- [ ] Injection tokens (symbols) for loose coupling
- [ ] No `index.ts` barrel files re-exporting across layers

## SOLID & KISS
- [ ] SRP: one class = one responsibility
- [ ] OCP: extension via new adapters, never modify ports
- [ ] LSP: all implementations respect their port's contract
- [ ] ISP: small, targeted interfaces (no ports with 20 methods)
- [ ] DIP: depend on abstractions via `@Inject(TOKEN)`
- [ ] Direct transformations with spread operators
- [ ] No `fromEntity()`, `toEntity()` methods
- [ ] No Response DTOs unless serialization is genuinely needed

## TypeScript
- [ ] TypeScript 5.0+ strict mode
- [ ] Types mandatory everywhere (no `any`, use `unknown`)
- [ ] Async/await for all I/O
- [ ] Readonly for immutable properties
- [ ] Naming: classes `PascalCase`, functions `camelCase`, constants `UPPER_SNAKE_CASE`

## Zod
- [ ] Domain entities use Zod schemas in constructors
- [ ] Application DTOs defined as Zod schemas, types via `z.infer`
- [ ] Controllers use `ZodValidationPipe`
- [ ] Config validated with Zod at bootstrap
- [ ] Schemas composed with `.extend()` / `.pick()` / `.omit()` / `.partial()`

## NestJS
- [ ] Constructor injection everywhere
- [ ] Thin controllers delegate to use cases
- [ ] Exception filters map domain errors to HTTP
- [ ] Guards for auth (`@UseGuards()`)
- [ ] Modules: one per bounded context / adapter
- [ ] Swagger via `@anatine/zod-openapi`

## Testing
- [ ] Real implementations for all internal components (repositories, use cases, entities)
- [ ] Mocks ONLY for outbound adapters toward external systems (email, S3, Stripe, third-party APIs)
- [ ] Jest + ts-jest
- [ ] `Test.createTestingModule()` overrides with real impls, not mock stubs, for internals
- [ ] In-memory adapters satisfy the domain port contract (they're real, not mocks)
- [ ] Coverage ≥ 80%

## DevOps
- [ ] GitHub Actions CI/CD
- [ ] Docker + Docker Compose
- [ ] `.env.example`
- [ ] README.md