# Checklist

Run end-to-end before declaring supply chain security + drift detection done.

## Baseline
- [ ] `security-baseline.yaml` created with `owasp:llm`, `pii:*`, `rbac`, `bola`, `prompt-extraction` + `jailbreak:composite`, `jailbreak-templates`
- [ ] `redteam.purpose` set as an explicit security contract
- [ ] Target has a consistent `label` for tracking across runs
- [ ] Baseline run with `--output baseline-results.json`
- [ ] `baseline-results.json` and `security-baseline.yaml` committed to version control

## Drift Detection CI
- [ ] Scheduled workflow runs `redteam eval` daily (same tests, apples-to-apples)
- [ ] Weekly `redteam run --force` regenerates tests with latest patterns
- [ ] ASR threshold set in CI (e.g. `ASR > 15%` fails; 10% for customer-facing)
- [ ] Results uploaded as artifacts
- [ ] NOT using `redteam run` daily (regeneration masks drift)

## Custom Test Tracking (if applicable)
- [ ] Custom `tests:` block with `llm-rubric`, `contains`, `not-contains` assertions
- [ ] Pass rate threshold set (e.g. `< 95%` fails)
- [ ] Combined with red team tests in CI (separate jobs)

## Pre-Deployment Gate
- [ ] Static scan runs if `models/` directory exists (`promptfoo scan-model --strict`)
- [ ] Dynamic red team runs against `security-baseline.yaml`
- [ ] Deploy job depends on `security-gate` job
- [ ] SARIF output uploaded to GitHub CodeQL (if static scan)

## Vendor Acceptance (if new model)
- [ ] `vendor-acceptance.yaml` with `{{CANDIDATE_MODEL}}` variable
- [ ] Regulatory + domain-specific plugins selected
- [ ] Run with `--var CANDIDATE_MODEL=...`
- [ ] ASR compared against acceptance threshold
- [ ] If comparing multiple models: same plugins + strategies + `numTests`

## Fine-Tune Regression (if fine-tuned)
- [ ] Both base and fine-tuned set as targets with distinct `label`s
- [ ] Same plugins + strategies for comparison
- [ ] Fine-tuned ASR compared to base ASR
- [ ] If FT ASR > base ASR + 5% → investigate, add guardrails, or retrain

## Adjacent Supply Chains
- [ ] RAG data sources tested: `rag-poisoning`, `rag-document-exfiltration`, `indirect-prompt-injection`
- [ ] MCP tools tested: `mcp`, `tool-discovery`, `excessive-agency`, `ssrf`

## Alerting
- [ ] Slack notification on CI failure (regression detected)
- [ ] Email/HTML report generation for stakeholders
- [ ] Incident response procedure documented (compare, determine cause, roll back / add guardrails / accept + update baseline)

## Ongoing
- [ ] `promptfooconfig.yaml` tracked in version control
- [ ] Changes to config are intentional and reviewed
- [ ] Drift detection runs against the same environment consistently
- [ ] Baseline updated when changes are acceptable (committed to git)