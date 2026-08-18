---
name: promptfoo-redteam-rag
description: Red team Retrieval-Augmented Generation (RAG) applications with promptfoo. Use when testing RAG systems for prompt injection via retrieved context, context injection from compromised knowledge base documents, data poisoning, source attribution fabrication, data/PII exfiltration, context window overflow, and component-level (retrieval vs generation) isolation.
---

# Red Team RAG Applications with Promptfoo

RAG systems introduce application-layer attacks beyond base-model risks: prompt injection via retrieved context, data poisoning of the knowledge base, source attribution fabrication, and context window overflow. Use the `indirect-prompt-injection` plugin, the `rag-poisoning` CLI, and component-level custom providers to test each attack surface.

## Use this skill when
- Testing a RAG system for prompt injection via retrieved context
- Testing context injection from compromised knowledge base documents
- Generating and ingesting poisoned documents (`promptfoo redteam poison`)
- Detecting source attribution fabrication (fabricated citations, policy numbers)
- Testing data/PII exfiltration from the knowledge base
- Testing context window overflow attacks
- Isolating retrieval vs generation components for failure analysis
- Setting `redteam.purpose` as a security contract for the RAG

## Do not use this skill when
- Testing a general LLM app without RAG → use `promptfoo-redteam-llm`
- Testing LLM agents with tools/state → use `promptfoo-redteam-agents`
- Testing multi-input apps with user_id + context → use `promptfoo-redteam-multi-input` (but use this skill for the RAG-specific plugins)
- Testing guardrails → use `promptfoo-redteam-guardrails`
- Testing foundation models in isolation → use `promptfoo-redteam-foundation-models`

## 🛡️ Edge cases (mandatory handling)
- **Trusting retrieved docs** — many orgs treat the knowledge base as privileged; instructions in retrieved text can override system prompts. NEVER put retrieved docs in the system message — always place them in a separate user/context message.
- **`indirectInjectionVar` mismatch** — must match the variable holding retrieved docs (e.g. `context` matching `{{context}}` in your prompt). A mismatch silently tests the wrong surface.
- **Testing only the full pipeline** — when a failure occurs you can't tell if retrieval or generation is at fault. Use component-level providers (`retrieval_only_provider.py`, `generation_only_provider.py`).
- **Vague `purpose`** — "You are a helpful assistant" generates generic, off-target tests. Be explicit about what data is off-limits (salary, customer data, financial details).
- **Context window overflow fixture** — must be tuned to your model's context window; over-filling breaks all tests. Use `chat_turns: 1000` with a Jinja filler template as a starting point.
- **RAG poisoning requires re-ingestion** — `promptfoo redteam poison` generates poisoned docs but you must ingest them into your live KB; non-trivial in production-like environments.
- **Source attribution fabrication** — the model may confidently cite non-existent policy numbers/sections; use the `rag-source-attribution` plugin to catch this.

## 🎯 Core workflow
1. **Map attack surfaces** — load `references/attack-surfaces.md` for the seven RAG attack types and their plugins.
2. **Configure indirect injection** — load `references/indirect-injection.md` for the `indirect-prompt-injection` plugin and `indirectInjectionVar` config.
3. **Generate poisoned docs** — load `references/rag-poisoning.md` for the `promptfoo redteam poison` CLI workflow.
4. **Component-level testing** — load `references/component-testing.md` for retrieval-only and generation-only providers.
5. **Set security boundaries** — load `references/purpose-field.md` for `redteam.purpose` as a security contract.
6. **Configure full RAG provider** — load `references/full-rag-provider.md` for the end-to-end RAG red team config.
7. **Checklist** — run `references/checklist.md` end-to-end before declaring done.

## 🎯 Core principles (summary)
- **Treat the knowledge base as untrusted input** — anything retrieved can be attacker-controlled. Never put retrieved docs in the system message.
- **`indirectInjectionVar` is the key knob** — must match the variable holding retrieved docs (e.g. `context` for `{{context}}`).
- **Two surfaces: retrieval and generation** — retrieval (poisoning, manipulation) and generation (hallucination, exfiltration). Test both via component-level providers.
- **`purpose` = security contract** — be explicit about what data is off-limits; this guides both generation and grading.
- **RAG poisoning CLI** generates poisoned docs + a `poisoned-config.yaml` summary for ingestion testing.
- **Source attribution fabrication** — use `rag-source-attribution` plugin to catch fabricated citations.

## 📦 RAG attack → plugin mapping

| Attack | Plugin(s) |
|---|---|
| Prompt injection (user input) | `indirect-prompt-injection`, `jailbreak`, `jailbreak-templates` |
| Context injection (KB docs) | `indirect-prompt-injection` with `indirectInjectionVar` set to context field |
| Data poisoning | `competitors`, `harmful:misinformation-disinformation`, `bias`, `harmful:copyright-violations`, custom `policy` |
| RAG document poisoning (CLI) | `promptfoo redteam poison` → ingest → `redteam run` |
| Source attribution fabrication | `rag-source-attribution` |
| PII / data exfiltration | `pii:direct`, `pii:api-db`, `pii:social`, `harmful:privacy`, custom `policy` |
| Retrieval manipulation | `hallucination`, custom `policy` |
| Context window overflow | `harmful`, `excessive-agency`, custom `policy`; fixture with `chat_turns: 1000` |

## References
- `references/attack-surfaces.md` — the seven RAG attack types with examples and mitigations
- `references/indirect-injection.md` — `indirect-prompt-injection` plugin config, `indirectInjectionVar`, supporting plugins
- `references/rag-poisoning.md` — `promptfoo redteam poison` CLI workflow and poisoned doc ingestion
- `references/component-testing.md` — retrieval-only and generation-only Python providers, full RAG provider
- `references/purpose-field.md` — `redteam.purpose` as a security contract, retrieval vs generation purpose examples
- `references/full-rag-provider.md` — end-to-end RAG red team config with all plugins and strategies
- `references/checklist.md` — pre-flight, attack-surface, component, and post-run checklist