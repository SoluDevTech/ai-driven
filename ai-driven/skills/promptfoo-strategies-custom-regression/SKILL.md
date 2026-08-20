---
name: promptfoo-strategies-custom-regression
description: Custom, composition, and regression red team strategies for promptfoo — custom (text-based multi-turn), custom strategy scripts (JavaScript), layer (compose multiple strategies sequentially), retry (regression testing from historical failures). Use when creating user-defined attack strategies, chaining strategies together (jailbreak → encoding, agentic → multimodal), building regression test suites from past failures, or writing custom JavaScript strategy transforms.
---

# Custom, Composition, and Regression Strategies

Four strategies for advanced use cases: `custom` (text-based multi-turn instructions, no coding), `custom` scripts (JavaScript transformations), `layer` (compose multiple strategies sequentially), and `retry` (regression testing from historical failures). These let you create user-defined approaches, chain strategies into sophisticated attack chains, and learn from past failures.

## Use this skill when
- Creating a custom multi-turn strategy from natural language instructions (no coding)
- Writing custom JavaScript strategy transforms for programmatic control
- Composing multiple strategies sequentially (`layer`) — e.g. jailbreak → base64, agentic → multimodal
- Building a regression test suite that learns from past failures (`retry`)
- Chaining agentic + multimodal strategies (e.g. hydra → audio, crescendo → image)
- Automating manual red team discoveries into reusable strategies
- Creating named strategy variants for different attack personas

## Do not use this skill when
- You need standard static encoding strategies → use `promptfoo-strategies-static`
- You need standard dynamic/iterative strategies → use `promptfoo-strategies-dynamic`
- You need standard multi-turn strategies → use `promptfoo-strategies-multi-turn`
- You need indirect prompt injection via web pages → use `promptfoo-strategies-indirect-injection`

## 🛡️ Edge cases (mandatory handling)
- **Layer ordering rules** — agentic strategies (hydra, crescendo, goat, jailbreak) must come FIRST (max 1); multimodal strategies (audio, image) must come LAST (max 1); text transforms (base64, rot13, leetspeak) go in between. Violating this corrupts the attack.
- **Transforms before agentic modify the attack goal** — placing `base64` before `jailbreak:hydra` encodes the goal itself, not each turn. Rarely useful.
- **Multiple agentic or multiple multimodal strategies in one layer** — invalid; only 1 agentic first, 1 multimodal last.
- **`retry` is target-specific** — only retries test cases that previously failed against the SAME target system (identified by target label). Ensure consistent labels across runs.
- **`retry` runs first in the pipeline** — other strategies build upon historical test cases.
- **`retry` uses local database only** — Cloud sharing of retry test cases across teams is coming soon.
- **Custom strategy scripts need `strategyId` in metadata** — preserve original `pluginId` via spread operator while adding `strategyId`.
- **Custom text-based strategies** — the AI has access to the objective, current turn number, turns remaining, and conversation history. Write instructions accordingly.
- **Labels for multiple layer strategies** — without labels, layer strategies are deduplicated by their steps. Use `label` to have multiple distinct layer strategies in the same config.
- **Test case multiplication** — some strategies multiply test cases (e.g. global `language: ['en', 'es', 'fr']` multiplies by 3). Plan test counts to avoid excessive evaluation time.

## 🎯 Core workflow
1. **Choose approach** — load `references/approach-selection.md` for custom text vs custom script vs layer vs retry.
2. **Custom text strategy** — load `references/custom-text.md` for `id: custom` with `strategyText`, no coding required.
3. **Custom script strategy** — load `references/custom-script.md` for `file://custom-strategy.js` with JavaScript `action` function.
4. **Layer composition** — load `references/layer.md` for chaining strategies, ordering rules, valid/invalid patterns, agentic + multimodal.
5. **Retry regression** — load `references/retry.md` for `id: retry` config, `numTests`, `plugins`, target-specific retry.
6. **Custom provider for multimodal** — load `references/custom-provider.md` for handling hybrid audio/image payloads from layer.
7. **Checklist** — run `references/checklist.md` before declaring done.

## 🎯 Core principles (summary)
- **`custom` (text-based)** — write natural language instructions for multi-turn strategies. No coding. The AI follows your instructions across conversation turns. Good for automating manual discoveries.
- **Custom strategy scripts** — JavaScript `action(testCases, injectVar, config)` function for full programmatic control. Transform test cases, call external APIs, create unique attack vectors.
- **`layer`** — compose multiple strategies sequentially. Two modes: transform chain (all static) and agentic + per-turn transforms (agentic first, multimodal last). Enables sophisticated attack chains.
- **`retry`** — regression testing that automatically incorporates previously failed test cases. Target-specific (same label). Runs first in pipeline. 50-70% ASR increase from historical knowledge.
- **Layer ordering** — agentic first (max 1), text transforms middle, multimodal last (max 1). Violating this corrupts the attack.
- **Labels for multiple layers** — use `label` field to have multiple distinct layer strategies in the same config.
- **`retry` is target-specific** — only retries failures against the same target (by label). Ensure consistent labels.
- **Custom scripts preserve metadata** — spread `...testCase.metadata` to keep `pluginId` while adding `strategyId`.

## 📦 Strategy catalog

| Strategy | ID | Cost | ASR | Description |
|---|---|---|---|---|
| Custom (text-based) | `custom` | Variable | Variable | Natural language multi-turn instructions, no coding |
| Custom Script | `file://custom-strategy.js` | Variable | Variable | JavaScript `action` function for programmatic control |
| Layer | `layer` | Cumulative | Cumulative | Compose multiple strategies sequentially |
| Retry | `retry` | Low | 50-70% | Regression testing from historical failures |

## References
- `references/approach-selection.md` — decision matrix: custom text vs custom script vs layer vs retry
- `references/custom-text.md` — `id: custom` with `strategyText`, instruction patterns, stateful vs stateless, named variants, debugging
- `references/custom-script.md` — JavaScript `action` function, `file://custom-strategy.js`, config options, example script
- `references/layer.md` — chaining strategies, ordering rules, valid/invalid patterns, agentic + multimodal, labels, step-level plugin targeting
- `references/retry.md` — `id: retry` config, `numTests`, `plugins`, target-specific retry, how it works, best practices
- `references/custom-provider.md` — handling hybrid audio/image payloads from layer strategy, hybrid JSON format
- `references/checklist.md` — approach, custom, layer, retry, multimodal provider checklist