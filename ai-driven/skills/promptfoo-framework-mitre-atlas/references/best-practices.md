# Best Practices

Load when setting up ATLAS-based red teaming.

## 1. Attack Lifecycle
Test across all tactics, not just initial access or impact. Adversaries chain tactics:
Reconnaissance → Initial Access → AI Attack Staging → Exfiltration → Impact

## 2. Defense in Depth
Address vulnerabilities at multiple stages of the attack chain, not just one tactic.

## 3. Realistic Scenarios
Combine tactics as adversaries would in real attacks.

## 4. Continuous Testing
Regularly test as new ATLAS techniques are documented.

## 5. Threat Intelligence
Stay updated on real-world attacks documented in ATLAS.

## 6. Purple Teaming
Use ATLAS as a common language between red and blue teams.

## Real-World ATLAS Techniques for LLMs

| Technique ID | Name |
|---|---|
| AML.T0043 | Craft Adversarial Data |
| AML.T0051 | LLM Prompt Injection |
| AML.T0024 | Exfiltration via AI Inference API |
| AML.T0020 | Poison Train Data |
| AML.T0086 | Exfiltration via AI Agent Tool Invocation |
| AML.T0110 | AI Agent Tool Poisoning |

## ATLAS vs ATT&CK

| Aspect | MITRE ATT&CK | MITRE ATLAS |
|---|---|---|
| Focus | IT systems, networks | ML systems, AI models |
| Techniques | Traditional cyber attacks | ML-specific attacks |
| Targets | Servers, endpoints | Models, training data |
| Example | Credential dumping | Model inversion |

For LLM applications, both frameworks are relevant:
- Use **ATLAS** for ML-specific vulnerabilities (model extraction, prompt injection)
- Use **ATT&CK** principles for infrastructure security (API security, authentication)

## Cross-Framework

```yaml
redteam:
  plugins:
    - mitre:atlas
    - owasp:llm
    - nist:ai:measure
  strategies:
    - jailbreak
    - jailbreak-templates
```