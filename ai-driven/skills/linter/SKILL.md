---
name: linter
description: Run linting and formatting checks on the codebase. Use this skill when code changes are made and need static analysis validation. Runs ruff (Python) and eslint+prettier (TypeScript/React) depending on the project type. Invoke after implementation and before code review.
---

You are a code quality engineer. Run all relevant linters on the project and fix any issues found.

## Workflow

### 1. Detect project type

Examine the project directory to determine the stack:
- **Python (FastAPI)**: Look for `pyproject.toml`, `*.py` files → use `ruff`
- **TypeScript (React)**: Look for `package.json`, `eslint.config.*`, `*.tsx` files → use `eslint` + `prettier`
- **Both**: Run both linters

### 2. Run linters

#### Python projects (ruff)

```bash
# Check for issues
uv run ruff check . --fix

# Format
uv run ruff format .
```

If `ruff` is not in dependencies, **configure it**:
1. Add `ruff` to dev dependencies (`uv add --dev ruff` or add to `pyproject.toml`)
2. Add a `[tool.ruff]` section in `pyproject.toml` with sensible defaults:
```toml
[tool.ruff]
target-version = "py312"
line-length = 100

[tool.ruff.lint]
select = [
    "E",      # pycodestyle errors
    "W",      # pycodestyle warnings
    "F",      # pyflakes
    "I",      # isort
    "B",      # flake8-bugbear
    "C4",     # flake8-comprehensions
    "UP",     # pyupgrade
    "ARG",    # flake8-unused-arguments
    "SIM",    # flake8-simplify
]

[tool.ruff.lint.isort]
known-first-party = ["domain", "application", "infrastructure"]
```
3. Run `uv run ruff check . --fix` and `uv run ruff format .`

#### TypeScript/React projects (eslint + prettier)

```bash
# ESLint
npx eslint . --fix

# Prettier
npx prettier --write "src/**/*.{ts,tsx}"
```

If the project has a `lint` script in `package.json`, prefer `npm run lint` or `npx eslint .`.

### 3. Report & fix

- If linters find auto-fixable issues, apply the fixes automatically
- If linters find non-auto-fixable issues, list them and fix manually
- Run the linter again after fixes to confirm zero issues
- Run the full test suite after fixing to ensure no regressions

### 4. Summary

Provide a table:

```
| Linter   | Issues found | Auto-fixed | Manual fixes | Remaining |
|----------|-------------|------------|-------------|-----------|
| ruff     | X           | Y          | Z           | 0         |
| eslint   | X           | Y          | Z           | 0         |
| prettier | X           | Y          | Z           | 0         |
```

## Rules

- **Never disable linter rules** to make issues disappear — fix the underlying code
- **Never add `# noqa`, `// eslint-disable`, or `@ts-ignore`** unless the rule is genuinely a false positive, and explain why
- **Run tests after every fix** to catch regressions
- **Only lint changed files** when possible (use `git diff --name-only main` to scope), unless the user asks for a full lint
- **Respect existing linter configs** — do not modify `.eslintrc`, `ruff.toml`, `pyproject.toml` linter sections
