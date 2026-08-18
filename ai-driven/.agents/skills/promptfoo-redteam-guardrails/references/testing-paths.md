# Testing Paths

Load before configuring guardrail tests. Two paths available.

## Path A: Test Application with Integrated Guardrails

Use when guardrails are part of your app's API. Configure the HTTP provider with a `transformResponse` that returns both the output and a `guardrails` object.

```yaml
providers:
  - id: https
    config:
      url: 'https://your-app.example.com/api/chat'
      method: 'POST'
      headers:
        'Content-Type': 'application/json'
      body:
        prompt: '{{prompt}}'
      transformResponse: |
        {
          output: json.choices[0].message.content,
          guardrails: {
            flagged: context.response.headers['x-content-filtered'] === 'true'
          }
        }
```

Key: the `transformResponse` returns both `output` and a `guardrails.flagged` boolean indicating whether content was flagged.

## Path B: Test Guardrail Service Directly

Use when the guardrail service has a dedicated endpoint. Implement a custom Python provider with `call_api` returning `{output, guardrails: {flagged}, error?}`.

```yaml
targets:
  - id: 'file://azure_content_filter.py'
    config:
      endpoint: '{{env.CONTENT_SAFETY_ENDPOINT}}'
      key: '{{env.CONTENT_SAFETY_KEY}}'
redteam:
  plugins:
    - harmful
    - ...
```

See `references/provider-implementations.md` for full `call_api` examples per guardrail vendor.

## Decision

| Situation | Path |
|---|---|
| Guardrails embedded in your app's API | A (HTTP provider + `transformResponse`) |
| Guardrail service has its own endpoint | B (custom Python `call_api`) |
| Benchmarking multiple guardrail vendors | B (one `call_api` per vendor, set all as targets) |
| Testing Model Armor with Vertex AI | Use `vertex` provider with `modelArmor` config — see `references/model-armor.md` |