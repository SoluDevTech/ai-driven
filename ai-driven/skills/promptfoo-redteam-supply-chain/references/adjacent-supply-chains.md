# Adjacent Supply Chains

Load when testing RAG data sources and MCP tools as part of supply chain security.

## RAG Data Sources

Compromised document stores can poison model outputs. Test with:

```yaml
redteam:
  plugins:
    - rag-poisoning
    - rag-document-exfiltration
    - indirect-prompt-injection
  strategies:
    - jailbreak-templates
```

See `promptfoo-redteam-rag` for comprehensive RAG security coverage.

## MCP Tools

Third-party MCP servers can exfiltrate data or escalate privileges. Test with:

```yaml
redteam:
  plugins:
    - mcp
    - tool-discovery
    - excessive-agency
    - ssrf
  strategies:
    - jailbreak:composite
    - jailbreak-templates
```

See `promptfoo-redteam-agents` for MCP security testing details.

## Why These Matter

Beyond the model itself, LLM applications have supply chain risks in connected systems:
- **RAG data sources** — compromised knowledge bases manipulate outputs
- **MCP tools** — third-party servers exfiltrate data or escalate privileges
- **Prompt template drift** — changes to system prompts weaken security controls
- **Fine-tuning data** — malicious examples in training datasets introduce targeted vulnerabilities

These are all part of your LLM supply chain and should be tested alongside the model itself.