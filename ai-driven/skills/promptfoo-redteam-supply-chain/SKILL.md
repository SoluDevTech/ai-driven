---
name: promptfoo-redteam-supply-chain
description: Secure the LLM supply chain and detect model drift with promptfoo. Use when establishing behavioral baselines, setting up CI/CD pre-deployment security gates, detecting model drift via ASR thresholds, running vendor acceptance tests, comparing fine-tuned vs base models, integrating static (ModelAudit) + dynamic (red team) gates, or alerting on security regressions over time. Covers OWASP LLM03 supply chain vulnerabilities.
---

# LLM Supply Chain Security and Drift Detection

LLM supply chains break the traditional "hash and verify" model — a model can pass every static check and still behave dangerously; an API can change behavior overnight. OWASP LLM03 covers this. Use two complementary approaches: **static** (ModelAudit for code-execution risks) + **dynamic** (red team baselines + drift detection for behavioral risks). Establish a baseline, schedule daily `redteam eval`, track ASR, and alert on regressions.

## Use this skill when
- Establishing a security baseline for production LLM deployments
- Setting up CI/CD pre-deployment security gates (static + dynamic)
- Detecting model drift via ASR thresholds over time
- Running vendor acceptance tests before enabling a new model/provider
- Comparing fine-tuned vs base models for safety regression
- Integrating static (ModelAudit) + dynamic (red team) gates in CI
- Alerting on security regressions via Slack/email
- Scheduling daily drift checks and weekly test regeneration

## Do not use this skill when
- Running a one-off red team assessment → use `promptfoo-redteam-llm` or the relevant domain skill
- Assessing a foundation model in isolation (no CI/CD) → use `promptfoo-redteam-foundation-models`
- Testing guardrails → use `promptfoo-redteam-guardrails`
- Testing RAG, agents, MCP, or multi-input apps → use the corresponding skill

## 🛡️ Edge cases (mandatory handling)
- **Static-only assessment** — a model that passes static analysis might still be dangerous; static is necessary but not sufficient. Always add dynamic testing.
- **No baseline saved** — without a saved baseline you can't detect drift; ALWAYS run `redteam run --output baseline-results.json` first.
- **Regenerating tests every drift run** — introduces variation that masks or simulates drift; use `redteam eval` (same tests) for daily comparison, `redteam run --force` weekly for coverage.
- **Comparing across environments** — staging vs production confounds; pick one environment and stick with it.
- **No ASR threshold** — without a fail threshold, CI never alerts; set `ASR > 15%` (or your tolerance; 10% for customer-facing).
- **Not versioning config** — track `promptfooconfig.yaml` in git; changes should be intentional and reviewed.
- **Skipping adjacent supply chains** — RAG data sources and MCP tools are part of your supply chain; test them too.
- **Silent API updates** — providers update models without notice; schedule regular dynamic re-tests to catch this.
- **Fine-tuning degradation** — custom training erodes base model safety; always compare fine-tuned vs base.

## 🎯 Core workflow
1. **Establish baseline** — load `references/baseline.md` for the initial `security-baseline.yaml` config + `--output baseline-results.json`.
2. **Set up drift detection** — load `references/drift-detection.md` for daily `redteam eval` + ASR threshold gate + weekly `redteam run --force`.
3. **Pre-deployment gate** — load `references/ci-cd-gates.md` for static + dynamic CI workflow that blocks deployments.
4. **Vendor acceptance** — load `references/vendor-acceptance.md` for testing new models/providers before enabling.
5. **Fine-tune regression** — load `references/finetune-regression.md` for comparing fine-tuned vs base.
6. **Adjacent supply chains** — load `references/adjacent-supply-chains.md` for RAG data sources + MCP tools.
7. **Alerting** — load `references/alerting.md` for Slack notifications + email reports.
8. **Checklist** — run `references/checklist.md` end-to-end before declaring done.

## 🎯 Core principles (summary)
- **Two threat classes**: code-execution (static, ModelAudit) + behavioral (dynamic, red team). Both required.
- **Static catches code-execution risks** — trojaned files, malicious pickle, embedded executables, hidden credentials.
- **Dynamic catches behavioral risks** — drift, poisoning effects, alignment degradation, silent API updates.
- **Establish a baseline** — `redteam run --output baseline-results.json` encodes your security requirements.
- **Daily `eval`, weekly `run --force`** — `eval` for apples-to-apples drift comparison; `run --force` for current attack coverage.
- **ASR is the security SLA** — `failures / (successes + failures) * 100`; set CI thresholds tied to risk tolerance.
- **Always compare fine-tuned vs base** — fine-tuning degrades safety.
- **Adjacent supply chains** — RAG data sources (`rag-poisoning`, `rag-document-exfiltration`) and MCP tools (`mcp`, `tool-discovery`) need their own tests.
- **Version your config** — track `promptfooconfig.yaml` in git; changes should be intentional and reviewed.

## 📦 Drift types

| Drift Type | Indicator | Likely Cause |
|---|---|---|
| Security regression | ASR increases | Model update weakened safety, guardrail disabled, prompt change |
| Security improvement | ASR decreases | Better guardrails, improved prompt, stronger safety model |
| Category-specific | Single category ASR changes | Targeted guardrail change, fine-tuning on specific content |
| Volatility | ASR fluctuates between runs | Non-deterministic behavior, rate limiting, infra issues |

## References
- `references/baseline.md` — `security-baseline.yaml` config, purpose field, plugin selection, saving baseline results
- `references/drift-detection.md` — daily `redteam eval` + weekly `run --force`, ASR threshold gate, CI workflow, custom test tracking
- `references/ci-cd-gates.md` — pre-deployment static + dynamic gate, SARIF output, GitHub Actions workflow
- `references/vendor-acceptance.md` — vendor acceptance test config, `--var CANDIDATE_MODEL`, regulatory + domain plugins
- `references/finetune-regression.md` — fine-tuned vs base comparison, interpreting ASR differences
- `references/adjacent-supply-chains.md` — RAG data sources + MCP tools supply chain testing
- `references/alerting.md` — Slack notifications, email HTML reports, incident response
- `references/checklist.md` — baseline, drift CI, pre-deployment gate, vendor acceptance, adjacent supply chains, alerting checklist