# OWASP API Security Mappings

Load when targeting specific OWASP API risks.

## Comprehensive Testing

```yaml
redteam:
  plugins:
    - owasp:api
  strategies:
    - jailbreak
    - jailbreak-templates
```

## API1: Broken Object Level Authorization (BOLA)
Users manipulate the LLM to access other users' data.

```yaml
redteam:
  plugins:
    - owasp:api:01
# Or: bola, rbac
```

## API2: Broken Authentication
Session hijacking through prompt manipulation, credential leaks.

```yaml
redteam:
  plugins:
    - owasp:api:02
# Or: bfla, rbac
```

## API3: Broken Object Property Level Authorization
Over-sharing data in LLM responses, excessive agency in modifying properties.

```yaml
redteam:
  plugins:
    - owasp:api:03
# Or: excessive-agency, overreliance
```

## API4: Unrestricted Resource Consumption
Expensive API calls, unlimited context window, excessive queries.

```yaml
redteam:
  plugins:
    - owasp:api:04
# Or: harmful:privacy, pii:api-db, pii:session
```

## API5: Broken Function Level Authorization (BFLA)
Users invoke privileged functions through prompts.

```yaml
redteam:
  plugins:
    - owasp:api:05
# Or: bfla, bola, rbac
```

## API6: Unrestricted Access to Sensitive Business Flows
Natural language manipulation of business processes.

```yaml
redteam:
  plugins:
    - owasp:api:06
# Or: harmful:misinformation-disinformation, overreliance
```

## API7: Server Side Request Forgery (SSRF)
LLMs tricked into making unauthorized requests.

```yaml
redteam:
  plugins:
    - owasp:api:07
# Or: shell-injection, sql-injection
```

## API8: Security Misconfiguration
Exposed debugging info, overly permissive API access, leaked system prompts.

```yaml
redteam:
  plugins:
    - owasp:api:08
# Or: harmful:privacy, pii:api-db, pii:session
```

## API9: Improper Inventory Management
Undocumented function calls, out-of-scope expertise.

```yaml
redteam:
  plugins:
    - owasp:api:09
# Or: harmful:specialized-advice, overreliance
```

## API10: Unsafe Consumption of APIs
Untrusted data from third-party APIs, debug info from external APIs.

```yaml
redteam:
  plugins:
    - owasp:api:10
# Or: debug-access, harmful:privacy
```