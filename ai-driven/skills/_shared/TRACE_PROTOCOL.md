# Loop Trace Protocol

Shared protocol for `loop-implementation-review` and `loop-implementation-review-agents`.
Guarantees that every skill load and every agent delegation is recorded and verifiable.

## 0. Loop directory

Every implementation loop stores **all** its artifacts — spec, bug report, and trace — in one per-loop directory under the global opencode config:

```
~/.config/opencode/loops/loop-<timestamp>/
├── specs/
│   └── <slug>.md          # written by the product-owner agent
├── bug-reports/
│   └── <slug>.md          # written by the tester-qa agent / orchestrator (QA step)
└── loop-trace.md           # written by trace.sh
```

`<timestamp>` is `$(date +%Y%m%d-%H%M%S)`. The directory name (`loop-<timestamp>`) is also the `loop_id`.

### Creation

- **Normal flow** — the **product-owner agent** runs first. It generates the slug + timestamp, creates `~/.config/opencode/loops/loop-<timestamp>/specs/`, writes the spec, and prints:
  ```
  LOOP_DIR: <absolute-path-to-loop-dir>
  SPEC_FILE: <absolute-path-to-loop-dir>/specs/<slug>.md
  ```
- **Fallback (no spec / no product-owner)** — the **orchestrator** creates `~/.config/opencode/loops/loop-<timestamp>` itself at loop start, then derives `loop_id` from the directory name.
- **Orchestrator derivation** — at loop start the orchestrator detects `LOOP_DIR:` from the conversation (or extracts it from the `SPEC_FILE:` path). It then sets:
  ```bash
  loop_id="$(basename "${LOOP_DIR}")"
  ```
  No separate `loop_id` generation. The timestamp in the directory name is the single source of truth.

### Path style

All pointer lines (`LOOP_DIR:`, `SPEC_FILE:`, `BUG_REPORT:`) use **absolute paths** so agents running with `cwd=repo` can `read` them directly without tilde expansion or cwd assumptions.

## 1. Trace file

Path: `<LOOP_DIR>/loop-trace.md` (created on first write, one file per implementation loop).

Format: append-only markdown table. Every line is one event.

```
| timestamp | loop_id | step | type | target | status | detail |
|-----------|---------|------|------|--------|--------|--------|
| 2026-08-19T10:32:01 | loop-20260819-103201 | 4 | skill | code-reviewer | loaded | score=9, critical=0 |
```

- `timestamp` — ISO 8601 local.
- `loop_id` — the loop directory name (`loop-<timestamp>`), derived from `LOOP_DIR` (see §0).
- `step` — the checklist step number (0-12).
- `type` — `skill` | `agent` | `bash`.
- `target` — the skill name or agent identifier.
- `status` — `loaded` | `delegated` | `done` | `failed` | `skipped-by-user`.
- `detail` — short free text (score, file count, exit code, etc.).

## 2. Helper script

`trace.sh` (in this `_shared` directory) appends one line to the trace file.

Usage from a skill / orchestrator (Bash tool):

```bash
bash /Users/yohan/.config/opencode/skills/_shared/trace.sh \
  "<LOOP_DIR>" "<loop_id>" "<step>" "<type>" "<target>" "<status>" "<detail>"
```

- `<LOOP_DIR>` is the absolute path to the per-loop directory (e.g. `/Users/yohan/.config/opencode/loops/loop-20260819-103201`).
- Creates the loop directory if missing.
- Creates the trace file with the header row if it does not exist.
- Appends the event row.
- Prints the full trace to stdout on every call (so the orchestrator and the user see the audit trail grow in real time).

## 3. loop_id derivation

The orchestrator does NOT generate a `loop_id` from scratch. It derives it from the `LOOP_DIR` provided by the product-owner agent (or from the `SPEC_FILE:` path):

```bash
LOOP_DIR="<absolute-path>"      # from LOOP_DIR: or SPEC_FILE: pointer
loop_id="$(basename "${LOOP_DIR}")"
```

The orchestrator MUST print the `loop_id` at the start of the session and reuse it for every `trace.sh` / `verify-step.sh` call. `loop_id` and the loop directory name are always identical.

## 4. Gate: verify before proceeding (runtime)

Before moving from step N to step N+1, the orchestrator MUST verify that the expected event for step N exists in the trace file:

```bash
bash /Users/yohan/.config/opencode/skills/_shared/verify-step.sh \
  "<LOOP_DIR>" "<loop_id>" "<step>" "<type>" "<target>"
```

Exit code 0 = step is recorded as `loaded`/`delegated`/`done`. Exit code 1 = missing or failed — the orchestrator MUST STOP, print the trace, and redo step N.

## 5. Skill / agent confirmation string (gate runtime, in-output)

In addition to the trace file, every agent task prompt and every skill step MUST end its output with a single confirmation line:

- Skill: `SKILL_CONFIRM: <skill_name> loaded and applied on step <N>`
- Agent: `AGENT_CONFIRM: <agent_name> delegated on step <N> → <one-line result>`

The orchestrator greps this line from the output before calling `verify-step.sh`. If the line is missing, the step is considered not executed — redo it.

This dual gate (file trace + in-output confirmation) guarantees that:
- The skill/agent was actually invoked (in-output confirmation).
- The event is auditable after the fact (trace file).
- The orchestrator cannot silently skip a step (verify-step.sh blocks progression).