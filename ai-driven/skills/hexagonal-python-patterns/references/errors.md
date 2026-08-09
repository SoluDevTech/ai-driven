# Errors

### errors

#### error codes
```python
class ErrorCode(IntEnum):
    """HTTP status codes used by domain error handlers."""

    NOT_FOUND = 404
    FORBIDDEN = 403
    GONE = 410
    INTERNAL_SERVER_ERROR = 500
    SERVICE_UNAVAILABLE = 503
```

#### Error messages
```python
from enum import StrEnum


class ErrorMessage(StrEnum):
    """Standardized error messages used across the application."""

    DATABASE_SERVICE_UNAVAILABLE = "Database service unavailable"
    DATABASE_OPERATION_FAILED = "Database operation failed"
    MONGODB_CONNECTION_FAILURE = "MongoDB connection failure"
    MONGODB_OPERATION_FAILURE = "MongoDB operation failure"
    MONGODB_HEALTH_CHECK_FAILED = "MongoDB health check failed"
```

#### Custom exceptions
```python
class GraphDeltaLinkExpiredError(Exception):
    """Raised when the MS Graph delta link has expired (HTTP 410 Gone).

    This occurs when the delta token is no longer valid and a full
    resynchronization is required.

    Attributes:
        detail: Human-readable error description.
        status_code: HTTP status code.
    """

    status_code = ErrorCode.GONE

    def __init__(self, detail: str) -> None:
        self.detail = detail
        super().__init__(self.detail)
```