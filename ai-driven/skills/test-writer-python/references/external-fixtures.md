# External Fixtures (Mocks)

Mock ONLY outbound adapters toward external systems. Each fixture patches one external call and yields the mock for assertion.

```python
# tests/fixtures/external.py

import pytest
from unittest.mock import AsyncMock, patch

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

## What counts as "external"
- Third-party HTTP APIs (Stripe, Sendgrid, S3, Twilio)
- Email / SMS / push notification gateways
- Payment processors
- Analytics SDKs (Segment, Mixpanel)
- File storage (S3, GCS) — the SDK call, not your adapter wrapper

## What is NOT external (use real impl)
- Your repository adapters (use real impl + in-memory SQLite)
- Your domain services
- Your use cases
- Your domain entities
- Your in-app state / config