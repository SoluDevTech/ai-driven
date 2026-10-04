# conftest.py and Test Structure

## Test Structure
```
tests/
├── api/                          # Behavioral tests from the router (main focus)
│   ├── test_users_api.py
│   └── test_orders_api.py
├── unit/                         # EXCEPTION — non-HTTP logic only (cron, queue, pure domain)
├── fixtures/
│   └── external.py               # Fixtures for mocked external calls
└── conftest.py                   # app, client, db session fixtures
```

## conftest.py — app + httpx client + real DB session

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

## Docker is a hard requirement
Do NOT add a SQLite fallback. If the container fails to start, wrap startup in `try/except` and re-raise a clear error (see the fail-fast pattern in `router-test.md`) so the suite exits non-zero on the very first test.

## Why real implementations
Using real implementations ensures tests reflect actual behavior. A fake that diverges silently from the real implementation produces tests that pass but don't detect real regressions. Since external dependencies are mocked, there is no infrastructure cost to using real internal implementations.
