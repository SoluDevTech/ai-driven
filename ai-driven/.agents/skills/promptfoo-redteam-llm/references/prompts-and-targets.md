# Prompts and Targets

Load before configuring `promptfooconfig.yaml`. Covers prompt formats and target types.

## Prompt Formats

### Inline single-turn
```yaml
prompts:
  - 'Act as a travel agent and help the user plan their trip to {{destination}}. User query: {{query}}'
```

### Chat-style JSON
```json
[
  { "role": "system", "content": "Act as a travel agent for {{destination}}. Be friendly and concise." },
  { "role": "user", "content": "{{query}}" }
]
```
```yaml
prompts:
  - file://prompt.json
```

### Dynamically generated (Python)
```python
def get_prompt(context):
    if context['vars']['destination'] == 'Australia':
        return f"Act as a travel agent, mate: {{query}}"
    return f"Act as a travel agent and help the user plan their trip. User query: {{query}}"
```
```yaml
prompts:
  - file://rag_agent.py:get_prompt
```

### Dynamically generated (JavaScript)
```javascript
function getPrompt(context) {
  if (context.vars.destination === 'Australia') {
    return `Act as a travel agent, mate: ${context.query}`;
  }
  return `Act as a travel agent and help the user plan their trip. User query: ${context.query}`;
}
```
```yaml
prompts:
  - file://agent.js:getPrompt
```

### No prompt (direct API pentest)
Omit the `prompts:` field entirely when pentesting a live API endpoint directly.

## Target Types

### LLM APIs
```yaml
targets:
  - openai:gpt-5
  - anthropic:claude-sonnet-4-6
  - ollama:chat:llama4:scout
```
Set the appropriate API key env var (`OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, etc.).

### Custom flows
```yaml
targets:
  - file://path/to/js_agent.js        # JS natively supported
  - file://path/to/python_agent.py    # Python natively supported
  - exec:/path/to/shell_agent         # Any executable
  - webhook:http://localhost:8000/api/agent  # HTTP requests
```

### HTTP endpoints
```yaml
targets:
  - id: 'https://example.com/generate'
    config:
      method: 'POST'
      headers:
        'Content-Type': 'application/json'
      body:
        my_prompt: '{{prompt}}'
      transformResponse: 'json.path[0].to.output'
```
- `{{prompt}}` is replaced by the final prompt during the pentest.
- `transformResponse` is a JS snippet manipulating the `json` response object.
- `json.choices[0].message.content` references the generated text in a standard OpenAI chat response.

## Grader Configuration

The grader judges each test pass/fail. Default: `gpt-5` with `OPENAI_API_KEY`.

### Override with a local model
```yaml
defaultTest:
  options:
    provider: 'ollama:chat:llama4:scout'
```

### Override with Azure OpenAI
```yaml
defaultTest:
  options:
    provider:
      id: azureopenai:chat:gpt-4-deployment-name
      config:
        apiHost: 'xxxxxxx.openai.azure.com'
```