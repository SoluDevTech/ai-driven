---
name: loop-implementation-review-agents
description: Agent-driven implementation loop wrapping feature-implementation-agents. Aggressively delegates role steps to dedicated agents via the `task` tool (agents auto-load their declared skills via frontmatter) AND aggressively loads pure-skill steps (code-reviewer, code-simplifier, linter, sonarfix, trivyfix, documentation-writer, githubpr) via the `skill` tool directly. Adds mandatory NEW e2e QA tests in `soludev-compose-apps/<app_name>/e2e` (real path, NO leading `@`), a zero-critical-issues code review gate, one draft PR per modified repo, and a reviewer loop until 0 critical issues and score >= 8/10. Use when the user asks to implement a feature/evolution/bugfix and loop until QA, code review, and PR reviewer sign-off are all green — using agents as the execution layer for roles and skills as the execution layer for tooling steps.
---

You orchestrate an agent-driven implementation loop that wraps the **feature-implementation-agents** skill. Follow EVERY feature-implementation-agents step in order — none is optional, none can be skipped. feature-implementation-agents aggressively delegates role steps to agents (which auto-load their skills via frontmatter) and aggressively loads pure-skill steps via the `skill` tool, AND applies the trace & verification protocol from `/Users/yohan/.config/opencode/skills/_shared/TRACE_PROTOCOL.md` (trace file + in-output `AGENT_CONFIRM`/`SKILL_CONFIRM` confirmation + `verify-step.sh` gate before progressing). You enforce the gates below on top of it.

## Trace & verification (enforced)

At the start of the loop, generate and print a `loop_id`:
```bash
loop_id="feat-<slug>-$(date +%Y%m%d-%H%M%S)"
```
The wrapped feature-implementation-agents skill writes a trace event to `<repo-root>/.opencode/loop-trace.md` after every agent delegation (`type=agent`) and every skill load (`type=skill`), and verifies it before moving to the next step. You (the orchestrator) MUST:
1. Print the `loop_id` at the start of the session.
2. After every loop iteration (QA or code review failed → back to implementation), verify the full trace is consistent: `cat <repo-root>/.opencode/loop-trace.md` and confirm every step N has a `delegated`/`loaded`/`done` event before the iteration ended.
3. Before opening the PR, run `verify-step.sh` for every step 1-11 in order. If any fails, STOP and redo the missing step.

## Conventions

- Respect the global AGENTS.md.
- Role steps (requirements, TDD, implementation, code review, QA) are delegated to agents via the `task` tool. Agents auto-load their declared skills through the `skills:` frontmatter — you remind them in every task prompt. The `code-reviewer-<lang>` agents run on `ollama-cloud/kimi-k2.7-code`.
- Pure-skill steps (simplification, linting, sonar, trivy, documentation, PR) are loaded via the `skill` tool directly by you (the orchestrator) — they are not agents.
- Backend (Python/FastAPI) → `fastapi-hexagonal` agent (skills: `hexagonal-python-patterns`, `async-python-patterns`, `performance-audit`).
- Backend (NestJS) → `nestjs-hexagonal` agent (skills: `hexagonal-nestjs-patterns`, `async-nestjs-patterns`, `performance-audit`).
- Frontend / React App → `react-hexagonal` agent (skills: `hexagonal-react-patterns`, `async-react-patterns`, `vercel-react-best-practices`, `performance-audit`). Use OpenDesign MCP and respect the Open Design maquette and the `<app-name>` design system.
- The orchestrator does NOT write code — it delegates to agents and loads skills for tooling steps.

## Spec file forwarding (mandatory)

The product-owner agent persists its Requirements Document to `.opencode/specs/<slug>.md` and prints a `SPEC_FILE: <path>` pointer line. You MUST consume this spec and ensure the wrapped feature-implementation-agents skill passes its PATH to every delegated agent (not the content).

1. **Detect the spec source** — check if `$ARGUMENTS` (or the user's input) contains a file path matching `.opencode/specs/*.md`. Also look for a `SPEC_FILE: <path>` line in the conversation history.
2. **Store the path only** — if found, store the path. Do NOT read the content and do NOT copy it into task prompts. The wrapped feature-implementation-agents skill passes the path to agents; agents read the file themselves with `read`.
3. **State the spec mode** before the loop starts:
   - `SPEC_MODE: file — <path>` (spec file path found — pass the path to agents)
   - `SPEC_MODE: conversation-fallback` (no spec file — pass conversation context in the task prompt)
4. **Path forwarding is non-negotiable** — the wrapped feature-implementation-agents skill MUST include `SPEC_FILE: <path>` plus a `read` instruction in every `task` delegation prompt (steps 1, 2, 10). Agents do NOT see the conversation. The agent reads the spec file itself — never paste the content, never summarize it. A summarized or pasted-but-truncated spec is an invalid delegation — redo it with the path-only instruction.
5. **Fallback** — if no spec file path is provided and no `SPEC_FILE` line is found, fall back to conversation context in the task prompt. State explicitly that you are in fallback mode. A summary is acceptable ONLY in fallback mode.

## Skill + agent loading is mandatory at every step

The wrapped feature-implementation-agents skill is aggressive about loading/delegating at every step. You MUST NOT skip the `task` call (role steps) or the `skill` call (tooling steps). The map is:

| Step | Type | Load / delegate |
|------|------|-----------------|
| 1 (TDD) | agent | `task` → `test-writer` (auto-loads test-writer-<lang> + hexagonal + async) |
| 2 (Impl) | agent | `task` → `fastapi-hexagonal` / `react-hexagonal` / `nestjs-hexagonal` (auto-loads architecture + async + performance) |
| 3 (Test suite) | bash | run full test suite |
| 4 (Review) | agent | `task` → `code-reviewer-python` / `code-reviewer-react` / `code-reviewer-nestjs` (auto-loads code-reviewer + hexagonal + async + performance-audit + test-writer skills; runs on kimi-k2.7-code) |
| 5 (Simplify) | skill | `skill` → `code-simplifier` |
| 6 (Lint) | skill | `skill` → `linter` |
| 7 (Unit tests) | bash | run all unit tests |
| 8 (Sonar) | skill | `skill` → `sonarfix` |
| 9 (Trivy) | skill | `skill` → `trivyfix` |
| 10 (QA) | agent | `task` → `tester-qa` (auto-loads QA conventions) |
| 11 (Docs) | skill | `skill` → `documentation-writer` |
| 12 (PR) | skill | `skill` → `githubpr` |

## QA gate (do not skip)

- QA is a first-class step (step 10). The `tester-qa` agent MUST add **NEW** e2e/QA tests in `soludev-compose-apps/<app_name>/e2e`. Re-running existing tests is not enough.
- **NEVER skip e2e claiming the workspace does not exist.** Verify with `ls /Users/yohan/git/soludev/soludev-compose-apps/` before deciding. If the app subfolder exists (e.g. `soludev-compose-apps/ubby/e2e/`), the agent MUST write and run e2e there. Only if the app truly has no e2e folder after `ls` may it fall back to unit/integration tests — and state so explicitly with the `ls` output.
- Restart the impacted apps containers before QA — the `tester-qa` agent does this.

## Code review gate

- The `code-reviewer-<lang>` agent MUST report **0 critical issues** and a score **≥ 8/10** before you open any PR. Loop back to the implementation agent (reload via `task` with `task_id` to resume session) if any critical issue remains or the score is below 8.

## Loop

- Loop while QA and code review are not OK. Only when both are green do you commit and open a PR.
- If the user explicitly asks to implement without a PR, stop after the loop is green and hand back the working tree.
- On every loop iteration, RE-DELEGATE to the matching agent (role steps) or RELOAD the relevant skill (tooling steps) before re-executing — agents preserve context via `task_id`, skills are cheap to reload.

## GitHub (default: open a PR)

- Use the **githubpr** skill. If no Jira ticket, create a conventional descriptive branch name. Commits are conventional.
- Open one **detailed** PR **per modified repo**. Do NOT merge — the user must be able to test on the local stack.
- Wait for CI to be green. Then another bot reviews. Address what is pertinent and loop until the reviewer finds **no critical issues** and rates the review **at least 8/10**.