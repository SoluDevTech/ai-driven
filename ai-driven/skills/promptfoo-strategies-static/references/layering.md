# Layering Static Strategies

Load when chaining multiple static strategies sequentially via the `layer` strategy.

## Quick Start

```yaml
strategies:
  - id: layer
    config:
      steps:
        - base64  # First encode as base64
        - rot13   # Then apply ROT13
```

## How It Works (Transform Chain Mode)

When all steps are transforms (base64, rot13, leetspeak, etc.), layer works as a pipeline:
1. **Sequential processing** — each step receives the output from the previous step
2. **Cumulative transformation** — changes stack (text → base64 → rot13)
3. **Final output only** — only the last step's outputs become test cases
4. **Pre-evaluation** — all transforms applied before sending to the target

## Example Scenarios

### Double Encoding
```yaml
strategies:
  - id: layer
    config:
      steps:
        - hex      # First encode as hexadecimal
        - base64   # Then base64 encode
```

### Progressive Obfuscation
```yaml
strategies:
  - id: layer
    config:
      steps:
        - leetspeak  # First apply leetspeak
        - hex        # Then hex encode
        - base64     # Finally base64 encode
```

### Jailbreak Template + Encoding
```yaml
strategies:
  - id: layer
    config:
      steps:
        - jailbreak-templates  # Apply static jailbreak templates
        - rot13                # Obfuscate the payload
```

## Ordering Rules

When layering ONLY static strategies, order is flexible — transformations stack cumulatively.

When combining with agentic or multimodal strategies, rules change:
- **Agentic first** (max 1) — `jailbreak`, `jailbreak:meta`, `jailbreak:hydra`, `crescendo`, `goat`
- **Text transforms in between** — `base64`, `rot13`, `leetspeak`, etc.
- **Multimodal last** (max 1) — `audio`, `image`

### Valid Patterns
```
steps: [base64, rot13]              # Transform chain
steps: [leetspeak, audio]           # Transform + multimodal
steps: [jailbreak-templates, rot13] # Template + encoding
```

### Invalid Patterns
```
# ❌ Multi-modal not last
steps: [audio, base64]
# ❌ Multiple multimodal
steps: [audio, image]
```

See `promptfoo-strategies-custom-regression` skill for full `layer` documentation including agentic + multimodal combinations.