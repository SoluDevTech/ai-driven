---
name: promptfoo-framework-owasp-api
description: Test LLM applications with API access against the OWASP API Security Top 10 (2023) with promptfoo. Use when testing BOLA (API1), broken authentication (API2), excessive data exposure (API3), resource consumption (API4), BFLA (API5), sensitive business flows (API6), SSRF (API7), security misconfiguration (API8), inventory management (API9), or unsafe API consumption (API10).
---

# OWASP API Security Top 10

The OWASP API Security Top 10 (2023) identifies critical API risks. LLM applications with function calling, tool usage, or agent architectures are particularly susceptible — the LLM acts as a dynamic interface between users and backend systems. Use `owasp:api` for comprehensive testing.

## Use this skill when
- Testing LLM apps with API/function-cling/tool access against OWASP API Top 10
- Testing BOLA (API1), BFLA (API5), SSRF (API7)
- Testing broken authentication, resource consumption, security misconfiguration
- Testing sensitive business flows, inventory management, unsafe API consumption

## Do not use this skill when
- Testing OWASP LLM Top 10 → use `promptfoo-framework-owasp-llm`
- Testing OWASP Agentic → use `promptfoo-framework-owasp-agentic`
- Testing general agent security → use `promptfoo-redteam-agents`

## 🛡️ Edge cases (mandatory handling)
- **LLMs as API interfaces** — natural language input, autonomous tool usage, context-dependent authorization, and indirect injection create unique API security challenges.
- **Defense in depth** — implement authorization at BOTH the LLM and API layers.
- **Principle of least privilege** — limit LLM access to only necessary APIs and functions.
- **Input validation** — validate LLM outputs before passing to APIs.
- **Rate limiting** — apply both token-based and API call rate limits.

## 🎯 Core workflow
1. **Comprehensive testing** — `redteam: plugins: [owasp:api]` covers all 10.
2. **Targeted testing** — load `references/api-mappings.md` for per-risk plugin configs.
3. **Best practices** — load `references/best-practices.md` for LLM-specific API security.
4. **Checklist** — run `references/checklist.md`.

## 🎯 Core principles (summary)
- **10 risks: API1-API10** — each maps to specific plugins.
- **`owasp:api`** — comprehensive; `owasp:api:01` through `owasp:api:10` for individual risks.
- **LLM-specific challenges**: natural language as attack vector, autonomous tool usage, context-dependent authorization, indirect injection.
- **API1 (BOLA) and API5 (BFLA) are most relevant** — `bola`, `bfla`, `rbac` plugins.

## References
- `references/api-mappings.md` — all 10 risks (API1-API10) with plugin configs and LLM context
- `references/best-practices.md` — LLM-specific API security best practices
- `references/checklist.md` — pre-flight, risk selection, post-run checklist