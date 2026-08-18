---
name: promptfoo-framework-owasp-llm
description: Test LLM applications against the OWASP LLM Top 10 (2025) with promptfoo. Use when testing for prompt injection (LLM01), sensitive information disclosure (LLM02), supply chain vulnerabilities (LLM03), data/model poisoning (LLM04), improper output handling (LLM05), excessive agency (LLM06), system prompt leakage (LLM07), vector/embedding weaknesses (LLM08), misinformation (LLM09), or unbounded consumption (LLM10).
---

# OWASP LLM Top 10

The OWASP Top 10 for LLM Applications lists the top 10 critical vulnerabilities. Promptfoo maps each to plugins via `owasp:llm`. Includes Gen AI Red Team best practices (4 phases: Model, Implementation, System, Runtime).

## Use this skill when
- Testing OWASP LLM Top 10 (2025) compliance
- Testing prompt injection (LLM01), PII disclosure (LLM02), supply chain (LLM03)
- Testing excessive agency (LLM06), system prompt leakage (LLM07)
- Testing RAG/vector weaknesses (LLM08), misinformation (LLM09), unbounded consumption (LLM10)
- Running OWASP Gen AI red team best practices (4 phases)

## Do not use this skill when
- Testing OWASP Agentic Applications → use `promptfoo-framework-owasp-agentic`
- Testing OWASP API Security → use `promptfoo-framework-owasp-api`
- Testing NIST AI RMF → use `promptfoo-framework-nist-ai-rmf`
- Testing general LLM app security → use `promptfoo-redteam-llm`

## 🛡️ Edge cases (mandatory handling)
- **`prompt-extraction` plugin requires `systemPrompt` config** — must provide the actual system prompt for LLM07 testing.
- **LLM03 (Supply Chain) needs ModelAudit + dynamic testing** — static scanning + behavioral comparison across model versions.
- **LLM04 (Poisoning) can't be directly prevented** — test for effects (bias, inconsistency) not the poisoning itself.
- **LLM05 (Output Handling) uses assertions not plugins** — `not-contains` assertions for script tags, HTML, etc.
- **LLM08 (Vector/Embedding) includes RAG poisoning CLI** — `promptfoo redteam poison` for generating poisoned docs.
- **LLM10 (Unbounded Consumption) includes `divergent-repetition` plugin** — tests for repetitive pattern exploitation.
- **Gen AI red team phases** — `owasp:llm:redteam` covers all 4 phases; `:model`, `:implementation`, `:system`, `:runtime` for individual phases.

## 🎯 Core workflow
1. **Comprehensive testing** — `redteam: plugins: [owasp:llm]` covers all 10.
2. **Targeted testing** — load `references/llm-top-10.md` for per-vulnerability plugin configs.
3. **Gen AI red team phases** — load `references/red-team-phases.md` for the 4-phase approach.
4. **Checklist** — run `references/checklist.md`.

## 🎯 Core principles (summary)
- **OWASP LLM Top 10 (2025)**: LLM01-LLM10, each mapped to specific plugins.
- **`owasp:llm`** — comprehensive plugin; `owasp:llm:01` through `owasp:llm:10` for individual vulnerabilities.
- **`owasp:llm:redteam`** — Gen AI red team best practices (4 phases).
- **Custom plugins** — for domain-specific sensitive data (financial, health, business confidential).

## References
- `references/llm-top-10.md` — all 10 vulnerabilities (LLM01-LLM10) with plugin configs and testing strategies
- `references/red-team-phases.md` — OWASP Gen AI red team 4 phases (Model, Implementation, System, Runtime)
- `references/checklist.md` — pre-flight, vulnerability selection, Gen AI phases, post-run checklist