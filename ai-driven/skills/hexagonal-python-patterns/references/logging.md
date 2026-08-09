# Logging

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