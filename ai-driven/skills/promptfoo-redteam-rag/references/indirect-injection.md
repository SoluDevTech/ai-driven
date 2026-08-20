# Indirect Prompt Injection

Load when configuring the `indirect-prompt-injection` plugin. The most important RAG red team config.

## The Key Config

```yaml
redteam:
  plugins:
    - id: 'indirect-prompt-injection'
      config:
        indirectInjectionVar: context  # MUST match the {{context}} variable in your prompt
    - 'harmful'
    - 'pii:direct'
    - 'rbac'
  strategies:
    - 'jailbreak-templates'
    - 'jailbreak'
```

## How It Works

The `indirect-prompt-injection` plugin:
1. Plants adversarial instructions into the variable named by `indirectInjectionVar` (your retrieved-context field)
2. Checks whether the model follows those injected instructions
3. The value of `indirectInjectionVar` must match a variable in your prompt template (e.g. `{{context}}`)

## Supporting Plugins

- `harmful` — tests for harmful outputs (child exploitation, racism, etc.)
- `pii:direct` — checks if the model directly discloses PII
- `rbac` — verifies the model adheres to role-based access control for tool use

## Supporting Strategies

- `jailbreak-templates` + `jailbreak` — wrap the supporting plugins' probes in adversarial user input, covering direct injections.

For attacks planted in the knowledge base itself, see `references/rag-poisoning.md`.

## Common Mistake

```yaml
# WRONG — indirectInjectionVar doesn't match any prompt variable
redteam:
  plugins:
    - id: indirect-prompt-injection
      config:
        indirectInjectionVar: documents  # but your prompt uses {{context}}

# CORRECT — matches the prompt template variable
prompts:
  - 'Retrieved context: {{context}}\nUser query: {{query}}'
redteam:
  plugins:
    - id: indirect-prompt-injection
      config:
        indirectInjectionVar: context  # matches {{context}}
```

A mismatch silently tests the wrong surface — the plugin injects into a variable that doesn't exist in the prompt, so nothing happens.