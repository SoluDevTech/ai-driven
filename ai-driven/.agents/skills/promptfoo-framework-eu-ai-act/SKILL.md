---
name: promptfoo-framework-eu-ai-act
description: Test AI systems against the EU AI Act with promptfoo. Use when testing prohibited AI practices (Article 5: subliminal manipulation, exploitation of vulnerabilities, social scoring, biometric categorisation, remote biometric ID) and high-risk AI systems (Annex III: biometric ID, critical infrastructure, education, employment, essential services, law enforcement, migration, justice).
---

# EU AI Act

The EU AI Act is the world's first comprehensive legal framework for AI. It uses a risk-based approach: Unacceptable Risk (prohibited, Article 5), High Risk (Annex III), Limited Risk (transparency), Minimal Risk. Promptfoo tests for prohibited practices and high-risk system requirements. Penalties up to €35M or 7% of global turnover.

## Use this skill when
- Testing EU AI Act compliance for AI systems
- Testing prohibited practices (Article 5): subliminal manipulation, vulnerability exploitation, social scoring, biometric categorisation, remote biometric ID
- Testing high-risk AI systems (Annex III): biometric ID, critical infrastructure, education, employment, essential services, law enforcement, migration, justice/democracy
- Demonstrating due diligence for EU AI Act compliance

## Do not use this skill when
- Testing GDPR → use `promptfoo-framework-gdpr` (applies alongside AI Act)
- Testing ISO 42001 → use `promptfoo-framework-iso-42001`
- Testing NIST AI RMF → use `promptfoo-framework-nist-ai-rmf`
- Testing general LLM app security → use `promptfoo-redteam-llm`

## 🛡️ Edge cases (mandatory handling)
- **Severe penalties** — prohibited practices: up to €35M or 7% of global turnover; high-risk violations: up to €15M or 3%; incorrect info to authorities: up to €7.5M or 1%.
- **Phased implementation** — 6 months (prohibited practices), 12 months (GPAI rules), 24 months (high-risk Annex III), 36 months (full application).
- **Compliance beyond testing** — documentation, transparency obligations, human oversight, quality management, post-market monitoring, incident reporting.
- **Biometric ID testing requires customization** — set `redteam.purpose` to explicitly state the biometric ID behaviors to test.
- **Combine with GDPR** — data protection requirements apply alongside the AI Act.

## 🎯 Core workflow
1. **Comprehensive testing** — `redteam: plugins: [eu:ai-act]` covers all prohibited + high-risk.
2. **Article 5 prohibited practices** — load `references/article-5.md` for subliminal manipulation, vulnerability exploitation, social scoring, biometric categorisation, remote biometric ID.
3. **Annex III high-risk** — load `references/annex-3.md` for biometric ID, critical infrastructure, education, employment, essential services, law enforcement, migration, justice.
4. **Compliance requirements** — load `references/compliance.md` for documentation, transparency, human oversight, penalties, timeline.
5. **Checklist** — run `references/checklist.md`.

## 🎯 Core principles (summary)
- **4 risk levels**: Unacceptable (prohibited), High (Annex III), Limited (transparency), Minimal (no requirements).
- **`eu:ai-act`** — comprehensive plugin; `eu:ai-act:art5:*` for prohibited practices, `eu:ai-act:annex3:*` for high-risk systems.
- **Article 5 prohibitions**: subliminal manipulation, vulnerability exploitation, social scoring, biometric categorisation, remote biometric ID (real-time and post).
- **Annex III high-risk**: 8 categories — biometric ID, critical infrastructure, education, employment, essential services, law enforcement, migration, justice/democracy.
- **Penalties up to €35M / 7% turnover** for prohibited practices.

## References
- `references/article-5.md` — all 6 prohibited practices with plugin configs
- `references/annex-3.md` — all 8 high-risk categories with plugin configs
- `references/compliance.md` — documentation, transparency, human oversight, penalties, timeline, cross-framework
- `references/checklist.md` — pre-flight, Article 5, Annex III, compliance, post-run checklist