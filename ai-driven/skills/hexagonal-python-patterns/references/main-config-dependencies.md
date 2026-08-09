# main.py, config.py, dependencies.py

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