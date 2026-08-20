# CLI Reference

Full command reference for the promptfoo red team CLI.

## Scaffold

```bash
npx promptfoo@latest redteam init my-redteam-project --no-gui
```
Creates `promptfooconfig.yaml` with useful defaults.

## Generate Adversarial Tests

```bash
npx promptfoo@latest redteam generate
```
- Reads prompts + targets, generates adversarial inputs.
- Takes ~5 min.
- Writes tests to `promptfooconfig.yaml` or `redteam.yaml`.

### Scope to specific plugins
```bash
npx promptfoo@latest redteam generate --plugins 'harmful,hijacking'
```

## Run the Pentest

```bash
npx promptfoo@latest redteam eval
```
- Runs existing adversarial tests against targets.
- Takes ~15 min for default plugins.

## Generate + Run in One Step

```bash
npx promptfoo@latest redteam run
```

### With specific config
```bash
npx promptfoo@latest redteam run -c path/to/config.yaml
```

### Save results
```bash
npx promptfoo@latest redteam run --output results.json
```

### Pass variables
```bash
npx promptfoo@latest redteam run --var CANDIDATE_MODEL=anthropic:claude-sonnet-4-6
```

### Force regeneration (drift detection)
```bash
npx promptfoo@latest redteam run --force
```
Regenerates tests with latest attack patterns. Use weekly; use `redteam eval` daily for apples-to-apples drift comparison.

## View Results

```bash
npx promptfoo@latest redteam report
```
Opens the vulnerability report in the web viewer.

```bash
npx promptfoo@latest redteam report --output report.html
```
Generates an HTML report.

```bash
npx promptfoo@latest view
```
Opens the web viewer with detailed test results.

## Compare Results (Drift Detection)

```bash
npx promptfoo@latest redteam compare \
  --baseline baseline-results.json \
  --current current-results.json \
  --threshold 0.05
```
Fails if failure rate increased by more than 5%.

## Standard Eval (Custom Tests)

```bash
npx promptfoo@latest eval -c promptfooconfig.yaml -o results.json
```
For custom test cases (not red team generated).

## Scaffold Examples

```bash
npx promptfoo@latest init --example redteam-mcp-agent
npx promptfoo@latest init --example redteam-multi-modal
npx promptfoo@latest init --example redteam-foundation-model
npx promptfoo@latest init --example redteam-multi-input
npx promptfoo@latest init --example redteam-docx-document-upload
```