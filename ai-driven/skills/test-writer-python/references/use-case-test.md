# Testing a Use Case — EXCEPTION ONLY (`tests/unit/`)

> **Use this template ONLY for logic that has NO HTTP route and NO consumer trigger** (cron jobs, pure domain algorithms). These tests live in `tests/unit/`.
>
> Decision order:
> - Route exposes it → test from the router (`router-test.md`).
> - A queue/cron consumer triggers it → test via `consumer-test.md` (real message published to the real broker, observable side effects only) — do NOT instantiate the use case here.
> - Adapter/internal service → NEVER a direct test subject; its behavior is asserted through whichever entry point triggers it.
> - Pure domain with no entry point → direct unit test allowed (`tests/unit/`).

Real repository backed by testcontainers Postgres; external adapters mocked via fixtures. AAA pattern: Arrange, Act, Assert. Docker is a hard requirement — no SQLite fallback.

```python
import pytest
from uuid import uuid4
from unittest.mock import patch, AsyncMock
from src.domain.entities import User
from src.application.use_cases import CreateUserUseCase
from src.application.requests import CreateUserRequest
from src.infrastructure.persistence.postgres_user_repository import PostgresUserRepository

class TestCreateUserUseCase:
    """Tests for CreateUserUseCase."""

    @pytest.fixture
    def use_case(self, pg_session) -> CreateUserUseCase:
        repository = PostgresUserRepository(session=pg_session)
        return CreateUserUseCase(user_repository=repository)

    @pytest.fixture
    def valid_request(self) -> CreateUserRequest:
        return CreateUserRequest(
            email="test@example.com",
            name="John Doe"
        )

    async def test_creates_user_successfully(
        self,
        use_case: CreateUserUseCase,
        valid_request: CreateUserRequest,
        pg_session
    ):
        """Should create and persist a new user."""
        # Act
        result = await use_case.execute(valid_request)

        # Assert
        assert result.email == valid_request.email
        assert result.name == valid_request.name

        # Verify real persistence
        repository = PostgresUserRepository(session=pg_session)
        saved_user = await repository.get_by_id(result.id)
        assert saved_user is not None
        assert saved_user.email == valid_request.email

    async def test_raises_when_email_already_exists(
        self,
        use_case: CreateUserUseCase,
        valid_request: CreateUserRequest,
        pg_session
    ):
        """Should raise DuplicateEmailError when email exists."""
        # Arrange — insert via real repository
        repository = PostgresUserRepository(session=pg_session)
        await repository.save(User(id=uuid4(), email=valid_request.email, name="Existing User"))

        # Act & Assert
        with pytest.raises(DuplicateEmailError):
            await use_case.execute(valid_request)
```

## Using external fixtures

```python
from tests.fixtures.external import mock_email_success, mock_email_timeout

class TestCreateUserWithNotification:

    async def test_sends_welcome_email_on_success(
        self,
        use_case,
        valid_request,
        mock_email_success
    ):
        """Should trigger a welcome email after successful creation."""
        await use_case.execute(valid_request)
        mock_email_success.assert_called_once()

    async def test_does_not_fail_when_email_times_out(
        self,
        use_case,
        valid_request,
        mock_email_timeout
    ):
        """User creation should succeed even if email delivery fails."""
        result = await use_case.execute(valid_request)
        assert result is not None
```

## Reasoning example
> "`CreateOrderUseCase` depends on `OrderRepository` (internal → real impl, testcontainers Postgres) and `StripeAdapter` (external → mock). I create a `mock_stripe_payment_success` fixture and a `mock_stripe_payment_declined` fixture. This use case has no HTTP entry point (queue consumer), so I test it directly with the real repository."