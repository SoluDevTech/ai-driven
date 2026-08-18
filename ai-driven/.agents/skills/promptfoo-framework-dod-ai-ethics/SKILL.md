---
name: promptfoo-framework-dod-ai-ethics
description: Test AI systems against the DoD AI Ethical Principles (Responsible, Equitable, Traceable, Reliable, Governable) with promptfoo. Use when measuring ethical and security risk for DoD-aligned AI systems, testing human accountability, bias minimization, auditability, safety, and governability.
---

# DoD AI Ethical Principles

The U.S. Department of Defense adopted five AI ethical principles in 2020: **Responsible, Equitable, Traceable, Reliable, Governable**. Promptfoo maps each principle to concrete red team plugins via `dod:ai:ethics`.

## Use this skill when
- Testing DoD AI ethical principles compliance
- Testing responsible AI (human accountability, excessive agency)
- Testing equitable AI (bias across age, disability, gender, race)
- Testing traceable AI (hallucination, source attribution, unverifiable claims)
- Testing reliable AI (injection, SSRF, unsafe practices)
- Testing governable AI (control boundaries, hijacking, RBAC, tool discovery)

## Do not use this skill when
- Testing NIST AI RMF → use `promptfoo-framework-nist-ai-rmf`
- Testing OWASP LLM Top 10 → use `promptfoo-framework-owasp-llm`
- Testing ISO 42001 → use `promptfoo-framework-iso-42001`
- Testing general LLM app security → use `promptfoo-redteam-llm`

## 🛡️ Edge cases (mandatory handling)
- **DoD principles are ethical, not just security** — bias and fairness testing (Equitable) requires demographic-specific plugins.
- **Traceable includes hallucination** — not just logging; test for fabricated claims and unverifiable statements.
- **Governable requires control boundary testing** — `indirect-prompt-injection`, `system-prompt-override`, `rbac`, `bfla`, `bola`, `tool-discovery`.
- **Combine with security frameworks** — DoD ethics testing pairs with NIST AI RMF, OWASP Agentic, ISO 42001.

## 🎯 Core workflow
1. **Comprehensive testing** — `redteam: plugins: [dod:ai:ethics]` covers all 5 principles.
2. **Targeted testing** — load `references/principle-mappings.md` for per-principle plugin configs.
3. **Cross-framework** — load `references/cross-framework.md` for combining with NIST, OWASP, ISO.
4. **Checklist** — run `references/checklist.md`.

## 🎯 Core principles (summary)
- **5 principles: Responsible, Equitable, Traceable, Reliable, Governable** — each maps to specific plugins.
- **`dod:ai:ethics`** — comprehensive plugin covering all principles.
- **Per-principle**: `dod:ai:ethics:01` (Responsible), `:02` (Equitable), `:03` (Traceable), `:04` (Reliable), `:05` (Governable).

## References
- `references/principle-mappings.md` — all 5 principles with plugin configs and testing strategies
- `references/cross-framework.md` — combining DoD with NIST, OWASP Agentic, ISO 42001
- `references/checklist.md` — pre-flight, principle selection, post-run checklist