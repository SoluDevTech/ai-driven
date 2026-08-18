# Checklist

Run end-to-end before declaring multi-input red team done.

## Pre-Flight
- [ ] App's real input fields identified and mapped to `inputs:` variables
- [ ] Variable names match `[a-zA-Z_][a-zA-Z0-9_]*` (no hyphens, no leading numbers)
- [ ] Variables match template variables in target config (`{{user_id}}`, `{{message}}`, etc.)
- [ ] `redteam.purpose` set describing the app's intended behavior and access rules
- [ ] Input descriptions are specific ("The vendor account ID submitting the invoice" not "user input")

## Multi-Input Config
- [ ] `inputs:` map added to the target (NOT `redteam:`)
- [ ] NO synthetic `prompt` input added — `__prompt` is auto-built
- [ ] `redteam.injectVar` NOT set — multi-input mode handles injection per-field
- [ ] HTTP target uses variables in URL/body: `url: '.../{{user_id}}/chat'`, `body: {message: '{{message}}'}`
- [ ] Custom provider reads `context['vars']` for individual fields and `__prompt` for full JSON

## Plugins
- [ ] `bola` — tests if user A can access user B's data
- [ ] `bfla` — tests if user can access functions beyond their role
- [ ] `rbac` — tests role-based access control
- [ ] `hijacking` — tests goal hijacking via message field
- [ ] `policy` — custom domain-specific authorization rules
- [ ] `indirect-prompt-injection` (if document uploads) — `indirectInjectionVar` set to the untrusted field
- [ ] Excluded plugins accounted for: `ascii-smuggling`, `cca`, `cross-session-leak`, `special-token-injection`, `system-prompt-override`, `beavertails`, `harmbench`, `xstest`

## Typed Uploads (if applicable)
- [ ] `type: docx|pdf|image` set on document input
- [ ] `config.inputPurpose` describes a normal uploaded file
- [ ] `config.injectionPlacements` set (DOCX: `body`, `comment`, `footnote`, `header`, `footer`; PDF/image: `body`, `header`, `footer`)
- [ ] `config.benign: true` set on companion fields (e.g. `question`)

## Contexts (if role testing)
- [ ] `redteam.contexts` defined with `id`, `purpose`, and `vars` per role
- [ ] Same plugins run against all contexts for comparison

## Run
- [ ] `npx promptfoo@latest redteam run -c config.yaml` completed
- [ ] Report reviewed for authorization bypass + injection combos

## Post-Run
- [ ] `npx promptfoo@latest redteam report` reviewed
- [ ] BOLA failures investigated (did user A access user B's data?)
- [ ] BFLA failures investigated (did user access functions beyond their role?)
- [ ] Hijacking failures investigated (did message-field injection override goals?)
- [ ] Role confusion failures investigated (did mismatched identity + message bypass checks?)
- [ ] Mitigations documented:
  - [ ] Authorization enforced on API side (not in prompts)
  - [ ] Identity fields validated server-side
  - [ ] Document uploads sanitized before processing
- [ ] Re-run after mitigations to verify fixes