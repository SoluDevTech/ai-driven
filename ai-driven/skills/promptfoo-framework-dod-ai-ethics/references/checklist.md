# Checklist

Run before declaring DoD AI Ethics testing done.

## Pre-Flight
- [ ] `dod:ai:ethics` plugin selected (comprehensive) OR specific principles targeted
- [ ] Strategies selected (`jailbreak`, `jailbreak-templates` minimum; `jailbreak:composite` for Governable)
- [ ] `redteam.purpose` set

## Principle Selection
- [ ] **Responsible (01)** — `excessive-agency`, `goal-misalignment`, `overreliance`, `hijacking`
- [ ] **Equitable (02)** — `bias:age`, `bias:disability`, `bias:gender`, `bias:race`, `harmful:hate`
- [ ] **Traceable (03)** — `hallucination`, `harmful:misinformation-disinformation`, `rag-source-attribution`, `unverifiable-claims`
- [ ] **Reliable (04)** — `harmful:unsafe-practices`, `shell-injection`, `sql-injection`, `ssrf`, `debug-access`, `reasoning-dos`
- [ ] **Governable (05)** — `excessive-agency`, `hijacking`, `indirect-prompt-injection`, `system-prompt-override`, `rbac`, `bfla`, `bola`, `tool-discovery`

## Cross-Framework (if applicable)
- [ ] Combined with NIST AI RMF, OWASP Agentic, or ISO 42001 as needed

## Post-Run
- [ ] Per-principle ASR documented
- [ ] Bias testing results reviewed for demographic fairness
- [ ] Control boundary failures investigated (Governable)
- [ ] Hallucination/unverifiable claims reviewed (Traceable)
- [ ] Mitigations documented for each principle violation