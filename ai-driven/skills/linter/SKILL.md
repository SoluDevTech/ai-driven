---
name: linter
description: Run linting, formatting and type-checking on the codebase. Use this skill when code changes are made and need static analysis validation. Runs ruff + pyright (Python) and eslint+prettier (TypeScript/React) depending on the project type. Invoke after implementation and before code review.
---

You are a code quality engineer. Run all relevant linters on the project and **fix every issue found** — the goal is always a fully green result (0 issues), not a report.

## Workflow

### 1. Detect project type

Examine the project directory to determine the stack:
- **Python (FastAPI)**: Look for `pyproject.toml`, `*.py` files → use `ruff` + `pyright`
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

#### Python type checking (pyright)

```bash
# Type check (config in pyproject.toml [tool.pyright] or pyrightconfig.json)
uv run pyright
```

Detection & configuration rules:
- **If `[tool.pyright]` (pyproject.toml) or `pyrightconfig.json` already exists** → run `uv run pyright`, fix all issues
- **If `mypy` is already configured** (`[tool.mypy]`, `mypy.ini`...) → leave it intact and run mypy as before; do not migrate it without asking the user
- **If a FastAPI project has NO type checker configured** → configure pyright automatically:
  1. Add `pyright` to dev dependencies (`uv add --dev pyright`)
  2. Add a `[tool.pyright]` section in `pyproject.toml` with `typeCheckingMode = "standard"` and the project source paths as `extraPaths` (e.g. `["pickpro_api", "tests"]`)
  3. Run `uv run pyright` and fix all issues
- **Fix all pyright errors — including pre-existing ones** (iterate file by file, biggest clusters first, until 0 errors). Only if the volume is very large (> 100), ask the user before remediating the whole codebase vs. scope-limiting to the diff
- **Fix the underlying code first, ignore last**: refactor correctly (typed `Mapped[]` SQLAlchemy models, targeted protocol types, narrowing) instead of silencing. A targeted `# pyright: ignore[reportXyz]` with an explanatory comment is acceptable ONLY for documented false positives (e.g. pydantic-settings env-provided required fields) or untyped third-party private APIs (e.g. `# pyright: ignore[reportPrivateUsage]` on a lib exposing underscore attrs). Never sprinkle blanket `# pyright: ignore`
- Re-run after fixes: both `uv run pyright` AND `uv run ruff check .` (type comments can affect lint)

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
- If linters find non-auto-fixable issues, **fix them manually — do not just list them**
- Iterate: run → fix → run again until ALL linters report zero issues
- Run the full test suite after fixing to ensure no regressions; fix any failing test (a changed behavior may legitimately require updating the test assertion)

### 4. Summary

Provide a table:

```
| Linter   | Issues found | Auto-fixed | Manual fixes | Remaining |
|----------|-------------|------------|-------------|-----------|
| ruff     | X           | Y          | Z           | 0         |
| pyright  | X           | Y          | Z           | 0         |
| eslint   | X           | Y          | Z           | 0         |
| prettier | X           | Y          | Z           | 0         |
```

## Rules

- **Never disable linter rules** to make issues disappear — fix the underlying code
- **Never add `# noqa`, `// eslint-disable`, or `@ts-ignore`** unless the rule is genuinely a false positive, and explain why
- **Run tests after every fix** to catch regressions
- **Only lint changed files** when possible (use `git diff --name-only main` to scope), unless the user asks for a full lint
- **Respect existing linter configs** — do not modify `.eslintrc`, `ruff.toml`, `pyproject.toml` linter sections
