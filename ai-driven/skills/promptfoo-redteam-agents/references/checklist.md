# Checklist

Run end-to-end before declaring agent/MCP/multi-turn red team done.

## Layered Testing
- [ ] **Black-box** — HTTP endpoint target with `agentic:memory-poisoning`, `tool-discovery`, `excessive-agency`
- [ ] **Component** — `file://agent.py:do_planning` custom provider for isolated step testing
- [ ] **Trace-based** — OpenTelemetry tracing enabled with `spanFilter` aligned to agent's span names
- [ ] `includeInAttack: false` for first-pass black-box; `true` for adaptive strategies (`jailbreak:meta`, `jailbreak:hydra`)

## Agent Plugins
- [ ] **RBAC/BOLA/BFLA triad** — `rbac`, `bola`, `bfla` + `jailbreak-templates`, `jailbreak`
- [ ] **Memory poisoning** — `agentic:memory-poisoning` + `jailbreak`, `crescendo`, `mischievous-user` (if stateful)
- [ ] **Context poisoning/exfiltration** — `harmful:privacy`, `pii`, `ssrf`, `cross-session-leak`, `rag-poisoning`, `rag-document-exfiltration`
- [ ] **Tool/API manipulation** — `bola`, `bfla`, `ssrf`, `tool-discovery`, `mcp`
- [ ] **Objective hijacking** — `hijacking`, `excessive-agency`, `harmful`
- [ ] **Prompt leak** — custom `policy` plugin
- [ ] `redteam.purpose` set describing the agent's intended behavior and tool restrictions

## Tracing (if enabled)
- [ ] `tracing.enabled: true` + `otlp.http.enabled: true`
- [ ] `redteam.tracing.enabled: true`
- [ ] `spanFilter` covers `chat*`, `*tool*`, `*guardrail*`, `*command*`, `*search*`
- [ ] No secrets in span names, tool names, or attributes
- [ ] Agent emits spans with `tool.name`, `tool.arguments` attributes

## Trajectory Assertions (if findings converted)
- [ ] High-risk findings converted to `trajectory:*` regression assertions
- [ ] `not-trajectory:tool-args-match` used for "must NOT call" regression checks
- [ ] Regression evals run in CI alongside red-team plugins

## MCP Testing (if applicable)
- [ ] **Scenario 1** — trusted client config with `mcp`, `pii`, `bfla`, `bola`, `sql-injection` plugins
- [ ] **Scenario 2** — multi-server with `evil-mcp-server` co-tenant; `jailbreak:tree`, `jailbreak:composite`
- [ ] **Scenario 3** — direct MCP testing with `providers: - id: mcp`
- [ ] Agent-based MCP testing (`redteam-mcp-agent` example) if testing tool return value handling
- [ ] All three scenario YAMLs integrated into CI/CD on every push

## Multi-Turn (if applicable)
- [ ] `stateful: true` on `goat`, `crescendo`, `mischievous-user` strategies
- [ ] `transformVars` injects `conversationId: context.uuid`
- [ ] `transformRequest` formats OpenAI-compatible messages
- [ ] `transformResponse` extracts response text

## Post-Run
- [ ] `npx promptfoo@latest redteam report` reviewed
- [ ] Privilege escalation failures investigated (did the agent access unauthorized resources?)
- [ ] Memory poisoning failures investigated (did the agent follow poisoned instructions?)
- [ ] Tool manipulation failures investigated (did the agent call forbidden tools?)
- [ ] MCP tool poisoning failures investigated (did the agent follow hidden tool-description instructions?)
- [ ] Mitigations documented:
  - [ ] Deterministic RBAC on API side (not in prompts)
  - [ ] Tool descriptions sanitized before passing to model
  - [ ] Cross-server tool chaining blocked at proxy layer
  - [ ] Memory attribution and temporal limits added
- [ ] Re-run after mitigations to verify fixes