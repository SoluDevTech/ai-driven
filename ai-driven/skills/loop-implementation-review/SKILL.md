---
name: loop-implementation-review
description: Skill-driven implementation loop wrapping feature-implementation. Aggressively loads the matching skill via the `skill` tool at EVERY step. Adds mandatory NEW e2e QA tests in `soludev-compose-apps/<app_name>/e2e` (real path on disk, NO leading `@`), a zero-critical-issues code review gate, one draft PR per modified repo, and a reviewer loop until 0 critical issues and score >= 8/10. Use when the user asks to implement a feature/evolution/bugfix and loop until QA, code review, and PR reviewer sign-off are all green. Skills version (no agent delegation).
---

You orchestrate a skill-driven implementation loop that wraps the **feature-implementation** skill. Follow EVERY feature-implementation step in order — none is optional, none can be skipped. feature-implementation aggressively loads the required skill via the `skill` tool at every step AND applies the trace & verification protocol from `/Users/yohan/.config/opencode/skills/_shared/TRACE_PROTOCOL.md` (trace file + in-output `SKILL_CONFIRM` confirmation + `verify-step.sh` gate before progressing). You enforce the gates below on top of it.

## Trace & verification (enforced)

At the start of the loop, generate and print a `loop_id`:
```bash
loop_id="feat-<slug>-$(date +%Y%m%d-%H%M%S)"
```
The wrapped feature-implementation skill writes a trace event to `<repo-root>/.opencode/loop-trace.md` after every skill load and verifies it before moving to the next step. You (the orchestrator) MUST:
1. Print the `loop_id` at the start of the session.
2. After every loop iteration (QA or code review failed → back to implementation), verify the full trace is consistent: `cat <repo-root>/.opencode/loop-trace.md` and confirm every step N has a `loaded`/`done` event before the iteration ended.
3. Before opening the PR, run `verify-step.sh` for every step 1-11 in order. If any fails, STOP and redo the missing step.

## Conventions

- Respect the global AGENTS.md and the invoked skills.
- Backend (Python/FastAPI) → feature-implementation loads `hexagonal-python-patterns`, `async-python-patterns`, `performance-audit` at the implementation step.
- Backend (NestJS) → feature-implementation loads `hexagonal-nestjs-patterns`, `async-nestjs-patterns`, `performance-audit`.
- Frontend / React App → feature-implementation loads `hexagonal-react-patterns`, `async-react-patterns`, `vercel-react-best-practices`, `performance-audit`. Use OpenDesign MCP and respect the Open Design maquette and the `<app-name>` design system.
- The orchestrator does NOT write code — it loads the skill for each step and executes the step per the skill's guidance.

## Skill loading is mandatory at every step

The wrapped feature-implementation skill loads the required skill via the `skill` tool BEFORE executing each step. You MUST NOT skip the `skill` call. The skill map is:

| Step | Skill(s) loaded |
|------|------------------|
| 1 (TDD) | `test-writer-<lang>` + `hexagonal-<lang>` + `async-<lang>` |
| 2 (Impl) | `hexagonal-<lang>` + `async-<lang>` + `performance-audit` |
| 4 (Review) | `code-reviewer` + `hexagonal-python-patterns` + `async-python-patterns` + `performance-audit` + `test-writer-python` | `code-reviewer` + `hexagonal-react-patterns` + `async-react-patterns` + `performance-audit` + `test-writer-react` | `code-reviewer` + `hexagonal-nestjs-patterns` + `async-nestjs-patterns` + `performance-audit` + `test-writer-nestjs` |
| 5 (Simplify) | `code-simplifier` |
| 6 (Lint) | `linter` |
| 8 (Sonar) | `sonarfix` |
| 9 (Trivy) | `trivyfix` |
| 10 (QA) | `test-writer-<lang>` (for e2e spec conventions) |
| 11 (Docs) | `documentation-writer` |
| 12 (PR) | `githubpr` |

`<lang>` ∈ {`python`, `react`, `nestjs`} per the detected stack.

## QA gate (do not skip)

- QA is a first-class step. In addition to the manual QA run, you MUST add **NEW** e2e/QA tests in `soludev-compose-apps/<app_name>/e2e` to validate the feature/evolution/bugfix you just shipped. Re-running existing tests is not enough.
- **NEVER skip e2e claiming the workspace does not exist.** The directory is `soludev-compose-apps` (NO leading `@` — that is a monorepo alias, not a real path). Verify with `ls /Users/yohan/git/soludev/soludev-compose-apps/` before deciding. If the app subfolder exists (e.g. `soludev-compose-apps/ubby/e2e/`), you MUST write and run e2e there. Only if the app truly has no e2e folder after `ls` may you fall back to unit/integration tests — and state so explicitly with the `ls` output.
- Restart the impacted apps containers before QA.

## Code review gate

- The code review (step 4) loads `code-reviewer` + stack-specific skills (`hexagonal-<lang>-patterns`, `async-<lang>-patterns`, `performance-audit`, `test-writer-<lang>`) to enrich the review with architecture compliance, async correctness, performance patterns, and test quality conventions. It MUST report **0 critical issues** and a score **≥ 8/10** before you open any PR. Loop back to implementation (reload the impl skills first) if any critical issue remains or the score is below 8.

## Loop

- Loop while QA and code review are not OK. Only when both are green do you commit and open a PR.
- If the user explicitly asks to implement without a PR, stop after the loop is green and hand back the working tree.
- On every loop iteration, RELOAD the relevant skill via the `skill` tool before re-executing the step — skills are cheap to reload and guarantee the guidance is present.

## GitHub (default: open a PR)

- Use the **githubpr** skill. If no Jira ticket, create a conventional descriptive branch name. Commits are conventional.
- Open one **detailed** PR **per modified repo**. Do NOT merge — the user must be able to test on the local stack.
- Wait for CI to be green. Then another bot reviews. Address what is pertinent and loop until the reviewer finds **no critical issues** and rates the review **at least 8/10**.