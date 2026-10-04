---
description: "Lightweight agent-driven implementation loop wrapping feature-implementation-light. Delegates role steps (TDD, implementation, code review) to dedicated agents via the task tool — agents auto-load their declared skills via frontmatter. Tooling step (simplification) is loaded via the skill tool directly. Only 4 steps — TDD, implementation, code review (0 critical + score >= 8/10 with reviewer loop), and simplification. No QA, lint, Sonar, Trivy, docs, or PR steps. Use when the user asks to implement a feature/evolution/bugfix with a fast loop until code review sign-off — using agents as the execution layer."
---

Load the skill named "loop-implementation-review-agents-light" using the `skill` tool, then apply it to the following task:

$ARGUMENTS
