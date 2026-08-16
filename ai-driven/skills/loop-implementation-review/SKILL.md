---
name: loop-implementation-review
description: Implementation loop wrapping feature-implementation. Adds mandatory NEW e2e QA tests in @soludev-compose-apps/<app_name>, a zero-critical-issues code review gate, one draft PR per modified repo, and a reviewer loop until 0 critical issues and score >= 8/10. Use when the user asks to implement a feature/evolution/bugfix and loop until QA, code review, and PR reviewer sign-off are all green.
---

You orchestrate an implementation loop that wraps the **feature-implementation** skill. Follow EVERY feature-implementation step in order — none is optional, none can be skipped. On top of it, apply the rules below.

## Conventions

- Respect the global AGENTS.md and the invoked skills.
- You load skills directly via the `skill` tool. Do not delegate to agents inside this workflow.
- Backend (Python/FastAPI) → load skills: `hexagonal-python-patterns`, `async-python-patterns`, `performance-audit`.
- Frontend / React App → load skills: `hexagonal-react-patterns`, `async-react-patterns`, `vercel-react-best-practices`, `performance-audit`. Use OpenDesign MCP and respect the Open Design maquette and the `<app-name>` design system.
- NestJS backend → load skills: `hexagonal-nestjs-patterns`, `async-nestjs-patterns`, `performance-audit`.

## QA gate (do not skip)

- QA is a first-class step. In addition to loading the `tester-qa` skill, you MUST add **NEW** e2e/QA tests in `@soludev-compose-apps/<app_name>` to validate the feature/evolution/bugfix you just shipped. Re-running existing tests is not enough.
- Restart the impacted apps containers before QA.

## Code review gate

- The `code-reviewer` skill MUST report **0 critical issues** and a score **≥ 8/10** before you open any PR. Loop back to implementation if any critical issue remains or the score is below 8.

## Loop

- Loop while QA and code review are not OK. Only when both are green do you commit and open a PR.
- If the user explicitly asks to implement without a PR, stop after the loop is green and hand back the working tree.

## GitHub (default: open a PR)

- Use the **githubpr** skill. If no Jira ticket, create a conventional descriptive branch name. Commits are conventional.
- Open one **detailed** PR **per modified repo**. Do NOT merge — the user must be able to test on the local stack.
- Wait for CI to be green. Then another bot reviews. Address what is pertinent and loop until the reviewer finds **no critical issues** and rates the review **at least 8/10**.