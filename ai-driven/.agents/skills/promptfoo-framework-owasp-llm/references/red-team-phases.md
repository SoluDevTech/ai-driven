# OWASP Gen AI Red Team Phases

Load when using the 4-phase OWASP Gen AI red team best practices.

## All Phases
```yaml
redteam:
  plugins:
    - owasp:llm:redteam
```

## Phase 1: Model Evaluation
Focus on alignment, robustness, bias, socio-technological harms, and data risk at the base model layer.

```yaml
redteam:
  plugins:
    - owasp:llm:redteam:model
```

## Phase 2: Implementation Evaluation
Focus on guardrails, knowledge retrieval security (RAG), content filtering bypass, access control tests, and other "middle tier" application-level defenses.

```yaml
redteam:
  plugins:
    - owasp:llm:redteam:implementation
```

## Phase 3: System Evaluation
Focus on full-application or system-level vulnerabilities, supply chain, sandbox escapes, resource controls, and overall infrastructure.

```yaml
redteam:
  plugins:
    - owasp:llm:redteam:system
```

## Phase 4: Runtime / Human & Agentic Evaluation
Focus on live environment, human-agent interaction, multi-agent chaining, brand & trust issues, social engineering, and over-reliance.

```yaml
redteam:
  plugins:
    - owasp:llm:redteam:runtime
```

## Combining with OWASP LLM Top 10
```yaml
redteam:
  plugins:
    - owasp:llm
    - owasp:llm:redteam
  strategies:
    - jailbreak-templates
    - jailbreak
```