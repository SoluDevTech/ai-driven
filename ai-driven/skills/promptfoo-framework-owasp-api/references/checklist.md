# Checklist

Run before declaring OWASP API Security testing done.

## Pre-Flight
- [ ] `owasp:api` plugin selected (comprehensive) OR specific API01-API10 targeted
- [ ] Strategies selected (`jailbreak`, `jailbreak-templates`)
- [ ] Target has API/function-calling/tool access

## Risk Selection
- [ ] **API1 BOLA** — `bola`, `rbac`
- [ ] **API2 Broken Auth** — `bfla`, `rbac`
- [ ] **API3 Property Level** — `excessive-agency`, `overreliance`
- [ ] **API4 Resource Consumption** — `harmful:privacy`, `pii:api-db`, `pii:session`
- [ ] **API5 BFLA** — `bfla`, `bola`, `rbac`
- [ ] **API6 Business Flows** — `harmful:misinformation-disinformation`, `overreliance`
- [ ] **API7 SSRF** — `shell-injection`, `sql-injection`
- [ ] **API8 Misconfiguration** — `harmful:privacy`, `pii:api-db`, `pii:session`
- [ ] **API9 Inventory** — `harmful:specialized-advice`, `overreliance`
- [ ] **API10 Unsafe Consumption** — `debug-access`, `harmful:privacy`

## Best Practices
- [ ] Authorization at both LLM and API layers
- [ ] Principle of least privilege for LLM tool access
- [ ] LLM output validation before API calls
- [ ] Token-based + API call rate limits
- [ ] LLM-initiated API call monitoring

## Post-Run
- [ ] Per-risk ASR documented (API01-API10)
- [ ] BOLA/BFLA failures investigated (unauthorized access?)
- [ ] SSRF failures investigated (unauthorized requests?)
- [ ] Combined with OWASP LLM Top 10 if needed
- [ ] Mitigations documented