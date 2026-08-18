# Layer Strategy

Load when composing multiple strategies sequentially. The most powerful composition tool.

## Quick Start

```yaml
strategies:
  - id: layer
    config:
      steps:
        - base64  # First encode as base64
        - rot13   # Then apply ROT13
```

## Two Modes

### Mode 1: Transform Chain (No Agentic Steps)

When all steps are transforms (base64, rot13, leetspeak, etc.):
1. **Sequential processing** — each step receives the output from the previous step
2. **Cumulative transformation** — changes stack (text → base64 → rot13)
3. **Final output only** — only the last step's outputs become test cases
4. **Pre-evaluation** — all transforms applied before sending to the target

### Mode 2: Agentic + Per-Turn Transforms

When the first step is an agentic strategy (hydra, crescendo, goat, jailbreak, etc.):
1. **Agentic orchestration** — the agentic strategy controls the attack loop
2. **Per-turn transforms** — remaining steps (audio, image) applied to each turn dynamically
3. **Multi-modal attacks** — combine conversation-based attacks with audio/image delivery

```yaml
strategies:
  - id: layer
    config:
      steps:
        - id: jailbreak
          config:
            maxIterations: 2
        - audio
```

## Ordering Rules (CRITICAL)

- **Agentic strategies** (hydra, crescendo, goat, jailbreak) must come FIRST (max 1)
- **Multi-modal strategies** (audio, image) must come LAST (max 1)
- **Text transforms** (base64, rot13, leetspeak) can be chained in between

### Valid Patterns
```yaml
# Transform chain (no agentic)
steps: [base64, rot13]

# Transform + multimodal
steps: [leetspeak, audio]

# Agentic only
steps: [jailbreak:hydra]

# Agentic + multimodal (recommended for voice/vision targets)
steps: [jailbreak:hydra, audio]

# Agentic + transform + multimodal
steps: [jailbreak:meta, leetspeak, audio]
```

### Invalid Patterns
```yaml
# ❌ Agentic not first (transforms will corrupt the goal)
steps: [base64, jailbreak:hydra]

# ❌ Multi-modal not last
steps: [audio, base64]

# ❌ Multiple agentic strategies
steps: [hydra, crescendo]

# ❌ Multiple multi-modal strategies
steps: [audio, image]
```

**Warning**: transforms before an agentic strategy modify the attack goal, not each turn — rarely useful.

## Label (for Multiple Layer Strategies)

Use `label` to differentiate multiple layer strategies in the same config:

```yaml
redteam:
  strategies:
    - id: layer
      config:
        label: hydra-audio
        steps:
          - jailbreak:hydra
          - audio
    - id: layer
      config:
        label: crescendo-audio
        steps:
          - crescendo
          - audio
```

Without labels, layer strategies are deduplicated based on their steps. With labels, each labeled layer is treated as a distinct strategy.

## Advanced Configuration

Object-based steps with individual configurations:

```yaml
strategies:
  - id: layer
    config:
      steps:
        - id: jailbreak
          config:
            maxIterations: 10
        - hex
        - id: file://custom-obfuscator.js
          config:
            intensity: high
```

## Step-Level Plugin Targeting

Control which plugins each step applies to:

```yaml
strategies:
  - id: layer
    config:
      plugins: ['harmful', 'pii']  # Default for all steps
      steps:
        - id: jailbreak
          config:
            plugins: ['harmful']  # Override for this step
        - rot13  # Uses default plugins
        - id: base64
          config:
            plugins: ['pii', 'contracts']  # Different plugin set
```

## Example Scenarios

### Multi-Turn Audio Attack
```yaml
strategies:
  - id: layer
    config:
      steps:
        - jailbreak:hydra  # Multi-turn jailbreak
        - audio            # Convert each turn to speech
```

### Multi-Turn Image Attack
```yaml
strategies:
  - id: layer
    config:
      steps:
        - crescendo  # Gradual escalation
        - image      # Convert each turn to image
```

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
        - leetspeak
        - hex
        - base64
```

### Custom Strategy Pipeline
```yaml
strategies:
  - id: layer
    config:
      steps:
        - file://strategies/add-context.js
        - base64
        - file://strategies/final-transform.js
```

## Supported Agentic Strategies (as first step)

| Strategy | Type | Description |
|---|---|---|
| `jailbreak:hydra` | Multi-turn | Branching conversation attack |
| `crescendo` | Multi-turn | Gradual escalation attack |
| `goat` | Multi-turn | Goal-oriented adversarial testing |
| `custom` | Multi-turn | Custom multi-turn strategy |
| `jailbreak` | Multi-attempt | Iterative single-turn attempts |
| `jailbreak:meta` | Multi-attempt | Meta-agent attack generation |
| `jailbreak:tree` | Multi-attempt | Tree-based attack search |

## Performance Considerations

- **Test case multiplication** — some strategies multiply test cases; plan accordingly
- **Order matters** — place filtering strategies early, expanding strategies late
- **Avoid redundancy** — don't use the same strategy both in a layer and at the top level
- **Test small first** — validate with a subset before scaling up
- **Monitor memory** — complex layers with many steps can consume significant memory

## Implementation Notes

- **Empty step handling** — if any step returns no test cases, subsequent steps receive an empty array
- **Error handling** — failed steps are logged and skipped; the pipeline continues
- **Metadata preservation** — each step preserves and extends test case metadata
- **Strategy resolution** — supports both built-in strategies and `file://` custom strategies