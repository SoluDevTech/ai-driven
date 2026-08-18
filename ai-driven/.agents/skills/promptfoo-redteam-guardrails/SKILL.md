---
name: promptfoo-redteam-guardrails
description: Test and validate LLM guardrails (Azure Content Filter, AWS Bedrock Guardrails, NVIDIA NeMo, OpenAI moderation, Google Model Armor) with promptfoo. Use when benchmarking content filters, measuring true/false positives, testing evasion resistance, configuring Model Armor with Vertex AI, or comparing guardrail vendors.
---

# Test and Validate Guardrails with Promptfoo

Guardrails are content-filtering services in front of LLMs. Test them as standalone endpoints with custom Python providers returning `{output, guardrails: {flagged: bool}}`, then grade with `guardrails`/`not-guardrails` assertions. Always measure both true positives (caught harmful) and false positives (blocked benign).

## Use this skill when
- Testing Azure Content Filter, Azure Prompt Shields, AWS Bedrock Guardrails, NVIDIA NeMo, or OpenAI moderation
- Testing Google Cloud Model Armor with Vertex AI
- Benchmarking multiple guardrail vendors side-by-side
- Measuring true positives (`not-guardrails`) and false positives (`guardrails`)
- Testing evasion resistance (misspellings, translation, coded language)
- Configuring Model Armor templates and floor settings
- Comparing strict vs moderate template policies

## Do not use this skill when
- Setting up a first red team for an LLM app without guardrails → use `promptfoo-redteam-llm`
- Testing image guardrails specifically → use `promptfoo-redteam-multimodal` (UnsafeBench + Bedrock image provider)
- Testing RAG, agents, MCP, or multi-input apps → use the corresponding skill

## 🛡️ Edge cases (mandatory handling)
- **Only testing true positives** — a guardrail that blocks everything scores 100% on harmful but fails benign users. ALWAYS measure false positives with benign prompts.
- **Single-language testing** — guardrails often behave differently across languages; use the `translation` strategy.
- **Skipping evasion strategies** — attackers use misspellings and coded language; test with `misspelling`, `jailbreak-templates`.
- **Floor settings in inspect-only mode** — they log but don't block; set "Inspect and block" in GCP Console for real protection.
- **AWS Bedrock image format** — JPEG/PNG only, 5MB max; base64 must be decoded to bytes before sending.
- **Model Armor region support** — only `us-central1`, `us-east4`, `us-west1`, `europe-west4`.
- **Nova image data prefix** — Amazon Bedrock Nova needs `data:binary/octet-stream;base64,` prefix stripped via `transformVars`; other providers don't.
- **Access token expiry** — Model Armor direct sanitization API tokens expire after 1 hour; use service account keys or Workload Identity Federation for CI.

## 🎯 Core workflow
1. **Choose path** — load `references/testing-paths.md` to decide: test app with integrated guardrails (HTTP provider) vs test guardrail service directly (custom Python provider).
2. **Implement provider** — load `references/provider-implementations.md` for `call_api` examples (Azure, Bedrock, NeMo, Model Armor sanitization API).
3. **Configure assertions** — load `references/assertions.md` for `guardrails`/`not-guardrails` semantics and F1-score.
4. **Add evasion strategies** — load `references/evasion-strategies.md` for `translation`, `misspelling`, `jailbreak-templates`.
5. **Model Armor (if applicable)** — load `references/model-armor.md` for Vertex AI integration, floor settings, template comparison.
6. **Benchmark** — load `references/benchmarking.md` for multi-vendor comparison configs.
7. **Checklist** — run `references/checklist.md` end-to-end before declaring done.

## 🎯 Core principles (summary)
- **Guardrails are endpoints** — treat them as targets, not as invisible infrastructure. Test them directly.
- **`call_api` contract** — custom Python providers return `{output, guardrails: {flagged: bool, ...}, error?}`. `flagged: true` means the guardrail intervened.
- **`guardrails` assertion** passes when content is NOT flagged (use for benign → false-positive check).
- **`not-guardrails` assertion** passes when content IS blocked (use for harmful → true-positive check).
- **Always measure both sides** — guardrails commonly over-block. Use F1-score to quantify the precision/recall balance.
- **Guardrails are a commodity** — there are hundreds of vendors; benchmark before committing.
- **Model Armor** — use `vertex` provider with `modelArmor.promptTemplate` + `responseTemplate`; start at `MEDIUM_AND_ABOVE` confidence.

## 📦 Supported guardrails
- Azure Content Filter (`ContentSafetyClient.analyze_text`)
- Azure Prompt Shields (`/contentsafety/text:shieldPrompt`)
- AWS Bedrock Guardrails — text (`bedrock-runtime.apply_guardrail` with `source='INPUT'`)
- AWS Bedrock Guardrails — images (separate provider, base64 bytes, 5MB cap)
- NVIDIA NeMo Guardrails (`ng.LLMRails(rails_config).generate(...)`)
- OpenAI Moderation API
- Google Cloud Model Armor (Vertex AI `modelArmor` config or direct sanitization API)

## References
- `references/testing-paths.md` — two-path decision (integrated vs direct) and HTTP provider config with `transformResponse`
- `references/provider-implementations.md` — full `call_api` implementations for Azure, Bedrock, NeMo, Model Armor sanitization
- `references/assertions.md` — `guardrails`/`not-guardrails` semantics, F1-score, true/false positive test cases
- `references/evasion-strategies.md` — `translation`, `misspelling`, `jailbreak-templates`, `jailbreak` for evasion resistance
- `references/model-armor.md` — Vertex AI integration, five filters, floor settings vs templates, template comparison, direct sanitization API
- `references/benchmarking.md` — multi-vendor side-by-side config, plugin selection, strategies
- `references/checklist.md` — pre-flight, true-positive, false-positive, evasion, and CI/CD checklist