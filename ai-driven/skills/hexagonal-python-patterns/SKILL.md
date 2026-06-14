# Instructions: FastAPI Backend with Hexagonal Architecture

You are a Python/FastAPI expert. Create a backend following hexagonal architecture, SOLID principles, and KISS.

## 🏗️ Project Structure

```
├── .github/workflows/         # CI/CD (tests, linting, deploy)
├── src/
│   ├── main.py               # FastAPI app
│   ├── config.py             # Pydantic Settings
│   ├── dependencies.py       # Dependency injection
│   ├── domain/               # Business core
│   │   ├── entities/         # Business entities (Pydantic)
│   │   ├── ports/            # Interfaces (ABC)
|   │   |  ├── inbound/            # Interfaces for application use cases entry points(ABC)
|   │   |  ├── outbound/            # Interfaces for infrastructure implementation (ABC)
│   │   └── services/         # Business services (optional, required if use case logic start to be heavy)
│   │   └── errors/           # Redefined and centralised all errors types and messages
│   │   └── logging/          # Centralised all log messages
│   ├── application/
│   │   ├── requests/         # Input DTOs (Pydantic)
│   │   └── responses/        # FastAPI responses output DTOs (Pydantic)z
│   │   ├── use_cases/        # Application logic
│   │   └── routes/           # FastAPI routes
│   └── infrastructure/       # One folder = one implementation
│       ├── postgres/         # adapter.py + models.py
│       ├── mongodb/          # adapter.py + models.py
│       └── email/            # adapter.py
```

## Examples of implementation:

### main.py

```python
"""FastAPI application entry point."""

# Logs format
logging.basicConfig(
    level=app_config.log_level,
    format="%(asctime)s | %(levelname)-8s | %(name)s | %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

logger = logging.getLogger(__name__)

_scheduler = None


def _on_consumer_task_done(task) -> None:
    """Log unhandled exceptions raised by the confirmation consumer background task."""
    if task.cancelled():
        return
    exc = task.exception()
    if exc is not None:
        logger.exception(KafkaLogMessage.TASK_CRASHED, exc)


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    """Application lifespan: startup and shutdown logic."""
    global _scheduler

    # Initialize resources like cron scheduler and Kafka consumer

    cron_times = parse_cron_times(sync_config.sync_cron_times)

    use_cases = get_detect_changes_use_cases()

    _scheduler = create_scheduler(use_cases, cron_times=cron_times, timezone_str=sync_config.sync_cron_timezone)
    _scheduler.start()
    logger.info(SchedulerLogMessage.SCHEDULER_STARTED, sync_config.sync_cron_times, sync_config.sync_cron_timezone)

    consumer = None
    consumer_task: asyncio.Task[None] | None = None
    if kafka_config.kafka_enabled:
        consumer = await get_kafka_confirmation_consumer()
        consumer_task = asyncio.create_task(consumer.start())
        consumer_task.add_done_callback(_on_consumer_task_done)
        logger.info(KafkaLogMessage.CONSUMER_STARTED, kafka_config.kafka_topic)

    try:
        yield
    finally:
        # Close resources
        await close_kafka_event_publisher()
        await close_sharepoint_client()
        await close_mongo_client()


app = FastAPI(
    title="API Supervisor",
    description="API for managing team project configurations",
    version="0.0.1",
    lifespan=lifespan,
    root_path=app_config.root_path or None,
)

app.add_exception_handler(ProjectNotFoundError, project_not_found_handler)

app.include_router(health_router, prefix=app_config.api_prefix)

if __name__ == "__main__":
    uvicorn.run("src.main:app", host=app_config.app_host, port=app_config.app_port, reload=app_config.reload)
```

### config.py

```python
class BaseAppConfig(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")


class AppConfig(BaseAppConfig):
    """Application settings loaded from environment variables.

    Attributes:
        app_host: Host address for the FastAPI application.
        app_port: Port number for the FastAPI application.
    """
    app_host: str = Field(description="Host address to run the FastAPI application on")
    app_port: int = Field(description="Port to run the FastAPI application on")
    reload: bool = Field(description="Enable auto-reload for development")
    api_prefix: str = Field(description="Base prefix for all API routes")
    root_path: str = Field(default="", description="Root path for the application (e.g. /ragaas-supervisor)")
    log_level: str = Field(description="Logging level (e.g. DEBUG, INFO, WARNING)")
```

### dependencies.py

```python
# Use this when you can and instantion requires no logic
app_config = AppConfig()
mongodb_config = MongoDBConfig()
graph_config = GraphConfig()
sync_config = SyncConfig()
kafka_config = KafkaConfig()
schema_registry = SchemaRegistry(kafka_config)


mongo_client = AsyncMongoClient(mongodb_config.mongodb_uri)
database = mongo_client[mongodb_config.mongodb_db_name]

project_repo = MongodbProjectRepository(database, mongodb_config.collection_name)

sharepoint_client = GraphSharePointAdapter(
        client_id=graph_config.azure_client_id,
        client_secret=graph_config.azure_client_secret,
        tenant_id=graph_config.azure_tenant_id,
    )


# Use this when instantiation requires logic, like creating a connection or using other dependencies
@lru_cache(maxsize=1)
def get_sync_state_repository() -> MongodbSyncStateRepository:
    return MongodbSyncStateRepository(database, sync_config.sync_state_collection)

@lru_cache(maxsize=1)
def get_event_publisher() -> EventPublisher:
    """Return the singleton KafkaEventPublisher.

    Initialized by the lifespan at startup. Returns the log fallback
    when Kafka is disabled. Raises if called before lifespan startup
    with Kafka enabled.
    """
    if kafka_config.kafka_enabled:
        return KafkaEventPublisher(kafka_config).create(schema_registry)
    return LogAlerter()

handle_deletion = HandleDeletionConfirmation(publisher=get_event_publisher())
```

### routes

```python
router = APIRouter(prefix="/projects", tags=["supervision"])
@router.patch(
    "/supervise",
    response_model=SupervisionResponse,
    status_code=status.HTTP_200_OK,
    summary="Set project supervision status",
    description="Enable or disable supervision (sync) for a project by its id.",
)
@log_execution_time("set project supervision")
async def set_project_supervision(
    request: SupervisionRequest,
    use_case: Annotated[SetProjectSupervision, Depends(get_set_supervision_use_case)],
) -> SupervisionResponse:
    """Set supervision status for a project."""
    project = await use_case.execute(request.id, request.supervised)
    return SupervisionResponse(**project.model_dump())
```

### responses / requests

```python
from pydantic import BaseModel, ConfigDict


class SupervisionRequest(BaseModel):
    """Request DTO for setting project supervision status."""

    id: str
    supervised: bool


class SupervisionResponse(BaseModel):
    """Response DTO for project supervision status."""

    model_config = ConfigDict(extra="ignore")

    id: str
    project_name: str
    supervised: bool
```

### use cases 

```python
logger = logging.getLogger(__name__)

# Use ports inbound only when you want to call use case from infrastructure, like a consumer or a scheduler, to avoid importing application logic into infrastructure.
class HandleDeletionConfirmation(DeletionConfirmationListener):
    """Convert a terminator confirmation into a CREATE request to the scrapper."""

    def __init__(self, publisher: EventPublisher) -> None:
        self._publisher = publisher

    async def execute(self, message: KafkaMessage) -> None:
        project_id = message.payload.entity.project_id
        document_id = message.payload.entity.document_id
        correlation_id = message.metadata.correlationId
        uuid = message.metadata.uuid

        logger.info(
            UseCaseLogMessage.CONFIRMATION_RECEIVED,
            project_id,
            document_id,
            correlation_id,
        )

        create_message = KafkaMessage(
            metadata=EventMetadata(
                uuid=uuid,
                correlationId=correlation_id,
                timestamp=message.metadata.timestamp,
                # TODO: change to event or command later
                type=OperationCode.CREATE,
                source=MetadataSource(app=AppName.SUPERVISOR),
                target=MetadataTarget(app=AppName.SCRAPPER),
            ),
            payload=EventPayload(
                eventCode=EventCode(operationCode=OperationCode.CREATE),
                entity=message.payload.entity,
            ),
        )

        await self._publisher.publish(create_message)

        logger.info(
            UseCaseLogMessage.FORWARDING_CREATE_TO_SCRAPPER,
            project_id,
            document_id,
            correlation_id,
        )
```

### entities

```python
class Credentials(BaseModel):
    """OAuth credentials for the project."""

    client_id: str
    tenant_id: str


class Project(BaseModel):
    """A project configuration for a team.

    Maps directly to the MongoDB document structure.
    """

    model_config = ConfigDict(populate_by_name=True, extra="ignore")

    id: str = Field(alias="_id")
    project_name: str
    site_name: str
    folders: list[str] = []
    drive_name: str
    source: ProjectSource
    credentials: Credentials
    embedding_model_name: str
    email_team: str
    document_types: list[str] = []
    created_at: datetime
    status: str
    site_hostname: str
    supervised: bool = False
```

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

### logging
```python
from enum import StrEnum


class KafkaLogMessage(StrEnum):
    FETCHED_SCHEMA = "Fetched schema ID %d for topic %s"
    SCHEMA_CONTENT = "Schema content: %s"
    SCHEMA_REGISTRY_UNAVAILABLE = "Kafka Schema Registry unavailable"
    PRODUCED_MESSAGE = (
        "Produced message for change of source %s in project '%s', message : %s"
```

### ports
```python
from abc import ABC, abstractmethod

from src.domain.entities.changes.change import Change
from src.domain.entities.project import Project
from src.infrastructure.kafka.message import KafkaMessage


class EventPublisher(ABC):
    """Outbound port: produce Kafka events on the configured topic."""

    @abstractmethod
    async def publish(self, message: KafkaMessage) -> None:
        """Serialize ``message`` and produce it to the configured topic.

        Args:
            message: The fully-built message to publish. ``source`` and
                ``target`` are already set on the message.
        """
        ...

    @abstractmethod
    async def publish_changes(self, project: Project, changes: list[Change]) -> None:
        """Build a KafkaMessage for each change and ``publish`` it.

        Args:
            project: The project the changes belong to.
            changes: Detected changes to alert about.
        """
        ...

    @abstractmethod
    async def close(self) -> None:
        """Flush and close any resources held by the publisher."""
        ...
```
