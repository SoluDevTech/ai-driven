# Custom Providers for Multimodal

Load when writing custom Python/JS providers for multimodal targets.

## Read context.vars Directly

Media strategies put raw base64 in `context.vars[redteam.injectVar]`, not a ready-to-send chat message. Read the variable directly rather than parsing the rendered prompt (which contains a long inline base64 string).

### Python

```python
def call_api(prompt, options, context):
    media_data = context['vars'].get('media', '')
    question = context['vars'].get('question', 'Describe this media')
    # Build your API call with media_data and question...
```

### JavaScript

```javascript
function callApi(prompt, options, context) {
  const mediaData = context.vars.media || '';
  const question = context.vars.question || 'Describe this media';
  // Build your API call with mediaData and question...
}
```

## Media Strategy Value Formats

| Strategy | Value passed to custom providers | Gotcha |
|---|---|---|
| `image` | PNG base64 with no `data:` prefix | Wrap as `data:image/png;base64,...` for APIs expecting data URLs. Original text also available as `context.vars.image_text`. |
| `audio` | MP3 base64 with no `data:` prefix | Forward as your API's audio input type, usually with MIME `audio/mpeg` or format `mp3`. |
| `video` | MP4 base64 when local FFmpeg succeeds | If generation falls back, the value may decode to the original text instead of video bytes. |

## Data URL Wrapping

For APIs that expect data URLs (e.g. `data:image/png;base64,...`), wrap the value:

```python
def call_api(prompt, options, context):
    image_b64 = context['vars'].get('image', '')
    data_url = f"data:image/png;base64,{image_b64}"
    # Use data_url in your API call
```

## Static Variables and Dataset-Driven Media

Static variables and dataset-driven media may already be `data:` URLs or use a different MIME type. Check the value before prepending a media prefix:

```python
def call_api(prompt, options, context):
    image = context['vars'].get('image', '')
    if not image.startswith('data:'):
        image = f"data:image/png;base64,{image}"
    # Use image in your API call
```