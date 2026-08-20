# Checklist

Run end-to-end before declaring RAG red team done.

## Pre-Flight
- [ ] RAG provider implemented (`rag_redteam_provider.py` with `call_api`)
- [ ] `redteam.purpose` set as an explicit security contract (what data is off-limits)
- [ ] Retrieved docs placed in a separate user/context message — NOT in the system message
- [ ] `indirectInjectionVar` matches the variable holding retrieved docs (e.g. `context` for `{{context}}`)

## Attack Surfaces
- [ ] **Prompt injection (user)** — `indirect-prompt-injection` + `jailbreak` + `jailbreak-templates`
- [ ] **Context injection (KB docs)** — `indirect-prompt-injection` with `indirectInjectionVar: context`
- [ ] **Data poisoning** — `competitors`, `harmful:misinformation-disinformation`, `bias`, custom `policy`
- [ ] **RAG document poisoning** — `promptfoo redteam poison` docs ingested into KB, then `redteam run`
- [ ] **Source attribution fabrication** — `rag-source-attribution` plugin
- [ ] **PII / data exfiltration** — `pii:direct`, `pii:api-db`, `pii:social`, `harmful:privacy`, custom `policy`
- [ ] **Context window overflow** — fixture with `chat_turns: 1000` + Jinja filler template
- [ ] **Retrieval manipulation** — `hallucination`, custom `policy`

## Component-Level Testing
- [ ] `retrieval_only_provider.py` implemented (tests retrieval in isolation)
- [ ] `generation_only_provider.py` implemented (tests generation with fixed malicious context)
- [ ] `full_rag_provider.py` implemented (end-to-end pipeline)
- [ ] Component-level results compared to identify which component is most vulnerable

## Custom Policy
- [ ] Custom `policy` plugin added for domain-specific rules (finance, healthcare, etc.)
- [ ] Policy explicitly states what data must never be disclosed

## Run
- [ ] `npx promptfoo@latest redteam run` completed
- [ ] Results saved with `--output results.json` if establishing a drift baseline

## Post-Run
- [ ] `npx promptfoo@latest redteam report` reviewed
- [ ] Indirect injection failures investigated (did the model follow context-embedded instructions?)
- [ ] Source attribution fabrication failures checked (did the model cite non-existent sources?)
- [ ] PII exfiltration failures checked (did the model disclose sensitive data?)
- [ ] Mitigations documented:
  - [ ] Retrieved docs moved to separate message (if not already)
  - [ ] Content validation added for KB updates
  - [ ] Citation verification added
  - [ ] Output filtering for PII added
- [ ] Re-run after mitigations to verify fixes