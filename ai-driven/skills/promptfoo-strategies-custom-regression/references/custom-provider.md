# Custom Provider for Multimodal Layer Targets

Load when using `layer` with audio or image transforms. Your custom provider receives a hybrid JSON payload.

## The Hybrid Payload

When using layer with audio or image transforms, your custom provider receives a hybrid JSON payload containing both conversation history (as text) and the current turn (as audio/image).

```json
{
  "_promptfoo_audio_hybrid": true,
  "history": [
    { "role": "user", "content": "Hello" },
    { "role": "assistant", "content": "Hi there!" }
  ],
  "currentTurn": {
    "role": "user",
    "transcript": "Tell me about...",
    "audio": { "data": "base64...", "format": "mp3" }
  }
}
```

## Custom Provider Example (JavaScript)

```javascript
// audio-provider.js
class AudioProvider {
  id() {
    return 'audio-target';
  }

  async callApi(prompt) {
    let messages = [];

    // Check for hybrid payload from layer strategy
    if (typeof prompt === 'string' && prompt.startsWith('{')) {
      try {
        const parsed = JSON.parse(prompt);
        if (parsed._promptfoo_audio_hybrid) {
          // Build messages from conversation history (text)
          messages = (parsed.history || []).map((msg) => ({
            role: msg.role,
            content: msg.content,
          }));

          // Add current turn with audio/image
          const currentTurn = parsed.currentTurn;
          if (currentTurn?.audio?.data) {
            messages.push({
              role: currentTurn.role,
              content: [
                {
                  type: 'input_audio',
                  input_audio: {
                    data: currentTurn.audio.data,
                    format: currentTurn.audio.format || 'mp3',
                  },
                },
              ],
            });
          } else if (currentTurn?.image?.data) {
            messages.push({
              role: currentTurn.role,
              content: [
                {
                  type: 'image_url',
                  image_url: {
                    url: `data:image/${currentTurn.image.format || 'png'};base64,${currentTurn.image.data}`,
                  },
                },
              ],
            });
          }
        }
      } catch (e) {
        // Fallback to treating as plain text
        messages = [{ role: 'user', content: prompt }];
      }
    }

    // Call your audio-capable API
    const response = await yourApiCall(messages);
    return {
      output: response.text,
      audio: response.audio
        ? {
            data: response.audio.data,
            transcript: response.audio.transcript,
            format: 'mp3',
          }
        : undefined,
    };
  }
}

module.exports = AudioProvider;
```

## Key Points

- **Check for `_promptfoo_audio_hybrid`** flag to detect layer strategy payloads
- **History is text** — prior turns are in `parsed.history` as plain text messages
- **Current turn is multimodal** — `parsed.currentTurn` contains the audio/image data
- **Fallback to plain text** — if parsing fails, treat the prompt as a plain string
- **Data URL wrapping for images** — wrap as `data:image/png;base64,...` for APIs expecting data URLs
- **Audio format** — default to `mp3` if not specified in the payload

## When You Need This

You need a custom provider like this when:
- Using `layer` with `[agentic_strategy, audio]` or `[agentic_strategy, image]`
- Your target is a voice-enabled or vision-enabled AI agent
- The built-in providers don't handle the hybrid payload format

See `promptfoo-redteam-multimodal` skill for more on multimodal custom providers.