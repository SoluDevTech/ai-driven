# pytest Commands

```bash
# Run all tests
uv run pytest

# With coverage
uv run pytest --cov=src --cov-report=html

# Specific test file
uv run pytest tests/unit/test_use_cases.py -v

# Single test
uv run pytest tests/unit/test_use_cases.py::TestCreateUserUseCase::test_creates_user_successfully -v

# Watch mode (requires pytest-watch)
ptw -- -x

# Parallel (requires pytest-xdist)
uv run pytest -n auto
```

## Best Practices
- **Explicit names**: `test_raises_when_email_already_exists` > `test_error`
- **One logical assert per test** (multiple asserts OK if same concept)
- **Independent tests**: no shared state between tests — each test gets a fresh db session
- **Reusable fixtures**: factor out common setup in `conftest.py` and `tests/fixtures/`
- **Coverage ≥ 80%**: but prioritize quality over quantity