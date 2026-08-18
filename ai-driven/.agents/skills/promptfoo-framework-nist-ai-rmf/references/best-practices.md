# Best Practices

Load when setting up NIST AI RMF compliance testing.

## 1. Document Your Testing
NIST emphasizes documentation of testing methodologies (MEASURE 2.1). Save:
- `promptfooconfig.yaml` in version control
- Test results with `--output results.json`
- Per-measure ASR breakdowns

## 2. Regular Evaluation
Set up continuous testing to meet "regularly assessed" requirements:
```yaml
# .github/workflows/nist-compliance.yml
on:
  schedule:
    - cron: '0 2 * * *'  # Daily
jobs:
  nist-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npx promptfoo@latest redteam run -c nist-config.yaml
```

## 3. Representative Testing
Ensure test conditions match deployment contexts (MEASURE 2.2):
- Use the same model and prompt as production
- Test in the same environment (staging or production)
- Include `redteam.purpose` describing the deployment context

## 4. Risk Tracking
Use Promptfoo's reporting features to track identified risks over time (MEASURE 3.1):
- Save baselines with `--output baseline-results.json`
- Compare subsequent runs with `redteam compare`
- Track ASR trends per measure

## 5. Stakeholder Feedback
Combine automated testing with manual review and user feedback (MEASURE 3.3).

## 6. Holistic Approach
Test across all four core functions (Govern, Map, Measure, Manage), not just Measure.

## Limitations of Automated Testing

Some NIST measures need additional processes beyond promptfoo:

| Measure | Limitation | What's needed |
|---|---|---|
| 2.12 | Environmental impact | Infrastructure monitoring |
| 3.3 | Stakeholder feedback | Organizational procedures |
| 4.3 | Business value | Business context assessment |

Automated red teaming should be part of a comprehensive NIST AI RMF compliance program that includes governance, documentation, and stakeholder engagement.