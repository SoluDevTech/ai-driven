# ISO 42001 Domain Mappings

Load when targeting specific ISO 42001 risk domains.

## Comprehensive Testing

```yaml
redteam:
  plugins:
    - iso:42001
  strategies:
    - jailbreak-templates
    - jailbreak
    - base64
    - rot13
```

## 1. Accountability & Human Oversight (`iso:42001:accountability`)
```yaml
redteam:
  plugins:
    - iso:42001:accountability
# Or: excessive-agency, overreliance, hijacking
```

## 2. Fairness & Bias Prevention (`iso:42001:fairness`)
```yaml
redteam:
  plugins:
    - iso:42001:fairness
# Or: bias:age, bias:disability, bias:gender, bias:race, harmful:hate
```

## 3. Privacy & Data Protection (`iso:42001:privacy`)
```yaml
redteam:
  plugins:
    - iso:42001:privacy
# Or: harmful:privacy, pii:direct, pii:api-db, pii:session, pii:social
```

## 4. Robustness & Resilience (`iso:42001:robustness`)
```yaml
redteam:
  plugins:
    - iso:42001:robustness
# Or: ascii-smuggling, prompt-extraction
#     + strategies: jailbreak, jailbreak-templates
```

## 5. Security & Vulnerability Management (`iso:42001:security`)
```yaml
redteam:
  plugins:
    - iso:42001:security
# Or: shell-injection, sql-injection, ssrf, debug-access
#     + strategies: jailbreak, jailbreak-templates, base64, rot13
```

## 6. Safety & Ethical Use (`iso:42001:safety`)
```yaml
redteam:
  plugins:
    - iso:42001:safety
# Or: harmful:chemical-biological-weapons, harmful:child-exploitation,
#     harmful:violent-crime, harmful:cybercrime, harmful:cybercrime:malicious-code
#     + strategies: jailbreak, jailbreak-templates
```

## 7. Transparency & Trustworthiness (`iso:42001:transparency`)
```yaml
redteam:
  plugins:
    - iso:42001:transparency
# Or: harmful:misinformation-disinformation, hallucination, imitation,
#     unverifiable-claims, politics, religion
```