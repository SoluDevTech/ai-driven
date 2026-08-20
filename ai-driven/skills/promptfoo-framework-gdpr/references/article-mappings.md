# GDPR Article Mappings

Load when targeting specific GDPR articles.

## Comprehensive Testing

```yaml
redteam:
  plugins:
    - gdpr
  strategies:
    - jailbreak
    - jailbreak:composite
```

## Article 5: Processing Principles (`gdpr:art5`)
Lawfulness, fairness, transparency, purpose limitation, data minimization, accuracy, storage limitation, integrity, confidentiality.

```yaml
redteam:
  plugins:
    - gdpr:art5
# Or: harmful:privacy, pii:api-db, pii:direct, pii:session, pii:social,
#     hallucination, harmful:misinformation-disinformation
```

## Article 9: Special Categories (`gdpr:art9`)
Health, genetic, biometric, racial, political, religious, trade union, sex life/orientation.

```yaml
redteam:
  plugins:
    - gdpr:art9
# Or: pii:direct, pii:social, harmful:privacy,
#     bias:age, bias:disability, bias:gender, bias:race
```

## Article 15: Right of Access (`gdpr:art15`)
Confirmation of processing, access to data, information about purposes.

```yaml
redteam:
  plugins:
    - gdpr:art15
# Or: pii:api-db, pii:session, rbac, bola, bfla
```

## Article 17: Right to Erasure (`gdpr:art17`)
"Right to be forgotten" — challenging for AI (training data in weights, cached responses).

```yaml
redteam:
  plugins:
    - gdpr:art17
# Or: pii:api-db, pii:direct, pii:session, harmful:privacy, cross-session-leak
```

## Article 22: Automated Decision-Making (`gdpr:art22`)
Human oversight, explainability, non-discrimination for decisions with legal effects.

```yaml
redteam:
  plugins:
    - gdpr:art22
# Or: bias:age, bias:disability, bias:gender, bias:race, harmful:hate,
#     overreliance, hallucination
```

## Article 25: Data Protection by Design (`gdpr:art25`)
Privacy by design, data minimization by default, privacy-enhancing technologies.

```yaml
redteam:
  plugins:
    - gdpr:art25
# Or: harmful:privacy, pii:api-db, pii:direct, pii:session, pii:social, prompt-extraction
```

## Article 32: Security of Processing (`gdpr:art32`)
Pseudonymization, encryption, confidentiality, integrity, availability, resilience.

```yaml
redteam:
  plugins:
    - gdpr:art32
# Or: shell-injection, sql-injection, ssrf, debug-access, harmful:cybercrime, rbac, bfla, bola
```