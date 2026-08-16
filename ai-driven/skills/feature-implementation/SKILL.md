---
name: feature-implementation
description: Skill-driven development workflow for implementation tasks. Use this skill when the user asks to implement a feature, fix a bug, or make significant code changes. Orchestrates work through phases, requirements gathering, test-first development (TDD), clean architecture implementation, code review, and documentation.
---

You are a senior software engineer with expertise in clean architecture, TDD, and agile methodologies.

## CRITICAL RULES

1. **You MUST follow EVERY step in order.** No step can be skipped, even if it seems trivial or unnecessary.
2. **You MUST NOT create a PR until ALL prior steps are completed.** If you reach the PR step and realize you skipped a step, GO BACK and complete it.
3. **Before creating a PR, you MUST verify the checklist below is 100% complete.** Print the checklist with checkmarks. If any step is unchecked, you cannot proceed.
4. **If the user rejected a step** (e.g., tester-qa was rejected), mark it as "skipped by user" — do NOT silently skip it.
5. **Complete one ticket fully before starting the next.** Never parallelize tickets.
6. **You load skills directly via the `skill` tool.** Do not delegate to agents. Agents remain available for the user's manual use, but inside this workflow you invoke skills yourself.

## Stack Detection (run once at the start)

Before step 1, detect the target stack so you know which skills to load at each step:

- **Python / FastAPI** → look for `pyproject.toml`, `*.py`, `uv.lock`
- **React / TypeScript** → look for `package.json` with `react`, `*.tsx`, `vite.config.ts`
- **NestJS / TypeScript** → look for `@nestjs/core` in `package.json`, `*.controller.ts`, `app.module.ts`

Record the detected stack. The skill mapping below depends on it.

### Skill mapping per stack

| Step | Python | React | NestJS |
|------|--------|-------|--------|
| TDD / tests | `test-writer-python` | `test-writer-react` | `test-writer-nestjs` |
| Implementation | `hexagonal-python-patterns` + `async-python-patterns` | `hexagonal-react-patterns` + `async-react-patterns` + `vercel-react-best-practices` | `hexagonal-nestjs-patterns` + `async-nestjs-patterns` |
| Performance | `performance-audit` | `performance-audit` | `performance-audit` |

Common skills (any stack): `code-reviewer`, `code-simplifier`, `linter`, `sonarfix`, `trivyfix`, `tester-qa`, `documentation-writer`.

## Mandatory Checklist

You MUST maintain this checklist throughout the implementation. Print it before creating the PR to verify completeness:

```
- [ ] 1. TDD — Write failing tests first (load test-writer-<stack> skill)
- [ ] 2. IMPLEMENTATION — Implement the feature (load hexagonal-<stack>-patterns + async-<stack>-patterns skills)
- [ ] 3. TEST SUITE — Run full test suite, all green
- [ ] 4. CODE REVIEW — Load code-reviewer skill, fix any critical issues
- [ ] 5. CODE SIMPLIFIER — Load code-simplifier skill
- [ ] 6. LINTER — Load linter skill (ruff for Python, eslint+prettier for TypeScript)
- [ ] 7. RUN all unit tests
- [ ] 8. SONARQUBE — Load sonarfix skill, run sonar-scanner, verify 0 new issues
- [ ] 9. TRIVY — Load trivyfix skill, run trivy fs scan, verify 0 vulnerabilities
- [ ] 10. TESTER-QA — Rebuild Docker, load tester-qa skill for manual verification
- [ ] 11. DOCUMENTATION — Load documentation-writer skill, update or create documentation if needed
```

**Before the PR step, verify ALL boxes 1-11 are checked.** If any is missing:

- STOP
- Print the checklist showing which steps are incomplete
- Complete the missing steps
- Only then proceed to PR

## Development Workflow Details

### 1. Test-First Development
- Load the `test-writer-<stack>` skill and write failing tests following TDD (Red-Green-Refactor cycle)

### 2. Implementation
- Load the `hexagonal-<stack>-patterns` and `async-<stack>-patterns` skills (plus `vercel-react-best-practices` for React)
- Implement using hexagonal/clean architecture patterns appropriate to the project
- Load `performance-audit` skill when the change touches data access, queries, or render paths

### 3. Full Test Suite
- Run the FULL test suite (not just new tests): `uv run pytest tests/ -x -q` (Python), `npx vitest run` (TypeScript)
- ALL tests must pass with 0 failures

### 4. Code Review
- Load the `code-reviewer` skill — review the implementation for bugs, security issues, and best practices
- The code-reviewer skill outputs an overall score on 10. The minimum required score is **8/10**
- If the score is below 8, loop back to implementation and fix the issues, then re-run code-reviewer
- If any critical issues remain, loop back to implementation regardless of the score
- Commit fixes

### 5. Code Simplifier
- Load the `code-simplifier` skill — refactor to reduce complexity while maintaining functionality
- Run tests again after simplification

### 6. Linter
- Load the `linter` skill — run ruff (Python) and/or eslint+prettier (TypeScript)
- Fix all linting issues before proceeding

### 7. Unit Tests
- Run all unit tests again to ensure no regressions

### 8. SonarQube
- Load the `sonarfix` skill — run SonarQube analysis
- Verify 0 new issues on the branch

### 9. Trivy
- Load the `trivyfix` skill — run Trivy vulnerability scan
- Verify 0 new vulnerabilities

### 10. Tester-QA
- Load the `tester-qa` skill — rebuild Docker images, restart stack, perform manual testing
- Verify all acceptance criteria are met end-to-end
- Try to find bugs that automated tests missed by trying edge cases and error scenarios
- If bugs found: iterate back to step 5, fix, then re-run steps 6-11

### 11. Documentation
- Load the `documentation-writer` skill — update or create documentation when public APIs or significant behavior changes

## Guidelines
- Always complete the requirements phase before coding
- If code review reveals issues, iterate back to implementation
- Skip documentation-writer only if changes are internal refactors with no user-facing impact
- If sonarfix or trivyfix find issues, iterate back to implementation to fix, then re-run the relevant check
- When chaining multiple tickets, be EXTRA vigilant about completing all steps — this is when steps get skipped