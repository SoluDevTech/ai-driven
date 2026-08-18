# Checklist

Run end-to-end before declaring foundation model assessment done.

## Dynamic Scan
- [ ] `foundation` plugin selected in `redteam.plugins`
- [ ] Canonical strategies selected: `best-of-n`, `jailbreak`, `jailbreak:composite`, `jailbreak:likert`, `jailbreak-templates`
- [ ] `redteam.purpose` set describing the model's intended use and the adversarial persona
- [ ] Target model configured (`openrouter:...`, `openai:...`, `ollama:...`)
- [ ] Target has a distinct `label` (if comparing multiple models)
- [ ] `npx promptfoo@latest redteam run` completed
- [ ] Results saved with `--output results.json` (for drift baseline — see `promptfoo-redteam-supply-chain`)

## Static Scan (if hosting model files)
- [ ] `promptfoo scan-model ./models/ --strict` run on all downloaded model files
- [ ] Scan covers: pickle, TensorFlow, embedded executables, credentials, network patterns, encoded payloads, weight anomalies
- [ ] SARIF output generated for CI/CD (`--format sarif --output model-scan-results.sarif`)
- [ ] CI/CD workflow blocks deployments with unscanned or suspicious models

## Model Comparison (if comparing)
- [ ] Multiple targets configured with distinct `label`s
- [ ] Same `foundation` plugin + same strategies across all targets
- [ ] Same `numTests` for apples-to-apples comparison
- [ ] Report reviewed for per-model ASR per plugin/strategy

## HarmBench (if benchmarking)
- [ ] `harmbench` plugin configured with `numTests: 400` (full) or filtered `categories` + `functionalCategories`
- [ ] Semantic categories valid: `chemical_biological`, `copyright`, `cybercrime_intrusion`, `harassment_bullying`, `harmful`, `illegal`, `misinformation_disinformation`
- [ ] Functional categories valid: `standard`, `contextual`, `copyright`
- [ ] Tested in app-context (not just vanilla model) if assessing production risk
- [ ] Combined with dynamic plugins for evolving threat coverage

## Fine-Tune Regression (if fine-tuned)
- [ ] Both base and fine-tuned models set as targets with distinct `label`s
- [ ] Same plugins + strategies for comparison
- [ ] Fine-tuned ASR compared to base ASR per plugin
- [ ] If ASR significantly higher → investigate fine-tuning data, add guardrails, consider retraining

## Post-Run
- [ ] `npx promptfoo@latest redteam report` reviewed
- [ ] Vulnerability Report checked for critical/high findings
- [ ] Static scan results reviewed (if applicable)
- [ ] Results contributed to [promptfoo.dev/models](https://www.promptfoo.dev/models/) (if new model)
- [ ] Baseline saved for drift detection (see `promptfoo-redteam-supply-chain`)