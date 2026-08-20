# Strategy Selection

Load when choosing a multi-turn strategy. Decision matrix by goal, Cloud availability, and cost.

## Quick Start (Recommended for Multi-Turn)

```yaml
redteam:
  strategies:
    - jailbreak:hydra  # Multi-turn adaptive conversations
```

If Cloud is unavailable:
```yaml
redteam:
  strategies:
    - crescendo  # Gradual escalation, no Cloud needed
```

## Decision Matrix

| Goal | Strategy | ASR | Cost | Cloud? |
|---|---|---|---|---|
| Adaptive branching with memory | `jailbreak:hydra` | 70-90% | High | Yes |
| IICL-inspired exploration | `jailbreak:goblin` | 70-90% | High | Yes |
| Gradual escalation | `crescendo` | 70-90% | High | No |
| Meta GOAT research approach | `goat` | 70-90% | High | No |
| Persistent creative user | `mischievous-user` | 10-20% | High | No |

## Hydra vs Crescendo

| Aspect | Hydra (`jailbreak:hydra`) | Crescendo |
|---|---|---|
| Approach | Adaptive branching with persistent scan-wide memory | Gradual escalation from benign to harmful |
| Memory | Shares learnings across ALL tests in the scan | Per-test only |
| Cloud | Required | Not required |
| Backtracking | Automatic, with `maxBacktracks` | Yes, rewinds on refusal |
| Best for | Stateful agents with evasive defenses, large org-wide red teams | Simple gradual escalation, no Cloud |
| ASR | 70-90% | 70-90% |

## Hydra vs Goblin

Goblin reuses Hydra's multi-turn mechanics with a different attacker prompt:
- **Hydra** — general-purpose adaptive attacker
- **Goblin** — IICL-inspired (abstract few-shot pattern completion, occasional encoding shifts)

Use Goblin as a complementary strategy when you want research-inspired exploration rather than the default general-purpose attacker.

## When to Use Each

**Use `jailbreak:hydra` when:**
- Your product exposes a conversational bot or agent with stateful behavior
- Guardrails block straightforward jailbreaks and you need an adversary that can pivot
- You want to reuse learnings across an entire scan (large org-wide red teams)
- Cloud access is available

**Use `crescendo` when:**
- You want gradual escalation without Cloud
- Testing simple stateful chatbots
- Cost is a concern (still high, but no Cloud dependency)

**Use `goat` when:**
- You want Meta's GOAT research approach
- No Cloud available
- Iterative template refinement fits your needs

**Use `mischievous-user` when:**
- You want to simulate a persistent, creative user
- Lower ASR (10-20%) is acceptable
- Testing customer service bot scenarios

## Combining with Other Strategies

Multi-turn strategies can be combined with static or dynamic via `layer`:

```yaml
# Multi-turn + audio encoding
strategies:
  - id: layer
    config:
      steps:
        - jailbreak:hydra  # Multi-turn branching
        - audio            # Convert each turn to speech
```

See `promptfoo-strategies-custom-regression` skill for full `layer` documentation.