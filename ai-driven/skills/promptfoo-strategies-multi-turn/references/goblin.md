# Goblin Multi-Turn Strategy

Load when configuring the goblin strategy. 70-90% ASR, high cost, requires Cloud.

## Implementation

```yaml
# Basic usage
redteam:
  strategies:
    - jailbreak:goblin

# With configuration
redteam:
  strategies:
    - id: jailbreak:goblin
      config:
        maxTurns: 10      # Optional: default 10
        stateful: false   # Optional: default false (replay mode)
```

## Cloud Required

Goblin uses Hydra's multi-turn mechanics, which require Promptfoo Cloud. Set `PROMPTFOO_REMOTE_GENERATION_URL` or sign in to Promptfoo Cloud.

## What Makes Goblin Different

Goblin reuses Hydra's adaptive multi-turn mechanics (branching, persistent memory, backtracking) but with a different attacker prompt:
- **IICL-inspired** — abstract few-shot pattern completion
- **Occasional encoding shifts** — rotates between encoding techniques during the attack
- **Math and logic problems** — incorporates mathematical and logical reasoning into attacks

Use Goblin as a **complementary strategy** when you want research-inspired exploration rather than the default general-purpose attacker (Hydra).

## Configuration Options

| Option | Default | Description |
|---|---|---|
| `maxTurns` | 10 | Maximum conversation turns |
| `stateful` | `false` | `true` = target-managed session; `false` = replay transcript |

(Same options as Hydra — Goblin shares the underlying mechanics.)

## When to Use Goblin

- You want **research-inspired exploration** (IICL pattern completion, encoding shifts)
- Hydra's general-purpose attacker isn't finding vulnerabilities
- You want a **complementary** strategy alongside Hydra
- Testing targets that may be resistant to standard conversational attacks but vulnerable to encoding/math-based approaches

## When NOT to Use

- You need the default general-purpose attacker → use `jailbreak:hydra`
- You need gradual escalation without Cloud → use `crescendo`
- You need a low-cost option → use `promptfoo-strategies-dynamic` (`jailbreak`)