# Retry Strategy

Load when building a regression test suite from historical failures. 50-70% ASR increase, low cost.

## Implementation

### Basic Usage
```yaml
redteam:
  strategies:
    - id: retry
```

### With Configuration
```yaml
redteam:
  strategies:
    - id: retry
      config:
        numTests: 10  # Historical test cases per plugin
        plugins:      # Only retry failed tests from these plugins
          - harmful:hate
          - harmful:illegal
```

## Configuration Options

| Option | Default | Description |
|---|---|---|
| `numTests` | Matches each plugin's `numTests` | Max historical test cases per plugin |
| `plugins` | All plugins | List of specific plugins to apply retry to |

## How It Works

1. **Identifies** previously failed test cases for the target system (by target label)
2. **Selects** the most relevant failed test cases by plugin
3. **Incorporates** these cases into the current test suite
4. **Allows** subsequent strategies to build upon this historical knowledge

The retry strategy runs FIRST in the pipeline, allowing other strategies to build upon these historical test cases.

## Target-Specific

The retry strategy is **target-specific** — it only retries test cases that previously failed against the SAME target system (identified by target label). This ensures retried test cases are relevant to the specific target's known vulnerabilities.

**Important**: ensure consistent `label` values across runs for the same target.

## Example Scenario

```yaml
redteam:
  plugins:
    - id: harmful:hate
      numTests: 5
  strategies:
    - id: retry
    - id: jailbreak
```

If some hate speech tests previously failed against your target:
1. Retry generates 5 new hate speech test cases
2. Finds previously failed hate speech test cases for this target
3. Combines and deduplicates them
4. Selects the top 5 most relevant test cases
5. Passes these to `jailbreak` strategy for further refinement

## Best Practices

1. **Review and grade** your most recent red team scan before generating new test cases
2. **Use consistent target labels** across runs so retry can find historical failures
3. **Combine with other strategies** for maximum coverage — retry runs first, others build on it
4. **Scope with `plugins`** to focus retry on specific vulnerability categories

## Limitations

- Currently uses only your local database
- Cloud sharing of retry test cases across teams is coming soon
- Only retries tests that FAILED — passing tests are not re-included (use `basic` strategy for that)

## When to Use

- **Regression testing** — ensure past vulnerabilities are still fixed
- **Continuous monitoring** — re-test known weaknesses over time
- **Combined with drift detection** — see `promptfoo-redteam-supply-chain` skill
- **After mitigations** — verify that previously-failing tests now pass

## When NOT to Use

- First red team run (no historical failures to retry)
- Testing a new target with a different label (no matching history)
- You only want new test cases (use other strategies without retry)