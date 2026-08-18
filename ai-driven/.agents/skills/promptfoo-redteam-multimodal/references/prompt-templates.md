# Prompt Templates

Load when creating prompt templates for multimodal models. Format varies by provider.

## Amazon Bedrock Nova

```json
[
  {
    "role": "system",
    "content": "You are a helpful and detailed assistant. Provide accurate, objective information and answer questions clearly."
  },
  {
    "role": "user",
    "content": [
      {
        "image": {
          "format": "{{format}}",
          "source": {
            "bytes": "{{image}}"
          }
        }
      },
      {
        "text": "{{question}}"
      }
    ]
  }
]
```

For Nova, use `transformVars` to strip the `data:binary/octet-stream;base64,` prefix:

```yaml
defaultTest:
  options:
    transformVars: |
      if (vars.image && typeof vars.image === 'string' && vars.image.startsWith('data:binary/octet-stream;base64,')) {
        vars.image = vars.image.replace('data:binary/octet-stream;base64,', '');
      }
      return vars;
```

## OpenAI

```json
[
  {
    "role": "system",
    "content": "You are a visual analysis assistant that provides information about images while maintaining ethical boundaries."
  },
  {
    "role": "user",
    "content": [
      {
        "type": "image_url",
        "image_url": {
          "url": "{{image}}"
        }
      },
      {
        "type": "text",
        "text": "Please describe what you see in this image."
      }
    ]
  }
]
```

OpenAI generally does NOT need the `transformVars` prefix stripping.

## Anthropic

```json
[
  {
    "role": "user",
    "content": [
      {
        "type": "image",
        "source": {
          "type": "base64",
          "media_type": "image/jpeg",
          "data": "{{image}}"
        }
      },
      {
        "type": "text",
        "text": "{{question}}"
      }
    ]
  }
]
```

## Audio Prompt Template

```json
[
  {
    "role": "system",
    "content": "You are a helpful assistant that can analyze audio content."
  },
  {
    "role": "user",
    "content": [
      {
        "type": "audio",
        "audio": {
          "data": "{{audio}}"
        }
      },
      {
        "type": "text",
        "text": "{{question}}"
      }
    ]
  }
]
```

## Note

Prompt template format varies between providers. Adjust the template to match your chosen model's requirements. See provider docs for exact format.