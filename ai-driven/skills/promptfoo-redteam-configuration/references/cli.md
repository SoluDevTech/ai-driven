# CLI Reference — Local Red Team Scans

## Prerequisites

```bash
# Required env vars
export CI=true                              # Skip email verification (THE critical one)
export OPENROUTER_API_KEY="sk-or-v1-..."    # No underscore between OPEN and ROUTER

# Optional (for HTTP targets behind oauth2-proxy)
export API_URL="http://localhost:8000"
export OAUTH_COOKIE="n-lhQ7khTYc..."
```

## Generate adversarial tests only

```bash
# Generate with a specific provider (only for `generate`, not `run`)
promptfoo redteam generate \
  -c redteam/promptfoo/config.yaml \
  --provider openrouter:anthropic/claude-haiku-4.5 \
  -o redteam/reports/promptfoo/tests.yaml \
  --no-cache
```

## Run full scan (generate + eval)

```bash
# NOTE: --provider is NOT accepted by `redteam run`
# Set the provider in the config's redteam.provider field instead
promptfoo redteam run \
  -c redteam/promptfoo/config.yaml \
  --output redteam/reports/promptfoo/results.yaml \
  --no-cache
```

## Run eval only (with pre-generated tests)

```bash
promptfoo redteam eval \
  -c redteam/reports/promptfoo/generated-tests.yaml \
  --output redteam/reports/promptfoo/eval-results.yaml
```

## View results

```bash
# Web UI (opens browser)
promptfoo redteam report

# Or open specific results
promptfoo view
```

## Scope to specific plugins

```bash
# Only run certain plugins
promptfoo redteam generate \
  -c config.yaml \
  --plugins 'hijacking,pii,prompt-extraction'
```

## Force regeneration

```bash
promptfoo redteam run -c config.yaml --force --no-cache
```

## Verbose / debug

```bash
promptfoo redteam run -c config.yaml --verbose --no-cache 2>&1 | tee scan.log
```

## List available plugins

```bash
promptfoo redteam plugins
```

## List available strategies

```bash
promptfoo redteam strategies
```

## npm script isolation

### package.json

```json
{
  "scripts": {
    "test": "npx playwright test",
    "redteam:chat": "promptfoo redteam run -c redteam/promptfoo/chat.yaml --output redteam/reports/promptfoo/chat-results.yaml --no-cache",
    "redteam:cv": "promptfoo redteam run -c redteam/promptfoo/cv.yaml --output redteam/reports/promptfoo/cv-results.yaml --no-cache",
    "redteam:studio": "promptfoo redteam run -c redteam/promptfoo/studio.yaml --output redteam/reports/promptfoo/studio-results.yaml --no-cache",
    "redteam:search": "promptfoo redteam run -c redteam/promptfoo/search.yaml --output redteam/reports/promptfoo/search-results.yaml --no-cache",
    "redteam:all": "npm run redteam:chat && npm run redteam:cv && npm run redteam:studio && npm run redteam:search",
    "redteam:report": "promptfoo redteam report"
  }
}
```

### Running

```bash
# Normal tests (Playwright) — NEVER runs promptfoo
npm test

# Red team only — NEVER runs Playwright
npm run redteam:all

# Single surface
npm run redteam:chat

# View report
npm run redteam:report
```

### Isolation rules
- Configs live in `redteam/promptfoo/` — NOT at repo root, NOT in `specs/`
- Never put `promptfooconfig.yaml` at repo root (promptfoo auto-discovers it)
- Scripts prefixed `redteam:` only invoke promptfoo
- `npm test` only invokes Playwright

## Background execution (long scans)

```bash
# Run in background (for scans > 30 min)
nohup promptfoo redteam run -c config.yaml --output results.yaml --no-cache > scan.log 2>&1 &

# Monitor progress
tail -f scan.log

# Check if still running
ps aux | grep "promptfoo redteam" | grep -v grep
```

## Environment loading

```bash
# Load env vars from .env.local before running
export $(grep -v '^#' redteam/.env.local | xargs)

# Or use promptfoo's --env-file flag
promptfoo redteam run -c config.yaml --env-file redteam/.env.local
```