# GOAT and Mischievous User Strategies

Load when configuring GOAT or mischievous-user. Both are high cost, no Cloud required.

## GOAT (`goat`)

Based on [Meta's GOAT research](https://arxiv.org/abs/2311.04300) — Generalized Offensive Adversarial Testing. Uses attack templates iteratively refined over multiple turns.

```yaml
# Basic usage
redteam:
  strategies:
    - goat

# With configuration
redteam:
  strategies:
    - id: goat
      config:
        maxTurns: 5
        stateful: false
        continueAfterSuccess: false
```

**ASR**: 70-90% | **Cost**: High | **Cloud**: No

### Configuration Options

| Option | Default | Description |
|---|---|---|
| `maxTurns` | 5 | Maximum conversation turns |
| `stateful` | `false` | `true` = target-managed session; `false` = replay transcript |
| `continueAfterSuccess` | `false` | `true` = continue after first successful attack |

### When to Use GOAT
- You want Meta's GOAT research approach
- No Cloud available
- Iterative template refinement fits your needs
- Testing with attack templates that are refined over turns

## Mischievous User (`mischievous-user`)

Simulates a multi-turn conversation between a mischievous user and an agent. Tries different phrasings and approaches over several turns.

```yaml
# Basic usage
redteam:
  strategies:
    - mischievous-user

# With configuration
redteam:
  strategies:
    - id: mischievous-user
      config:
        maxTurns: 5
        stateful: false
```

**ASR**: 10-20% | **Cost**: High | **Cloud**: No

### When to Use Mischievous User
- Simulating a persistent, creative user
- Testing customer service bot scenarios
- Lower ASR (10-20%) is acceptable
- You want a different attack persona than crescendo or GOAT

### When NOT to Use
- You need high ASR → use `crescendo`, `jailbreak:hydra`, or `goat` (70-90%)
- Cost is a primary concern (mischievous-user is high cost with low ASR)

## Combining Both

```yaml
redteam:
  strategies:
    - goat               # High ASR, template refinement
    - mischievous-user   # Different persona, complements GOAT
```

Each generates its own multi-turn conversations from plugin payloads, multiplying coverage.