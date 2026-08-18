# Reporting — Interpreting Results

## Result categories

| Category | Meaning | Action |
|---|---|---|
| **Passed** (✓) | The model/target resisted the attack | Good — security boundary held |
| **Failed** (✗) | The adversarial payload succeeded | **Vulnerability found** — investigate and fix |
| **Error** | Target returned non-200, timeout, or grading failed | Check target availability, auth, rate limits |

## What "failed" means

A failed test = the grader (LLM judge) determined the target's response violated the security boundary defined in `redteam.purpose` or the plugin's policy. This means:
- The model followed injected instructions it shouldn't have
- The model revealed its system prompt
- The model exfiltrated PII
- The model called a tool with unauthorized arguments
- The model generated harmful content

## What "error" means

Errors are NOT security findings. They're infrastructure issues:
- HTTP 401 → auth expired (re-run auth setup, refresh cookie)
- HTTP 429 → rate limited (reduce `maxConcurrency` or add `delay`)
- Timeout → target too slow (increase `timeout` in config)
- "Invariant failed: Expected a JSON object" → multi-turn strategy (crescendo) got a refusal instead of structured output. This is the grader LLM refusing to generate the next attack step — **good sign for security, not a bug.**
- "returned a refusal during inference" → generation LLM (e.g., Claude) refused to generate adversarial content. Plugin skipped, 0 tests. Not a bug — the generation model is aligned.

## Viewing results

### Web UI

```bash
promptfoo redteam report
# or
promptfoo view
```

Opens a browser with:
- Summary table (pass/fail/error per plugin and strategy)
- Individual test details (payload, response, grader reasoning)
- Vulnerability breakdown by OWASP category
- Severity levels (critical/high/medium/low)

### YAML output

Results are saved to the `--output` path as YAML. Parse with:

```bash
# Count results by status
grep -c "pass: true" results.yaml   # passed
grep -c "pass: false" results.yaml  # failed

# List failed test descriptions
grep -B5 "pass: false" results.yaml | grep "description"
```

### HTML export

```bash
promptfoo redteam report --output report.html
```

## Common result patterns

### High pass rate (>90%) with few errors
- Model is well-aligned, resisting most attacks
- Check the failed tests for real vulnerabilities
- Errors are likely refusals during generation (good sign)

### High error rate (>50%) with few failures
- Likely crescendo/jailbreak strategy failing because grader LLM refuses to generate next attack step
- Check error log: if "Invariant failed: Expected a JSON object" → model refused to attack
- Not a security issue — the grader is behaving correctly

### High failure rate (>20%)
- **Real security issue** — multiple attack vectors succeeding
- Prioritize by severity (critical > high > medium > low)
- Fix the most critical first, re-run to verify

## Comparing runs (drift detection)

```bash
promptfoo redteam compare \
  --baseline baseline-results.yaml \
  --current current-results.yaml \
  --threshold 0.05
```

Fails if failure rate increased by more than 5% between runs. Use for CI/CD regression checks.

## Token usage

The scan summary shows token usage:
- **Probes**: tokens used sending payloads to your target
- **Grading**: tokens used by the grader LLM to judge responses
- **Generation**: tokens used generating adversarial test cases (if `redteam run` generated them)

With OpenRouter, all token costs are on your OpenRouter account.