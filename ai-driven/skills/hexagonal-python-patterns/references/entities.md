# Entities

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