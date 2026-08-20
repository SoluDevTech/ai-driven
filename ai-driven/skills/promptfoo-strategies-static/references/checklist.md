# Checklist

Run before declaring static strategy red team done.

## Pre-Flight
- [ ] Strategies selected based on target's likely weaknesses (encoding, character substitution, known jailbreaks)
- [ ] `injectVar` set explicitly for any multimodal strategy (`image`, `audio`, `video`)
- [ ] FFmpeg installed + `PROMPTFOO_DISABLE_REMOTE_GENERATION=true` (if using `video`)
- [ ] Network available (if using `audio` — requires remote generation)
- [ ] Plugin targeting configured (if scoping strategies to specific plugins)

## Encoding Strategies
- [ ] `base64` — 20-30% ASR, tests Base64 encoding bypass
- [ ] `hex` — 20-30% ASR, tests hex encoding bypass
- [ ] `rot13` — 20-30% ASR, tests ROT13 encoding bypass
- [ ] `leetspeak` — 20-30% ASR, tests character substitution (a→4, e→3)
- [ ] `homoglyph` — 20-30% ASR, tests Unicode confusable characters

## Multimodal Encodings
- [ ] `image` — text→PNG, `injectVar: image` set explicitly
- [ ] `audio` — text→MP3, `injectVar: audio` set, remote generation available
- [ ] `video` — text→MP4, FFmpeg installed, `PROMPTFOO_DISABLE_REMOTE_GENERATION=true`
- [ ] Custom provider reads `context.vars[injectVar]` directly (not rendered prompt)
- [ ] Data URL wrapping for APIs expecting `data:image/png;base64,...`

## Jailbreak Templates
- [ ] `jailbreak-templates` included for known template coverage (DAN, Skeleton Key)
- [ ] Paired with dynamic strategies for modern prompt injection coverage

## Minor Encodings (if completeness needed)
- [ ] `camelCase` — 0-5% ASR
- [ ] `emoji` — 0-5% ASR, emoji variation selector smuggling
- [ ] `morse` — 20-30% ASR, Morse code encoding
- [ ] `pig-latin` — 20-30% ASR, word transformation

## Layering
- [ ] `layer` strategy configured with ordered `steps`
- [ ] Agentic first (max 1), text transforms middle, multimodal last (max 1)
- [ ] No invalid patterns (multi-modal not last, multiple multimodal, agentic not first)

## Configuration
- [ ] `basic` strategy enabled/disabled intentionally (controls untransformed test case inclusion)
- [ ] Plugin targeting set if scoping strategies
- [ ] Cost estimate: static strategies are low cost, but combining many multiplies test cases

## Post-Run
- [ ] Report reviewed for encoding-specific bypasses
- [ ] Per-strategy ASR compared (which encodings bypassed filters?)
- [ ] Mitigations documented (encoding detection, OCR for image-embedded text, transcription for audio)
- [ ] Re-run periodically — foundation model vendors add encoding detection over time