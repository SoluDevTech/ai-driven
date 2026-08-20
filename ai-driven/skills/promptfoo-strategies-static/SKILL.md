---
name: promptfoo-strategies-static
description: Static (deterministic, single-turn) red team strategies for promptfoo — base64, hex, ROT13, leetspeak, homoglyph, image/audio/video encoding, jailbreak-templates, camelCase, emoji smuggling, morse code, pig latin. Use when testing filter bypass via encoding, character substitution, known jailbreak templates, or multimodal encoding without an LLM-as-attacker.
---

# Static Red Team Strategies

Static strategies transform inputs using predefined patterns to bypass security controls. They are deterministic — no attacker LLM needed. Low cost, low resource, 20-30% ASR increase. Easy to detect and often patched in foundation models, but useful for baseline coverage and testing filter robustness.

## Use this skill when
- Testing if Base64/Hex/ROT13-encoded payloads bypass content filters
- Testing if leetspeak or homoglyph substitutions evade safety training
- Testing if image/audio/video-embedded text bypasses text-only filters
- Applying known static jailbreak templates (DAN, Skeleton Key, etc.)
- Testing camelCase, emoji smuggling, morse code, or pig latin transformations
- Running a low-cost baseline before adding dynamic strategies
- Combining encodings via the `layer` strategy (e.g. base64 → rot13)

## Do not use this skill when
- You need adaptive, iterative refinement → use `promptfoo-strategies-dynamic`
- You need multi-turn conversation attacks → use `promptfoo-strategies-multi-turn`
- You need indirect prompt injection via web pages → use `promptfoo-strategies-indirect-injection`
- You need custom or regression strategies → use `promptfoo-strategies-custom-regression`
- You're testing guardrails specifically → use `promptfoo-redteam-guardrails`

## 🛡️ Edge cases (mandatory handling)
- **More capable models are MORE vulnerable** — GPT-4o, Claude 3.5, Llama 3.3 decode Base64/Hex better, but their safety training doesn't scale proportionally. Don't assume a stronger model is safer against encoding attacks.
- **Static strategies are often patched** — foundation model vendors regularly add encoding detection. Re-run periodically; a strategy that fails today may work after the next model update.
- **Low ASR increase for some** — camelCase (0-5%), emoji smuggling (0-5%) have minimal impact; use them for completeness, not as primary attack vectors.
- **Multimodal encoding needs `injectVar`** — image/audio/video strategies require explicit `injectVar` set to the media variable (not the text variable). See `references/multimodal-encodings.md`.
- **`jailbreak-templates` doesn't cover modern prompt injection** — it only applies known static templates (DAN, Skeleton Key); pair with dynamic strategies for modern attacks.
- **Audio encoding uses remote generation** — cannot run offline; plan accordingly.
- **Video encoding needs local FFmpeg** — set `PROMPTFOO_DISABLE_REMOTE_GENERATION=true` or it falls back to text bytes.
- **`basic` strategy controls whether original test cases are included** — it's not a transformation; it's a toggle for including untransformed plugin-generated cases.

## 🎯 Core workflow
1. **Select encodings** — load `references/encoding-strategies.md` for base64, hex, ROT13, leetspeak, homoglyph configs.
2. **Select multimodal encodings** — load `references/multimodal-encodings.md` for image, audio, video strategies + `injectVar`.
3. **Select jailbreak templates** — load `references/jailbreak-templates.md` for static DAN/Skeleton Key templates.
4. **Select minor encodings** — load `references/minor-encodings.md` for camelCase, emoji smuggling, morse code, pig latin.
5. **Layer encodings** — load `references/layering.md` for chaining multiple static strategies (e.g. base64 → rot13).
6. **Configure** — load `references/configuration.md` for basic config, plugin targeting, `basic` strategy toggle.
7. **Checklist** — run `references/checklist.md` before declaring done.

## 🎯 Core principles (summary)
- **Static = deterministic transforms, no attacker LLM** — low cost, low resource, 20-30% ASR increase (0-5% for minor encodings).
- **Encoding exploits a gap**: LLMs learn to decode encodings during pretraining, but safety training rarely includes encoded content — making encoded inputs out-of-distribution.
- **More capable models are often MORE vulnerable** — they decode encodings better, but safety training doesn't scale proportionally.
- **`jailbreak-templates` applies known static templates** (DAN, Skeleton Key) — doesn't cover modern prompt injection; pair with dynamic strategies.
- **Multimodal encodings (image/audio/video) require explicit `injectVar`** set to the media variable.
- **Layer multiple encodings** via the `layer` strategy for cumulative obfuscation.
- **`basic` strategy** controls whether original untransformed test cases are included (not a transformation itself).

## 📦 Strategy catalog

| Strategy | ID | ASR Increase | Cost | Description |
|---|---|---|---|---|
| Base64 | `base64` | 20-30% | Low | Base64 encoding bypass |
| Hex | `hex` | 20-30% | Low | Hex encoding bypass |
| ROT13 | `rot13` | 20-30% | Low | Letter rotation encoding |
| Leetspeak | `leetspeak` | 20-30% | Low | Character substitution (a→4, e→3) |
| Homoglyph | `homoglyph` | 20-30% | Low | Unicode confusable characters |
| Image Encoding | `image` | 20-30% | Low | Text-to-image conversion |
| Audio Encoding | `audio` | 20-30% | Low 🌐 | Text-to-speech encoding |
| Video Encoding | `video` | 20-30% | Low | Text-to-video encoding |
| Jailbreak Templates | `jailbreak-templates` | 20-30% | Low | Static templates (DAN, Skeleton Key) |
| camelCase | `camelCase` | 0-5% | Low | camelCase transformation |
| Emoji Smuggling | `emoji` | 0-5% | Low | UTF-8 payloads in emoji variation selectors |
| Morse Code | `morse` | 20-30% | Low | Dots and dashes encoding |
| Pig Latin | `pig-latin` | 20-30% | Low | Word transformation encoding |
| Basic | `basic` | None | Low | Toggle for including original plugin test cases |

*🌐 = uses remote inference in Promptfoo Community edition*

## References
- `references/encoding-strategies.md` — base64, hex, ROT13, leetspeak, homoglyph configs, examples, and why they work
- `references/multimodal-encodings.md` — image, audio, video encoding strategies, `injectVar` requirement, environment setup
- `references/jailbreak-templates.md` — static jailbreak templates (DAN, Skeleton Key), limitations
- `references/minor-encodings.md` — camelCase, emoji smuggling, morse code, pig latin (low ASR, completeness coverage)
- `references/layering.md` — chaining static strategies with `layer` (e.g. base64 → rot13, progressive obfuscation)
- `references/configuration.md` — basic config, plugin targeting, `basic` strategy toggle
- `references/checklist.md` — pre-flight, encoding, multimodal, layering checklist