# Configuration

Load when configuring dynamic strategies. Plugin targeting, token budget, env vars, cost management.

## Basic Configuration

String syntax:
```yaml
redteam:
  strategies:
    - jailbreak
    - jailbreak:composite
```

Object syntax (with config):
```yaml
redteam:
  strategies:
    - id: jailbreak
      config:
        numIterations: 50
    - id: jailbreak:meta
      config:
        numIterations: 20
```

## Plugin Targeting

Strategies can be applied to specific plugins or the entire test suite. By default, strategies apply to all plugins.

```yaml
redteam:
  strategies:
    - id: jailbreak:tree
      config:
        plugins:
          - harmful:hate  # Only apply to harmful:hate plugin
```

## numIterations

Controls the number of refinement iterations for iterative strategies:

```yaml
strategies:
  - id: jailbreak
    config:
      numIterations: 50  # default: 4
```

Or via env var:
```bash
PROMPTFOO_NUM_JAILBREAK_ITERATIONS=5
```

- **Increase** for deeper exploration (higher cost, potentially higher ASR)
- **Decrease** for cost savings (may miss vulnerabilities)

## Token Budget

Dynamic strategies track token usage to prevent runaway costs:
- Stop after exhausting the configured token budget
- Stop early if a successful harmful output is generated
- Target, attacker, and grading tokens tracked separately

## Cost Management

| Strategy | Cost | Tip |
|---|---|---|
| `jailbreak` | High | Start with `numIterations: 4` (default), increase if needed |
| `jailbreak:meta` | High | Requires Cloud; start with `numIterations: 10` (default) |
| `jailbreak:composite` | Medium | Good balance of ASR and cost |
| `jailbreak:tree` | High | Branching exploration, no Cloud needed |
| `best-of-n` | High | Parallel sampling, highest cost |
| `citation`/`likert`/`math-prompt` | Medium | Academic framing, moderate cost |
| `gcg` | High | Low ASR (0-10%), research use only |

## Recommended Starting Point

For most applications, this provides comprehensive single-turn coverage:

```yaml
redteam:
  strategies:
    - jailbreak:meta       # Broad single-turn coverage (70-90% ASR)
    - jailbreak:composite  # Deep technique chaining (60-80% ASR)
```

If Cloud is unavailable:
```yaml
redteam:
  strategies:
    - jailbreak            # Iterative refinement (60-80% ASR, no Cloud)
    - jailbreak:tree       # Branching exploration (60-80% ASR, no Cloud)
```

## Session Management

When using `transformVars` with `context.uuid`, each iteration gets a new UUID:

```yaml
defaultTest:
  options:
    transformVars: '{ ...vars, sessionId: context.uuid }'
```

This prevents conversation history from affecting subsequent attempts in iterative strategies.