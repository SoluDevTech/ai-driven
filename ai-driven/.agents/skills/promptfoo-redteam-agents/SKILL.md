---
name: promptfoo-redteam-agents
description: Red team LLM agents, MCP servers, and multi-turn chatbots with promptfoo. Use when testing agents for privilege escalation (RBAC/BOLA/BFLA), memory poisoning, multi-stage attack chains, tool/API manipulation, objective hijacking, MCP tool poisoning, tool shadowing, cross-server attacks, and multi-turn conversation manipulation. Covers layered testing (black-box/component/trace-based), OpenTelemetry tracing, trajectory assertions, and stateful strategies.
---

# Red Team LLM Agents, MCP, and Multi-Turn Chatbots

LLM agents have state, tools, and multi-step execution — introducing unique risks beyond base models. Use a layered testing approach: black-box (end-to-end), component (direct hooks), and trace-based (OpenTelemetry glass box). For MCP servers, test three scenarios: trusted client, multi-server poisoning, and direct protocol testing. For multi-turn chatbots, use stateful strategies with `conversationId`.

## Use this skill when
- Testing LLM agents with tools, state, or multi-step execution
- Testing for privilege escalation (RBAC, BOLA, BFLA)
- Testing for memory poisoning in stateful agents
- Testing multi-stage attack chains and tool/API manipulation
- Testing objective hijacking and prompt leaks
- Enabling OpenTelemetry trace-based testing with iterative strategies
- Converting red-team findings into trajectory regression assertions
- Testing MCP servers for tool poisoning, tool shadowing, and cross-server attacks
- Testing multi-turn chatbots (Chatbase, conversational agents) with stateful strategies

## Do not use this skill when
- Testing a simple LLM app without tools/state → use `promptfoo-redteam-llm`
- Testing RAG systems → use `promptfoo-redteam-rag` (but use this skill for agent-specific RAG risks like `rag-poisoning`)
- Testing multi-input apps with user_id + message → use `promptfoo-redteam-multi-input`
- Testing foundation models in isolation → use `promptfoo-redteam-foundation-models`
- Testing guardrails → use `promptfoo-redteam-guardrails`

## 🛡️ Edge cases (mandatory handling)
- **Auth in the prompt** — LLM-based permission systems are bypassable; use deterministic RBAC on the API side, never in the prompt. Treat all tool APIs as public.
- **Single-layer testing** — black-box alone misses *why* a failure occurred; always add component + trace layers for agents with state/tools.
- **`includeInAttack: true` with secrets in spans** — the attacker strategy sees sanitized span summaries; never put API keys, tokens, or sensitive IDs in span names, tool names, or attributes.
- **Always-on `includeInAttack`** — for a first-pass black-box assessment, set `includeInAttack: false` to avoid giving the attacker extra info; keep `includeInGrading: true`.
- **Missing `stateful: true`** — without it, `goat`, `crescendo`, `mischievous-user` strategies treat each message independently, missing multi-turn attack chains.
- **Missing `conversationId`** — `transformVars` must inject `conversationId: context.uuid` or state tracking breaks.
- **MCP tool descriptions not inspected** — tool descriptions are an attack surface; the AI reads them as instructions, not documentation.
- **Single-server MCP testing only** — cross-server attacks only emerge in multi-server environments; always test with a malicious co-tenant.
- **Rug pulls** — MCP server behavior can change after user approval; test post-approval behavior.

## 🎯 Core workflow
1. **Choose testing layers** — load `references/layered-testing.md` for black-box, component, and trace-based configs.
2. **Select agent plugins** — load `references/agent-plugins.md` for the RBAC/BOLA/BFLA triad, memory poisoning, tool discovery, and more.
3. **Configure tracing** — load `references/tracing.md` for OpenTelemetry setup, `spanFilter`, `includeInAttack`/`includeInGrading`, and trajectory assertions.
4. **Test MCP servers** — load `references/mcp-testing.md` for three scenarios, `evil-mcp-server`, and agent-based MCP testing.
5. **Test multi-turn chatbots** — load `references/multi-turn.md` for stateful strategies, `conversationId`, and Chatbase config.
6. **Convert findings to regression** — load `references/trajectory-assertions.md` for `trajectory:*` assertions.
7. **Checklist** — run `references/checklist.md` end-to-end before declaring done.

## 🎯 Core principles (summary)
- **Layered testing** — black-box (HTTP end-to-end), component (`file://` hooks), trace-based (OpenTelemetry). All three for agents with state/tools.
- **RBAC/BOLA/BFLA triad** — covers most agent access-control risks. `rbac` (role-based), `bola` (broken object auth), `bfla` (broken function auth).
- **Treat all tool APIs as public** — enforce auth deterministically on the API side, never in prompts.
- **Tool descriptions are an attack surface** — MCP poisoning exploits the gap between what users see and what the model processes.
- **Memory poisoning** — `agentic:memory-poisoning` establishes a memory, sends a poisoned message, verifies with a follow-up question.
- **Tracing creates an evidence loop** — attack → spans → summary → grading + next attack iteration. Use `includeInAttack: true` for adaptive strategies, `false` for black-box first passes.
- **Stateful strategies need `stateful: true`** — `goat`, `crescendo`, `mischievous-user` + `conversationId` via `transformVars`.
- **Convert findings to trajectory assertions** — `trajectory:tool-used`, `trajectory:tool-args-match`, `trajectory:tool-sequence`, `trajectory:step-count`, `trajectory:goal-success`.

## 📦 Agent vulnerability → plugin/strategy mapping

| Vulnerability | Plugins | Strategies |
|---|---|---|
| Privilege escalation | `rbac`, `bola`, `bfla` | `jailbreak-templates`, `jailbreak` |
| Context poisoning / exfiltration | `harmful:privacy`, `pii`, `ssrf`, `cross-session-leak`, `rag-poisoning`, `rag-document-exfiltration` | `jailbreak-templates`, `jailbreak`, `jailbreak:tree` |
| Memory poisoning | `agentic:memory-poisoning` | `jailbreak`, `crescendo`, `mischievous-user` |
| Multi-stage attack chains | `sql-injection`, `excessive-agency`, `rbac` | `jailbreak` |
| Tool/API manipulation | `bola`, `bfla`, `ssrf`, `tool-discovery`, `mcp` | `jailbreak-templates`, `jailbreak` |
| Objective hijacking | `hijacking`, `excessive-agency`, `harmful` | `jailbreak-templates`, `jailbreak` |
| Prompt leak | custom `policy` | `jailbreak-templates`, `jailbreak` |
| MCP tool poisoning | `mcp`, `pii`, `bola`, `bfla` | `jailbreak`, `jailbreak:tree`, `jailbreak:composite` |

## References
- `references/layered-testing.md` — black-box, component, trace-based testing configs and the car analogy
- `references/agent-plugins.md` — RBAC/BOLA/BFLA triad, memory poisoning, tool discovery, SSRF, cross-session leak, with configs
- `references/tracing.md` — OpenTelemetry setup, `spanFilter`, `includeInAttack`/`includeInGrading`, trace summary format, how feedback improves attacks
- `references/trajectory-assertions.md` — `trajectory:*` assertion types and converting findings to CI regression checks
- `references/mcp-testing.md` — three MCP scenarios, `evil-mcp-server`, tool poisoning, tool shadowing, agent-based MCP testing, CI/CD integration
- `references/multi-turn.md` — stateful strategies, `conversationId`, Chatbase HTTP provider config
- `references/checklist.md` — layered testing, agent plugins, tracing, MCP, multi-turn checklist