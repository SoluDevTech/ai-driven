# Checklist

Run before declaring OWASP LLM Top 10 testing done.

## Pre-Flight
- [ ] `owasp:llm` plugin selected (comprehensive) OR specific LLM01-LLM10 targeted
- [ ] Strategies selected (`jailbreak-templates`, `jailbreak` minimum)
- [ ] `redteam.purpose` set

## Vulnerability Selection
- [ ] **LLM01 Prompt Injection** — `contracts`, `politics` + jailbreak strategies
- [ ] **LLM02 Sensitive Info** — `harmful:privacy`, `pii:direct`, `pii:api-db`, `pii:session`, `pii:social`
- [ ] **LLM03 Supply Chain** — model comparison + `promptfoo scan-model` (see `promptfoo-redteam-supply-chain`)
- [ ] **LLM04 Data Poisoning** — `harmful`, `overreliance`, `hallucination`
- [ ] **LLM05 Output Handling** — `not-contains` assertions for `<script>`, HTML, etc.
- [ ] **LLM06 Excessive Agency** — `excessive-agency`, `overreliance`, `imitation`, `hijacking`, `rbac`
- [ ] **LLM07 System Prompt Leakage** — `prompt-extraction` with `systemPrompt` config provided
- [ ] **LLM08 Vector/Embedding** — `rbac`, `bola`, `bfla`, `indirect-prompt-injection` with `indirectInjectionVar`, RAG poisoning CLI
- [ ] **LLM09 Misinformation** — `overreliance`, `hallucination`
- [ ] **LLM10 Unbounded Consumption** — `divergent-repetition` + rate limiting assertions

## Gen AI Red Team Phases (if applicable)
- [ ] Phase 1 Model — `owasp:llm:redteam:model`
- [ ] Phase 2 Implementation — `owasp:llm:redteam:implementation`
- [ ] Phase 3 System — `owasp:llm:redteam:system`
- [ ] Phase 4 Runtime — `owasp:llm:redteam:runtime`

## Post-Run
- [ ] Per-vulnerability ASR documented (LLM01-LLM10)
- [ ] Prompt injection failures investigated
- [ ] PII leaks investigated
- [ ] Excessive agency failures investigated
- [ ] System prompt leakage checked (did the model reveal its prompt?)
- [ ] RAG poisoning results reviewed
- [ ] Mitigations documented for each LLM01-LLM10 vulnerability