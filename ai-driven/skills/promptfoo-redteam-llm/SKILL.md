---
name: promptfoo-redteam-llm
description: Red team an LLM application end-to-end with promptfoo — the foundational workflow. Use when setting up the first red team for an LLM app, configuring prompts/targets/plugins/strategies, generating adversarial test cases, and reviewing the vulnerability report. Covers OWASP LLM01/08/09, PII, harmful content, hallucination, hijacking.
---

# Red Team an LLM Application with Promptfoo

Run the canonical promptfoo red team workflow against an LLM application: configure prompts and targets, generate adversarial test cases via plugins, wrap them in attack strategies, run the pentest, and review the vulnerability report.

## Use this skill when
- Setting up the first red team for an LLM application
- Configuring `promptfooconfig.yaml` (prompts, targets, plugins, strategies, grader)
- Generating adversarial tests with `promptfoo redteam generate` / `redteam run`
- Reviewing the vulnerability report with `promptfoo redteam report`
- Scoping a red team to specific OWASP LLM Top 10 categories (LLM01, LLM08, LLM09)
- Comparing multiple LLM targets side-by-side

## Do not use this skill when
- Testing a content filter / guardrail service directly → use `promptfoo-redteam-guardrails`
- Testing a RAG system with retrieved context → use `promptfoo-redteam-rag`
- Testing LLM agents with tools/state/memory → use `promptfoo-redteam-agents`
- Testing an app with multiple input fields (user_id + message) → use `promptfoo-redteam-multi-input`
- Testing vision/audio/video models → use `promptfoo-redteam-multimodal`
- Assessing a foundation/base model in isolation → use `promptfoo-redteam-foundation-models`
- Setting up CI/CD drift detection or supply chain gates → use `promptfoo-redteam-supply-chain`

## 🛡️ Edge cases (mandatory handling)
Every red team config MUST handle these defensively — not just the happy path:
- **Missing grader API key** — the default grader is `gpt-5` requiring `OPENAI_API_KEY`; if unavailable, override via `defaultTest.options.provider` (e.g. `ollama:chat:llama4:scout`) or every test fails to grade
- **Empty prompt** — if the user has no prompt (direct API pentest), omit the `prompts:` field entirely; do not leave an empty string
- **Multiple targets** — when comparing models, each target must have a distinct `label` or results are indistinguishable in the report
- **Long generation time** — `redteam generate` takes ~5 min, `redteam eval` takes ~15 min for default plugins; set CI timeouts accordingly
- **Plugin scope** — running all default plugins when only a subset is needed wastes time; use `--plugins 'harmful,hijacking'` to scope
- **Chat-style vs single-turn prompts** — chat-style prompts go in `prompt.json` referenced as `file://prompt.json`; inline `prompts:` strings are single-turn

## 🎯 Core workflow
1. **Scaffold** — `npx promptfoo@latest redteam init my-project --no-gui` creates `promptfooconfig.yaml`.
2. **Configure prompts** — load `references/prompts-and-targets.md` for prompt formats and target types.
3. **Select plugins** — load `references/plugins.md` to map vulnerability classes to plugin IDs.
4. **Select strategies** — load `references/strategies.md` for attack-framing options.
5. **Generate + run** — `npx promptfoo@latest redteam run` (generate + eval in one step).
6. **Review** — `npx promptfoo@latest redteam report` opens the vulnerability report.
7. **Checklist** — run `references/checklist.md` end-to-end before declaring done.

## 🎯 Core principles (summary)
- **Plugin = what vulnerability class**; **Strategy = how the attacker frames it**. Pair them under `redteam.plugins` + `redteam.strategies`.
- **`promptfooconfig.yaml` is the single source of truth** — prompts, targets, plugins, strategies, grader, purpose all live here.
- **Treat the red team as pentest, not unit tests** — tests are adversarial, scored by an LLM grader, not deterministic.
- **Default plugins cover OWASP LLM01 (injection/jailbreak), LLM08 (excessive agency), LLM09 (overreliance)** + harmful categories from ML Commons / HarmBench.
- **`purpose` guides generation and grading** — always set `redteam.purpose` describing the app's intended behavior and security boundaries.
- **Multiple targets = side-by-side comparison** — set 2+ `targets:` with distinct `label`s to compare models.

## 📦 Default stack
- Runtime: Node.js `>=22.22.0`
- CLI: `npx promptfoo@latest`
- Default grader: `gpt-5` (override via `defaultTest.options.provider`)
- Default plugins: `contracts`, `excessive-agency`, `hallucination`, `harmful`, `imitation`, `hijacking`, `overreliance`, `pii`, `politics`
- Optional plugin: `competitors`
- Generation time: ~5 min
- Eval time: ~15 min (default plugins)

## References
- `references/prompts-and-targets.md` — prompt formats (inline, chat-style JSON, dynamic Python/JS) and target types (LLM APIs, custom flows, HTTP endpoints, webhooks)
- `references/plugins.md` — default + optional plugins, vulnerability-class mapping, OWASP LLM Top 10 mapping, harmful categories
- `references/strategies.md` — jailbreak variants, `--plugins` scoping, `numTests` tuning, grader override
- `references/checklist.md` — pre-flight and post-run checklist
- `references/cli.md` — full CLI command reference (init, generate, eval, run, report, view)