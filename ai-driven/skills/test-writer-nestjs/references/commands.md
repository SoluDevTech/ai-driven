# Jest Commands

```bash
# Run all tests (behavioral + unit)
npm run test

# Watch mode
npm run test:watch

# With coverage
npm run test:cov

# Single behavioral file
npx jest test/behavioral/users/create-user.spec.ts --verbose

# Single test by name
npx jest --testNamePattern="creates and persists a new user"

# Unit-only exceptions (pure domain, scripts, consumers)
npx jest test/unit/
```

## Best Practices
- **Explicit names**: `returns 201 with the created user` > `test user creation`
- **One logical behavior per test** (multiple assertions OK if they describe the same observable outcome)
- **Behavioral tests from the router**: one Supertest call per behavior on the real AppModule, one spec per endpoint in `test/behavioral/<feature>/<endpoint>.spec.ts` (see `router-test.md`) — `npm run test`
- **Independent modules**: each test gets a fresh app instance; reset data between tests (`users.clear()`), don't recreate the container
- **Always call `app.close()`** in `afterAll` to release DB connections and avoid open handle warnings
- **Reusable provider factories**: factor out external-adapter mocks (configurable failures: success/error/timeout/empty) in `test/fixtures/external.ts` as plain factory functions returning NestJS provider objects
- **Shared bootstrap + auth helpers** in `test/setup.ts` — register/login via the real API, never forged tokens
- **Configure the app exactly as production** in behavioral tests (`useGlobalPipes`, `useGlobalFilters`, etc.)
- **Coverage ≥ 80%**: but prioritize quality over quantity