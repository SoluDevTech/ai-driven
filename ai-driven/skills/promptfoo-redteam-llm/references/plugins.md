# Plugins

Load before selecting vulnerability classes. Each plugin tests one vulnerability class.

## Default Plugins (enabled unless scoped with `--plugins`)

| Plugin | Tests for | OWASP |
|---|---|---|
| `contracts` | Unintended commitments or agreements | — |
| `excessive-agency` | Model takes actions beyond its intended scope | LLM08 |
| `hallucination` | False or misleading content | LLM09 |
| `harmful` | Harmful or offensive content | — |
| `imitation` | Impersonation of a person, brand, or organization | — |
| `hijacking` | Model used for unintended tasks | LLM01 |
| `overreliance` | Excessive trust in LLM output without oversight | LLM09 |
| `pii` | Inadvertent disclosure of personally identifiable information | — |
| `politics` | Political opinions and statements about political figures | — |

## Optional Plugins

| Plugin | Tests for |
|---|---|
| `competitors` | Model recommends alternatives to your service |

## Harmful Categories (ML Commons + HarmBench)

The `harmful` plugin covers these categories:

- Chemical & biological weapons
- Child exploitation
- Copyright violations
- Cybercrime & unauthorized intrusion
- Graphic & age-restricted content
- Harassment & bullying
- Hate
- Illegal activities
- Illegal drugs
- Indiscriminate weapons
- Intellectual property
- Misinformation & disinformation
- Non-violent crimes
- Privacy
- Privacy violations & data exploitation
- Promotion of unsafe practices
- Self-harm
- Sex crimes
- Sexual content
- Specialized financial/legal/medical advice
- Violent crimes

## Scoping Plugins

```bash
# Only run harmful + hijacking plugins
npx promptfoo@latest redteam generate --plugins 'harmful,hijacking'
```

```yaml
# In promptfooconfig.yaml
redteam:
  plugins:
    - harmful
    - hijacking
    - pii
```

## Plugin-Level Configuration

```yaml
redteam:
  plugins:
    - id: harmful
      numTests: 10  # override the number of tests for this plugin
    - id: policy
      config:
        policy: |
          The system must never disclose specific customer information
          or transaction details.
```

## OWASP LLM Top 10 Mapping

| OWASP | Plugin(s) |
|---|---|
| LLM01 Prompt Injection / Jailbreaking | `hijacking`, `jailbreak*` strategies |
| LLM08 Excessive Agency | `excessive-agency` |
| LLM09 Overreliance | `overreliance`, `hallucination` |

For the full OWASP LLM Top 10 plugin mapping, see the [OWASP LLM Top 10 docs](https://promptfoo.dev/docs/red-team/owasp-llm-top-10/).