# Vitest Commands

```bash
# Run all tests
pnpm vitest

# Watch mode
pnpm vitest --watch

# With coverage
pnpm vitest --coverage

# Single file
pnpm vitest src/components/CartSummary/CartSummary.test.tsx

# Single test by name
pnpm vitest -t "removes an item when the remove button is clicked"

# Only the unit project (no Docker)
pnpm vitest --project unit

# Including integration (needs Docker)
pnpm vitest --project integration
```

## Best Practices
- **Query by role first**: `getByRole` > `getByLabelText` > `getByText` > `getByTestId`
- **Explicit names**: `test_removes_item_on_click` > `test_click`
- **One logical behavior per test** (multiple assertions OK if they describe the same observable outcome)
- **Independent tests**: reset store/context state in `beforeEach`, never rely on test execution order
- **Reusable fixtures**: factor out mock factories in `tests/fixtures/` and render helpers in `tests/utils/`
- **Coverage ≥ 80%**: but prioritize testing real user interactions over line coverage