# Annex III — High-Risk AI Systems

Load when testing EU AI Act Annex III high-risk AI system categories.

## Biometric Identification (`eu:ai-act:annex3:biometric-id`)
**Requires customization** — set `redteam.purpose` to explicitly state biometric ID behaviors.

```yaml
redteam:
  purpose: 'AI system for biometric identification and categorization of persons...'
  plugins:
    - eu:ai-act:annex3:biometric-id
# Or: pii:direct, pii:session, harmful:privacy
```

## Critical Infrastructure (`eu:ai-act:annex3:critical-infrastructure`)
Safety components in energy, water, transport, etc.

```yaml
redteam:
  plugins:
    - eu:ai-act:annex3:critical-infrastructure
# Or: shell-injection, sql-injection, ssrf, excessive-agency
#     + strategies: jailbreak, jailbreak-templates
```

## Education (`eu:ai-act:annex3:education`)
Access to education, evaluating learning outcomes, assessing education level.

```yaml
redteam:
  plugins:
    - eu:ai-act:annex3:education
# Or: harmful:misinformation-disinformation, hallucination, overreliance
```

## Employment (`eu:ai-act:annex3:employment`)
Recruitment, selection, evaluation, promotion, termination.

```yaml
redteam:
  plugins:
    - eu:ai-act:annex3:employment
# Or: imitation, pii:direct, overreliance
```

## Essential Services (`eu:ai-act:annex3:essential-services`)
Creditworthiness, emergency services, public services access.

```yaml
redteam:
  plugins:
    - eu:ai-act:annex3:essential-services
# Or: pii:direct, pii:session, excessive-agency
```

## Law Enforcement (`eu:ai-act:annex3:law-enforcement`)
Risk assessments, polygraph, evidence evaluation.

```yaml
redteam:
  plugins:
    - eu:ai-act:annex3:law-enforcement
# Or: pii:direct, pii:api-db, harmful:privacy
```

## Migration and Border Control (`eu:ai-act:annex3:migration-border`)
Verification of authenticity, risk assessments for migration/asylum.

```yaml
redteam:
  plugins:
    - eu:ai-act:annex3:migration-border
# Or: pii:direct, harmful:hate, harmful:privacy
```

## Justice and Democracy (`eu:ai-act:annex3:justice-democracy`)
Administration of justice, democratic processes, judicial assistance.

```yaml
redteam:
  plugins:
    - eu:ai-act:annex3:justice-democracy
# Or: hallucination, harmful:misinformation-disinformation, pii:direct
```