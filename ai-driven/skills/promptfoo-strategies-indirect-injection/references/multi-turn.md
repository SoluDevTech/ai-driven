# Multi-Turn Attacks with Embedding Rotation

Load when configuring persistent multi-turn indirect injection attacks.

## Configuration

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

## How It Works

On each turn of the multi-turn attack:
1. **Hydra generates** the next attack message based on prior turns and scan-wide memory
2. **`indirect-web-pwn` embeds** the message in a dynamically generated web page
3. **Page content is updated** — the page changes each turn to avoid pattern detection
4. **Embedding location is rotated** — the injection moves between invisible text, semantic embed, and HTML comment

This creates a persistent, evolving attack that's harder for the agent's defenses to detect and block.

## Why Embedding Rotation Matters

Without rotation, the agent's guardrails might learn to detect a specific injection pattern (e.g. "always block HTML comments containing instructions"). With rotation:
- Turn 1: injection in HTML comment
- Turn 2: injection in invisible text
- Turn 3: injection in semantic embed
- Each turn uses a different technique, evading pattern-based detection

## Requirements

- **Promptfoo Cloud** — both `jailbreak:hydra` and `indirect-web-pwn` require Cloud
- **Agent with web browsing** — target must fetch URLs on each turn
- **Stateful or replay mode** — configure based on your target's session handling (see `promptfoo-strategies-multi-turn` skill)

## When to Use

- Testing agents with sophisticated guardrails that detect static injection patterns
- Large-scale org-wide red teams where you need adaptive, evolving attacks
- Testing whether the agent's defenses degrade over multiple turns of varied injection techniques