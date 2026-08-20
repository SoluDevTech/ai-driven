# Checklist

Run before declaring OWASP Agentic testing done.

## Pre-Flight
- [ ] `owasp:agentic` plugin selected (comprehensive) OR specific ASI01-ASI10 targeted
- [ ] Strategies selected (`jailbreak`, `jailbreak-templates`, `crescendo`)
- [ ] Target is an AI agent (not a simple LLM app)

## Risk Selection
- [ ] **ASI01 Goal Hijack** — `hijacking`, `system-prompt-override`, `indirect-prompt-injection`, `intent`
- [ ] **ASI02 Tool Misuse** — `excessive-agency`, `mcp`, `tool-discovery`
- [ ] **ASI03 Identity/Privilege** — `rbac`, `bfla`, `bola`, `imitation`
- [ ] **ASI04 Supply Chain** — `indirect-prompt-injection`, `mcp`
- [ ] **ASI05 Code Execution** — `shell-injection`, `sql-injection`, `harmful:cybercrime:malicious-code`, `ssrf`
- [ ] **ASI06 Memory Poisoning** — `agentic:memory-poisoning`, `cross-session-leak`, `indirect-prompt-injection`
- [ ] **ASI07 Inter-Agent Comm** — `indirect-prompt-injection`, `hijacking`, `imitation`
- [ ] **ASI08 Cascading Failures** — `hallucination`, `harmful:misinformation-disinformation`, `divergent-repetition`
- [ ] **ASI09 Trust Exploitation** — `overreliance`, `imitation`, `harmful:misinformation-disinformation`
- [ ] **ASI10 Rogue Agents** — `excessive-agency`, `hijacking`, `rbac`, `goal-misalignment`

## Cross-Framework
- [ ] Combined with OWASP LLM Top 10 for comprehensive coverage

## Post-Run
- [ ] Per-risk ASR documented (ASI01-ASI10)
- [ ] Goal hijack failures investigated
- [ ] Tool misuse failures investigated
- [ ] Memory poisoning failures investigated
- [ ] Mitigations documented for each ASI risk