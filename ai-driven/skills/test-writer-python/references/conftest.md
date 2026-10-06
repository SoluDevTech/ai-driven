# conftest.py and Test Structure

## Test Structure
```
tests/
├── conftest.py                    # real app + testcontainers + httpx client + auth helpers
├── fixtures/
│   └── external.py                # mocks for external adapters (configurable failures)
├── behavioral/                    # Behavioral tests from the router (main focus)
│   └── <feature>/
│       ├── test_create_user.py
│       └── test_get_order.py
└── unit/                          # ONLY: pure domain without HTTP entry, scripts, consumers
```

- `behavioral/<feature>/test_<endpoint>.py` — one file per endpoint; every branch is an HTTP call.
- `unit/` — pure domain logic without an HTTP entry point, standalone scripts, queue/cron consumers. Never an endpoint test.

## conftest.py — real app + httpx client + real DB session

The full fixture set (session-scoped testcontainers PG, real app with `dependency_overrides` for externals only, httpx `AsyncClient`) is described in `router-test.md`. The DB session fixture:

```python
import pytest
from testcontainers.postgres import PostgresContainer
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from src.infrastructure.persistence.base import Base


@pytest.fixture(scope="session")
def postgres_url():
    with PostgresContainer("postgres:16-alpine") as pg:
        yield pg.get_connection_url(driver="asyncpg")


@pytest.fixture
async def pg_session(postgres_url):
    """Real testcontainers Postgres session per test."""
    engine = create_async_engine(postgres_url)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    async with AsyncSession(engine) as session:
        yield session
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    await engine.dispose()
```

## conftest.py — auth helpers

Auth helpers live in `conftest.py` and go through the REAL API — no token forgery, no fake auth:

```python
@pytest_asyncio.fixture
async def auth_headers(client):
    """Register + login through the real API, return reusable auth headers."""
    await client.post("/auth/register", json={
        "email": "test@example.com", "password": "S3curePassw0rd!", "name": "John Doe"
    })
    response = await client.post("/auth/login", json={
        "email": "test@example.com", "password": "S3curePassw0rd!"
    })
    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}", **AUTH_EXTRA_HEADERS}


@pytest_asyncio.fixture
async def admin_headers(client):
    """Same flow for a privileged account (seed the role via the real API or the real repository)."""
    ...
```

Usage in a behavioral test: `await client.get("/users/me", headers=auth_headers)`. Tests for the login route itself live in `behavioral/auth/test_login.py` and must NOT use these helpers — they test the flow directly.

## Docker is a hard requirement
Do NOT add a SQLite fallback. If the container fails to start, wrap startup in `try/except` and re-raise a clear error (see the fail-fast pattern in `router-test.md`) so the suite exits non-zero on the very first test.

## Why real implementations
Using real implementations ensures tests reflect actual behavior. A fake that diverges silently from the real implementation produces tests that pass but don't detect real regressions. Since external dependencies are mocked, there is no infrastructure cost to using real internal implementations.