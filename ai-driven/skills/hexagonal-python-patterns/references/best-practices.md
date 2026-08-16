# Python Best Practices

Load this before writing Python code. These rules apply across all layers.

## Python Best Practices
- **Python 3.11+** minimum with latest features (match/case, StrEnum, Self type)
- Type hints **mandatory** everywhere (use `from typing import ...`)
- Async/await for all I/O operations (database, HTTP calls, file operations)
- **One Entity, One File, One Object** do not use a file for several entities
- **Pydantic BaseModel** for domain entities (simple, immutable when possible with `frozen=True`)
- **ABC (Abstract Base Classes)** for ports/interfaces
- Google-style docstrings for all public methods/classes
- **Error handling**: Custom exceptions hierarchy (inherit from base domain exception)
- **Naming conventions**:
  - Classes: `PascalCase`
  - Functions/variables: `snake_case`
  - Constants: `UPPER_SNAKE_CASE`
  - Private attributes: `_leading_underscore`
- Use **context managers** (`async with`) for resource management
- Prefer **composition over inheritance**
- **No mutable default arguments** (use `None` and initialize in function body)
- Use **Enum** for constants/status values
- **List/Dict comprehensions** over loops when readable
- Dependency manager: **UV** (not Poetry/pip)

## FastAPI Best Practices
- **Dependency injection** via `Depends()` for all services, repositories, and configurations
- **Annotated types** for cleaner dependency injection: `Annotated[Service, Depends(get_service)]`
- **Pydantic V2** for all request/response validation with Field constraints
- **Explicit HTTP status codes**: Use `status.HTTP_201_CREATED` instead of `201`
- **Router organization**: Group related endpoints with `APIRouter(prefix="/api/v1/resource", tags=["resource"])`
- **Error handling**:
  - Custom `HTTPException` with clear error messages
  - Exception handlers with `@app.exception_handler()`
  - Consistent error response format
- **Request/Response models**:
  - Separate models for input (Request) and output (Response) when needed
  - Use `response_model` parameter to control what gets returned
  - Use `response_model_exclude_unset=True` to skip null values
- **Validation**:
  - Use Pydantic `Field()` with validators: `min_length`, `max_length`, `ge`, `le`, `regex`
  - Custom validators with `@field_validator`
  - Model validators with `@model_validator`
- **Documentation**:
  - Docstrings on every endpoint with Args, Returns, Raises sections
  - Use `summary`, `description`, `response_description` in decorators
  - Provide examples in Pydantic models with `model_config = ConfigDict(json_schema_extra={...})`
- **Security**:
  - JWT authentication with `python-jose`
  - Password hashing with `passlib[bcrypt]`
  - OAuth2PasswordBearer for protected routes
  - CORS configuration explicit and restrictive
  - Rate limiting (use `slowapi` or custom middleware)
  - Security headers middleware
- **Performance**:
  - Use `BackgroundTasks` for non-blocking operations (emails, logs)
  - Connection pooling for databases
  - Caching with Redis/in-memory for frequent queries
  - Pagination for list endpoints: `limit`/`offset` or cursor-based
- **Startup/Shutdown events**:
  - Database connection initialization in `lifespan` context manager
  - Graceful shutdown handling
- **Middleware**:
  - Request ID tracking
  - Logging middleware for all requests
  - CORS middleware properly configured
  - Compression middleware for large responses

## Data Transformations
```python
# ✅ GOOD: Direct transformation
user_entity = User(**user_model.__dict__)
db_user = UserModel(**user_entity.__dict__)
request_dto = CreateUserRequest(**pydantic_model.model_dump())

# ❌ BAD: Unnecessary intermediate methods
user_entity = User.from_model(user_model)
db_user = UserModel.from_entity(user_entity)
```

## Database model conversion
Use `model_validate(my_model, from_attributes=True)` for converting from ORM/database models to Pydantic entities.