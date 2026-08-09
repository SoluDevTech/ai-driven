# Code Review Scoring Rubric

Score each of the 6 dimensions from 1 to 10 using the anchors below. The overall score is your holistic judgment from the 6 dimension scores — you weight the dimensions based on the change's context (e.g. a security-critical change weights security higher; a pure refactor weights maintainability/architecture higher).

## Correctness
Does the code do what it's supposed to do, including edge cases?

| Score | Anchor |
|---|---|
| 10 | All happy paths and edge cases handled; null/empty/boundary inputs verified by tests; no logic errors |
| 8 | Happy paths correct; most edge cases handled; minor gaps that don't affect production |
| 5 | Core logic works but noticeable edge-case gaps (unhandled null, off-by-one, missing retry) |
| 0 | Logic errors present; will fail in production for legitimate inputs |

## Security
Is the code free of injection, secret exposure, broken auth, and unsafe input handling?

| Score | Anchor |
|---|---|
| 10 | Input validated at trust boundaries; secrets never logged/hardcoded; dependencies current; least privilege applied |
| 8 | No known vulnerabilities; minor hardening suggestions only |
| 5 | Missing input validation on an external-facing path OR a secret in a log OR an outdated dependency with a known CVE |
| 0 | RCE/SQLi/auth-bypass possible, or secrets committed to the repo |

## Performance
Will this scale without unnecessary CPU, memory, or I/O cost?

| Score | Anchor |
|---|---|
| 10 | No N+1, no blocking I/O on hot path, O(n) where needed, batches/pools used correctly |
| 8 | Acceptable for expected scale; one obvious optimization opportunity |
| 5 | N+1 query, O(n²) loop, or blocking call on a request path that will degrade under load |
| 0 | Will fall over at modest scale (unbounded fetch, full-table scan per request, memory leak) |

## Maintainability
Can the next developer understand and extend this without rewriting?

| Score | Anchor |
|---|---|
| 10 | Clear naming, single-responsibility units, no duplication, complexity matches the problem |
| 8 | Readable; one minor duplication or slightly-too-long function |
| 5 | Magic numbers, duplicated logic across 2+ places, or a function doing 3+ things |
| 0 | Unreadable, deeply nested, or copy-pasted with divergent edits — future changes will be risky |

## Testability
Is the code testable, and are the tests actually present and meaningful?

| Score | Anchor |
|---|---|
| 10 | Real implementations for internal deps, mocks only for external; tests cover happy + error + edge cases; coverage ≥ 80% on changed code |
| 8 | Good coverage of happy + error paths; one edge case missing |
| 5 | Only happy-path tested, OR internal deps mocked (false confidence), OR coverage < 50% on changed code |
| 0 | No tests, or tests that assert on implementation details rather than behavior |

## Architecture
Does the change respect the layer boundaries, dependency direction, and existing patterns?

| Score | Anchor |
|---|---|
| 10 | Respects domain/application/infrastructure split; depends on ports not adapters; follows repo conventions exactly |
| 8 | Right layer; one small convention violation (e.g. a domain file importing infrastructure) |
| 5 | Cross-layer leak (application reaching infrastructure directly, or infrastructure importing application) OR diverges from repo patterns without reason |
| 0 | Architecture broken (domain depends on framework, god class, dependency cycle) |

## How to decide the overall score
- Look at the 6 dimension scores
- Weight by context: a one-line bugfix weights correctness + testability; a new feature weights all six; a security-sensitive change weights security heavily; a pure refactor weights maintainability + architecture
- A single 0–3 in **Correctness** or **Security** usually caps the overall at 5 (request changes) regardless of other dimensions — these are production-safety blockers
- A 0–3 in any other dimension alone usually doesn't block, but two or more low dimensions pull the overall down
- The overall is a holistic judgment, not an average — justify it in one sentence in the Score table