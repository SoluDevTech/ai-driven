---
name: promptfoo-redteam-multi-input
description: Red team multi-input LLM applications with promptfoo — apps that combine user identity, session context, form fields, and messages into one request. Use when testing authorization bypass + prompt injection combos across multiple fields, role confusion attacks, BOLA/BFLA/RBAC with user_id + action inputs, typed DOCX/PDF/image upload workflows, and role-based context testing.
---

# Red Team Multi-Input LLM Applications

Real-world AI apps combine multiple fields (user_id + message + context) into one LLM request. Single-input testing misses vulnerabilities that emerge from field interactions. Multi-input mode generates coordinated adversarial content across all variables simultaneously, uncovering authorization bypass + prompt injection combos.

## Use this skill when
- Testing apps that accept user identity alongside prompts (`user_id` + `message`)
- Testing form submissions with multiple fields sent to an AI backend
- Testing RAG with user context (retrieved content + user query + user role)
- Testing role-based access (different users should see different data)
- Testing typed DOCX/PDF/image upload workflows with indirect prompt injection
- Testing authorization bypass + prompt injection combos across fields
- Testing role confusion attacks (mismatched identity and message)

## Do not use this skill when
- Testing a single-prompt LLM app → use `promptfoo-redteam-llm`
- Testing RAG systems without user identity fields → use `promptfoo-redteam-rag`
- Testing agents with tools/state → use `promptfoo-redteam-agents`
- Testing vision/audio models with a single image input → use `promptfoo-redteam-multimodal`
- Testing guardrails → use `promptfoo-redteam-guardrails`

## 🛡️ Edge cases (mandatory handling)
- **Adding a synthetic `prompt` input** — multi-input mode auto-builds `__prompt` JSON from your inputs; do NOT set `redteam.injectVar`, add a synthetic `prompt` input, or rewrite your target to use `{{prompt}}` just to make multi-input work.
- **Hyphenated variable names** — must match `[a-zA-Z_][a-zA-Z0-9_]*`; `my-var` fails, use `my_var`. `123invalid` also fails.
- **Excluded plugins** — multi-input mode automatically skips `ascii-smuggling`, `cca`, `cross-session-leak`, `special-token-injection`, `system-prompt-override`, and dataset-backed plugins (`beavertails`, `harmbench`, `xstest`). Don't rely on these in multi-input mode.
- **Vague input descriptions** — better descriptions generate more targeted attacks. "The user making the request" is better than "user input".
- **`indirectInjectionVar` for document uploads** — when using `indirect-prompt-injection` with typed DOCX/PDF inputs, set `indirectInjectionVar` to point at the untrusted input field (e.g. `document`), not the question field.
- **Benign companion fields** — set `config.benign: true` for fields that should remain natural (e.g. the question about an uploaded document).

## 🎯 Core workflow
1. **Identify inputs** — load `references/inputs.md` to map your app's real input fields to multi-input variables.
2. **Configure target** — load `references/target-config.md` for HTTP and custom provider configs with `inputs:`.
3. **Select plugins** — load `references/plugins.md` for BOLA/BFLA/RBAC + hijacking + policy + indirect-prompt-injection.
4. **Typed uploads (if applicable)** — load `references/typed-uploads.md` for DOCX/PDF/image upload workflows.
5. **Role contexts** — load `references/contexts.md` for testing different user roles.
6. **Run + review** — `npx promptfoo@latest redteam run -c config.yaml` + `redteam report`.
7. **Checklist** — run `references/checklist.md` end-to-end before declaring done.

## 🎯 Core principles (summary)
- **`inputs:` on the target activates multi-input mode** — each key becomes a variable that plugins generate adversarial content for.
- **`__prompt` is auto-built** — Promptfoo combines all inputs into a JSON string in `__prompt`; do NOT set `injectVar` or add a synthetic `prompt` input.
- **Coordination is the attack** — both fields contain adversarial content that works together (spoofed `vendor_id` + injected `description`).
- **BOLA/BFLA/RBAC are the best multi-input plugins** — they test identity/action field interactions.
- **Variable names must match `[a-zA-Z_][a-zA-Z0-9_]*`** — no hyphens, no leading numbers.
- **Typed uploads** — `type: docx|pdf|image` with `injectionPlacements` for indirect prompt injection in documents.

## 📦 Best plugins for multi-input

| Plugin | Why |
|---|---|
| `bola` | Tests if user A can access user B's data via identity field manipulation |
| `bfla` | Tests if user can access functions beyond their role |
| `rbac` | Tests role-based access control across identity + action fields |
| `hijacking` | Tests goal hijacking via message field injection |
| `policy` | Custom rules for domain-specific authorization |
| `indirect-prompt-injection` | For document uploads — set `indirectInjectionVar` to the untrusted field |

## References
- `references/inputs.md` — identifying app inputs, variable naming rules, `__prompt` structure
- `references/target-config.md` — HTTP and custom provider configs with `inputs:`, plugin-level input overrides
- `references/plugins.md` — best multi-input plugins, excluded plugins, plugin-level config
- `references/typed-uploads.md` — DOCX/PDF/image typed inputs, `injectionPlacements`, benign companion fields
- `references/contexts.md` — role-based testing with `redteam.contexts`
- `references/checklist.md` — pre-flight, inputs, plugins, typed uploads, contexts checklist