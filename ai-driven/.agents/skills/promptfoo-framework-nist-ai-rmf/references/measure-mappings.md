# NIST AI RMF Measure Mappings

Load when targeting specific NIST AI RMF measures. Each measure maps to specific plugins.

## Comprehensive Testing

```yaml
redteam:
  plugins:
    - nist:ai:measure
  strategies:
    - jailbreak
    - jailbreak-templates
```

## MEASURE 1: Measurement Approaches

### 1.1 & 1.2 — Measurement Approaches
```yaml
redteam:
  plugins:
    - nist:ai:measure:1.1
    - nist:ai:measure:1.2
# Or equivalent:
#   - excessive-agency
#   - harmful:misinformation-disinformation
```

## MEASURE 2: Trustworthy Characteristics

### 2.1 & 2.2 — Test Documentation
```yaml
redteam:
  plugins:
    - nist:ai:measure:2.1
    - nist:ai:measure:2.2
# Or: harmful:privacy, pii:api-db, pii:direct, pii:session, pii:social
```

### 2.3 & 2.5 — Performance Validation
```yaml
redteam:
  plugins:
    - nist:ai:measure:2.3
    - nist:ai:measure:2.5
# Or: excessive-agency
```

### 2.4 — Safety Risk Evaluation (CRITICAL)
```yaml
redteam:
  plugins:
    - nist:ai:measure:2.4
# Or: excessive-agency, harmful:misinformation-disinformation
#     + strategies: jailbreak, jailbreak-templates
```

### 2.6 — Misuse and Abuse Potential
```yaml
redteam:
  plugins:
    - nist:ai:measure:2.6
# Or: harmful:chemical-biological-weapons, harmful:indiscriminate-weapons, harmful:unsafe-practices
```

### 2.7 — Security and Resilience
```yaml
redteam:
  plugins:
    - nist:ai:measure:2.7
# Or: harmful:cybercrime, shell-injection, sql-injection
#     + strategies: jailbreak, jailbreak-templates
```

### 2.8 — Privacy and Data Protection
```yaml
redteam:
  plugins:
    - nist:ai:measure:2.8
# Or: bfla, bola, rbac
```

### 2.9 & 2.13 — Risk Assessment and Transparency
```yaml
redteam:
  plugins:
    - nist:ai:measure:2.9
    - nist:ai:measure:2.13
# Or: excessive-agency
```

### 2.10 — Privacy Risk Assessment
```yaml
redteam:
  plugins:
    - nist:ai:measure:2.10
# Or: harmful:privacy, pii:api-db, pii:direct, pii:session, pii:social
```

### 2.11 — Fairness and Bias
```yaml
redteam:
  plugins:
    - nist:ai:measure:2.11
# Or: harmful:harassment-bullying, harmful:hate, harmful:insults
```

## MEASURE 3: Risk Tracking

### 3.1-3.3 — Risk Tracking
```yaml
redteam:
  plugins:
    - nist:ai:measure:3.1
    - nist:ai:measure:3.2
    - nist:ai:measure:3.3
# Or: excessive-agency, harmful:misinformation-disinformation
#     + strategies: jailbreak, jailbreak-templates
```

## MEASURE 4: Impact Measurement

### 4.1-4.3 — Impact Measurement
```yaml
redteam:
  plugins:
    - nist:ai:measure:4.1
    - nist:ai:measure:4.2
    - nist:ai:measure:4.3
# Or: excessive-agency, harmful:misinformation-disinformation
```

## Targeting Specific Measures

```yaml
redteam:
  plugins:
    - nist:ai:measure:2.4  # Safety risks
    - nist:ai:measure:2.7  # Security and resilience
    - nist:ai:measure:2.11 # Fairness and bias
  strategies:
    - jailbreak
    - jailbreak-templates
```