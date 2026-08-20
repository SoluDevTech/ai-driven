# Minor Encoding Strategies

Load for completeness coverage. Low ASR increase (0-5%), but test filter robustness against niche encodings.

## camelCase

Tests handling of text transformed into camelCase (removing spaces and capitalizing words).

```yaml
strategies:
  - camelCase
```

**ASR increase**: 0-5% — minimal impact, use for completeness.

## Emoji Smuggling

Tests hiding UTF-8 payloads inside emoji variation selectors to evaluate filter evasion.

```yaml
strategies:
  - emoji
```

**ASR increase**: 0-5% — minimal impact, but tests a novel evasion vector.

## Morse Code

Tests handling of text encoded in Morse code (dots and dashes).

```yaml
strategies:
  - morse
```

**ASR increase**: 20-30% — models may learn Morse code from training data.

## Pig Latin

Tests handling of text transformed into Pig Latin (rearranging word parts).

```yaml
strategies:
  - pig-latin
```

**ASR increase**: 20-30% — word-level transformation that models may understand from pretraining.

## When to Use These

- **Completeness** — include in a broad strategy suite for full coverage
- **Filter robustness** — test if your guardrail catches niche encodings
- **Compliance** — some frameworks require testing against known encoding types

## When NOT to Use

- You need high ASR increase → use `base64`, `hex`, `rot13`, `leetspeak` (20-30%)
- You need adaptive attacks → use `promptfoo-strategies-dynamic`
- Cost is a primary concern → skip 0-5% ASR strategies