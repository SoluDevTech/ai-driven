---
name: promptfoo-framework-gdpr
description: Test AI systems against EU data protection requirements (GDPR) with promptfoo. Use when testing seven key GDPR articles: Article 5 (processing principles), Article 9 (special categories), Article 15 (right of access), Article 17 (right to erasure), Article 22 (automated decision-making), Article 25 (data protection by design), and Article 32 (security of processing).
---

# GDPR Data Protection Testing

Promptfoo's `gdpr` preset groups privacy, access-control, and security checks for reviewing AI systems against EU data protection requirements. Maps to 7 key GDPR articles. **Not legal compliance certification** — intended for technical testing and risk discovery.

## Use this skill when
- Testing AI systems against GDPR data protection requirements
- Testing Article 5 (processing principles: lawfulness, minimization, accuracy)
- Testing Article 9 (special categories: health, genetic, racial, political, religious)
- Testing Article 15 (right of access: BOLA, RBAC, session boundaries)
- Testing Article 17 (right to erasure: PII persistence, cross-session leakage)
- Testing Article 22 (automated decision-making: bias, overreliance, hallucination)
- Testing Article 25 (data protection by design: PII protection, prompt extraction)
- Testing Article 32 (security of processing: injection, SSRF, debug access, cybercrime)

## Do not use this skill when
- Testing ISO 42001 → use `promptfoo-framework-iso-42001` (privacy domain overlaps)
- Testing EU AI Act → use `promptfoo-framework-eu-ai-act`
- Testing OWASP LLM Top 10 → use `promptfoo-framework-owasp-llm`
- Testing general LLM app security → use `promptfoo-redteam-llm`

## 🛡️ Edge cases (mandatory handling)
- **NOT legal compliance** — this preset is for technical testing and risk discovery only. Does not certify legal compliance, provide legal advice, or replace review by privacy counsel.
- **Article 17 (right to erasure) is challenging for AI** — training data persists in model weights, cached responses might retain PII, session data might not be properly cleared.
- **Article 22 (automated decision-making)** — requires human oversight, explainability, and non-discrimination. Test bias, overreliance, and hallucination.
- **Combine with legal review** — automated testing complements but doesn't replace: legal review by DPOs, privacy impact assessments (PIAs/DPIAs), organizational policies, user consent mechanisms.
- **Test in context** — consider your specific use case and jurisdictional requirements.

## 🎯 Core workflow
1. **Comprehensive testing** — `redteam: plugins: [gdpr]` covers all 7 articles.
2. **Targeted testing** — load `references/article-mappings.md` for per-article plugin configs.
3. **Custom plugins** — load `references/custom-plugins.md` for data subject rights testing.
4. **Best practices** — load `references/best-practices.md` for testing limitations and legal review.
5. **Checklist** — run `references/checklist.md`.

## 🎯 Core principles (summary)
- **7 GDPR articles**: Art 5 (processing principles), Art 9 (special categories), Art 15 (right of access), Art 17 (right to erasure), Art 22 (automated decision-making), Art 25 (data protection by design), Art 32 (security of processing).
- **`gdpr`** — comprehensive plugin; `gdpr:art5`, `gdpr:art9`, `gdpr:art15`, `gdpr:art17`, `gdpr:art22`, `gdpr:art25`, `gdpr:art32` for individual articles.
- **Technical testing only** — not legal compliance certification.

## References
- `references/article-mappings.md` — all 7 articles with plugin configs and testing strategies
- `references/custom-plugins.md` — custom plugin for data subject rights requests
- `references/best-practices.md` — testing limitations, legal review, cross-framework
- `references/checklist.md` — pre-flight, article selection, post-run checklist