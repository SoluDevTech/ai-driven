# Multimodal Encoding Strategies

Load when testing image, audio, or video encoding bypasses. All require explicit `injectVar`.

## Image Encoding

Converts harmful text into images (black text on white background, PNG, base64). Tests whether image-embedded text bypasses text-only safety filters.

```yaml
strategies:
  - image
```

**Requires**: `injectVar: image` set explicitly — the default (last template variable) is wrong for multimodal.

```yaml
redteam:
  injectVar: image  # CRITICAL — must be explicit
  strategies:
    - image
```

**Output**: PNG base64 with no `data:` prefix. Wrap as `data:image/png;base64,...` for APIs expecting data URLs. Original text also available as `context.vars.image_text`.

See `promptfoo-redteam-multimodal` skill for full multimodal config details.

## Audio Encoding

Converts harmful text into speech audio (MP3, base64). Tests whether audio-delivered harmful content bypasses text filters.

```yaml
strategies:
  - audio
```

**Requires**:
- `injectVar: audio` set explicitly
- Remote generation (cannot run offline)

```yaml
redteam:
  injectVar: audio  # CRITICAL
  strategies:
    - audio
```

**Output**: MP3 base64 with no `data:` prefix. Forward with MIME type `audio/mpeg` or format `mp3`.

## Video Encoding

Converts harmful text into videos with text overlay (MP4, base64). Tests whether video-embedded content bypasses filters.

```yaml
strategies:
  - video
```

**Requires**:
- `injectVar: video` set explicitly
- Local FFmpeg installed
- `PROMPTFOO_DISABLE_REMOTE_GENERATION=true` (or `PROMPTFOO_DISABLE_REDTEAM_REMOTE_GENERATION=true`)

```bash
# macOS
brew install ffmpeg
# Ubuntu
sudo apt install ffmpeg

export PROMPTFOO_DISABLE_REMOTE_GENERATION=true
```

**Output**: MP4 base64 when local FFmpeg succeeds. Without FFmpeg, falls back to text bytes (decodes to original text, not video).

## Opposite Generation Requirements

Audio and video have OPPOSITE requirements:
- **Audio** — requires remote generation (cannot run offline)
- **Video** — requires local FFmpeg (remote generation is the fallback)

Run separate scans if you need to verify both remote audio AND local MP4 handling.

## Layering with Agentic Strategies

Combine multimodal encoding with agentic strategies via `layer`:

```yaml
# Multi-turn audio attack
strategies:
  - id: layer
    config:
      steps:
        - jailbreak:hydra  # Multi-turn jailbreak
        - audio            # Convert each turn to speech

# Multi-turn image attack
strategies:
  - id: layer
    config:
      steps:
        - crescendo        # Gradual escalation
        - image            # Convert each turn to image
```

**Ordering rules**: agentic first (max 1), multimodal last (max 1). See `references/layering.md`.