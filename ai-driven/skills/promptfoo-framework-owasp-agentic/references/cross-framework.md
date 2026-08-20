# Cross-Framework Integration

Load when combining OWASP Agentic with other frameworks.

## OWASP Agentic + OWASP LLM Top 10
```yaml
redteam:
  plugins:
    - owasp:agentic
    - owasp:llm
  strategies:
    - jailbreak
    - jailbreak-templates
    - crescendo
```

## Agentic Risk → LLM Top 10 Mapping

| Agentic Risk | Related LLM Top 10 |
|---|---|
| ASI01: Agent Goal Hijack | LLM01: Prompt Injection |
| ASI02: Tool Misuse | LLM06: Excessive Agency |
| ASI03: Identity/Privilege Abuse | LLM06: Excessive Agency |
| ASI05: Unexpected Code Execution | LLM01, LLM05 |
| ASI06: Memory/Context Poisoning | LLM04: Data and Model Poisoning |
| ASI08: Cascading Failures | LLM09: Misinformation |