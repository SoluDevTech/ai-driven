# Checklist

Run end-to-end before declaring guardrail testing done.

## Pre-Flight
- [ ] Guardrail service chosen (Azure, Bedrock, NeMo, OpenAI moderation, Model Armor)
- [ ] Custom Python `call_api` provider implemented returning `{output, guardrails: {flagged: bool}}` (or HTTP provider with `transformResponse` for integrated guardrails)
- [ ] Provider credentials set in env vars (`CONTENT_SAFETY_KEY`, `AWS_ACCESS_KEY_ID`, etc.)
- [ ] Each target has a distinct `label` (if benchmarking multiple vendors)
- [ ] `redteam.purpose` set describing the guardrail's intended behavior

## True-Positive Tests (harmful should be blocked)
- [ ] `not-guardrails` assertion on harmful prompts (explosives, injection, PII)
- [ ] Plugins: `harmful:hate`, `harmful:self-harm`, `harmful:sexual`, `harmful:violence`
- [ ] `numTests: 20` (or higher for benchmarks)

## False-Positive Tests (benign should NOT be blocked)
- [ ] `guardrails` assertion on benign prompts (medical info, security research, history)
- [ ] At least 3-5 benign test cases covering edge cases (borderline topics)

## Evasion Resistance
- [ ] `translation` strategy added
- [ ] `misspelling` strategy added
- [ ] `jailbreak-templates` + `jailbreak` strategies added

## Model Armor (if applicable)
- [ ] `modelarmor.googleapis.com` API enabled
- [ ] IAM role `roles/modelarmor.user` granted to Vertex AI service account
- [ ] Template created with `gcloud model-armor templates create`
- [ ] `gcloud auth application-default login` run
- [ ] Confidence level set to `MEDIUM_AND_ABOVE` (starting point)
- [ ] Floor settings set to "Inspect and block" (if org-wide baseline needed)
- [ ] Region is one of: `us-central1`, `us-east4`, `us-west1`, `europe-west4`

## Benchmarking (if multiple vendors)
- [ ] All vendors configured as targets with distinct `label`s
- [ ] Same `numTests` across all targets
- [ ] Same plugins and strategies across all targets
- [ ] Report reviewed for per-vendor ASR and false-positive rate

## Post-Run
- [ ] `npx promptfoo@latest redteam report` reviewed
- [ ] True-positive rate documented per vendor/category
- [ ] False-positive rate documented per vendor
- [ ] F1-score calculated if both sides measured
- [ ] Evasion resistance compared (translation, misspelling rows)
- [ ] Vendor selected based on priority (true positives, false positives, F1, or ops simplicity)