# Strategies

Load before selecting attack-framing strategies. Strategies wrap plugin probes in adversarial framing.

## Why Plugin + Strategy
- **Plugin** = *what* vulnerability class
- **Strategy** = *how* the attacker frames the probe

Pair them under `redteam.plugins` + `redteam.strategies`.

## Common Strategies

| Strategy | Description | When to use |
|---|---|---|
| `jailbreak` | Single-shot optimization of safety bypass | Default for most red teams |
| `jailbreak-templates` | Static jailbreak templates (DAN, etc.) | Quick static coverage |
| `jailbreak:tree` | Tree-based complex jailbreaks | Deep adaptive attacks |
| `jailbreak:composite` | Combines multiple jailbreak techniques | Maximum effectiveness |
| `jailbreak:meta` | Adaptive meta-reasoning (needs tracing) | Trace-based agent testing |
| `jailbreak:hydra` | Hydra-style adaptive (needs tracing) | Trace-based agent testing |
| `jailbreak:likert` | Likert-scale technique (Anthropic/Stanford) | Foundation model assessment |
| `best-of-n` | Best-of-N sampling (Anthropic/Stanford) | Foundation model assessment |
| `crescendo` | Multi-turn gradual escalation | Stateful chatbots |
| `goat` | Goal-oriented adversarial | Stateful chatbots |
| `mischievous-user` | Mischievous user persona | Stateful chatbots |
| `translation` | Cross-language evasion | Guardrail evasion testing |
| `misspelling` | Character substitution evasion | Guardrail evasion testing |
| `image` | Text→image conversion | Multimodal (see `promptfoo-redteam-multimodal`) |
| `audio` | Text→audio conversion | Multimodal |
| `video` | Text→video conversion | Multimodal |

## Configuration

```yaml
redteam:
  strategies:
    - jailbreak-templates
    - jailbreak
    - id: jailbreak:composite
      config:
        # strategy-specific config if needed
```

## Stateful Strategies (Multi-Turn)

For multi-turn chatbots, set `stateful: true`:

```yaml
strategies:
  - id: goat
    config:
      stateful: true
  - id: crescendo
    config:
      stateful: true
  - id: mischievous-user
    config:
      stateful: true
```

Requires `conversationId` via `transformVars` — see `promptfoo-redteam-agents` skill.

## numTests Tuning

```yaml
redteam:
  numTests: 10  # tests per plugin (default)
  plugins:
    - id: harmful
      numTests: 20  # override per-plugin
```

- **Iterative dev**: 5-10 per plugin
- **Benchmarks**: 20+ per plugin
- **Full HarmBench**: 400 (see `promptfoo-redteam-foundation-models`)

## Purpose Field

Always set `redteam.purpose` — it guides both generation and grading:

```yaml
redteam:
  purpose: |
    Customer service chatbot for an e-commerce platform.
    Users can ask about orders, returns, and product information.
    The bot should not reveal internal pricing, customer data, or system details.
```

## Grader Override

When the default `gpt-5` grader is unavailable:

```yaml
defaultTest:
  options:
    provider: 'ollama:chat:llama4:scout'
```