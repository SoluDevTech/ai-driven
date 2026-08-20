---
name: promptfoo-redteam-foundation-models
description: Assess foundation and fine-tuned LLM security with promptfoo — dynamic red team scans against live models plus static ModelAudit scanning of model files. Use when baseline-testing a base/foundation model, comparing multiple models side-by-side, scanning model files for trojans/malicious pickle/embedded executables, running HarmBench standardized benchmarks, or contributing results to promptfoo.dev/models.
---

# Red Team Foundation Models with Promptfoo

LLM security starts at the foundation model level. Assess base/fine-tuned models with two complementary approaches: (1) **dynamic** red team scans against live models using the `foundation` plugin + canonical strategies, and (2) **static** scanning of model files with ModelAudit for trojans, malicious pickle payloads, and embedded executables. Use HarmBench for standardized safety benchmarking.

## Use this skill when
- Baseline security assessment of a foundation or fine-tuned model
- Comparing multiple foundation models side-by-side (ASR comparison)
- Scanning model files for trojans, malicious pickle, embedded executables (`promptfoo scan-model`)
- Running HarmBench standardized benchmarks (400 harmful behaviors)
- Testing fine-tuned models against their base for safety regression
- Contributing results to promptfoo.dev/models

## Do not use this skill when
- Testing an LLM application with prompts/guardrails/context → use `promptfoo-redteam-llm`
- Testing RAG, agents, MCP, or multi-input apps → use the corresponding skill
- Setting up CI/CD drift detection → use `promptfoo-redteam-supply-chain` (this skill establishes the baseline)
- Testing guardrails → use `promptfoo-redteam-guardrails`

## 🛡️ Edge cases (mandatory handling)
- **Skipping static scans for downloaded models** — pickle deserialization executes arbitrary code; ALWAYS scan with `promptfoo scan-model --strict` before deploying any downloaded model.
- **Only testing the base model** — fine-tuning degrades safety training; ALWAYS compare fine-tuned vs base to detect regression.
- **Trusting API providers not to drift** — silent updates weaken safety; schedule regular dynamic re-tests (see `promptfoo-redteam-supply-chain`).
- **Static-only assessment** — a model that passes static analysis might still be dangerous; static is necessary but not sufficient. Always add dynamic testing.
- **Running HarmBench in isolation** — HarmBench is a static dataset; pair with dynamic plugins for evolving threat coverage.
- **Testing vanilla model only** — your app's prompt engineering and context significantly affect behavior; always test in-app context too.
- **UnsafeBench commercial use** — restricted to non-commercial academic research; check license.

## 🎯 Core workflow
1. **Choose approach** — load `references/dynamic-vs-static.md` to decide: dynamic red team (live model) vs static scan (model file) vs both.
2. **Dynamic scan** — load `references/dynamic-scan.md` for `foundation` plugin + canonical strategies config.
3. **Static scan** — load `references/static-scan.md` for `promptfoo scan-model` CLI, detection categories, CI/CD integration.
4. **Model comparison** — load `references/model-comparison.md` for side-by-side multi-target configs.
5. **HarmBench** — load `references/harmbench.md` for standardized 400-behavior benchmark with category filtering.
6. **Fine-tune regression** — load `references/finetune-regression.md` for comparing fine-tuned vs base.
7. **Checklist** — run `references/checklist.md` end-to-end before declaring done.

## 🎯 Core principles (summary)
- **Two approaches, both required**: static (ModelAudit for code-execution risks) + dynamic (red team for behavioral risks).
- **`foundation` plugin** — collection of plugins assessing foundation-model risks; the canonical preset.
- **Canonical strategies** — `best-of-n`, `jailbreak`, `jailbreak:composite`, `jailbreak:likert`, `jailbreak-templates`.
- **ModelAudit detects**: malicious pickle opcodes, suspicious TF ops, Keras Lambda layers, embedded PE/ELF/Mach-O executables, hidden credentials, network patterns, encoded payloads, weight anomalies.
- **HarmBench** — 400 harmful behaviors across 7 semantic + 3 functional categories; test in-app context, not just vanilla model.
- **Always compare fine-tuned vs base** — fine-tuning degrades safety; a higher failure rate on fine-tuned = safety regression.
- **Contribute results** to [promptfoo.dev/models](https://www.promptfoo.dev/models/) by emailing `[email protected]`.

## 📦 Canonical strategy set

| Strategy | Source |
|---|---|
| `best-of-n` | Anthropic + Stanford |
| `jailbreak` | Single-shot optimization |
| `jailbreak:composite` | Combines multiple techniques |
| `jailbreak:likert` | Anthropic + Stanford |
| `jailbreak-templates` | Static templates (DAN, etc.) |

## References
- `references/dynamic-vs-static.md` — two approaches, what each detects, when to use
- `references/dynamic-scan.md` — `foundation` plugin config, Promptfoo Cloud vs local, CLI commands
- `references/static-scan.md` — `promptfoo scan-model` CLI, detection categories, SARIF output, CI/CD
- `references/model-comparison.md` — multi-target side-by-side config with distinct labels
- `references/harmbench.md` — HarmBench plugin, semantic/functional categories, filtering, app-context testing
- `references/finetune-regression.md` — fine-tuned vs base comparison config
- `references/checklist.md` — dynamic, static, comparison, HarmBench, fine-tune checklist