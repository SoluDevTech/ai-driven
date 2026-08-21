---
description: "Agent-driven development workflow for implementation tasks. Use this command when the user asks to implement a feature, fix a bug, or make significant code changes. Delegates role steps (TDD, implementation, QA) to dedicated agents via the task tool — agents auto-load their declared skills via frontmatter. Tooling steps (code review, simplification, linting, sonar, trivy, documentation, PR) are loaded via the skill tool directly. Use this when you want agents as the execution layer for roles and skills as the execution layer for tooling steps."
---

Load the skill named "feature-implementation-agents" using the `skill` tool, then apply it to the following task:

$ARGUMENTS