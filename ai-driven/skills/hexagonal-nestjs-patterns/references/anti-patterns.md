# Anti-patterns

Load this before review to catch violations.

## Absolutely Avoid
- ❌ Importing NestJS decorators, TypeORM, or Mongoose in `domain/`
- ❌ Using `any` type (use `unknown` or proper types)
- ❌ Response DTOs (return domain entities directly, unless serialization is genuinely needed)
- ❌ Complex transformation methods (`fromEntity`, `toEntity`)
- ❌ Mocking internal components (use real implementations; mock only outbound external adapters)
- ❌ Over-engineering (unnecessary builders, factories)
- ❌ Direct adapter injection in use cases (always inject via port tokens)
- ❌ In-memory test adapters that drift from the real adapter's behavior (they're real implementations of the port — keep them contract-faithful)
- ❌ `index.ts` files for re-exporting dependencies across layers
- ❌ Defining a port with 20 methods (split into focused interfaces — ISP)
- ❌ Calling `.parse()` twice on the same payload (entities already validate in their factory)
- ❌ Inferring DTO types from entity schemas when the DTO is a subset (define a separate schema)
- ❌ Using `.refine()` for synchronous DB checks (do those in the use case)

## Critical Reminders
1. **Domain** = pure TypeScript + Zod (NO NestJS decorators)
2. **Use cases** depend on **ports** (injection tokens), never **adapters**
3. **Ports** = abstract classes (interfaces don't exist at runtime in TS)
4. **Ports split**: `inbound/` (use case entry) vs `outbound/` (infra contracts)
5. Transformations: `new Class({ ...other })` or spread
6. Tests: test doubles for internal, mocks for external
7. SOLID + KISS above all: simplicity and design principles first