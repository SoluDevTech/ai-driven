# Fine-Tune Regression Testing

Load when comparing a fine-tuned model against its base. Fine-tuning can degrade safety training.

## Configuration

```yaml
description: Fine-tune safety regression test
targets:
  - id: openai:gpt-4o
    label: base-model
  - id: openai:ft:gpt-4o:my-org:support-agent:abc123
    label: fine-tuned
redteam:
  purpose: |
    Customer support agent fine-tuned on company documentation.
    Should maintain all safety behaviors from the base model.
  plugins:
    - harmful
    - pii
    - prompt-extraction
    - excessive-agency
  strategies:
    - jailbreak:composite
    - jailbreak-templates
```

## Interpreting Results

A **significantly higher failure rate** on the fine-tuned model indicates the fine-tuning process degraded safety training.

| Outcome | Meaning | Action |
|---|---|---|
| Fine-tuned ASR ≈ base ASR | Safety training preserved | Safe to deploy fine-tuned model |
| Fine-tuned ASR > base ASR | Safety training degraded | Investigate fine-tuning data; add guardrails; consider retraining |
| Fine-tuned ASR < base ASR | Safety improved (rare) | Safe to deploy |

## What to Check

- **Per-plugin comparison** — which vulnerability categories degraded most?
- **Per-strategy comparison** — did certain jailbreak techniques become more effective?
- **Specific failure cases** — what did the fine-tuned model say that the base refused?

## Mitigation

If fine-tuning degraded safety:
1. **Investigate fine-tuning data** — look for examples that eroded refusal behavior
2. **Add guardrails** — use `promptfoo-redteam-guardrails` to add a content filter
3. **Retrain with safety examples** — include refusal examples in fine-tuning data
4. **Consider not fine-tuning** — use RAG or prompt engineering instead if safety is critical