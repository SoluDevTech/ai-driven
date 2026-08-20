# Checklist

Run before declaring MITRE ATLAS testing done.

## Pre-Flight
- [ ] `mitre:atlas` plugin selected (comprehensive) OR specific tactics targeted
- [ ] Strategies selected (`jailbreak`, `jailbreak-templates`, `base64`, `rot13`)
- [ ] `language: ['en', 'es', 'fr']` set for multi-language reconnaissance testing

## Tactic Selection
- [ ] **Reconnaissance** — `competitors`, `policy`, `prompt-extraction`, `rbac`
- [ ] **Resource Development** — `harmful:cybercrime`, `harmful:illegal-drugs`, `harmful:indiscriminate-weapons`
- [ ] **Initial Access** — `debug-access`, `indirect-prompt-injection`, `mcp`, `shell-injection`, `sql-injection`, `ssrf`
- [ ] **AI Attack Staging** — `ascii-smuggling`, `excessive-agency`, `hallucination`, `indirect-prompt-injection`
- [ ] **Exfiltration** — `ascii-smuggling`, `harmful:privacy`, `pii:*`, `prompt-extraction`
- [ ] **Impact** — `excessive-agency`, `harmful`, `hijacking`, `imitation`
- [ ] Other tactics as needed (execution, persistence, privilege escalation, defense evasion, credential access, discovery, lateral movement, collection, C2)

## Best Practices
- [ ] Attack lifecycle tested (not just individual tactics)
- [ ] Tactics combined as adversaries would
- [ ] Defense in depth across multiple stages

## Post-Run
- [ ] Per-tactic ASR documented
- [ ] Attack chain scenarios documented (reconnaissance → exfiltration → impact)
- [ ] Reconnaissance failures investigated (prompt extraction, tool discovery)
- [ ] Exfiltration failures investigated (PII leaks, cross-session leaks)
- [ ] Impact failures investigated (hijacking, harmful content)
- [ ] Mitigations documented per tactic
- [ ] Purple team review if applicable