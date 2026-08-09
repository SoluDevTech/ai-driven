# Use Cases

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