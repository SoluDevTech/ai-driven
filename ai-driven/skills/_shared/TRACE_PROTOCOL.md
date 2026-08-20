# Loop Trace Protocol

Shared protocol for `loop-implementation-review` and `loop-implementation-review-agents`.
Guarantees that every skill load and every agent delegation is recorded and verifiable.

## 1. Trace file

Path: `<repo-root>/.opencode/loop-trace.md` (created on first write, one file per implementation loop).

Format: append-only markdown table. Every line is one event.

```
| timestamp | loop_id | step | type | target | status | detail |
|-----------|---------|------|------|--------|--------|--------|
| 2026-08-19T10:32:01 | feat-auth-20260819 | 4 | skill | code-reviewer | loaded | score=9, critical=0 |
```

- `timestamp` — ISO 8601 local.
- `loop_id` — short unique id for the current implementation loop (see §3).
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
  "<repo-root>" "<loop_id>" "<step>" "<type>" "<target>" "<status>" "<detail>"
```

- Creates `.opencode/` if missing.
- Creates the file with the header row if it does not exist.
- Appends the event row.
- Prints the full trace to stdout on every call (so the orchestrator and the user see the audit trail grow in real time).

## 3. loop_id generation

The orchestrator generates the `loop_id` once at the start of the loop:

```bash
loop_id="feat-<slug>-$(date +%Y%m%d-%H%M%S)"
```

`<slug>` is a short kebab-case derived from the feature/bug summary (max 30 chars). The orchestrator MUST print the `loop_id` at the start of the session and reuse it for every `trace.sh` call.

## 4. Gate: verify before proceeding (runtime)

Before moving from step N to step N+1, the orchestrator MUST verify that the expected event for step N exists in the trace file:

```bash
bash /Users/yohan/.config/opencode/skills/_shared/verify-step.sh \
  "<repo-root>" "<loop_id>" "<step>" "<type>" "<target>"
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