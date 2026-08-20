---
name: promptfoo-framework-owasp-agentic
description: Test AI agent applications against the OWASP Top 10 for Agentic Applications (ASI01-ASI10) with promptfoo. Use when testing agent goal hijack, tool misuse, identity/privilege abuse, agentic supply chain, unexpected code execution, memory/context poisoning, insecure inter-agent communication, cascading failures, human-agent trust exploitation, or rogue agents.
---

# OWASP Top 10 for Agentic Applications

The OWASP Top 10 for Agentic Applications (announced Black Hat Europe 2025) covers the most critical security risks for AI agents: ASI01-ASI10. Agents introduce unique risks via autonomous decision-making, persistent memory, tool/API access, and multi-agent coordination. Use `owasp:agentic` for comprehensive testing.

## Use this skill when
- Testing AI agents against OWASP Agentic Top 10 (ASI01-ASI10)
- Testing agent goal hijack, tool misuse, identity/privilege abuse
- Testing agentic supply chain, unexpected code execution, memory poisoning
- Testing insecure inter-agent communication, cascading failures
- Testing human-agent trust exploitation, rogue agents

## Do not use this skill when
- Testing OWASP LLM Top 10 → use `promptfoo-framework-owasp-llm`
- Testing OWASP API Security → use `promptfoo-framework-owasp-api`
- Testing general agent security → use `promptfoo-redteam-agents`
- Testing MCP servers → use `promptfoo-redteam-agents` (MCP section)

## 🛡️ Edge cases (mandatory handling)
- **Agents differ from LLM apps** — autonomous decision-making, persistent memory, tool access, multi-agent coordination create unique risks.
- **ASI04 (Supply Chain) includes MCP** — `mcp` plugin for compromised tools/plugins/servers.
- **ASI06 (Memory Poisoning) includes `agentic:memory-poisoning`** — tests stateful agent memory corruption.
- **ASI07 (Inter-Agent Communication) is multi-agent specific** — `indirect-prompt-injection`, `hijacking`, `imitation` for spoofing/tampering.
- **ASI08 (Cascading Failures) includes `divergent-repetition`** — tests error propagation across planning/execution.
- **Combine with OWASP LLM Top 10** — agentic extends and complements LLM Top 10.

## 🎯 Core workflow
1. **Comprehensive testing** — `redteam: plugins: [owasp:agentic]` covers all 10 risks.
2. **Targeted testing** — load `references/asi-mappings.md` for per-risk plugin configs.
3. **Cross-framework** — load `references/cross-framework.md` for combining with OWASP LLM Top 10.
4. **Checklist** — run `references/checklist.md`.

## 🎯 Core principles (summary)
- **10 risks: ASI01-ASI10** — each maps to specific plugins.
- **`owasp:agentic`** — comprehensive plugin; `owasp:agentic:asi01` through `asi10` for individual risks.
- **Agentic risks extend OWASP LLM Top 10** — ASI01↔LLM01, ASI02/03↔LLM06, ASI05↔LLM01/05, ASI06↔LLM04, ASI08↔LLM09.

## References
- `references/asi-mappings.md` — all 10 risks (ASI01-ASI10) with plugin configs, attack scenarios, and testing strategies
- `references/cross-framework.md` — combining OWASP Agentic with OWASP LLM Top 10
- `references/checklist.md` — pre-flight, risk selection, post-run checklist