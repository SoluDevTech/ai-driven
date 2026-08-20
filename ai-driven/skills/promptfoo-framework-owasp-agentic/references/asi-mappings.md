# OWASP Agentic ASI Mappings

Load when targeting specific OWASP Agentic risks.

## Comprehensive Testing

```yaml
redteam:
  plugins:
    - owasp:agentic
  strategies:
    - jailbreak
    - jailbreak-templates
    - crescendo
```

## ASI01: Agent Goal Hijack
Attackers alter agent objectives through malicious content.

```yaml
redteam:
  plugins:
    - owasp:agentic:asi01
# Or: hijacking, system-prompt-override, indirect-prompt-injection, intent
#     + strategies: jailbreak, jailbreak-templates, jailbreak:composite
```

## ASI02: Tool Misuse and Exploitation
Agents use legitimate tools in unsafe ways.

```yaml
redteam:
  plugins:
    - owasp:agentic:asi02
# Or: excessive-agency, mcp, tool-discovery
```

## ASI03: Identity and Privilege Abuse
Agents inherit or escalate high-privilege credentials.

```yaml
redteam:
  plugins:
    - owasp:agentic:asi03
# Or: rbac, bfla, bola, imitation
```

## ASI04: Agentic Supply Chain Vulnerabilities
Compromised tools, plugins, prompt templates, external servers.

```yaml
redteam:
  plugins:
    - owasp:agentic:asi04
# Or: indirect-prompt-injection, mcp
#     + strategies: jailbreak-templates
```

## ASI05: Unexpected Code Execution
Agents generate or run code/commands unsafely.

```yaml
redteam:
  plugins:
    - owasp:agentic:asi05
# Or: shell-injection, sql-injection, harmful:cybercrime:malicious-code, ssrf
```

## ASI06: Memory and Context Poisoning
Attackers poison agent memory, embeddings, RAG databases.

```yaml
redteam:
  plugins:
    - owasp:agentic:asi06
# Or: agentic:memory-poisoning, cross-session-leak, indirect-prompt-injection
#     + strategies: jailbreak, crescendo
```

## ASI07: Insecure Inter-Agent Communication
Multi-agent spoofing, replayed messages, tampering.

```yaml
redteam:
  plugins:
    - owasp:agentic:asi07
# Or: indirect-prompt-injection, hijacking, imitation
```

## ASI08: Cascading Failures
Small errors propagate across planning, execution, memory.

```yaml
redteam:
  plugins:
    - owasp:agentic:asi08
# Or: hallucination, harmful:misinformation-disinformation, divergent-repetition
```

## ASI09: Human Agent Trust Exploitation
Users over-trust agent recommendations.

```yaml
redteam:
  plugins:
    - owasp:agentic:asi09
# Or: overreliance, imitation, harmful:misinformation-disinformation
#     + strategies: crescendo
```

## ASI10: Rogue Agents
Compromised agents act harmfully while appearing legitimate.

```yaml
redteam:
  plugins:
    - owasp:agentic:asi10
# Or: excessive-agency, hijacking, rbac, goal-misalignment
#     + strategies: jailbreak, crescendo
```