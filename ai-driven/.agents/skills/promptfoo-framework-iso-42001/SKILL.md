---
name: promptfoo-framework-iso-42001
description: Test AI systems against ISO/IEC 42001:2023 (AI Management Systems standard) with promptfoo. Use when testing seven risk domains: accountability & human oversight, fairness & bias prevention, privacy & data protection, robustness & resilience, security & vulnerability management, safety & ethical use, and transparency & trustworthiness.
---

# ISO 42001

ISO/IEC 42001:2023 is the international standard for AI Management Systems. It covers seven key risk domains: Accountability, Fairness, Privacy, Robustness, Security, Safety, and Transparency. Use `iso:42001` for comprehensive testing or target specific domains.

## Use this skill when
- Testing ISO 42001 compliance across 7 risk domains
- Testing accountability & human oversight (excessive agency, overreliance)
- Testing fairness & bias prevention (demographic bias, hate speech)
- Testing privacy & data protection (PII, cross-session leaks)
- Testing robustness & resilience (prompt injection, ASCII smuggling)
- Testing security & vulnerability management (injection, SSRF, debug access)
- Testing safety & ethical use (harmful content, weapons, cybercrime)
- Testing transparency & trustworthiness (hallucination, misinformation, imitation)

## Do not use this skill when
- Testing GDPR specifically → use `promptfoo-framework-gdpr`
- Testing NIST AI RMF → use `promptfoo-framework-nist-ai-rmf`
- Testing EU AI Act → use `promptfoo-framework-eu-ai-act`
- Testing general LLM app security → use `promptfoo-redteam-llm`

## 🛡️ Edge cases (mandatory handling)
- **ISO 42001 is a management system standard** — automated testing covers technical risks; governance, documentation, and continuous improvement need organizational processes.
- **Custom plugins for organization-specific risks** — create `file://custom-iso-plugin.yaml` for domain-specific compliance.
- **Regular testing required** — ISO 42001 emphasizes continuous improvement; set up CI/CD.
- **Combine with other frameworks** — privacy domain overlaps with GDPR; security overlaps with OWASP.

## 🎯 Core workflow
1. **Comprehensive testing** — `redteam: plugins: [iso:42001]` covers all 7 domains.
2. **Targeted testing** — load `references/domain-mappings.md` for per-domain plugin configs.
3. **Custom plugins** — load `references/custom-plugins.md` for organization-specific risks.
4. **Checklist** — run `references/checklist.md`.

## 🎯 Core principles (summary)
- **7 risk domains**: Accountability, Fairness, Privacy, Robustness, Security, Safety, Transparency.
- **`iso:42001`** — comprehensive plugin; `iso:42001:accountability`, `:fairness`, `:privacy`, `:robustness`, `:security`, `:safety`, `:transparency` for individual domains.

## References
- `references/domain-mappings.md` — all 7 risk domains with plugin configs
- `references/custom-plugins.md` — custom plugin examples for organization-specific ISO 42001 risks
- `references/checklist.md` — pre-flight, domain selection, post-run checklist