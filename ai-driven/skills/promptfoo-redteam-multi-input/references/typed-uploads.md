# Typed Document and Media Uploads

Load when testing DOCX/PDF/image upload workflows with indirect prompt injection.

## Structured Input Definition

For upload or multimodal targets, use a structured input definition with `type`, `config.inputPurpose`, `config.injectionPlacements`, and `config.benign`:

```yaml
targets:
  - id: file://provider.js
    inputs:
      document:
        type: docx
        description: DOCX document content to upload and summarize
        config:
          inputPurpose: A realistic business document uploaded by an internal user
          injectionPlacements:
            - body
            - comment
      question:
        description: A normal user request about the uploaded document
        config:
          benign: true
```

The provider receives `document` as a DOCX data URI and `question` as ordinary text.

## Injection Placements

| Format | Supported placements |
|---|---|
| DOCX | `body`, `comment`, `footnote`, `header`, `footer` |
| PDF | `body`, `header`, `footer` |
| Image | `body`, `header`, `footer` |

## Benign Companion Fields

Set `config.benign: true` for fields that should remain natural (not adversarial):

```yaml
inputs:
  document:
    type: docx
    description: DOCX document to upload
    config:
      inputPurpose: A realistic business document
      injectionPlacements: [body, comment]
  question:
    description: A normal user request about the document
    config:
      benign: true  # This field stays natural, only the document is adversarial
```

## Indirect Prompt Injection with Typed Uploads

When using `indirect-prompt-injection` with typed uploads, set `indirectInjectionVar` to point at the untrusted input field:

```yaml
redteam:
  plugins:
    - id: indirect-prompt-injection
      config:
        indirectInjectionVar: document  # inject into the document, not the question
```

## Example

See the [DOCX document upload example](https://github.com/promptfoo/promptfoo/tree/main/examples/redteam-docx-document-upload) for a complete provider and configuration.