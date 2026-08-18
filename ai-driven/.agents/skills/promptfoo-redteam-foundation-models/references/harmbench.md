# HarmBench Standardized Benchmark

Load when running HarmBench evaluations. 400 harmful behaviors across 7 semantic + 3 functional categories.

## What HarmBench Tests

HarmBench (UC Berkeley, Google DeepMind, Center for AI Safety) evaluates models across 400 harmful behaviors:
- Chemical and biological threats
- Illegal activities (theft, fraud, trafficking)
- Misinformation and conspiracy theories
- Harassment and hate speech
- Cybercrime (malware, system exploitation)
- Copyright violations

## Full Evaluation

```yaml
# promptfooconfig.yaml
description: HarmBench evaluation of OpenAI GPT-5-mini
targets:
  - id: openai:gpt-5-mini
    label: OpenAI GPT-5-mini
redteam:
  plugins:
    - id: harmbench
      numTests: 400
```

## Filtered Evaluation

Focus on a smaller slice by category:

```yaml
redteam:
  plugins:
    - id: harmbench
      numTests: 50
      config:
        categories:
          - cybercrime
          - misinformation
        functionalCategories:
          - contextual
```

When you set both filters, Promptfoo uses their **intersection**.

## Semantic Categories

| Category | Description |
|---|---|
| `chemical_biological` | Chemical and biological threats |
| `copyright` | Copyright violations |
| `cybercrime_intrusion` | Cybercrime, malware, system exploitation |
| `harassment_bullying` | Harassment and bullying |
| `harmful` | General harmful content |
| `illegal` | Illegal activities |
| `misinformation_disinformation` | Misinformation and conspiracy theories |

## Functional Categories

| Category | Description |
|---|---|
| `standard` | Standard harmful prompts |
| `contextual` | Context-dependent harmful prompts |
| `copyright` | Copyright-specific prompts |

## Running

```bash
npx promptfoo@latest redteam run
npx promptfoo@latest view
```

## Why App-Context Testing Matters

Test the LLM **within your application's context** — including your prompt engineering, safety guardrails, and processing layers. This is important because:
- Your app's prompt engineering and context can significantly impact model behavior
- Even refusal-trained LLMs can still be jailbroken when operating as agents
- Vanilla model results don't reflect your production risk

## Testing Different Targets

### Ollama Models
```bash
ollama pull llama4:scout
```
```yaml
targets:
  - ollama:chat:llama4:scout
```

### Your Application
```yaml
targets:
  - id: https
    config:
      url: 'https://example.com/generate'
      method: 'POST'
      headers:
        'Content-Type': 'application/json'
      body:
        myPrompt: '{{prompt}}'
```

## Multi-Layered Approach

HarmBench is a static dataset. Combine with dynamic plugins for comprehensive coverage:
- HarmBench — standardized baseline, comparable across models
- Dynamic plugins (PII, hallucination, excessive-agency, emerging cybersec) — evolving threat coverage

## References

- [HarmBench paper](https://arxiv.org/abs/2402.04249)
- [HarmBench GitHub](https://github.com/centerforaisafety/HarmBench)
- [HarmBench Promptfoo plugin](https://promptfoo.dev/docs/red-team/plugins/harmbench/)