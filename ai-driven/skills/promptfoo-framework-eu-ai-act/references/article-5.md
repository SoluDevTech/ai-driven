# Article 5 — Prohibited Practices

Load when testing EU AI Act Article 5 prohibited AI practices.

## Comprehensive Article 5 Testing

```yaml
redteam:
  plugins:
    - eu:ai-act
  strategies:
    - jailbreak
    - jailbreak-templates
```

## Subliminal Manipulation (`eu:ai-act:art5:subliminal-manipulation`)
AI systems that deploy subliminal techniques beyond consciousness to distort behavior causing harm.

```yaml
redteam:
  plugins:
    - eu:ai-act:art5:subliminal-manipulation
# Or: hijacking, intent, excessive-agency
#     + strategies: jailbreak, jailbreak:tree, jailbreak:composite, jailbreak-templates
```

## Exploitation of Vulnerabilities (`eu:ai-act:art5:exploitation-of-vulnerabilities`)
AI that exploits vulnerabilities due to age, disability, or social/economic situation.

```yaml
redteam:
  plugins:
    - eu:ai-act:art5:exploitation-of-vulnerabilities
# Or: hijacking, imitation, harmful:misinformation-disinformation
```

## Social Scoring (`eu:ai-act:art5:social-scoring`)
AI that evaluates/classifies persons based on social behavior leading to detrimental treatment.

```yaml
redteam:
  plugins:
    - eu:ai-act:art5:social-scoring
# Or: harmful:misinformation-disinformation, overreliance
```

## Biometric Categorisation (`eu:ai-act:art5:biometric-categorisation`)
AI that categorizes based on biometric data to infer race, politics, religion, sex life, etc.

```yaml
redteam:
  plugins:
    - eu:ai-act:art5:biometric-categorisation
# Or: pii:direct, pii:session, harmful:privacy
```

## Real-time Remote Biometric ID (`eu:ai-act:art5:remote-biometric-id-live`)
Real-time remote biometric identification in publicly accessible spaces for law enforcement.

```yaml
redteam:
  plugins:
    - eu:ai-act:art5:remote-biometric-id-live
# Or: pii:session, pii:direct, harmful:privacy
```

## Post Remote Biometric ID (`eu:ai-act:art5:remote-biometric-id-post`)
Remote biometric identification on recorded footage.

```yaml
redteam:
  plugins:
    - eu:ai-act:art5:remote-biometric-id-post
# Or: pii:api-db, pii:direct, harmful:privacy
```