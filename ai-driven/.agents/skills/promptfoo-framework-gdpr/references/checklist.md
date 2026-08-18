# Checklist

Run before declaring GDPR data protection testing done.

## Pre-Flight
- [ ] `gdpr` plugin selected (comprehensive) OR specific articles targeted
- [ ] Strategies selected (`jailbreak`, `jailbreak:composite`)
- [ ] **Understood**: this is technical testing, NOT legal compliance certification

## Article Selection
- [ ] **Art 5 Processing Principles** — `harmful:privacy`, `pii:*`, `hallucination`, `harmful:misinformation-disinformation`
- [ ] **Art 9 Special Categories** — `pii:direct`, `pii:social`, `harmful:privacy`, `bias:*`
- [ ] **Art 15 Right of Access** — `pii:api-db`, `pii:session`, `rbac`, `bola`, `bfla`
- [ ] **Art 17 Right to Erasure** — `pii:api-db`, `pii:direct`, `pii:session`, `harmful:privacy`, `cross-session-leak`
- [ ] **Art 22 Automated Decisions** — `bias:*`, `harmful:hate`, `overreliance`, `hallucination`
- [ ] **Art 25 Data Protection by Design** — `harmful:privacy`, `pii:*`, `prompt-extraction`
- [ ] **Art 32 Security of Processing** — `shell-injection`, `sql-injection`, `ssrf`, `debug-access`, `harmful:cybercrime`, `rbac`, `bfla`, `bola`

## Custom Plugins (if applicable)
- [ ] Custom plugins created for data subject rights requests
- [ ] Combined with standard `gdpr` tests

## Legal Review
- [ ] Results shared with DPO/privacy counsel for legal review
- [ ] Privacy impact assessment (PIA/DPIA) referenced
- [ ] Testing complements (not replaces) legal review

## Cross-Framework (if applicable)
- [ ] Combined with ISO 42001, OWASP LLM Top 10, NIST AI RMF, or EU AI Act

## Post-Run
- [ ] Per-article ASR documented
- [ ] PII leak failures investigated
- [ ] Cross-session leakage investigated (Art 17)
- [ ] Bias in automated decisions investigated (Art 22)
- [ ] Security vulnerabilities investigated (Art 32)
- [ ] Mitigations documented
- [ ] Results shared with legal/privacy team