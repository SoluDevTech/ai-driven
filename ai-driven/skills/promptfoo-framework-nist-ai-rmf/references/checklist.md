# Checklist

Run before declaring NIST AI RMF compliance testing done.

## Pre-Flight
- [ ] `nist:ai:measure` plugin selected (comprehensive) OR specific measures targeted
- [ ] `redteam.purpose` set describing the AI system's intended use and deployment context
- [ ] Strategies selected (`jailbreak`, `jailbreak-templates` minimum)
- [ ] Target configured with consistent `label` for tracking

## Measure Selection
- [ ] **2.4 Safety** — `excessive-agency`, `harmful:misinformation-disinformation` + jailbreak strategies
- [ ] **2.6 Misuse** — `harmful:chemical-biological-weapons`, `harmful:indiscriminate-weapons`, `harmful:unsafe-practices`
- [ ] **2.7 Security** — `harmful:cybercrime`, `shell-injection`, `sql-injection` + jailbreak strategies
- [ ] **2.8 Privacy** — `bfla`, `bola`, `rbac`
- [ ] **2.10 Privacy Risk** — `harmful:privacy`, `pii:api-db`, `pii:direct`, `pii:session`, `pii:social`
- [ ] **2.11 Fairness** — `harmful:harassment-bullying`, `harmful:hate`, `harmful:insults`
- [ ] Other measures as needed (1.1, 1.2, 2.1, 2.2, 2.3, 2.5, 2.9, 2.13, 3.1-3.3, 4.1-4.3)

## Cross-Framework (if applicable)
- [ ] Combined with OWASP LLM Top 10, GDPR, EU AI Act, or ISO 42001 as needed

## Documentation
- [ ] `promptfooconfig.yaml` saved in version control
- [ ] Test results saved with `--output results.json`
- [ ] Per-measure ASR documented
- [ ] Testing methodology documented (MEASURE 2.1)

## Continuous Testing
- [ ] CI/CD workflow scheduled for regular evaluation
- [ ] Baseline saved for drift comparison
- [ ] ASR trends tracked per measure over time

## Limitations Acknowledged
- [ ] MEASURE 2.12 (environmental impact) — needs infrastructure monitoring
- [ ] MEASURE 3.3 (stakeholder feedback) — needs organizational procedures
- [ ] MEASURE 4.3 (business value) — needs business context
- [ ] Automated testing is part of a comprehensive compliance program