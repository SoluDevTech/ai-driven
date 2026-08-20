# Multi-Turn Chatbot Testing

Load when testing stateful chatbots (Chatbase, conversational agents). Stateful strategies + `conversationId`.

## Multi-turn vs Single-turn

| System | Security | Usability |
|---|---|---|
| Single-turn | Inherently safer (no history to poison) | Less usable (user must provide full context each message) |
| Multi-turn | Vulnerable to cross-message manipulation | Natural dialogue with conversation state |

## Stateful Strategies

```yaml
strategies:
  - id: 'goat'
    config:
      stateful: true
  - id: 'crescendo'
    config:
      stateful: true
  - id: 'mischievous-user'
    config:
      stateful: true
```

Without `stateful: true`, each message is treated independently — multi-turn attack chains are missed.

## Chatbase Configuration

### Prerequisites
- Node.js `>=22.22.0`
- promptfoo CLI (`npm install -g promptfoo`)
- Chatbase API credentials: Bearer Token + Chatbot ID

### Config

```yaml
targets:
  - id: 'http'
    config:
      method: 'POST'
      url: 'https://www.chatbase.co/api/v1/chat'
      headers:
        'Content-Type': 'application/json'
        'Authorization': 'Bearer YOUR_API_TOKEN'
      body:
        messages: '{{prompt}}'
        chatbotId: 'YOUR_CHATBOT_ID'
        stream: false
        temperature: 0
        model: 'gpt-5-mini'
        conversationId: '{{conversationId}}'
      transformResponse: 'json.text'
      transformRequest: '[{ role: "user", content: prompt }]'
defaultTest:
  options:
    transformVars: '{ ...vars, conversationId: context.uuid }'
strategies:
  - id: 'goat'
    config:
      stateful: true
  - id: 'crescendo'
    config:
      stateful: true
  - id: 'mischievous-user'
    config:
      stateful: true
```

### Key Config Notes

1. **`transformRequest`** — formats the request as OpenAI-compatible messages: `[{ role: "user", content: prompt }]`
2. **`transformResponse`** — extracts the response text from the JSON body: `json.text`
3. **`conversationId: '{{conversationId}}'`** — links messages in a conversation
4. **`transformVars`** — injects `conversationId: context.uuid` per test, enabling Chatbase to track conversation state across multiple messages

## Run

```bash
# Generate test cases
promptfoo redteam generate

# Execute evaluation
promptfoo redteam eval

# View detailed results in the web UI
promptfoo view
```

## Common Issues

| Issue | Solution |
|---|---|
| Tests fail to connect | Verify API credentials (Bearer Token, Chatbot ID) |
| Message content is garbled | Verify `transformRequest` and `transformResponse` are correct |
| Multi-turn attacks not working | Ensure `stateful: true` on strategies and `conversationId` is set via `transformVars` |