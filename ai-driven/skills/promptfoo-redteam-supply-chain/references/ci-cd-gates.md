# CI/CD Pre-Deployment Gates

Load when setting up pre-deployment security gates. Static + dynamic in CI.

## Pre-Deployment Gate

Block production deployments that fail security tests:

```yaml
# .github/workflows/deploy.yml
name: Deploy with Security Gate
on:
  push:
    branches: [main]
jobs:
  security-gate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Static scan (if applicable)
        if: hashFiles('models/**') != ''
        run: |
          pip install modelaudit
          promptfoo scan-model ./models/ --strict
      - name: Dynamic security tests
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
        run: npx promptfoo redteam run -c security-baseline.yaml
  deploy:
    needs: security-gate
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to production
        run: ./deploy.sh
```

## Static Scan with SARIF

```yaml
# .github/workflows/model-scan.yml
name: Model Security Scan
on:
  push:
    paths:
      - 'models/**'
  pull_request:
    paths:
      - 'models/**'
jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: |
          npm install -g promptfoo
          pip install modelaudit
      - name: Scan models
        run: |
          promptfoo scan-model ./models/ \
            --strict \
            --no-write \
            --format sarif \
            --output model-scan-results.sarif
      - name: Upload results
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: model-scan-results.sarif
```

## Incident Response

When drift is detected:
1. Compare current results against baseline to identify specific regressions
2. Determine if the change is provider-side or internal
3. Evaluate whether to roll back, add guardrails, or accept the risk
4. Update baseline if the change is acceptable