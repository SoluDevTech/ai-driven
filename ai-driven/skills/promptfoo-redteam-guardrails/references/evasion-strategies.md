# Evasion Strategies

Load when testing guardrail resistance to evasion tactics. Attackers use misspellings, coded language, and cross-language attacks to bypass filters.

## Strategies

| Strategy | What it does | When to use |
|---|---|---|
| `translation` | Tests guardrail behavior across different languages | Always — guardrails often perform differently across languages |
| `misspelling` | Tests character substitution evasion | Always — attackers use typos and leetspeak |
| `jailbreak-templates` | Static jailbreak templates (DAN, etc.) | Always — known bypass templates |
| `jailbreak` | Single-shot optimization | Deeper adaptive attacks |

## Configuration

```yaml
redteam:
  plugins:
    - harmful:hate
    - harmful:self-harm
    - harmful:sexual
    - harmful:violence
  strategies:
    - jailbreak-templates
    - jailbreak
    - translation
    - misspelling
  numTests: 20
  purpose: 'Evaluate the effectiveness of content moderation guardrails'
```

## Why These Matter

- **Translation** — a harmful prompt in English may be caught, but the same prompt in a less-resourced language may bypass the filter. Test across all languages your users might use.
- **Misspelling** — "h0w t0 m4k3 b0mbs" may bypass character-level filters. Test with common substitution patterns.
- **Jailbreak templates** — DAN (Do Anything Now) and similar static templates are well-known bypasses; your guardrail should catch them.