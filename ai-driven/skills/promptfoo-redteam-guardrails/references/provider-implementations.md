# Provider Implementations

Full `call_api` implementations for each guardrail vendor. All return `{output, guardrails: {flagged: bool, ...}, error?}`.

## Azure Content Filter

```python
import os
from azure.ai.contentsafety import ContentSafetyClient
from azure.core.credentials import AzureKeyCredential
from azure.ai.contentsafety.models import AnalyzeTextOptions, TextCategory
from azure.core.exceptions import HttpResponseError

def call_api(prompt, options, context):
    key = os.environ.get("CONTENT_SAFETY_KEY") or options.get("config", {}).get("key")
    endpoint = os.environ.get("CONTENT_SAFETY_ENDPOINT") or options.get("config", {}).get("endpoint")
    client = ContentSafetyClient(endpoint, AzureKeyCredential(key))
    request = AnalyzeTextOptions(text=prompt)
    try:
        response = client.analyze_text(request)
        hate_result = next((item for item in response.categories_analysis if item.category == TextCategory.HATE), None)
        self_harm_result = next((item for item in response.categories_analysis if item.category == TextCategory.SELF_HARM), None)
        sexual_result = next((item for item in response.categories_analysis if item.category == TextCategory.SEXUAL), None)
        violence_result = next((item for item in response.categories_analysis if item.category == TextCategory.VIOLENCE), None)
        threshold = 0.5
        flagged = False
        categories = {}
        for name, result in [("hate", hate_result), ("self_harm", self_harm_result), ("sexual", sexual_result), ("violence", violence_result)]:
            if result:
                categories[name] = result.severity
                if result.severity > threshold:
                    flagged = True
        return {"output": f"Content analysis completed. Categories: {categories}", "guardrails": {"flagged": flagged, "categories": categories}}
    except HttpResponseError as e:
        error_message = f"Error code: {e.error.code}, Message: {e.error.message}" if e.error else str(e)
        return {"output": None, "error": error_message}
```

```yaml
targets:
  - id: 'file://azure_content_filter.py'
    config:
      endpoint: '{{env.CONTENT_SAFETY_ENDPOINT}}'
      key: '{{env.CONTENT_SAFETY_KEY}}'
```

## Azure Prompt Shields

```python
import os, requests

def call_api(prompt, options, context):
    endpoint = os.environ.get("CONTENT_SAFETY_ENDPOINT") or options.get("config", {}).get("endpoint")
    key = os.environ.get("CONTENT_SAFETY_KEY") or options.get("config", {}).get("key")
    url = f'{endpoint}/contentsafety/text:shieldPrompt?api-version=2024-02-15-preview'
    headers = {'Ocp-Apim-Subscription-Key': key, 'Content-Type': 'application/json'}
    data = {"userPrompt": prompt}
    try:
        response = requests.post(url, headers=headers, json=data)
        result = response.json()
        injection_detected = result.get("containsInjection", False)
        return {"output": f"Prompt shield analysis: {result}", "guardrails": {"flagged": injection_detected, "promptShield": result}}
    except Exception as e:
        return {"output": None, "error": str(e)}
```

## AWS Bedrock Guardrails (text)

```python
import boto3

def call_api(prompt, options, context):
    config = options.get("config", {})
    guardrail_id = config.get("guardrail_id")
    guardrail_version = config.get("guardrail_version")
    bedrock_runtime = boto3.client('bedrock-runtime')
    try:
        content = [{"text": {"text": prompt}}]
        response = bedrock_runtime.apply_guardrail(
            guardrailIdentifier=guardrail_id,
            guardrailVersion=guardrail_version,
            source='INPUT',
            content=content
        )
        action = response.get('action', '')
        if action == 'GUARDRAIL_INTERVENED':
            outputs = response.get('outputs', [{}])
            message = outputs[0].get('text', 'Guardrail intervened') if outputs else 'Guardrail intervened'
            return {"output": message, "guardrails": {"flagged": True, "reason": message, "details": response}}
        else:
            return {"output": prompt, "guardrails": {"flagged": False, "reason": "Content passed guardrails check", "details": response}}
    except Exception as e:
        return {"output": None, "error": str(e)}
```

```yaml
targets:
  - id: 'file://aws_bedrock_guardrails.py'
    config:
      guardrail_id: 'your-guardrail-id'
      guardrail_version: 'DRAFT'
```

## NVIDIA NeMo Guardrails

```python
import nemoguardrails as ng

def call_api(prompt, options, context):
    config_path = options.get("config", {}).get("config_path", "./nemo_config.yml")
    try:
        rails = ng.RailsConfig.from_path(config_path)
        app = ng.LLMRails(rails)
        result = app.generate(messages=[{"role": "user", "content": prompt}])
        flagged = result.get("blocked", False)
        explanation = result.get("explanation", "")
        return {"output": result.get("content", ""), "guardrails": {"flagged": flagged, "reason": explanation if flagged else "Passed guardrails"}}
    except Exception as e:
        return {"output": None, "error": str(e)}
```

```yaml
targets:
  - id: 'file://nemo_guardrails.py'
    config:
      config_path: './nemo_config.yml'
```

## Google Model Armor (Direct Sanitization API)

For testing templates without calling an LLM, or getting detailed filter results:

```yaml
providers:
  - id: https
    config:
      url: 'https://modelarmor.{{ env.MODEL_ARMOR_LOCATION }}.rep.googleapis.com/v1/projects/{{ env.GOOGLE_PROJECT_ID }}/locations/{{ env.MODEL_ARMOR_LOCATION }}/templates/{{ env.MODEL_ARMOR_TEMPLATE }}:sanitizeUserPrompt'
      method: POST
      headers:
        Authorization: 'Bearer {{ env.GCLOUD_ACCESS_TOKEN }}'
      body:
        userPromptData:
          text: '{{prompt}}'
      transformResponse: file://transforms/sanitize-response.js
```

Env vars:
```bash
export GOOGLE_PROJECT_ID=your-project-id
export MODEL_ARMOR_LOCATION=us-central1
export MODEL_ARMOR_TEMPLATE=basic-safety
export GCLOUD_ACCESS_TOKEN=$(gcloud auth print-access-token)
```

Access tokens expire after 1 hour — use service account keys or Workload Identity Federation for CI.

See `references/model-armor.md` for the Vertex AI integration (preferred for most cases).