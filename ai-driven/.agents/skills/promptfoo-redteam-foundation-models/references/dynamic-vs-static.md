# Dynamic vs Static Analysis

Load before choosing an assessment approach. Two approaches, both required.

## Two Approaches

| Approach | Detects | Applies To | Tool |
|---|---|---|---|
| **Static analysis** | Trojaned files, malicious code, embedded executables, hidden credentials | Organizations hosting open-weight models | ModelAudit (`promptfoo scan-model`) |
| **Dynamic analysis** | Behavioral drift, poisoning effects, safety regression, jailbreak resistance | All LLM deployments (hosted or API) | Red teaming (`promptfoo redteam run`) |

## Why Both Are Required

Static scanning cannot detect:
- How the model behaves at inference time
- Whether safety training has been degraded
- Subtle behavioral backdoors triggered by specific inputs
- Whether the model meets your security requirements

A model that passes static analysis might still be dangerous to deploy. **Static scanning is necessary but not sufficient.**

Dynamic analysis cannot detect:
- Malicious pickle payloads that execute on deserialization
- Embedded executables (PE, ELF, Mach-O) hidden in model structures
- Hidden credentials exfiltrated during model loading
- Network backdoors to attacker-controlled servers

**Both approaches are required for full coverage.**

## When to Use Each

| Situation | Approach |
|---|---|
| Downloading models from HuggingFace, vendors, internal ML | Static + Dynamic |
| Using a third-party API (OpenAI, Anthropic, etc.) | Dynamic only (no files to scan) |
| Fine-tuned model from vendor | Static (scan file) + Dynamic (compare to base) |
| Pre-deployment gate | Static (if files) + Dynamic (always) |
| Ongoing monitoring | Dynamic (re-run baseline periodically) |

## Decision

```
Do you host model files locally?
  YES → Static scan (promptfoo scan-model) + Dynamic red team
  NO (API only) → Dynamic red team only

Is the model fine-tuned?
  YES → Compare fine-tuned vs base (dynamic) to detect safety regression
  NO → Dynamic red team with foundation plugin
```