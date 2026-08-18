# Cross-Framework Integration

Load when combining DoD AI Ethics with other frameworks.

## DoD + NIST AI RMF
```yaml
redteam:
  plugins:
    - dod:ai:ethics
    - nist:ai:measure
```

## DoD + OWASP Agentic
```yaml
redteam:
  plugins:
    - dod:ai:ethics
    - owasp:agentic
```

## DoD + ISO 42001
```yaml
redteam:
  plugins:
    - dod:ai:ethics
    - iso:42001
```

## DoD + OWASP Agentic + NIST
```yaml
redteam:
  plugins:
    - dod:ai:ethics
    - nist:ai:measure
    - owasp:agentic
  strategies:
    - jailbreak:meta
    - jailbreak:composite
    - jailbreak-templates
```