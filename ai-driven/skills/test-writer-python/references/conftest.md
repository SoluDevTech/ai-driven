# conftest.py and Test Structure

## Test Structure
```
tests/
├── unit/
│   ├── test_use_cases.py       # Use case tests (main focus)
├── fixtures/
│   └── external.py              # Fixtures for mocked external calls
└── conftest.py                  # Pytest fixtures (db session, etc.)
```

## conftest.py — real in-memory SQLite session

```python
import pytest
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from src.infrastructure.persistence.base import Base

@pytest.fixture
async def db_session():
    """Provides a real in-memory SQLite session for each test."""
    engine = create_async_engine("sqlite+aiosqlite:///:memory:")
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    async with AsyncSession(engine) as session:
        yield session
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
```

## Why real implementations
Using real implementations ensures tests reflect actual behavior. A fake that diverges silently from the real implementation produces tests that pass but do not detect real regressions. Since external dependencies are mocked, there is no infrastructure cost to using real internal implementations.