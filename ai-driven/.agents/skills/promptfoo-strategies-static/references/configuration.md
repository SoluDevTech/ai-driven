# Configuration

Load when configuring static strategies. Basic config, plugin targeting, `basic` strategy.

## Basic Configuration

String syntax (simple strategies):
```yaml
redteam:
  strategies:
    - base64
    - rot13
    - leetspeak
```

Object syntax (with config):
```yaml
redteam:
  strategies:
    - id: base64
    - id: rot13
    - id: leetspeak
```

## Plugin Targeting

Strategies can be applied to specific plugins or the entire test suite. By default, strategies apply to all plugins.

```yaml
redteam:
  strategies:
    - id: rot13
      config:
        plugins:
          - harmful:hate  # Only apply rot13 to harmful:hate plugin
```

## The `basic` Strategy

The `basic` strategy is NOT a transformation — it controls whether original plugin-generated test cases are included without any strategies applied.

```yaml
redteam:
  strategies:
    - basic  # Include original untransformed test cases
```

Typically used to ensure baseline coverage alongside transformation strategies. When you add other strategies, `basic` is usually enabled by default to include the original test cases too.

To disable `basic` (only run transformed cases):
```yaml
redteam:
  strategies:
    - id: basic
      config:
        enabled: false
    - image
```

## Multiple Strategies

Combine multiple static strategies for broader coverage:

```yaml
redteam:
  strategies:
    - base64
    - hex
    - rot13
    - leetspeak
    - homoglyph
    - jailbreak-templates
```

Each strategy generates its own set of test cases from the plugin payloads, multiplying coverage.

## Cost Considerations

Static strategies are low cost — they don't use an attacker LLM. The main cost is the target model API calls for each transformed test case. Combining many strategies multiplies test cases, so plan accordingly.