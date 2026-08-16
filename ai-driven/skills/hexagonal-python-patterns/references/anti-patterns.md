# Anti-patterns

Load this before review to catch violations.

## Absolutely Avoid
- ❌ Importing FastAPI, SQLAlchemy, etc. in domain
- ❌ Creating Response DTOs (return domain entities directly)
- ❌ Complex transformation methods (`from_entity`, `to_entity`)
- ❌ Over-engineering (unnecessary builders, factories)
- ❌ Too-wide interfaces with too many methods
- ❌ Use of `__init__.py`
- ❌ Use Protocol instead of ABC for ports
- ❌ Use object for return types no Dict
- ❌ Do not use infrastructure from application directly use domain
- ❌ Do not use application from infrastructure directly use domain
- ❌ Mocking internal components (use real implementations; mock only outbound external adapters)
- ❌ In-memory test adapters that drift from the real adapter's behavior (they're real implementations of the port — keep them contract-faithful)

## Critical Reminders
1. **Domain** = pure Python, zero external imports
2. **Use cases** depend on **ports** (abstractions), never **adapters**
3. Transformations: `Class(**other.__dict__)` or `Class(**model.model_dump())`
4. Use `model_validate(my_model, from_attributes=True)` for database model conversion
5. SOLID + KISS above all: simplicity and design principles first