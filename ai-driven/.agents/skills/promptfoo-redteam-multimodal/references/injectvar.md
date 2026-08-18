# injectVar — The Critical Multimodal Setting

Load before configuring any multimodal red team. The single most important setting.

## The Problem

`injectVar` specifies which template variable receives adversarial content. It defaults to the **last** template variable, which is WRONG for multimodal.

With a prompt template like:
```
{{image}} {{question}}
```

The default `injectVar` is `question` — the text variable, not the image. Adversarial content goes into the text, not the media.

## The Fix

ALWAYS set `injectVar` explicitly:

```yaml
redteam:
  injectVar: image  # adversarial content goes into the image, not the question
```

## When to Use Which

| Approach | `injectVar` | Why |
|---|---|---|
| Static image with variable text | `question` | Image is fixed; adversarial content is the text prompt |
| Image strategy (text→image) | `image` | Adversarial text is rendered into the image |
| UnsafeBench | `image` | Real unsafe images are the adversarial content |
| VLGuard | `image` | Curated unsafe images are the adversarial content |
| Audio strategy | `audio` | Adversarial text is converted to audio |
| Video strategy | `video` | Adversarial text is converted to video |

## Common Mistake

```yaml
# WRONG — injectVar defaults to "question" (last variable), adversarial
# content never reaches the image
prompts:
  - file://image-prompt.json  # uses {{image}} and {{question}}
redteam:
  # injectVar not set → defaults to "question"
  plugins:
    - harmful:hate

# CORRECT — explicitly set injectVar to the media variable
redteam:
  injectVar: image
  plugins:
    - harmful:hate
```

## Warning

Always set `injectVar` explicitly for multimodal prompts. It defaults to the **last** template variable, which may not be the media variable. With `{{image}} {{question}}`, the default is `question`.