# Layering with Jailbreak Strategies

Load when combining `indirect-web-pwn` with jailbreak strategies via `layer`.

## Why Layer

`indirect-web-pwn` alone delivers the injection payload, but the payload may not be sophisticated enough to bypass the agent's defenses. Layering with a jailbreak strategy first generates a more effective attack payload, then embeds it in the web page.

## Single-Turn: jailbreak:meta + indirect-web-pwn

```yaml
redteam:
  plugins:
    - id: data-exfil
      numTests: 1
  strategies:
    - id: layer
      config:
        steps:
          - jailbreak:meta        # Generate sophisticated attack payload
          - indirect-web-pwn      # Embed it in a web page
```

`jailbreak:meta` builds a custom attack taxonomy and refines the payload; `indirect-web-pwn` then embeds the refined payload in a dynamically generated web page.

## Multi-Turn: jailbreak:hydra + indirect-web-pwn

```yaml
redteam:
  plugins:
    - data-exfil
  strategies:
    - id: layer
      config:
        steps:
          - jailbreak:hydra       # Multi-turn adaptive branching
          - indirect-web-pwn      # Embed each turn in a web page
```

On each turn:
1. Hydra generates the next attack message
2. `indirect-web-pwn` embeds it in a web page
3. The page content is updated and the embedding location is rotated to evade detection

This creates a persistent multi-turn attack with embedding rotation — the agent sees different injection techniques on each turn.

## Ordering Rules

When layering with `indirect-web-pwn`:
- **Agentic first** (jailbreak strategy) — generates the attack payload
- **`indirect-web-pwn` last** — embeds the payload in a web page

### Valid Patterns
```
steps: [jailbreak:meta, indirect-web-pwn]      # Single-turn
steps: [jailbreak:hydra, indirect-web-pwn]      # Multi-turn with rotation
steps: [crescendo, indirect-web-pwn]            # Gradual escalation
```

### Invalid Patterns
```
# ❌ indirect-web-pwn not last
steps: [indirect-web-pwn, base64]
# ❌ Multiple agentic strategies
steps: [jailbreak:meta, jailbreak:hydra]
```

See `promptfoo-strategies-custom-regression` skill for full `layer` documentation.