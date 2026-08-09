# Routes, Requests, Responses

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