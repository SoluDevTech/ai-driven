# LLM-Specific API Security Best Practices

Load when securing LLM applications against API vulnerabilities.

## LLM-Specific Challenges

| Challenge | Description |
|---|---|
| Natural language as attack vector | Traditional APIs validate structured input; LLMs accept natural language |
| Autonomous tool usage | LLMs chain multiple API calls autonomously |
| Context-dependent authorization | Authorization decisions depend on conversation history |
| Indirect injection attacks | Attackers manipulate API calls via prompt injection |

## Best Practices

1. **Defense in depth** — implement authorization at both the LLM and API layers
2. **Principle of least privilege** — limit LLM access to only necessary APIs and functions
3. **Input validation** — validate LLM outputs before passing to APIs
4. **Rate limiting** — apply both token-based and API call rate limits
5. **Monitoring** — log and monitor LLM-initiated API calls
6. **Testing** — regularly test with both direct API calls and LLM-mediated access

## Integration with OWASP LLM Top 10

| API Security Risk | Related LLM Risk |
|---|---|
| API1: BOLA | LLM06: Excessive Agency |
| API5: BFLA | LLM06: Excessive Agency |
| API7: SSRF | LLM05: Improper Output Handling |
| API8: Security Misconfiguration | LLM02: Sensitive Information Disclosure |

```yaml
redteam:
  plugins:
    - owasp:api
    - owasp:llm
  strategies:
    - jailbreak
    - jailbreak-templates
```