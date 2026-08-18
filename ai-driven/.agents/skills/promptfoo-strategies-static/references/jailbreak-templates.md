# Jailbreak Templates Strategy

Load when applying known static jailbreak templates. Low cost, 20-30% ASR increase.

## Configuration

```yaml
strategies:
  - jailbreak-templates
```

## What It Does

Tests LLM resistance to known jailbreak techniques using static templates:
- **DAN** (Do Anything Now)
- **Skeleton Key**
- Other published jailbreak templates

The strategy wraps the plugin-generated payload in these known templates and sends to the target.

## Limitations

**Does NOT cover modern prompt injection techniques.** This strategy only applies known static templates. Pair with dynamic strategies (`jailbreak`, `jailbreak:composite`, `jailbreak:meta`) for modern adaptive attacks.

## When to Use

- **Baseline coverage** — quick, low-cost test of known jailbreak resistance
- **Compliance testing** — verify resistance to published CVE-like jailbreak templates
- **Pre-dynamic screening** — run before dynamic strategies to identify obvious gaps

## When NOT to Use

- You need adaptive, iterative attacks → use `promptfoo-strategies-dynamic` (`jailbreak`, `jailbreak:meta`)
- You need modern prompt injection → use `jailbreak:composite` or `jailbreak:meta`
- You need multi-turn attacks → use `promptfoo-strategies-multi-turn`

## Combining with Encoding

Layer jailbreak templates with encoding for obfuscated attacks:

```yaml
strategies:
  - id: layer
    config:
      steps:
        - jailbreak-templates  # Apply static jailbreak templates
        - rot13                # Obfuscate the payload
```