---
description: "Implementation loop wrapping feature-implementation. Adds mandatory NEW e2e QA tests in `soludev-compose-apps/<app_name>/e2e` (real path on disk, NO leading `@`), a zero-critical-issues code review gate, one draft PR per modified repo, and a reviewer loop until 0 critical issues and score >= 8/10. Use when the user asks to implement a feature/evolution/bugfix and loop until QA, code review, and PR reviewer sign-off are all green."
subtask: true
---

Load the skill named "loop-implementation-review" using the `skill` tool, then apply it to the following task:

$ARGUMENTS

