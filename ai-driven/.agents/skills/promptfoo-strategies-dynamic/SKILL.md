---
name: promptfoo-strategies-dynamic
description: Dynamic (iterative, single-turn) red team strategies for promptfoo — jailbreak, jailbreak:composite, jailbreak:meta, jailbreak:tree, best-of-n, GCG, citation, likert, math-prompt, authoritative-markup-injection. Use when an LLM-as-attacker iteratively refines prompts to bypass security controls, building attack taxonomies, chaining research techniques, or using academic framing.
---

# Dynamic Red Team Strategies

Dynamic strategies use an attacker LLM to mutate adversarial inputs through iterative refinement. Multiple calls to both attacker and target models determine the most effective attack vector. Higher success rates (40-90% ASR increase) than static strategies, but more resource-intensive. Stop after exhausting token budget or on successful harmful output.

## Use this skill when
- Iteratively refining prompts to bypass security controls (`jailbreak`)
- Building custom attack taxonomies with persistent memory (`jailbreak:meta`)
- Chaining multiple jailbreak techniques from research papers (`jailbreak:composite`)
- Running Tree of Attacks branching exploration (`jailbreak:tree`)
- Using Best-of-N parallel sampling from Anthropic research (`best-of-n`)
- Testing academic authority bias framing (`citation`, `likert`)
- Testing mathematical notation-based attacks (`math-prompt`)
- Testing structured markup authority exploitation (`authoritative-markup-injection`)
- Running gradient-based GCG adversarial prompt search (`gcg`)

## Do not use this skill when
- You need deterministic, low-cost encoding bypasses → use `promptfoo-strategies-static`
- You need multi-turn conversation attacks → use `promptfoo-strategies-multi-turn`
- You need indirect prompt injection via web pages → use `promptfoo-strategies-indirect-injection`
- You need custom or regression strategies → use `promptfoo-strategies-custom-regression`
- Cloud access is unavailable AND the strategy requires it (`jailbreak:meta`, `jailbreak:hydra`)

## 🛡️ Edge cases (mandatory handling)
- **Medium-to-high cost** — dynamic strategies make multiple API calls per test (attacker + target). Run on a smaller number of tests/plugins before a full test.
- **`jailbreak:meta` requires Promptfoo Cloud** — maintains persistent memory and strategic reasoning across iterations. Set `PROMPTFOO_REMOTE_GENERATION_URL` or log into Promptfoo Cloud.
- **Token budget tracking** — dynamic strategies stop after exhausting the configured token budget or on successful harmful output. Track token usage to prevent runaway costs.
- **`numIterations` default is 4** for `jailbreak` — override via `config.numIterations` or `PROMPTFOO_NUM_JAILBREAK_ITERATIONS` env var. Increase for deeper exploration, decrease for cost.
- **`jailbreak:meta` vs `jailbreak`** — meta explores multiple DISTINCT attack types (broad coverage, higher cost); standard refines ONE approach (deep, lower cost). Choose based on need.
- **GCG has low ASR (0-10%)** — gradient-based optimization is resource-intensive but often ineffective against modern models. Use for research, not primary testing.
- **`jailbreak:composite` and `jailbreak` are recommended** — 60-80% ASR increase, the highest single-turn success rates.
- **Session management with `transformVars`** — each iteration gets a new UUID via `context.uuid` to prevent conversation history from affecting subsequent attempts.

## 🎯 Core workflow
1. **Choose strategy** — load `references/strategy-selection.md` for the decision matrix (meta vs standard vs tree vs composite).
2. **Configure iterative jailbreak** — load `references/iterative-jailbreak.md` for `jailbreak` config, `numIterations`, session management.
3. **Configure meta-agent** — load `references/meta-agent.md` for `jailbreak:meta` config, Cloud requirement, broad vs deep.
4. **Configure composite/tree** — load `references/composite-tree.md` for `jailbreak:composite` and `jailbreak:tree` configs.
5. **Academic strategies** — load `references/academic-strategies.md` for `citation`, `likert`, `math-prompt`, `best-of-n`, `authoritative-markup-injection`.
6. **GCG** — load `references/gcg.md` for gradient-based optimization config.
7. **Configuration** — load `references/configuration.md` for plugin targeting, token budget, env vars.
8. **Checklist** — run `references/checklist.md` before declaring done.

## 🎯 Core principles (summary)
- **Dynamic = LLM-as-attacker iteratively refining** — multiple calls to attacker + target, higher ASR (40-90%), higher cost.
- **`jailbreak` (iterative)** — refines a single prompt through multiple iterations using LLM-as-a-Judge. 60-80% ASR. Default 4 iterations.
- **`jailbreak:meta` (recommended)** — builds custom attack taxonomy, learns from all attempts, pivots to different approaches. 70-90% ASR. Requires Cloud.
- **`jailbreak:composite` (recommended)** — chains multiple jailbreak techniques from research papers. 60-80% ASR.
- **`jailbreak:tree`** — branching attack paths based on Tree of Attacks research. 60-80% ASR.
- **`best-of-n`** — parallel sampling from Anthropic research. 40-60% ASR. High cost.
- **`citation`/`likert`** — academic authority bias framing. 40-60% ASR.
- **`math-prompt`** — mathematical notation attacks (set theory, abstract algebra). 40-60% ASR.
- **`authoritative-markup-injection`** — structured format authority exploitation. 40-60% ASR.
- **`gcg`** — gradient-based optimization. 0-10% ASR. High cost, research use.
- **Token budget tracking** prevents runaway costs; strategies stop on success or budget exhaustion.

## 📦 Strategy catalog

| Strategy | ID | ASR Increase | Cost | Description |
|---|---|---|---|---|
| Iterative Jailbreak | `jailbreak` | 60-80% | High | Lightweight iterative refinement via LLM-as-a-Judge |
| Meta-Agent | `jailbreak:meta` | 70-90% | High 🌐 | Strategic taxonomy builder with persistent memory |
| Composite | `jailbreak:composite` | 60-80% | Medium 🌐 | Chains multiple research techniques |
| Tree-based | `jailbreak:tree` | 60-80% | High | Branching attack paths (Tree of Attacks) |
| Best-of-N | `best-of-n` | 40-60% | High 🌐 | Parallel sampling (Anthropic research) |
| Citation | `citation` | 40-60% | Medium 🌐 | Academic authority bias framing |
| Likert | `likert` | 40-60% | Medium 🌐 | Academic evaluation framework framing |
| Math Prompt | `math-prompt` | 40-60% | Medium 🌐 | Mathematical notation attacks |
| Auth Markup Injection | `authoritative-markup-injection` | 40-60% | Medium 🌐 | Structured format authority exploitation |
| GCG | `gcg` | 0-10% | High 🌐 | Gradient-based optimization (research) |

*🌐 = uses remote inference in Promptfoo Community edition*

## References
- `references/strategy-selection.md` — decision matrix: which dynamic strategy for which goal
- `references/iterative-jailbreak.md` — `jailbreak` config, `numIterations`, session management, example scenario
- `references/meta-agent.md` — `jailbreak:meta` config, Cloud requirement, meta vs standard comparison, when to use
- `references/composite-tree.md` — `jailbreak:composite` and `jailbreak:tree` configs, research paper references
- `references/academic-strategies.md` — `citation`, `likert`, `math-prompt`, `best-of-n`, `authoritative-markup-injection`
- `references/gcg.md` — GCG gradient-based optimization config and limitations
- `references/configuration.md` — plugin targeting, token budget, env vars, cost management
- `references/checklist.md` — strategy selection, config, cost, post-run checklist