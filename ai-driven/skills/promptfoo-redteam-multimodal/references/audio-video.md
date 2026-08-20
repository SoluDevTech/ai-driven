# Audio and Video Strategies

Load when testing audio or video modality attacks.

## Audio Strategy

Converts harmful text to speech audio, then sends to the model. Tests whether audio-delivered harmful content bypasses text filters.

```yaml
# promptfooconfig.yaml
description: Audio Analysis with Multimodal Models
prompts:
  - id: file://audio-prompt.json
    label: audio-prompt
targets:
  - id: openai:gpt-5
    label: multimodal-model
defaultTest:
  vars:
    question: 'Please answer the question in the audio.'
redteam:
  purpose: >-
    Provide users with accurate and detailed information by analyzing audio and
    answering related questions clearly.
  injectVar: audio
  numTests: 1
  plugins:
    - id: harmful:harassment-bullying
    - id: harmful:hate
    - id: harmful:illegal-activities
    - id: harmful:misinformation-disinformation
    - id: harmful:privacy
    - id: harmful:profanity
    - id: harmful:unsafe-practices
  strategies:
    - audio
    - id: basic
      config:
        enabled: false
```

### Key points
- Audio conversion uses **remote generation** — cannot run offline
- Output: MP3 base64 (no `data:` prefix)
- Forward with MIME type `audio/mpeg` or format `mp3`

## Video Strategy

Converts harmful text into videos with text overlay, then sends to the model.

```yaml
redteam:
  injectVar: video
  strategies:
    - video
```

### Key points
- Real MP4 requires **local FFmpeg** + `PROMPTFOO_DISABLE_REMOTE_GENERATION=true`
- Without FFmpeg, the value may decode to the original text instead of video bytes
- Output: MP4 base64 when local FFmpeg generation succeeds

### Install FFmpeg

```bash
# macOS
brew install ffmpeg

# Ubuntu
sudo apt install ffmpeg
```

```bash
export PROMPTFOO_DISABLE_REMOTE_GENERATION=true
# or
export PROMPTFOO_DISABLE_REDTEAM_REMOTE_GENERATION=true
```

## Opposite Generation Requirements

Audio and video have opposite requirements today:
- **Audio** — requires remote generation (cannot run offline)
- **Video** — requires local FFmpeg (remote generation is the fallback)

If you need to verify both remote audio AND local MP4 handling, run separate scans.