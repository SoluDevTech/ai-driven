# Checklist

Run end-to-end before declaring done.

## Architecture
- [ ] 3 distinct layers: domain / application / infrastructure
- [ ] Domain without any external dependencies
- [ ] Use cases depend on ports (interfaces), not adapters
- [ ] Use cases should not contain a lot of logic and should orchestrate the logic in services
- [ ] Infrastructure: one folder per adapter with `adapter.py` + `models.py`

## SOLID & KISS
- [ ] SRP: One class = 1 responsibility
- [ ] DIP: Depend on abstractions (ports)
- [ ] Direct transformations with `**.__dict__` or `**model.model_dump()`
- [ ] No methods like `create()`, `from_entity()`, `to_entity()`
- [ ] Use `model_validate(my_model, from_attributes=True)` for database model conversion

## Python
- [ ] Type hints everywhere
- [ ] Async/await for I/O
- [ ] Pydantic V2 for validation
- [ ] Python 3.11+ features used where appropriate
- [ ] ABC for ports
- [ ] Custom exception hierarchy in `domain/errors/`

## Code Quality
- [ ] Centralized errors in `domain/errors/`
- [ ] Centralized logging in `domain/logging/`
- [ ] Google-style docstrings on public methods/classes
- [ ] No mutable default arguments
- [ ] Context managers for resource management

## DevOps
- [ ] GitHub Actions CI/CD (tests, linting, security)
- [ ] Docker + Docker Compose
- [ ] Documented `.env.example`
- [ ] README.md with quick start