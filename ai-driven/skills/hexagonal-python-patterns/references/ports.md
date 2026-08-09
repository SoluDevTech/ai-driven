# Ports

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