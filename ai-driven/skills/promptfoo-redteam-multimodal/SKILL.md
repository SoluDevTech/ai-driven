---
name: promptfoo-redteam-multimodal
description: Red team vision, audio, and video LLMs with promptfoo. Use when testing multimodal models against image-embedded harmful text, audio-delivered harmful content, video-embedded attacks, static image + variable text, real unsafe images (UnsafeBench), or VLGuard dataset. Covers the critical injectVar setting, image/audio/video strategies, and dataset plugins.
---

# Red Team Multi-Modal LLMs with Promptfoo

Vision/audio-capable LLMs have unique attack surfaces — harmful content embedded in images, audio, or video can bypass text-only safety filters. Use four visual approaches (static image, text-to-image, UnsafeBench, VLGuard) and one audio approach (text-to-audio), plus video strategies.

## Use this skill when
- Testing a vision-capable LLM (GPT-5, Claude, Bedrock Nova, etc.)
- Testing if image-embedded harmful text bypasses text filters
- Testing if audio-delivered harmful content bypasses filters
- Testing if video-embedded harmful content bypasses filters
- Testing against real unsafe images (UnsafeBench dataset)
- Testing against VLGuard curated images
- Configuring `injectVar` for multimodal prompts (critical — defaults are wrong)
- Testing AWS Bedrock Guardrails with images

## Do not use this skill when
- Testing a text-only LLM app → use `promptfoo-redteam-llm`
- Testing guardrails on text content → use `promptfoo-redteam-guardrails`
- Testing multi-input apps with text fields → use `promptfoo-redteam-multi-input`
- Testing foundation models with text-only benchmarks → use `promptfoo-redteam-foundation-models`

## 🛡️ Edge cases (mandatory handling)
- **Relying on default `injectVar`** — it picks the **last** template variable; with `{{image}} {{question}}` it picks `question`, not `image`. ALWAYS set `injectVar` explicitly for multimodal.
- **Vague `purpose`** — "You are a helpful assistant" generates tests unrelated to the actual image. Must describe the image content concretely (e.g. "You analyze this image of Barack Obama speaking at a podium").
- **Forgetting FFmpeg for video** — without local FFmpeg + `PROMPTFOO_DISABLE_REMOTE_GENERATION=true`, video falls back to text bytes (decodes to original text, not video).
- **Audio cannot run offline** — audio conversion uses remote generation; plan accordingly.
- **UnsafeBench commercial use** — dataset is restricted to non-commercial academic research; check license before commercial use.
- **Nova image data prefix** — Amazon Bedrock Nova needs `data:binary/octet-stream;base64,` prefix stripped via `transformVars`; OpenAI and Anthropic generally don't.
- **Custom providers reading the rendered prompt** — the rendered prompt contains a long inline base64 string. Read `context.vars[injectVar]` directly instead.
- **Media strategy value formats** — `image`: PNG base64 (no `data:` prefix); `audio`: MP3 base64 (no prefix); `video`: MP4 base64 when FFmpeg succeeds. Wrap as `data:image/png;base64,...` for APIs needing data URLs.

## 🎯 Core workflow
1. **Set environment** — load `references/environment.md` for provider env vars (AWS, OpenAI, Anthropic, HF_TOKEN).
2. **Choose approach** — load `references/visual-approaches.md` for the four visual strategies.
3. **Configure injectVar** — load `references/injectvar.md` — the single most important multimodal setting.
4. **Prompt templates** — load `references/prompt-templates.md` for provider-specific message formats.
5. **Audio/video** — load `references/audio-video.md` for audio and video strategy configs.
6. **Custom providers** — load `references/custom-providers.md` for handling media data in Python/JS.
7. **Checklist** — run `references/checklist.md` end-to-end before declaring done.

## 🎯 Core principles (summary)
- **ALWAYS set `injectVar` explicitly** — the default (last template variable) is wrong for multimodal. With `{{image}} {{question}}`, set `injectVar: image`.
- **Four visual approaches**: static image (fixed image, variable text), `image` strategy (text→PNG), `unsafebench` (real unsafe images, needs `HF_TOKEN`), `vlguard` (442 curated images).
- **One audio approach**: `audio` strategy (text→MP3, remote generation).
- **One video approach**: `video` strategy (text→MP4, needs local FFmpeg + `PROMPTFOO_DISABLE_REMOTE_GENERATION=true`).
- **Concrete `purpose` statements** — describe the actual image content or tests will be unrelated to what's in the image.
- **Custom providers read `context.vars[injectVar]`** directly, not the rendered prompt (which contains long base64).

## 📦 Multimodal strategies

| Strategy | Output | Generation | Key gotcha |
|---|---|---|---|
| Static image | `file://` auto-base64 | N/A | Set in `defaultTest.vars.image` |
| `image` | PNG base64 (no `data:`) | Local | Wrap as `data:image/png;base64,...` for data URLs; original text in `context.vars.image_text` |
| `audio` | MP3 base64 (no `data:`) | Remote | Cannot run offline; forward with MIME `audio/mpeg` |
| `video` | MP4 base64 (when FFmpeg local) | Local FFmpeg | Set `PROMPTFOO_DISABLE_REMOTE_GENERATION=true`; fallback decodes to text |
| `unsafebench` | Real unsafe images | HF dataset | Needs `HF_TOKEN`; non-commercial only |
| `vlguard` | 442 curated images | Local | Categories: deception, risky behavior, privacy, discrimination |

## References
- `references/environment.md` — provider env vars (AWS, OpenAI, Anthropic, HF_TOKEN, FFmpeg)
- `references/visual-approaches.md` — four visual approaches with full configs (static image, image strategy, UnsafeBench, VLGuard)
- `references/injectvar.md` — the critical `injectVar` setting, why defaults fail, how to set it
- `references/prompt-templates.md` — provider-specific prompt templates (Bedrock Nova, OpenAI)
- `references/audio-video.md` — audio and video strategy configs and gotchas
- `references/custom-providers.md` — handling media data in Python/JS custom providers
- `references/checklist.md` — environment, injectVar, approach, prompt template, custom provider checklist