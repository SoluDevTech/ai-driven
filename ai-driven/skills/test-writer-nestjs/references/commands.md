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
- **Explicit names**: `returns 201 with the created user` > `test user creation`
- **One logical behavior per test** (multiple assertions OK if they describe the same observable outcome)
- **Behavioral tests from the router**: one Supertest call per behavior on the real AppModule (see `router-test.md`) — `npm run test:e2e`
- **Independent modules**: each test gets a fresh app instance; reset data between tests (`users.clear()`), don't recreate the container
- **Always call `app.close()`** in `afterAll` to release DB connections and avoid open handle warnings
- **Reusable provider factories**: factor out external-adapter mocks in `test/fixtures/external.ts` as plain factory functions returning NestJS provider objects
- **Configure the app exactly as production** in behavioral tests (`useGlobalPipes`, `useGlobalFilters`, etc.)
- **Coverage ≥ 80%**: but prioritize quality over quantity