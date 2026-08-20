# Alerting on Drift

Load when setting up alerts for security regressions.

## Slack Notification

```yaml
# .github/workflows/redteam-drift.yml (continued)
- name: Notify on regression
  if: failure()
  uses: slackapi/slack-github-action@v2
  with:
    webhook: ${{ secrets.SLACK_WEBHOOK }}
    payload: |
      {
        "text": "Security drift detected in ${{ github.repository }}",
        "blocks": [
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "*Red Team Alert*\nASR exceeded threshold. <${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}|View results>"
            }
          }
        ]
      }
```

## Email Reports

Generate HTML reports for stakeholders:

```bash
npx promptfoo@latest redteam report --output report.html
```

## Incident Response

When drift is detected:

1. **Compare current results against baseline** — identify specific regressions
   ```bash
   npx promptfoo@latest redteam compare \
     --baseline baseline-results.json \
     --current current-results.json \
     --threshold 0.05
   ```

2. **Determine if the change is provider-side or internal** — check:
   - Did the model provider release an update?
   - Did we change the prompt template?
   - Did we disable a guardrail?
   - Did we fine-tune?

3. **Evaluate whether to roll back, add guardrails, or accept the risk**
   - **Roll back** — if ASR increased significantly and the change is internal
   - **Add guardrails** — if the change is provider-side and can't be reverted
   - **Accept the risk** — if the increase is within tolerance and documented

4. **Update baseline if the change is acceptable**
   ```bash
   cp current-results.json baseline-results.json
   git add baseline-results.json
   git commit -m "Update security baseline after acceptable drift"
   ```

## Multi-Model Drift Tracking

Track drift across model versions or providers by running the same tests against multiple targets:

```yaml
targets:
  - id: openai:gpt-4.1
    label: gpt-4.1-baseline
  - id: openai:gpt-4.1-mini
    label: gpt-4.1-mini-comparison
  - id: anthropic:claude-sonnet-4-20250514
    label: claude-sonnet-comparison
redteam:
  plugins:
    - harmful
    - jailbreak
    - prompt-extraction
```

This reveals which models drift and helps inform model selection decisions.