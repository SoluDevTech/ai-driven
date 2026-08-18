# Environment Setup — Full Checklist

## Required env vars for fully local red team scans

```bash
# ── CRITICAL: Skip email verification ──
export CI=true

# ── CRITICAL: Generation + grading provider ──
# NOTE: no underscore between OPEN and ROUTER
export OPENROUTER_API_KEY="sk-or-v1-..."

# ── If your project uses OPEN_ROUTER_API_KEY (with underscore), alias it ──
# export OPENROUTER_API_KEY="$OPEN_ROUTER_API_KEY"

# ── Target API URL (for HTTP targets) ──
export PICKPRO_API_URL="http://localhost:8000"

# ── OAuth2 proxy cookie (for cookie-auth targets) ──
# Extract from Playwright storage-state.json after auth setup
export PICKPRO_OAUTH_COOKIE="n-lhQ7khTYc2X6RQlwVj..."

# ── OPTIONAL: Disable remote generation (NOT recommended — loses 60%+ of plugins) ──
# export PROMPTFOO_DISABLE_REMOTE_GENERATION=1  # DON'T USE THIS — use CI=true instead

# ── OPTIONAL: Point remote generation to a self-hosted endpoint ──
# export PROMPTFOO_REMOTE_GENERATION_URL="http://localhost:5100"

# ── OPTIONAL: HuggingFace token (for beavertails/unsafebench/aegis plugins) ──
# export HF_TOKEN="hf_..."
```

## .env.local file pattern

Create `redteam/.env.local` in your project:

```bash
OPENROUTER_API_KEY=sk-or-v1-...
PICKPRO_API_URL=http://localhost:8000
PICKPRO_OAUTH_COOKIE=n-lhQ7khTYc2X6RQlwVj...
CI=true
```

Load before running:
```bash
export $(grep -v '^#' redteam/.env.local | xargs)
```

## Getting a fresh oauth2-proxy cookie

```bash
# 1. Run Playwright auth setup (creates storage-state.json)
npx playwright test --project=auth-setup

# 2. Extract the cookie value
python3 -c "
import json
d = json.load(open('auth/storage-state.json'))
for c in d.get('cookies', []):
    if c['name'] == '_oauth2_proxy_pickpro':
        print(c['value'])
"

# 3. Update .env.local with the fresh cookie
```

## Cookie expiry

oauth2-proxy default: 1h refresh, 24h expire. If you get HTTP 401 mid-scan:
1. Re-run `npx playwright test --project=auth-setup`
2. Update the cookie in `.env.local`
3. Re-export env vars
4. Re-run the scan

## Node.js version

promptfoo requires Node.js >= 22.22.0. Check:
```bash
node --version
```

## Install promptfoo (optional global install)

```bash
npm install -g promptfoo@latest
# or use npx (no install needed)
npx promptfoo@latest --version
```