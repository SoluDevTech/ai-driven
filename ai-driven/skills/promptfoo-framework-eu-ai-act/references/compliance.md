# Compliance Requirements

Load for EU AI Act compliance beyond automated testing.

## Penalties for Non-Compliance

| Violation | Fine |
|---|---|
| Prohibited practices (Article 5) | Up to €35M or 7% of global annual turnover |
| High-risk requirements violations | Up to €15M or 3% of global annual turnover |
| Incorrect information to authorities | Up to €7.5M or 1% of global annual turnover |

## Timeline (Phased Implementation)

| Phase | Timeline |
|---|---|
| Prohibited practices (Article 5) | 6 months |
| General-purpose AI rules | 12 months |
| High-risk system requirements (Annex III) | 24 months |
| Full application | 36 months |

## Compliance Requirements Beyond Testing

### Documentation
- Risk management system
- Technical documentation
- Record-keeping of operations
- Instructions for use

### Transparency Obligations
- Inform users when interacting with AI
- Mark AI-generated content
- Detect deepfakes

### Human Oversight
- Human intervention capabilities
- Stop buttons or disabling mechanisms
- Human review of high-risk decisions

### Quality Management
- Post-market monitoring system
- Incident reporting procedures
- Compliance assessment

## Cross-Framework

```yaml
redteam:
  plugins:
    - eu:ai-act
    - gdpr
    - iso:42001
  strategies:
    - jailbreak
    - jailbreak-templates
```

### Framework Alignment
- **GDPR**: Data protection requirements apply alongside AI Act
- **ISO 42001**: International standard for AI management systems
- **NIST AI RMF**: Similar risk-based approach to AI governance