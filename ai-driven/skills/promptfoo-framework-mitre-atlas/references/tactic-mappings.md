# MITRE ATLAS Tactic Mappings

Load when targeting specific ATLAS tactics.

## Comprehensive Testing

```yaml
redteam:
  language: ['en', 'es', 'fr']  # Test in multiple languages
  plugins:
    - mitre:atlas
  strategies:
    - jailbreak
    - jailbreak-templates
    - base64
    - rot13
```

## All Tactics

| Tactic | Alias | Coverage |
|---|---|---|
| Reconnaissance | `mitre:atlas:reconnaissance` | Mapped |
| Resource Development | `mitre:atlas:resource-development` | Mapped |
| Initial Access | `mitre:atlas:initial-access` | Mapped |
| AI Model Access | `mitre:atlas:ai-model-access` | Coverage gap |
| Execution | `mitre:atlas:execution` | Mapped |
| Persistence | `mitre:atlas:persistence` | Mapped |
| Privilege Escalation | `mitre:atlas:privilege-escalation` | Mapped |
| Defense Evasion | `mitre:atlas:defense-evasion` | Mapped |
| Credential Access | `mitre:atlas:credential-access` | Mapped |
| Discovery | `mitre:atlas:discovery` | Mapped |
| Lateral Movement | `mitre:atlas:lateral-movement` | Mapped |
| Collection | `mitre:atlas:collection` | Mapped |
| AI Attack Staging | `mitre:atlas:ai-attack-staging` | Mapped |
| Command and Control | `mitre:atlas:command-and-control` | Mapped |
| Exfiltration | `mitre:atlas:exfiltration` | Mapped |
| Impact | `mitre:atlas:impact` | Mapped |

## Key Tactic Configs

### Reconnaissance
```yaml
redteam:
  plugins:
    - mitre:atlas:reconnaissance
# Or: competitors, policy, prompt-extraction, rbac
#     + language: ['en', 'es', 'fr']
```

### Resource Development
```yaml
redteam:
  plugins:
    - mitre:atlas:resource-development
# Or: harmful:cybercrime, harmful:illegal-drugs, harmful:indiscriminate-weapons
```

### Initial Access
```yaml
redteam:
  plugins:
    - mitre:atlas:initial-access
# Or: debug-access, harmful:cybercrime, indirect-prompt-injection, mcp,
#     shell-injection, sql-injection, ssrf
#     + strategies: base64, jailbreak, leetspeak, jailbreak-templates, rot13
```

### AI Attack Staging
```yaml
redteam:
  plugins:
    - mitre:atlas:ai-attack-staging
# Or: ascii-smuggling, excessive-agency, hallucination, indirect-prompt-injection
#     + strategies: jailbreak, jailbreak:tree
```

### Exfiltration
```yaml
redteam:
  plugins:
    - mitre:atlas:exfiltration
# Or: ascii-smuggling, harmful:privacy, indirect-prompt-injection,
#     pii:api-db, pii:direct, pii:session, pii:social, prompt-extraction
```

### Impact
```yaml
redteam:
  plugins:
    - mitre:atlas:impact
# Or: excessive-agency, harmful, hijacking, imitation
#     + strategies: crescendo
```

## Targeting Specific Tactics

```yaml
redteam:
  plugins:
    - mitre:atlas:reconnaissance
    - mitre:atlas:persistence
    - mitre:atlas:credential-access
  strategies:
    - jailbreak
    - jailbreak-templates
```