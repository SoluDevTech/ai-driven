# DoD AI Ethics Principle Mappings

Load when targeting specific DoD AI ethical principles.

## Comprehensive Testing

```yaml
redteam:
  plugins:
    - dod:ai:ethics
  strategies:
    - jailbreak:meta
    - jailbreak:composite
    - jailbreak-templates
```

## 1. Responsible (`dod:ai:ethics:01`)
Humans remain accountable for AI outcomes. Test unauthorized actions and over-automation.

```yaml
redteam:
  plugins:
    - dod:ai:ethics:01
# Or: excessive-agency, goal-misalignment, overreliance, hijacking
#     + strategies: jailbreak, jailbreak-templates
```

## 2. Equitable (`dod:ai:ethics:02`)
AI should minimize unintended bias. Test demographic bias across protected classes.

```yaml
redteam:
  plugins:
    - dod:ai:ethics:02
# Or: bias:age, bias:disability, bias:gender, bias:race, harmful:hate
```

## 3. Traceable (`dod:ai:ethics:03`)
Decisions and outputs should be auditable. Test fabricated claims and hallucination.

```yaml
redteam:
  plugins:
    - dod:ai:ethics:03
# Or: hallucination, harmful:misinformation-disinformation, rag-source-attribution, unverifiable-claims
```

## 4. Reliable (`dod:ai:ethics:04`)
Systems should be safe, secure, and effective. Test injection and security vulnerabilities.

```yaml
redteam:
  plugins:
    - dod:ai:ethics:04
# Or: harmful:misinformation-disinformation, harmful:unsafe-practices, shell-injection,
#     sql-injection, ssrf, debug-access, reasoning-dos
#     + strategies: jailbreak, jailbreak-templates
```

## 5. Governable (`dod:ai:ethics:05`)
Operators should detect and disable unintended behavior. Test control boundaries.

```yaml
redteam:
  plugins:
    - dod:ai:ethics:05
# Or: excessive-agency, hijacking, indirect-prompt-injection, system-prompt-override,
#     rbac, bfla, bola, tool-discovery
#     + strategies: jailbreak, jailbreak-templates, jailbreak:composite
```

## Targeting Specific Principles

```yaml
redteam:
  plugins:
    - dod:ai:ethics:01  # Responsible
    - dod:ai:ethics:04  # Reliable
    - dod:ai:ethics:05  # Governable
  strategies:
    - jailbreak
    - jailbreak-templates
```