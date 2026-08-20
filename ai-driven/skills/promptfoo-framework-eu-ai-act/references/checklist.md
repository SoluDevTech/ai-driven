# Checklist

Run before declaring EU AI Act compliance testing done.

## Pre-Flight
- [ ] `eu:ai-act` plugin selected (comprehensive) OR specific Article 5 / Annex III categories targeted
- [ ] Strategies selected (`jailbreak`, `jailbreak-templates`)
- [ ] `redteam.purpose` set (especially for biometric ID — must explicitly state behaviors)
- [ ] Risk category identified (Unacceptable, High, Limited, Minimal)

## Article 5 — Prohibited Practices
- [ ] **Subliminal Manipulation** — `hijacking`, `intent`, `excessive-agency`
- [ ] **Exploitation of Vulnerabilities** — `hijacking`, `imitation`, `harmful:misinformation-disinformation`
- [ ] **Social Scoring** — `harmful:misinformation-disinformation`, `overreliance`
- [ ] **Biometric Categorisation** — `pii:direct`, `pii:session`, `harmful:privacy`
- [ ] **Real-time Remote Biometric ID** — `pii:session`, `pii:direct`, `harmful:privacy`
- [ ] **Post Remote Biometric ID** — `pii:api-db`, `pii:direct`, `harmful:privacy`

## Annex III — High-Risk Systems (if applicable)
- [ ] **Biometric ID** — `pii:direct`, `pii:session`, `harmful:privacy` (customize purpose)
- [ ] **Critical Infrastructure** — `shell-injection`, `sql-injection`, `ssrf`, `excessive-agency`
- [ ] **Education** — `harmful:misinformation-disinformation`, `hallucination`, `overreliance`
- [ ] **Employment** — `imitation`, `pii:direct`, `overreliance`
- [ ] **Essential Services** — `pii:direct`, `pii:session`, `excessive-agency`
- [ ] **Law Enforcement** — `pii:direct`, `pii:api-db`, `harmful:privacy`
- [ ] **Migration/Border** — `pii:direct`, `harmful:hate`, `harmful:privacy`
- [ ] **Justice/Democracy** — `hallucination`, `harmful:misinformation-disinformation`, `pii:direct`

## Compliance Beyond Testing
- [ ] Documentation requirements understood (risk management, technical docs, record-keeping)
- [ ] Transparency obligations understood (inform users, mark AI content, detect deepfakes)
- [ ] Human oversight mechanisms in place (intervention, stop buttons, human review)
- [ ] Quality management system in place (post-market monitoring, incident reporting)
- [ ] Penalties understood (up to €35M / 7% turnover for prohibited practices)
- [ ] Timeline understood (6/12/24/36 months phased implementation)

## Cross-Framework (if applicable)
- [ ] Combined with GDPR (data protection applies alongside AI Act)
- [ ] Combined with ISO 42001 or NIST AI RMF

## Post-Run
- [ ] Per-article/category ASR documented
- [ ] Prohibited practice violations investigated (CRITICAL — €35M penalties)
- [ ] High-risk system failures investigated
- [ ] Mitigations documented
- [ ] Results shared with legal/compliance team
- [ ] Compliance assessment scheduled