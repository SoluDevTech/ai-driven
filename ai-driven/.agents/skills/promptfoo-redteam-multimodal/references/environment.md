# Environment Setup

Load before running multimodal red teams. Set provider env vars and install dependencies.

## Provider Environment Variables

```bash
# AWS Bedrock
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_REGION=your_region

# OpenAI
export OPENAI_API_KEY=your_api_key

# Anthropic
export ANTHROPIC_API_KEY=your_api_key

# Required for UnsafeBench plugin
export HF_TOKEN=your_huggingface_token
```

## FFmpeg (for video strategy)

Real MP4 video requires local FFmpeg:

```bash
# macOS
brew install ffmpeg

# Ubuntu
sudo apt install ffmpeg
```

Plus set:
```bash
export PROMPTFOO_DISABLE_REMOTE_GENERATION=true
# or
export PROMPTFOO_DISABLE_REDTEAM_REMOTE_GENERATION=true
```

Without FFmpeg + this env var, the video strategy falls back to text bytes (decodes to original text, not video).

## Audio (remote generation)

Audio conversion uses remote generation — it cannot run offline. No FFmpeg needed, but network access is required.

## Sharp (for image processing)

Some examples require `sharp` for image processing:

```bash
npm install sharp
```

## Quick Start

```bash
npx promptfoo@latest init --example redteam-multi-modal
cd redteam-multi-modal
npm install sharp

# Run each approach
npx promptfoo@latest redteam run -c promptfooconfig.static-image.yaml
npx promptfoo@latest redteam run -c promptfooconfig.image-strategy.yaml
npx promptfoo@latest redteam run -c promptfooconfig.unsafebench.yaml
npx promptfoo@latest redteam run -c promptfooconfig.vlguard.yaml
```