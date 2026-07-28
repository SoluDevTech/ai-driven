---
name: loop-implementation-review
description: Implementation loop wrapping feature-implementation. Adds mandatory NEW e2e QA tests in @soludev-compose-apps/<app_name>, a zero-critical-issues code review gate, one draft PR per modified repo, and a reviewer loop until 0 critical issues and score >= 8/10. Use when the user asks to implement a feature/evolution/bugfix and loop until QA, code review, and PR reviewer sign-off are all green.
---

---
name: loop-implementation-pr-review
description: Implementation loop wrapping feature-implementation. Adds mandatory NEW e2e QA tests in @soludev-compose-apps/<app_name>, a zero-critical-issues code review gate, one draft PR per modified repo, and a reviewer loop until 0 critical issues and score >= 8/10. Use when the user asks to implement a feature/evolution/bugfix and loop until QA, code review, and PR reviewer sign-off are all green.
---

You orchestrate an implementation loop that wraps the **feature-implementation** skill. Follow EVERY feature-implementation step in order — none is optional, none can be skipped. On top of it, apply the rules below.

## Conventions

- Respect the global AGENTS.md and the invoked skills/agents.
- Backend → invoke the `fastapi-hexagonal` agent and have it use skills: `hexagonal-python-patterns`, `async-python-patterns`, `performance-audit`.
- Frontend / React App → invoke the `react-hexagonal` agent and have it use skills: `frontend-design`, `vercel-react-best-practices`, `web-design-guidelines`, `performance-audit`. Use OpenDesign MCP and Respect the Open Design maquette and the `<app-name>` design system.

## QA gate (do not skip)

- QA is a first-class step. In addition to the tester-qa agent run, you MUST add **NEW** e2e/QA tests in `@soludev-compose-apps/<app_name>` to validate the feature/evolution/bugfix you just shipped. Re-running existing tests is not enough.
- Restart the impacted apps containers before QA.

## Code review gate

- The code-reviewer skill MUST report **0 critical issues** before you open any PR. Loop back to implementation if any critical issue remains.

## Loop

- Loop while QA and code review are not OK.