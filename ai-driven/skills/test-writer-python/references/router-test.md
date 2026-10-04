# Behavioral Test from the Router (PRIMARY template)

The test entry point is an HTTP request through the real FastAPI app; the observable behavior is the HTTP response plus side effects (DB state, emitted events). The full chain runs real: Router → Use Case → Port → Repository.

- **Act** = one HTTP call via httpx `AsyncClient` + `ASGITransport` (no live server, no network)
- **Assert** = status code + response body + persistence via the real repository
- **Infra** = real Postgres via testcontainers (see `testcontainers.md`)
- **Externals** = the ONLY mocked boundary (email, Stripe, S3) via `app.dependency_overrides` or fixtures

## Test structure
```
tests/
├── api/                        # Behavioral tests from the router (main focus)
│   ├── test_users_api.py
│   └── test_orders_api.py
├── unit/                       # EXCEPTION: non-HTTP logic only (cron, queue, pure domain)
├── fixtures/
│   └── external.py             # Mocks for external calls only
└── conftest.py                 # app, client, pg_session fixtures
```

## conftest.py — real app + client + testcontainers PG

```python
import pytest
import pytest_asyncio
from httpx import ASGITransport, AsyncClient
from testcontainers.postgres import PostgresContainer
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession

from src.main import create_app        # real app factory — full chain wired
from src.infrastructure.persistence.base import Base


@pytest.fixture(scope="session")
def postgres_url():
    with PostgresContainer("postgres:16-alpine") as pg:
        yield pg.get_connection_url(driver="asyncpg")


@pytest_asyncio.fixture
async def pg_session(postgres_url):
    engine = create_async_engine(postgres_url)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    async with AsyncSession(engine) as session:
        yield session
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    await engine.dispose()


@pytest_asyncio.fixture
async def app(pg_session, mock_external_adapters):
    """Real app — only external outbound adapters are overridden."""
    application = create_app(session_factory=lambda: pg_session)
    mock_external_adapters(application)   # app.dependency_overrides: EmailPort, StripePort, S3Port...
    yield application
    application.dependency_overrides.clear()


@pytest_asyncio.fixture
async def client(app):
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac
```

## Behavioral test — AAA through the router

```python
from uuid import uuid4
from src.domain.entities import User
from src.infrastructure.persistence.postgres_user_repository import PostgresUserRepository


class TestCreateUserRoute:
    """POST /users — behavior through the full chain."""

    async def test_returns_201_and_persists(self, client, pg_session):
        # Act — ONE HTTP request, real chain behind it
        response = await client.post("/users", json={"email": "test@example.com", "name": "John Doe"})

        # Assert — HTTP contract
        assert response.status_code == 201
        body = response.json()
        assert body["email"] == "test@example.com"
        assert body["name"] == "John Doe"
        assert body["id"] is not None

        # Assert — side effect via the real repository
        repository = PostgresUserRepository(session=pg_session)
        saved = await repository.get_by_id(body["id"])
        assert saved is not None
        assert saved.email == "test@example.com"

    async def test_returns_409_when_email_already_exists(self, client, pg_session):
        # Arrange — seed via the real repository (or via a first API call)
        repository = PostgresUserRepository(session=pg_session)
        await repository.save(User(id=uuid4(), email="test@example.com", name="Existing User"))

        # Act
        response = await client.post("/users", json={"email": "test@example.com", "name": "Another User"})

        # Assert
        assert response.status_code == 409

    async def test_returns_422_when_email_is_missing(self, client):
        response = await client.post("/users", json={"name": "John Doe"})
        assert response.status_code == 422


class TestCreateUserNotification:
    """External adapter behavior — mocked, asserted at the boundary."""

    async def test_sends_welcome_email_on_success(self, client, mock_email_success):
        response = await client.post("/users", json={"email": "test@example.com", "name": "John Doe"})
        assert response.status_code == 201
        mock_email_success.send.assert_called_once()

    async def test_still_201_when_email_times_out(self, client, mock_email_timeout):
        response = await client.post("/users", json={"email": "test@example.com", "name": "John Doe"})
        assert response.status_code == 201
```

## Arranging state
- **Prefer seeding via the API itself** (a first POST, then test the conflict) — exercises real behavior end to end
- **Direct repository seeding** when the state can't be produced via the API (expired tokens, legacy rows) — still the real repository, never a fake

## Docker unavailable?
Do NOT fall back to SQLite. Wrap the container startup in `try/except` and fail fast with a clear error:

```python
@pytest.fixture(scope="session")
def postgres_url():
    try:
        with PostgresContainer("postgres:16-alpine") as pg:
            yield pg.get_connection_url(driver="asyncpg")
    except Exception as exc:
        raise RuntimeError(
            "Docker is required to run the test suite (testcontainers PostgreSQL). "
            "Start Docker and re-run 'uv run pytest'."
        ) from exc
```

A silent fallback produces tests that diverge from production — the suite must exit non-zero instead.

## Reasoning example
> "POST /users wires the user router → CreateUserUseCase → UserRepository (port) → PostgresUserRepository, plus EmailPort (external → mocked via dependency_overrides). I test from the router: one httpx AsyncClient call per behavior, assert status + body, then verify persistence through the real repository against the testcontainers Postgres."
