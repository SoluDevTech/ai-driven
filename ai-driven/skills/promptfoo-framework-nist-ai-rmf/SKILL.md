---
name: promptfoo-framework-nist-ai-rmf
description: Test AI systems against the NIST AI Risk Management Framework (AI RMF) with promptfoo. Use when measuring AI risks across the four core functions (Govern, Map, Measure, Manage), testing specific MEASURE categories (safety, security, privacy, fairness, misuse), or demonstrating NIST AI RMF compliance for federal AI guidelines.
---

# NIST AI Risk Management Framework

The NIST AI RMF is a voluntary framework for managing AI risks. Promptfoo focuses on the **Measure** function — testing and evaluating AI systems against specific risk metrics. Use `nist:ai:measure` for comprehensive testing or target specific measures (2.4 safety, 2.7 security, 2.8 privacy, 2.11 fairness).

## Use this skill when
- Testing AI systems against NIST AI RMF Measure categories
- Demonstrating NIST AI RMF compliance for federal AI guidelines
- Measuring safety risks (2.4), security and resilience (2.7), privacy (2.8, 2.10), fairness and bias (2.11)
- Testing misuse and abuse potential (2.6)
- Setting up continuous testing to meet "regularly assessed" requirements

## Do not use this skill when
- Testing OWASP LLM Top 10 specifically → use `promptfoo-framework-owasp-llm`
- Testing GDPR data protection → use `promptfoo-framework-gdpr`
- Testing EU AI Act compliance → use `promptfoo-framework-eu-ai-act`
- Testing DoD AI ethics → use `promptfoo-framework-dod-ai-ethics`
- Testing general LLM app security without a framework → use `promptfoo-redteam-llm`

## 🛡️ Edge cases (mandatory handling)
- **Automated testing covers Measure only** — Govern, Map, and Manage functions need organizational processes beyond promptfoo.
- **MEASURE 2.12 (environmental impact)** — requires infrastructure monitoring, not testable via red teaming.
- **MEASURE 3.3 (stakeholder feedback)** — requires organizational procedures for user feedback.
- **MEASURE 4.3 (business value)** — requires business context beyond automated testing.
- **Document your testing** — NIST emphasizes documentation (MEASURE 2.1); save test configs and results.
- **Regular evaluation** — set up CI/CD continuous testing to meet "regularly assessed" requirements.

## 🎯 Core workflow
1. **Comprehensive testing** — `redteam: plugins: [nist:ai:measure]` covers all measures.
2. **Targeted testing** — load `references/measure-mappings.md` for specific measure plugin configs.
3. **Cross-framework** — load `references/cross-framework.md` for combining with OWASP, GDPR, EU AI Act.
4. **Best practices** — load `references/best-practices.md` for documentation, regular evaluation, and limitations.
5. **Checklist** — run `references/checklist.md` before declaring done.

## 🎯 Core principles (summary)
- **NIST AI RMF = 4 functions: Govern, Map, Measure, Manage** — promptfoo focuses on **Measure**.
- **`nist:ai:measure`** — comprehensive plugin covering all measures.
- **Target specific measures** — `nist:ai:measure:2.4` (safety), `2.7` (security), `2.8` (privacy), `2.11` (fairness).
- **Each measure maps to specific plugins** — e.g., 2.7 → `harmful:cybercrime`, `shell-injection`, `sql-injection`; 2.11 → `harmful:hate`, `harmful:harassment-bullying`.
- **Automated testing is necessary but not sufficient** — combine with governance, documentation, and stakeholder engagement.

## References
- `references/measure-mappings.md` — all MEASURE categories (1.1-4.3) with plugin configs and descriptions
- `references/cross-framework.md` — combining NIST with OWASP, GDPR, EU AI Act, ISO 42001
- `references/best-practices.md` — documentation, regular evaluation, representative testing, limitations
- `references/checklist.md` — pre-flight, measure selection, cross-framework, post-run checklist