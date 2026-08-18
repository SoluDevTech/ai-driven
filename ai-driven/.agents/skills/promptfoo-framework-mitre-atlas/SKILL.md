---
name: promptfoo-framework-mitre-atlas
description: Test AI systems against MITRE ATLAS (Adversarial Threat Landscape for AI Systems) with promptfoo. Use when testing adversarial ML tactics across the attack lifecycle: reconnaissance, resource development, initial access, execution, persistence, privilege escalation, defense evasion, credential access, discovery, lateral movement, collection, AI attack staging, command and control, exfiltration, and impact.
---

# MITRE ATLAS

MITRE ATLAS (Adversarial Threat Landscape for AI Systems) is a knowledge base of adversary tactics and techniques against ML systems, modeled after MITRE ATT&CK. Promptfoo maps ATLAS tactics to plugins via `mitre:atlas`. Use for attack-lifecycle testing across all tactics.

## Use this skill when
- Testing AI systems against MITRE ATLAS tactics
- Testing adversarial ML attack lifecycle (reconnaissance → exfiltration → impact)
- Testing reconnaissance (prompt extraction, tool discovery)
- Testing initial access (injection, SSRF, debug access)
- Testing AI attack staging (ASCII smuggling, excessive agency, hallucination)
- Testing exfiltration (PII, prompt extraction, cross-session leaks)
- Testing impact (hijacking, harmful content, imitation)
- Using ATLAS as common language between red and blue teams (purple teaming)

## Do not use this skill when
- Testing OWASP LLM Top 10 → use `promptfoo-framework-owasp-llm`
- Testing NIST AI RMF → use `promptfoo-framework-nist-ai-rmf`
- Testing general LLM app security → use `promptfoo-redteam-llm`

## 🛡️ Edge cases (mandatory handling)
- **`AI Model Access` tactic has no direct checks** — it's a coverage gap in the preset.
- **`mitre:atlas:ml-attack-staging` is deprecated** — use `mitre:atlas:ai-attack-staging` in new configs.
- **Test in multiple languages** — `language: ['en', 'es', 'fr']` for comprehensive reconnaissance testing.
- **ATLAS vs ATT&CK** — use ATLAS for ML-specific vulnerabilities (model extraction, prompt injection); use ATT&CK principles for infrastructure security (API, auth).
- **Combine tactics as adversaries would** — test across the full attack chain, not individual tactics.

## 🎯 Core workflow
1. **Comprehensive testing** — `redteam: plugins: [mitre:atlas]` covers all tactics.
2. **Targeted testing** — load `references/tactic-mappings.md` for per-tactic plugin configs.
3. **Best practices** — load `references/best-practices.md` for attack lifecycle, purple teaming.
4. **Checklist** — run `references/checklist.md`.

## 🎯 Core principles (summary)
- **ATLAS = MITRE ATT&CK for ML** — adversary tactics and techniques against AI systems.
- **`mitre:atlas`** — comprehensive plugin; per-tactic aliases like `mitre:atlas:reconnaissance`.
- **16 tactics** covering the full attack lifecycle from reconnaissance to impact.
- **Real-world ATLAS techniques**: AML.T0043 (Craft Adversarial Data), AML.T0051 (LLM Prompt Injection), AML.T0024 (Exfiltration via AI Inference API), AML.T0020 (Poison Train Data), AML.T0086 (Exfiltration via AI Agent Tool Invocation), AML.T0110 (AI Agent Tool Poisoning).

## References
- `references/tactic-mappings.md` — all 16 tactics with plugin configs, threat landscapes, and testing strategies
- `references/best-practices.md` — attack lifecycle, defense in depth, purple teaming, real-world techniques
- `references/checklist.md` — pre-flight, tactic selection, post-run checklist