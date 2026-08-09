# Jest Commands

```bash
# Run all unit tests
npm run test

# Watch mode
npm run test:watch

# With coverage
npm run test:cov

# Single file
npx jest src/application/use-cases/create-user/create-user.use-case.spec.ts --verbose

# Single test by name
npx jest --testNamePattern="creates and persists a new user"

# E2E tests
npm run test:e2e
```

## Best Practices
- **Explicit names**: `creates and persists a new user` > `test user creation`
- **One logical behavior per test** (multiple assertions OK if they describe the same observable outcome)
- **Independent modules**: each test gets a fresh `Test.createTestingModule` with SQLite `:memory:` — no shared state
- **Always call `module.close()`** in `afterEach` to release DB connections and avoid open handle warnings
- **Reusable provider factories**: factor out mock providers in `test/fixtures/external.ts` as plain factory functions returning NestJS provider objects
- **ValidationPipe in controller tests**: always configure the app the same way as production (`useGlobalPipes`, `useGlobalFilters`, etc.)
- **Coverage ≥ 80%**: but prioritize quality over quantity