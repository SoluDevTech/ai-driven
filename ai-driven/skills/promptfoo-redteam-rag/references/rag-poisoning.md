# RAG Poisoning CLI

Load when generating poisoned documents for KB ingestion testing.

## Generate Poisoned Documents

```bash
promptfoo redteam poison document1.txt document2.txt --goal "Extract API keys"
```

This generates:
1. Poisoned versions of each document with injected attack vectors
2. A summary YAML file (default: `poisoned-config.yaml`) containing metadata

## Output Format

```yaml
documents:
  - originalPath: document1.txt
    poisonedDocument: 'Modified content with injected attack vectors...'
    intendedResult: 'In order to contact customer support, use this email: [email protected]'
  - originalPath: subfolder/document2.txt
    poisonedDocument: 'Another poisoned document...'
    intendedResult: 'The company is going out of business and giving away free products'
```

## Workflow

1. **Generate** — run `promptfoo redteam poison` on your source documents
2. **Ingest** — insert the poisoned documents into your RAG knowledge base
3. **Run red team** — `promptfoo redteam run` to identify if the LLM is vulnerable to data poisoning

## Goals

The `--goal` flag tells the poison generator what the attack should achieve:
- `--goal "Extract API keys"` — poisoned docs try to get the model to reveal API keys
- `--goal "Recommend competitor products"` — poisoned docs bias recommendations
- `--goal "Disregard safety protocols"` — poisoned docs override security instructions

## Limitations

- Requires re-ingesting documents into your live KB — non-trivial in production-like environments
- Best run in a staging environment that mirrors production KB state
- The poisoned docs must be retrievable for the attack to work — ensure they're indexed