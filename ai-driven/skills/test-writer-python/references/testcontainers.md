# Testcontainers — Real Infrastructure for Integration Tests

Use [testcontainers-python](https://testcontainers-python.readthedocs.io/) for integration tests against **real** databases, message brokers, and cloud-emulated services (LocalStack). This extends the "real implementations" golden rule to infrastructure that can't run in-memory.

## When to use testcontainers
- **Integration tests** that must validate real Postgres / MongoDB / Redis / Kafka / RabbitMQ behavior
- **Adapter tests** for infrastructure where SQLite in-memory doesn't match production (JSONB, `ON CONFLICT`, enum types, PostGIS)
- **S3 / SQS / SNS** tests via [LocalStack](https://docs.localstack.cloud/) container (instead of mocking boto3)
- **Event-driven** flows that must validate real Redis pub/sub or NATS

## When NOT to use testcontainers
- **Unit tests** — use SQLite in-memory (see `conftest.md`) for repositories, mocks for external HTTP
- **CI without Docker** — fall back to SQLite in-memory; mark testcontainers tests with a marker and skip them
- **Fast feedback loop** — testcontainers add ~5-15s startup per container; keep the unit suite separate

## Install
```bash
uv add --dev testcontainers[postgres,redis,kafka,rabbitmq]
```

## Postgres container (adapter integration test)

```python
import pytest
from testcontainers.postgres import PostgresContainer
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession

@pytest.fixture(scope="module")
async def postgres_url():
    with PostgresContainer("postgres:16-alpine") as pg:
        yield pg.get_connection_url(driver="asyncpg")

@pytest.fixture
async def pg_session(postgres_url):
    engine = create_async_engine(postgres_url)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    async with AsyncSession(engine) as session:
        yield session
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    await engine.dispose()

async def test_postgres_repository_persists(pg_session):
    repo = PostgresUserRepository(session=pg_session)
    user = User.create(id=uuid4(), email="a@b.c", name="Ada")
    await repo.save(user)
    found = await repo.get_by_id(user.id)
    assert found is not None
    assert found.email == "a@b.c"
```

## Redis container (event-driven adapter)

```python
from testcontainers.redis import RedisContainer

@pytest.fixture(scope="module")
def redis_url():
    with RedisContainer("redis:7-alpine") as redis:
        yield f"redis://{redis.get_container_host_ip()}:{redis.get_exposed_port(6379)}"

async def test_event_bus_publishes_to_redis(redis_url):
    bus = RedisEventBus(url=redis_url)
    await bus.publish(UserCreated("123"))
    # subscribe and assert
```

## RabbitMQ container

```python
from testcontainers.rabbitmq import RabbitMqContainer

@pytest.fixture(scope="module")
def amqp_url():
    with RabbitMqContainer("rabbitmq:3-management-alpine") as rb:
        yield rb.get_connection_url()
```

## Kafka container

```python
from testcontainers.kafka import KafkaContainer

@pytest.fixture(scope="module")
def kafka_url():
    with KafkaContainer("confluentinc/cp-kafka:7.6.0") as kafka:
        return kafka.get_bootstrap_server()
```

## LocalStack (S3 / SQS / SNS) — instead of mocking boto3

```python
from testcontainers.localstack import LocalStackContainer

@pytest.fixture(scope="module")
def s3_endpoint():
    with LocalStackContainer("localstack/localstack:3") as ls:
        ls.with_services("s3")
        yield f"http://{ls.get_container_host_ip()}:{ls.get_exposed_port(4566)}"

async def test_upload_adapter_writes_to_s3(s3_endpoint):
    adapter = S3StorageAdapter(endpoint_url=s3_endpoint)
    await adapter.upload("bucket", "key", b"data")
    # assert the object exists via a second read
```

## Markers — skip when Docker is unavailable

```python
# conftest.py
import pytest

def pytest_collection_modifyitems(config):
    if not shutil.which("docker"):
        skip = pytest.mark.skip(reason="Docker not available")
        for item in config.items:
            if "integration" in item.keywords:
                item.add_marker(skip)
```

```python
# tests/integration/test_postgres_repository.py
@pytest.mark.integration
async def test_postgres_repo(pg_session):
    ...
```

Run unit tests fast, integration tests separately:
```bash
uv run pytest                       # unit only (no docker)
uv run pytest -m integration        # integration only
uv run pytest -m "integration or not integration"  # everything
```

## Best practices
- **Scope containers to `module`** (or `session`) — reuse across tests to amortize startup cost
- **Reset state between tests** — truncate tables / flush keys, don't recreate the container
- **Pin image tags** — `postgres:16-alpine`, not `latest`, for reproducibility
- **Alpine variants** — smaller, faster startup
- **Don't mix with mocks** — if you're using a real Postgres container, use the real `PostgresUserRepository` (not a mock of it). This is the whole point.
- **Parallelism** — each test process needs its own container or a unique database/schema to avoid collisions