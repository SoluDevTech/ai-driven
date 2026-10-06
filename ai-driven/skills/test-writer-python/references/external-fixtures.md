# External Fixtures (Mocks) — `tests/fixtures/external.py`

Mock ONLY outbound adapters toward external systems. All mock fixtures live in `tests/fixtures/external.py` — never inline a mock in a behavioral test file. When testing from the router (see `router-test.md`), prefer `app.dependency_overrides` on the port; `unittest.mock.patch` is the fallback for adapters not wired via FastAPI DI.

## Configurable failures pattern

For EACH external adapter, the file provides one factory parameterized by outcome mode: `success` (default), `error` (adapter raises its domain error), `timeout`, `empty` (returns an empty/None response). Behavioral tests pick the mode and the mock is yielded for boundary assertions.

```python
# tests/fixtures/external.py

from enum import StrEnum
from unittest.mock import AsyncMock, patch
import pytest


class Outcome(StrEnum):
    SUCCESS = "success"
    ERROR = "error"
    TIMEOUT = "timeout"
    EMPTY = "empty"


def _email_mock(outcome: Outcome) -> AsyncMock:
    mock = AsyncMock()
    match outcome:
        case Outcome.SUCCESS:
            mock.return_value = True
        case Outcome.ERROR:
            mock.side_effect = SendgridError("Sendgrid rejected the message")
        case Outcome.TIMEOUT:
            mock.side_effect = TimeoutError("Sendgrid timeout")
        case Outcome.EMPTY:
            mock.return_value = None
    return mock


def make_email_adapter(outcome: Outcome = Outcome.SUCCESS):
    """Factory for EmailPort overrides — mode-pickable from tests."""
    return _email_mock(outcome)


@pytest.fixture
def mock_email_success():
    with patch("src.infrastructure.email.sendgrid_adapter.SendgridEmailAdapter.send") as mock:
        mock.return_value = True
        yield mock


@pytest.fixture
def mock_email_timeout():
    with patch("src.infrastructure.email.sendgrid_adapter.SendgridEmailAdapter.send") as mock:
        mock.side_effect = TimeoutError("Sendgrid timeout")
        yield mock


@pytest.fixture
def mock_stripe_payment_success():
    with patch("src.infrastructure.payment.stripe_adapter.StripeAdapter.charge") as mock:
        mock.return_value = {"status": "succeeded", "id": "ch_test_123"}
        yield mock


@pytest.fixture
def mock_stripe_payment_declined():
    with patch("src.infrastructure.payment.stripe_adapter.StripeAdapter.charge") as mock:
        mock.side_effect = CardDeclinedError("Your card was declined")
        yield mock
```

With the factory + `dependency_overrides` (preferred when the port is wired via DI):

```python
def override_email(app, outcome: Outcome):
    app.dependency_overrides[EmailPort] = lambda: make_email_adapter(outcome)
```

Each behavioral test then asserts how the ROUTE responds to that failure — correct status, error body, no silent swallow, no 500.

## What counts as "external"
- Third-party HTTP APIs (Stripe, Sendgrid, S3, Twilio)
- Email / SMS / push notification gateways
- Payment processors
- Analytics SDKs (Segment, Mixpanel)
- File storage (S3, GCS) — the SDK call, not your adapter wrapper

## What is NOT external (use real impl)
- Your repository adapters (use real impl + testcontainers Postgres — Docker is a hard requirement)
- Your domain services
- Your use cases
- Your domain entities
- Your in-app state / config