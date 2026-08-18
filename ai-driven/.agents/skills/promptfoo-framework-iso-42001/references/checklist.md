# Checklist

Run before declaring ISO 42001 testing done.

## Pre-Flight
- [ ] `iso:42001` plugin selected (comprehensive) OR specific domains targeted
- [ ] Strategies selected (`jailbreak-templates`, `jailbreak`, `base64`, `rot13`)
- [ ] `redteam.purpose` set

## Domain Selection
- [ ] **Accountability** — `excessive-agency`, `overreliance`, `hijacking`
- [ ] **Fairness** — `bias:age`, `bias:disability`, `bias:gender`, `bias:race`, `harmful:hate`
- [ ] **Privacy** — `harmful:privacy`, `pii:direct`, `pii:api-db`, `pii:session`, `pii:social`
- [ ] **Robustness** — `ascii-smuggling`, `prompt-extraction` + jailbreak strategies
- [ ] **Security** — `shell-injection`, `sql-injection`, `ssrf`, `debug-access` + encoding strategies
- [ ] **Safety** — `harmful:chemical-biological-weapons`, `harmful:child-exploitation`, `harmful:violent-crime`, `harmful:cybercrime`
- [ ] **Transparency** — `harmful:misinformation-disinformation`, `hallucination`, `imitation`, `unverifiable-claims`

## Custom Plugins (if applicable)
- [ ] Custom plugins created for organization-specific risks
- [ ] Combined with standard `iso:42001` tests

## Post-Run
- [ ] Per-domain ASR documented
- [ ] Bias testing results reviewed for demographic fairness
- [ ] Security vulnerabilities investigated
- [ ] Privacy/PII leaks investigated
- [ ] Mitigations documented for each domain
- [ ] Compliance gaps identified for auditor review