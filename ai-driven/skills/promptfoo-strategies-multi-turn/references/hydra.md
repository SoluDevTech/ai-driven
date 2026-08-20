# Hydra Multi-Turn Strategy

Load when configuring the hydra strategy. 70-90% ASR, high cost, requires Cloud.

## Implementation

```yaml
# Basic usage
redteam:
  strategies:
    - jailbreak:hydra

# With configuration
redteam:
  strategies:
    - id: jailbreak:hydra
      config:
        maxTurns: 12        # Optional: default 10
        maxBacktracks: 5    # Optional: default 10
        stateful: false     # Optional: default false (replay mode)
```

## Cloud Required

Hydra relies on Promptfoo Cloud to coordinate the attacker agent, maintain scan-wide learnings, and manage branching logic. Set `PROMPTFOO_REMOTE_GENERATION_URL` or sign in to Promptfoo Cloud.

## Configuration Options

| Option | Default | Description |
|---|---|---|
| `maxTurns` | 10 | Maximum conversation turns before stopping. Increase for deeper exploration. |
| `maxBacktracks` | 10 | Times to roll back last turn on refusal. Set to 0 automatically when `stateful: true`. |
| `stateful` | `false` | `true` = target-managed session (send only newest turn); `false` = replay full transcript |

## How It Works

1. **Goal selection** — Hydra pulls the red team goal from plugin metadata or injected variable
2. **Agent decisioning** — coordinating agent in Promptfoo Cloud evaluates prior turns, chooses next attack message
3. **Target probing** — message sent as replayed transcript or newest turn (based on `stateful`)
4. **Outcome grading** — responses graded with configured plugin assertions, stored for learning
5. **Adaptive branching** — on refusals, Hydra backtracks and explores alternate branches until success, `maxBacktracks` exhausted, or `maxTurns` reached

Hydra keeps a **per-scan memory** — later test cases can reuse successful tactics discovered earlier in the run.

## Two Delivery Modes

### Replay Mode (`stateful: false`, default)
- Sends full conversation transcript to target on every turn
- Use when target is stateless or expects entire message history
- Supports backtracking

### Target-Managed Session Mode (`stateful: true`)
- Sends only the newest turn
- Your provider must preserve earlier turns (cookies, server session, OpenAI Agents session factory)
- No backtracking (`maxBacktracks` set to 0)

## Hydra vs Other Agentic Strategies

| Strategy | Turn Model | Best For | Cost |
|---|---|---|---|
| `jailbreak` | Single-turn | Fast baselines, low cost | Low |
| `jailbreak:meta` | Iterative taxonomy | Broad single-shot coverage | Medium |
| `jailbreak:hydra` | Multi-turn branching | Stateful agents, evasive defenses | High |

## When to Use Hydra

- Product exposes a conversational bot or agent workflow with stateful behavior
- Guardrails block straightforward jailbreaks and you need an adversary that can pivot
- You want to reuse learnings across an entire scan (large org-wide red teams)

Hydra is most effective when paired with plugin suites like `harmful`, `pii`, or `rbac` that define concrete failure conditions via graders.

## Tip

Hydra manages attacker-side history and backtracking. Your target provider manages target-side persistence in `stateful: true` mode. In Cloud, Hydra can derive the mode from the target configuration. In the open-source CLI/UI, set `stateful: true` only after configuring sessions in the provider.