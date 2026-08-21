---
description: "Agent-driven implementation loop wrapping feature-implementation-agents. Delegates role steps (TDD, implementation, QA) to dedicated agents via the task tool — agents auto-load their declared skills via frontmatter. Tooling steps (code review, simplification, linting, sonar, trivy, documentation, PR) are loaded via the skill tool directly. Adds mandatory NEW e2e QA tests in `soludev-compose-apps/<app_name>/e2e`, a zero-critical-issues code review gate, one draft PR per modified repo, and a reviewer loop until 0 critical issues and score >= 8/10. Use when the user asks to implement a feature/evolution/bugfix and loop until QA, code review, and PR reviewer sign-off are all green — using agents as the execution layer."
---

Load the skill named "loop-implementation-review-agents" using the `skill` tool, then apply it to the following task:

$ARGUMENTS