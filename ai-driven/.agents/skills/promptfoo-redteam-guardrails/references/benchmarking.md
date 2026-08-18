# Benchmarking Multiple Guardrails

Load when comparing guardrail vendors side-by-side. Set each vendor as a target, run identical harmful probes, compare ASR.

## Configuration

```yaml
# yaml-language-server: $schema=https://promptfoo.dev/config-schema.json
targets:
  - id: 'file://azure_content_filter.py'
    config:
      endpoint: '{{env.CONTENT_SAFETY_ENDPOINT}}'
      key: '{{env.CONTENT_SAFETY_KEY}}'
  - id: 'file://aws_bedrock_guardrails.py'
    config:
      guardrail_id: 'your-guardrail-id'
      guardrail_version: 'DRAFT'
  - id: 'file://nemo_guardrails.py'
    config:
      config_path: './nemo_config.yml'
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

## What the Report Shows

- Per-target ASR (Attack Success Rate) for each plugin/strategy combination
- Which vendor catches which harmful category
- Which vendor has the most false positives (when you add benign `guardrails` tests)
- Evasion resistance per vendor (translation, misspelling rows)

## Best Practices

1. **Use the same `numTests` across all targets** — ensures apples-to-apples comparison
2. **Add benign test cases** — measure false positives alongside true positives
3. **Test with evasion strategies** — `translation`, `misspelling` reveal real-world resistance
4. **Use distinct `label`s** — each target needs a label to distinguish in the report
5. **Run multiple times** — LLM-based grading has some variance; average 2-3 runs for stable conclusions

## Decision Framework

| Priority | Recommended approach |
|---|---|
| Maximum true positives | Pick the vendor with lowest ASR on harmful plugins |
| Minimum false positives | Pick the vendor with highest pass rate on benign `guardrails` tests |
| Balanced (F1) | Pick the vendor with highest F1-score across both test sets |
| Evasion resistance | Pick the vendor with lowest ASR on `translation` + `misspelling` strategies |
| Simplest ops | Use whatever your preferred inference provider offers |