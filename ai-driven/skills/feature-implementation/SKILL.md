---
name: feature-implementation
description: Skill-driven development workflow for implementation tasks. Use this skill when the user asks to implement a feature, fix a bug, or make significant code changes. Aggressively loads the matching skill via the `skill` tool at EVERY step — TDD, clean architecture, code review, simplification, linting, security, QA, and documentation. Skills version (no agent delegation).
---

You are a senior software engineer with expertise in clean architecture, TDD, and agile methodologies.

## Trace & verification protocol (mandatory, non-negotiable)

Read and apply `/Users/yohan/.config/opencode/skills/_shared/TRACE_PROTOCOL.md` in full. Summary:

1. At the start of the loop, generate a `loop_id`:
   ```bash
   loop_id="feat-<slug>-$(date +%Y%m%d-%H%M%S)"
   ```
   Print it. Reuse it for every trace call.

2. **After every `skill` call** (steps 1, 2, 4, 5, 6, 8, 9, 10, 11, 12): append a trace event:
   ```bash
   bash /Users/yohan/.config/opencode/skills/_shared/trace.sh \
     "<repo-root>" "<loop_id>" "<step>" "skill" "<skill_name>" "loaded" "<detail>"
   ```

3. **Before moving from step N to step N+1**: verify the step N event was recorded:
   ```bash
   bash /Users/yohan/.config/opencode/skills/_shared/verify-step.sh \
     "<repo-root>" "<loop_id>" "<step>" "skill" "<skill_name>"
   ```
   If exit code ≠ 0: STOP, print the trace, redo step N. Do NOT proceed.

4. Every skill step MUST end its output with a single confirmation line:
   `SKILL_CONFIRM: <skill_name> loaded and applied on step <N>`
   The orchestrator greps this line from its own output before calling `verify-step.sh`. If missing, redo the step.

5. Bash-only steps (3, 7) are traced as `type=bash` with `status=done` and `detail=<exit code / pass count>`.

This dual gate (trace file + in-output confirmation) guarantees no step is silently skipped.

## CRITICAL RULES

1. **You MUST load the required skill via the `skill` tool BEFORE executing each step.** Loading a skill is not optional — it is the first action of every step. If you skip the `skill` call, the step is invalid and you must redo it starting with the skill load.
2. **You MUST follow EVERY step in order.** No step can be skipped, even if it seems trivial or unnecessary.
3. **You MUST NOT create a PR until ALL prior steps are completed.** If you reach the PR step and realize you skipped a step, GO BACK and complete it.
4. **Before creating a PR, you MUST verify the checklist below is 100% complete.** Print the checklist with checkmarks. If any step is unchecked, you cannot proceed.
5. **If the user rejected a step** (e.g., QA was rejected), mark it as "skipped by user" — do NOT silently skip it.
6. **Complete one ticket fully before starting the next.** Never parallelize tickets.

## Stack detection (run BEFORE step 1)

Detect the target stack from the repo files. This determines which hexagonal + async + test-writer skills to load at each step.

- **Python / FastAPI** → look for `pyproject.toml`, `*.py`, `uv.lock`
- **React / TypeScript** → look for `package.json` with `react`, `*.tsx`, `vite.config.ts`
- **NestJS / TypeScript** → look for `@nestjs/core` in `package.json`, `*.controller.ts`, `app.module.ts`

If ambiguous or mixed, ask the user which stack to target. Record the detected stack; you will use it to pick skills in every subsequent step.

## Spec file handling (mandatory, before step 1)

The product-owner agent persists its Requirements Document to `.opencode/specs/<slug>.md` and prints a `SPEC_FILE: <path>` pointer line. You MUST consume this spec and use it as the requirements context for every step.

1. **Detect the spec source** — check if `$ARGUMENTS` (or the user's input) contains a file path matching `.opencode/specs/*.md`. Also look for a `SPEC_FILE: <path>` line in the conversation history.
2. **Read the spec file** — if found, call the `read` tool to load the FULL file content. Store it as the spec context. Do NOT summarize it.
3. **State the spec mode** before starting step 1:
   - `SPEC_MODE: file — <path>` (spec file found and read)
   - `SPEC_MODE: conversation-fallback` (no spec file, using conversation history)
4. **Use the full spec at every step** — the spec content guides TDD (test cases based on acceptance criteria + edge cases), implementation (functional requirements + technical notes), and QA (validate all acceptance criteria end-to-end). Refer back to the full spec content at each step rather than relying on memory.
5. **Fallback** — if no spec file path is provided and no `SPEC_FILE` line is found, fall back to whatever requirements context is available in the conversation history. State explicitly that you are in fallback mode.

### Skill selection map per stack

| Step | Python / FastAPI | React / TypeScript | NestJS / TypeScript |
|------|------------------|--------------------|---------------------|
| 1 (TDD) | `test-writer-python` + `hexagonal-python-patterns` + `async-python-patterns` | `test-writer-react` + `hexagonal-react-patterns` + `async-react-patterns` | `test-writer-nestjs` + `hexagonal-nestjs-patterns` + `async-nestjs-patterns` |
| 2 (Impl) | `hexagonal-python-patterns` + `async-python-patterns` + `performance-audit` | `hexagonal-react-patterns` + `async-react-patterns` + `vercel-react-best-practices` + `performance-audit` | `hexagonal-nestjs-patterns` + `async-nestjs-patterns` + `performance-audit` |
| 4 (Review) | `code-reviewer` + `hexagonal-python-patterns` + `async-python-patterns` + `performance-audit` + `test-writer-python` | `code-reviewer` + `hexagonal-react-patterns` + `async-react-patterns` + `performance-audit` + `test-writer-react` | `code-reviewer` + `hexagonal-nestjs-patterns` + `async-nestjs-patterns` + `performance-audit` + `test-writer-nestjs` |
| 5 (Simplify) | `code-simplifier` | `code-simplifier` | `code-simplifier` |
| 6 (Lint) | `linter` | `linter` | `linter` |
| 8 (Sonar) | `sonarfix` | `sonarfix` | `sonarfix` |
| 9 (Trivy) | `trivyfix` | `trivyfix` | `trivyfix` |
| 11 (Docs) | `documentation-writer` | `documentation-writer` | `documentation-writer` |
| 12 (PR) | `githubpr` | `githubpr` | `githubpr` |

## Mandatory Checklist

You MUST maintain this checklist throughout the implementation. Print it before creating the PR to verify completeness:

```
- [ ] 1. TDD — load test-writer-<lang> + hexagonal-<lang> + async-<lang> skills, write failing tests (Red)
- [ ] 2. IMPLEMENTATION — load hexagonal-<lang> + async-<lang> + performance-audit skills, implement (Green)
- [ ] 3. TEST SUITE — run full test suite, all green
- [ ] 4. CODE REVIEW — load code-reviewer skill, review, 0 critical + score ≥ 8/10
- [ ] 5. CODE SIMPLIFIER — load code-simplifier skill, refactor
- [ ] 6. LINTER — load linter skill, run ruff / eslint+prettier
- [ ] 7. UNIT TESTS — run all unit tests
- [ ] 8. SONARQUBE — load sonarfix skill, run sonar-scanner, 0 new issues
- [ ] 9. TRIVY — load trivyfix skill, run trivy fs scan, 0 new vulns
- [ ] 10. TESTER-QA — load test-writer-<lang> skill, rebuild Docker, manual QA + new e2e + `BUG_REPORT: <path|none>` pointer
- [ ] 11. DOCUMENTATION — load documentation-writer skill, update docs
- [ ] 12. PR — load githubpr skill, open one draft PR per modified repo
```

**Before step 12 (PR), verify ALL boxes 1-11 are checked.** If any is missing:
- STOP
- Print the checklist showing which steps are incomplete
- Complete the missing steps (starting with the `skill` load)
- Only then proceed to PR

## Development Workflow Details

### 1. Test-First Development
**ACTIONS (in order):**
1. call the `skill` tool NOW with `test-writer-<lang>` (and `hexagonal-<lang>`, `async-<lang>` per the skill map).
2. write failing tests following TDD (Red-Green-Refactor cycle), using the loaded skill's templates and references.
3. print `SKILL_CONFIRM: test-writer-<lang> loaded and applied on step 1`.
4. `bash .../trace.sh "<repo-root>" "<loop_id>" "1" "skill" "test-writer-<lang>" "loaded" "<N> test files written"`.
5. before step 2: `bash .../verify-step.sh ... "1" "skill" "test-writer-<lang>"` — if fail, redo step 1.

### 2. Implementation
**ACTIONS (in order):**
1. call the `skill` tool NOW with `hexagonal-<lang>` + `async-<lang>` + `performance-audit` (per the skill map).
2. implement using hexagonal/clean architecture patterns from the loaded skill.
3. print `SKILL_CONFIRM: hexagonal-<lang> loaded and applied on step 2`.
4. `bash .../trace.sh "<repo-root>" "<loop_id>" "2" "skill" "hexagonal-<lang>" "loaded" "<N> files modified"`.
5. before step 3: `verify-step.sh ... "2" "skill" "hexagonal-<lang>"` — if fail, redo step 2.

### 3. Full Test Suite
1. Run the FULL test suite: `uv run pytest tests/ -x -q` (Python), `npx vitest run` (TypeScript). All tests must pass with 0 failures. If a failure appears, loop back to step 2 (reload the impl skills first).
2. `bash .../trace.sh "<repo-root>" "<loop_id>" "3" "bash" "test-suite" "done" "exit=<code>, pass=<N>"`.
3. before step 4: `verify-step.sh ... "3" "bash" "test-suite"` — if fail, redo step 3.

### 4. Code Review
**ACTIONS (in order):**
1. call the `skill` tool NOW with `code-reviewer`, then load the stack-specific skills: `hexagonal-<lang>-patterns`, `async-<lang>-patterns`, `performance-audit`, `test-writer-<lang>` (per the skill map). This enriches the review with stack-specific knowledge — architecture compliance, async correctness, performance patterns, and test quality conventions.
2. review the implementation. The skill outputs an overall score on 10. Minimum required: **8/10**. If below 8, loop back to step 2 (reload impl skills) and fix, then re-run. If any critical issues remain, loop back regardless of score. Commit fixes.
3. print `SKILL_CONFIRM: code-reviewer loaded and applied on step 4`.
4. `bash .../trace.sh "<repo-root>" "<loop_id>" "4" "skill" "code-reviewer" "loaded" "score=<S>, critical=<N>"`.
5. before step 5: `verify-step.sh ... "4" "skill" "code-reviewer"` — if fail, redo step 4.

### 5. Code Simplifier
**ACTIONS (in order):**
1. call the `skill` tool NOW with `code-simplifier`.
2. refactor to reduce complexity while maintaining functionality. Run tests again after simplification (step 3).
3. print `SKILL_CONFIRM: code-simplifier loaded and applied on step 5`.
4. `bash .../trace.sh "<repo-root>" "<loop_id>" "5" "skill" "code-simplifier" "loaded" "<detail>"`.
5. before step 6: `verify-step.sh ... "5" "skill" "code-simplifier"` — if fail, redo step 5.

### 6. Linter
**ACTIONS (in order):**
1. call the `skill` tool NOW with `linter`.
2. run ruff (Python) and/or eslint+prettier (TypeScript) per the loaded skill. Fix all linting issues before proceeding.
3. print `SKILL_CONFIRM: linter loaded and applied on step 6`.
4. `bash .../trace.sh "<repo-root>" "<loop_id>" "6" "skill" "linter" "loaded" "<N> issues fixed"`.
5. before step 7: `verify-step.sh ... "6" "skill" "linter"` — if fail, redo step 6.

### 7. Unit Tests
1. Run all unit tests again via Bash to ensure no regressions.
2. `bash .../trace.sh "<repo-root>" "<loop_id>" "7" "bash" "unit-tests" "done" "exit=<code>, pass=<N>"`.
3. before step 8: `verify-step.sh ... "7" "bash" "unit-tests"` — if fail, redo step 7.

### 8. SonarQube
**ACTIONS (in order):**
1. call the `skill` tool NOW with `sonarfix`.
2. run SonarQube analysis. Verify 0 new issues on the branch. If issues, loop back to step 2 (reload impl skills) to fix, then re-run.
3. print `SKILL_CONFIRM: sonarfix loaded and applied on step 8`.
4. `bash .../trace.sh "<repo-root>" "<loop_id>" "8" "skill" "sonarfix" "loaded" "<N> new issues"`.
5. before step 9: `verify-step.sh ... "8" "skill" "sonarfix"` — if fail, redo step 8.

### 9. Trivy
**ACTIONS (in order):**
1. call the `skill` tool NOW with `trivyfix`.
2. run Trivy vulnerability scan. Verify 0 new vulnerabilities. If issues, loop back to step 2 to fix, then re-run.
3. print `SKILL_CONFIRM: trivyfix loaded and applied on step 9`.
4. `bash .../trace.sh "<repo-root>" "<loop_id>" "9" "skill" "trivyfix" "loaded" "<N> vulns"`.
5. before step 10: `verify-step.sh ... "9" "skill" "trivyfix"` — if fail, redo step 9.

### 10. Tester-QA
**ACTIONS (in order):**
1. call the `skill` tool NOW with `test-writer-<lang>` (for e2e spec conventions).
2. rebuild Docker images, restart stack, perform manual testing. Add NEW e2e/QA tests validating the shipped feature. Re-running existing tests is not enough. Verify all acceptance criteria are met end-to-end. Try edge cases automated tests missed.
3. **Bug report persistence (mandatory)** — if you find confirmed bugs, persist the FULL bug report to `.opencode/bug-reports/<slug>.md` (reuse the `<slug>` from the `SPEC_FILE` path; if no spec, derive a short kebab-case slug, max 30 chars). Run `mkdir -p .opencode/bug-reports/` first, then `write` the complete tickets to that file — not a summary. Use the ticket format from the `tester-qa` skill (Severity, Feature, Layer, Observed/Expected behavior, Steps to reproduce, Evidence, Root cause hypothesis). This keeps the bug report co-located with the spec (`.opencode/specs/<slug>.md`) and the loop trace (`.opencode/loop-trace.md`) and lets you re-read it on a loop-back.
4. Print one line per confirmed bug right before the pointer line: `BUG-XXX | Severity | Layer | <one-line root cause hypothesis>`.
5. Print a mandatory pointer line so the loop is self-describing: `BUG_REPORT: .opencode/bug-reports/<slug>.md` (bugs found) or `BUG_REPORT: none` (no bugs).
6. If bugs found: iterate back to step 2 (reload the impl skills first), re-read the bug report file IN FULL (`read` tool) before fixing, then re-run steps 3-10. Loop until `BUG_REPORT: none`.
7. print `SKILL_CONFIRM: test-writer-<lang> loaded and applied on step 10`.
8. `bash .../trace.sh "<repo-root>" "<loop_id>" "10" "skill" "test-writer-<lang>" "loaded" "<N> e2e specs written, <N> bugs, BUG_REPORT: <path|none>"`.
9. before step 11: `verify-step.sh ... "10" "skill" "test-writer-<lang>"` — if fail, redo step 10.

### 11. Documentation
**ACTIONS (in order):**
1. call the `skill` tool NOW with `documentation-writer`.
2. update or create documentation when public APIs or significant behavior changes. Skip only if internal refactors with no user-facing impact (trace as `status=skipped-by-user`).
3. print `SKILL_CONFIRM: documentation-writer loaded and applied on step 11`.
4. `bash .../trace.sh "<repo-root>" "<loop_id>" "11" "skill" "documentation-writer" "loaded" "<detail>"`.
5. before step 12: `verify-step.sh ... "11" "skill" "documentation-writer"` — if fail, redo step 11.

### 12. PR
**ACTIONS (in order):**
1. call the `skill` tool NOW with `githubpr`.
2. if no Jira ticket, create a conventional descriptive branch name. Open one detailed draft PR per modified repo. Commits are conventional. Do NOT merge — the user must be able to test on the local stack. Wait for CI green, then address reviewer feedback until 0 critical and score ≥ 8/10.
3. print `SKILL_CONFIRM: githubpr loaded and applied on step 12`.
4. `bash .../trace.sh "<repo-root>" "<loop_id>" "12" "skill" "githubpr" "loaded" "<PR URLs>"`.
5. final: `verify-step.sh ... "12" "skill" "githubpr"` — if fail, redo step 12.

## Guidelines

- Always complete the requirements phase before coding
- If code review reveals issues, iterate back to implementation (reload impl skills first)
- When chaining multiple tickets, be EXTRA vigilant about completing all steps — this is when steps get skipped
- **Reloading a skill is cheap and idempotent.** When in doubt, load it again before the step. The `skill` tool is the canonical way to guarantee the workflow guidance is present in context.