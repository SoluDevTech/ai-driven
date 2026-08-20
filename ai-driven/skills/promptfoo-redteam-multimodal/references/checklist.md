# Checklist

Run end-to-end before declaring multimodal red team done.

## Environment
- [ ] Provider env vars set (`AWS_ACCESS_KEY_ID`, `OPENAI_API_KEY`, `ANTHROPIC_API_KEY` as needed)
- [ ] `HF_TOKEN` set (if using UnsafeBench)
- [ ] FFmpeg installed + `PROMPTFOO_DISABLE_REMOTE_GENERATION=true` (if using video strategy)
- [ ] `npm install sharp` (if running the example)
- [ ] Network access available (if using audio strategy — requires remote generation)

## injectVar (CRITICAL)
- [ ] `redteam.injectVar` set EXPLICITLY — does NOT rely on the default (last template variable)
- [ ] `injectVar: question` for static image approach
- [ ] `injectVar: image` for image strategy / UnsafeBench / VLGuard
- [ ] `injectVar: audio` for audio strategy
- [ ] `injectVar: video` for video strategy

## Approach
- [ ] **Static image** — `defaultTest.vars.image: file://photo.jpg`, `injectVar: question`
- [ ] **Image strategy** — `strategies: - image`, `injectVar: image`, constant `question`
- [ ] **UnsafeBench** — `plugins: - id: unsafebench; config: {categories: [...]}`, `injectVar: image`, `HF_TOKEN` set
- [ ] **VLGuard** — `plugins: - id: vlguard; config: {categories: [...]}`, `injectVar: image`
- [ ] **Audio** — `strategies: - audio`, `injectVar: audio`, remote generation available
- [ ] **Video** — `strategies: - video`, `injectVar: video`, FFmpeg installed + `PROMPTFOO_DISABLE_REMOTE_GENERATION=true`

## Purpose Statement
- [ ] `redteam.purpose` describes the ACTUAL image content concretely (not "you are a helpful assistant")
- [ ] Purpose relates to the image for realistic scenario generation

## Prompt Template
- [ ] Prompt template matches provider format (Bedrock Nova, OpenAI, Anthropic — see `references/prompt-templates.md`)
- [ ] `transformVars` strips `data:binary/octet-stream;base64,` prefix (if using Bedrock Nova)
- [ ] Template uses `{{image}}` / `{{question}}` / `{{audio}}` / `{{video}}` matching `injectVar`

## Custom Provider (if applicable)
- [ ] Reads `context.vars[injectVar]` directly, not the rendered prompt
- [ ] Wraps base64 as `data:image/png;base64,...` if API expects data URLs
- [ ] Checks for existing `data:` prefix before wrapping

## Run
- [ ] `npx promptfoo@latest redteam run -c config.yaml` completed
- [ ] Report reviewed for modality-specific bypasses

## Post-Run
- [ ] `npx promptfoo@latest redteam report` reviewed
- [ ] Image strategy failures investigated (did image-embedded text bypass text filters?)
- [ ] UnsafeBench/VLGuard failures investigated (did the model engage with harmful imagery?)
- [ ] Audio failures investigated (did audio-delivered content bypass filters?)
- [ ] Video failures investigated (did video-embedded content bypass filters?)
- [ ] Mitigations documented:
  - [ ] OCR-based content filtering on image inputs
  - [ ] Audio transcription + text filtering
  - [ ] Video frame analysis
- [ ] Re-run after mitigations to verify fixes