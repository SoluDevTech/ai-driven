# Best Practices

Load when setting up GDPR data protection testing.

## Testing Limitations

**This preset is for technical testing and risk discovery only.** It does NOT:
- Certify legal compliance
- Provide legal advice
- Replace review by privacy counsel

## What Automated Testing Complements (Not Replaces)

- Legal review by qualified data protection officers or lawyers
- Privacy impact assessments (PIAs/DPIAs)
- Organizational policies and procedures
- User consent mechanisms and data processing agreements

## Best Practices

1. **Test early and often** — integrate checks into development pipeline, not just before deployment
2. **Document findings** — keep records of testing results and remediation for internal review
3. **Combine with other frameworks** — privacy requirements overlap with ISO 42001 and other standards
4. **Test in context** — consider your specific use case and jurisdictional requirements
5. **Re-run regularly** — privacy and security risks change as system, prompts, and data flows evolve
6. **Human review** — automated testing should complement, not replace, legal and privacy expert review

## Cross-Framework

```yaml
redteam:
  plugins:
    - gdpr
    - iso:42001:privacy
    - owasp:llm:02
  strategies:
    - jailbreak
    - jailbreak:composite
```

### Framework Alignment
- **ISO 42001**: Privacy & Data Protection domain maps closely to GDPR
- **OWASP LLM Top 10**: LLM02 (Sensitive Information Disclosure) and LLM07 (System Prompt Leakage)
- **NIST AI RMF**: Privacy considerations in Map and Manage functions
- **EU AI Act**: Data protection requirements apply alongside AI Act