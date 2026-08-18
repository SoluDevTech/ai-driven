# promptfoo-redteam-configuration

Use this skill when configuring and running promptfoo red team scans. Covers the full YAML config schema, local execution without email verification (CI=true), OpenRouter provider setup, HTTP/WebSocket/multipart targets, cookie-based auth, plugin/strategy selection (local vs remote-only), and the traps that block scans in practice.

## When to use
- Writing or reviewing a `promptfooconfig.yaml` for red team scanning
- Running `promptfoo redteam run` / `generate` / `eval` locally
- Configuring OpenRouter as both generation and grading provider
- Hitting HTTP API targets with cookie-based auth (oauth2-proxy, Traefik)
- Uploading files (PDF/DOCX) via multipart for indirect prompt injection testing
- Debugging "Email Verification Required", "plugin requires remote generation", 401 on targets, or 0 tests generated

## Key traps solved
1. **`CI=true`** bypasses email verification without disabling remote generation (unlike `PROMPTFOO_DISABLE_REMOTE_GENERATION=1` which kills 60%+ of plugins)
2. **`OPENROUTER_API_KEY`** (no underscore) — promptfoo reads this exact env var name
3. **`redteam.provider`** in YAML, not `--provider` on CLI (`redteam run` doesn't accept it)
4. **`owasp:llm:01`** collection breaks `indirect-prompt-injection` — use individual plugins instead
5. **`jailbreak-templates`** is always local; `jailbreak` may need remote; `goat` requires remote grading
6. **Cookie auth**: pass `Cookie: _oauth2_proxy_<service>={{env.COOKIE}}` for oauth2-proxy targets
7. **Multipart**: needs `parts` array with `kind: file|field`, not nested objects
8. **npm isolation**: redteam configs in `redteam/`, scripts prefixed `redteam:`, never at repo root