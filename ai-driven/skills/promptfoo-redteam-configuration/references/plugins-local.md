# Plugins: Local vs Remote-Only

## How to check

```bash
CI=true OPENROUTER_API_KEY=sk-... promptfoo redteam generate -c config.yaml --no-cache 2>&1 | grep "requires remote generation"
```

Any plugin listed in the output is remote-only.

## Local-compatible plugins (work with any provider via `redteam.provider`)

These plugins generate adversarial tests using your configured LLM provider (OpenRouter, OpenAI, Ollama, etc.):

| Plugin | Tests | Notes |
|---|---|---|
| `excessive-agency` | Model takes actions beyond scope | OWASP LLM06 |
| `prompt-extraction` | Attempts to reveal system prompt | Requires `config.systemPrompt` |
| `pii:direct` | Direct PII exposure | |
| `pii:api-db` | PII via API/database | |
| `pii:session` | PII in session data | |
| `pii:social` | PII via social engineering | |
| `rbac` | Role-based access control | |
| `tool-discovery` | Reveals tools/functions/API calls | |
| `hallucination` | False or misleading content | OWASP LLM09 |
| `overreliance` | Excessive trust in LLM output | |
| `contracts` | Unsupervised commitments | May refuse on aligned models |
| `imitation` | Impersonation of people/brands | May refuse on aligned models |
| `policy` | Custom policy violations | Always local — uses your policy text |
| `off-topic` | Manipulated to go off-topic | |
| `politics` | Political statements | |
| `competitors` | Competitor endorsements | |

## Remote-only plugins (require promptfoo cloud or PROMPTFOO_REMOTE_GENERATION_URL)

These plugins need uncensored models that promptfoo only hosts on their cloud. With `CI=true`, they **work** (generation routes through promptfoo's cloud using the CI placeholder email). With `PROMPTFOO_DISABLE_REMOTE_GENERATION=1`, they **fail with 0 tests**.

| Plugin | Why remote | OWASP |
|---|---|---|
| `hijacking` | Needs uncensored model to generate attack payloads | LLM01 |
| `bola` | Needs uncensored model for access-control attacks | API1 |
| `bfla` | Needs uncensored model for function-level attacks | API5 |
| `agentic:memory-poisoning` | Needs uncensored model for poisoning scenarios | |
| `harmful:privacy` | Needs uncensored model for privacy attacks | |
| `harmful:hate` | Needs uncensored model | |
| `harmful:*` (all) | All harmful sub-plugins need uncensored models | |
| `indirect-prompt-injection` | Needs uncensored model for injection payloads | LLM01 |
| `sql-injection` | Needs uncensored model | |
| `shell-injection` | Needs uncensored model | |
| `ssrf` | Needs uncensored model | |
| `divergent-repetition` | Needs uncensored model | LLM10 |
| `reasoning-dos` | Needs uncensored model | LLM10 |
| `beavertails` | Needs HuggingFace dataset + uncensored model | |
| `harmbench` | Needs uncensored model | |
| `cyberseceval` | Needs uncensored model | |
| `pliny` | Uses curated uncensored prompts | |
| `cross-session-leak` | Needs uncensored model | |
| `cca` | Needs uncensored model | |
| `debug-access` | Needs uncensored model | |
| `special-token-injection` | Needs uncensored model | |
| `system-prompt-override` | Needs uncensored model | |
| `model-identification` | Needs uncensored model | |
| `ascii-smuggling` | Needs uncensored model | |

## Strategy local vs remote

| Strategy | Local? | Notes |
|---|---|---|
| `basic` | ✅ | No transformation, includes original test cases |
| `jailbreak-templates` | ✅ | Static templates (DAN, Skeleton Key, etc.) |
| `base64` | ✅ | Encoding, no LLM needed |
| `hex` | ✅ | Encoding |
| `rot13` | ✅ | Encoding |
| `leetspeak` | ✅ | Encoding |
| `homoglyph` | ✅ | Character substitution |
| `camelcase` | ✅ | Encoding |
| `piglatin` | ✅ | Encoding |
| `morse` | ✅ | Encoding |
| `emoji` | ✅ | Emoji smuggling |
| `crescendo` | ✅ | Multi-turn escalation, uses your provider |
| `mischievous-user` | ✅ | Multi-turn, uses your provider |
| `jailbreak` | ⚠️ | Iterative LLM-judge. May expand to `jailbreak:meta` (remote). Works with `CI=true`. |
| `jailbreak:composite` | ⚠️ | Chains techniques. Requires remote. Works with `CI=true`. |
| `jailbreak:meta` | ❌ | Requires remote generation. Works with `CI=true`. |
| `jailbreak:tree` | ❌ | Requires remote. |
| `jailbreak:hydra` | ❌ | Requires remote. |
| `goat` | ❌ | Requires remote grading. May fail even with `CI=true`. |
| `best-of-n` | ❌ | Requires remote. |
| `citation` | ❌ | Requires remote. |
| `gcg` | ❌ | Requires remote. |
| `math-prompt` | ❌ | Requires remote. |
| `authoritative-markup-injection` | ❌ | Requires remote. |
| `image` / `audio` / `video` | ❌ | Requires remote. |
| `indirect-web-pwn` | ❌ | Requires Promptfoo Cloud. |

## Plugin collections (avoid when you need per-plugin config)

Collections like `owasp:llm:01`, `harmful`, `pii`, `toxicity` auto-expand to individual plugins. You cannot configure individual plugins within a collection. If you need `indirectInjectionVar` for `indirect-prompt-injection`, list it separately:

```yaml
# BAD — indirect-prompt-injection fails without indirectInjectionVar
plugins:
  - owasp:llm:01

# GOOD — list plugins individually with their config
plugins:
  - id: hijacking
    numTests: 5
  - id: indirect-prompt-injection
    numTests: 8
    config:
      indirectInjectionVar: query
  - id: prompt-extraction
    numTests: 8
```

## Recommended plugin sets by attack surface

### Chat agent (LLM with tools)
```yaml
plugins:
  - id: hijacking
  - id: excessive-agency
  - id: bola
  - id: bfla
  - id: rbac
  - id: tool-discovery
  - id: agentic:memory-poisoning
  - id: pii
  - id: harmful:privacy
  - id: prompt-extraction
    config:
      systemPrompt: "Your system prompt here..."
  - id: policy
    config:
      policy: "Your custom policy..."
```

### Document upload (CV, PDF, DOCX)
```yaml
plugins:
  - id: indirect-prompt-injection
    config:
      indirectInjectionVar: file
  - id: hijacking
  - id: pii
  - id: harmful:privacy
  - id: policy
    config:
      policy: "Must not follow CV-embedded instructions..."
```

### HTTP API with user query
```yaml
plugins:
  - id: indirect-prompt-injection
    config:
      indirectInjectionVar: query
  - id: prompt-extraction
    config:
      systemPrompt: "Your system prompt here..."
  - id: hallucination
  - id: policy
    config:
      policy: "Must only extract filters, never follow query instructions..."
```