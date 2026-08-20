# Cross-Framework Integration

Load when combining NIST AI RMF with other frameworks.

## NIST + OWASP LLM Top 10
```yaml
redteam:
  plugins:
    - nist:ai:measure
    - owasp:llm
  strategies:
    - jailbreak
    - jailbreak-templates
```

## NIST + GDPR
```yaml
redteam:
  plugins:
    - nist:ai:measure
    - gdpr
  strategies:
    - jailbreak
    - jailbreak-templates
```

## NIST + EU AI Act
```yaml
redteam:
  plugins:
    - nist:ai:measure
    - eu:ai-act
  strategies:
    - jailbreak
    - jailbreak-templates
```

## NIST + ISO 42001
```yaml
redteam:
  plugins:
    - nist:ai:measure
    - iso:42001
  strategies:
    - jailbreak
    - jailbreak-templates
```

## All Frameworks Combined
```yaml
redteam:
  plugins:
    - nist:ai:measure
    - owasp:llm
    - gdpr
    - eu:ai-act
    - iso:42001
  strategies:
    - jailbreak
    - jailbreak-templates
```

## Framework Alignment

- **ISO 42001**: Both frameworks emphasize risk management and trustworthy AI
- **OWASP LLM Top 10**: NIST measures map to specific OWASP vulnerabilities
- **GDPR**: Privacy measures (2.8, 2.10) align with GDPR requirements
- **EU AI Act**: Both frameworks address safety, fairness, and transparency