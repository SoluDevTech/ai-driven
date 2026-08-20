---
name: promptfoo-strategies-multi-turn
description: Multi-turn (conversational) red team strategies for promptfoo — crescendo, goat, goblin, hydra, mischievous-user. Use when testing stateful chatbots or agents that maintain conversation history, gradually escalating harm over multiple turns, branching across conversation paths with persistent memory, or simulating persistent creative users.
---

# Multi-Turn Red Team Strategies

Multi-turn strategies use an attacker agent to coerce the target over multiple conversation turns. Particularly effective against stateful applications where they can convince the target to act against its purpose over time. Highest success rates (70-90% ASR) but most resource-intensive. All single-turn strategies can be applied to multi-turn apps, but multi-turn strategies require a stateful application.

## Use this skill when
- Testing stateful chatbots or agents that maintain conversation history
- Gradually escalating prompt harm over multiple turns (`crescendo`)
- Running adaptive multi-turn branching with persistent scan-wide memory (`hydra`)
- Using IICL-inspired encoding/math/logic exploration (`goblin`)
- Using Meta's GOAT (Generative Offensive Agent Tester) approach (`goat`)
- Simulating a persistent, creative mischievous user (`mischievous-user`)
- Testing conversation-based attacks with backtracking and escalation

## Do not use this skill when
- Testing a single-turn (stateless) LLM app → use `promptfoo-strategies-dynamic`
- You need static encoding bypasses → use `promptfoo-strategies-static`
- You need indirect prompt injection via web pages → use `promptfoo-strategies-indirect-injection`
- You need custom or regression strategies → use `promptfoo-strategies-custom-regression`
- The target app doesn't maintain conversation state (multi-turn strategies require stateful apps)

## 🛡️ Edge cases (mandatory handling)
- **Multi-turn strategies require a stateful application** — all single-turn strategies can be applied to multi-turn apps, but multi-turn strategies require the target to maintain conversation state.
- **`stateful: true` vs `false`** — `false` (default) replays the full transcript each turn (for stateless targets that expect full history); `true` sends only the newest turn (target must preserve earlier turns via cookies, server session, or OpenAI Agents session factory).
- **`hydra` and `goblin` require Promptfoo Cloud** — they need Cloud to coordinate the attacker agent, maintain scan-wide learnings, and manage branching logic.
- **`maxTurns` and `maxBacktracks`** — increasing these makes strategies more aggressive but slower and costlier. Defaults: `maxTurns: 10`, `maxBacktracks: 10` (for hydra/goblin), `maxTurns: 5` (for crescendo/goat/mischievous-user).
- **`continueAfterSuccess`** — by default, crescendo and goat stop on first successful attack. Set `continueAfterSuccess: true` to find additional attack vectors (longer, costlier).
- **Unblocking feature** — disabled by default. Enable with `PROMPTFOO_ENABLE_UNBLOCKING=true` when testing conversational agents that ask clarifying questions (customer service bots, domain assistants). Adds API calls and cost.
- **Backtracking** — on refusals, multi-turn strategies rewind to an earlier point and try a different approach. Only works in stateless mode (`stateful: false`). Set `maxBacktracks: 0` automatically when `stateful: true`.
- **High cost** — multi-turn strategies are the most resource-intensive. Run on a smaller number of tests/plugins, with a cheaper provider, or prefer a simpler iterative strategy.
- **`conversationId` via `transformVars`** — required for stateful targets; set `transformVars: '{ ...vars, conversationId: context.uuid }'`.

## 🎯 Core workflow
1. **Choose strategy** — load `references/strategy-selection.md` for the decision matrix (crescendo vs hydra vs goblin vs goat vs mischievous-user).
2. **Configure stateful mode** — load `references/stateful-mode.md` for `stateful: true` vs `false`, `conversationId`, session management.
3. **Configure crescendo** — load `references/crescendo.md` for gradual escalation, `maxTurns`, `continueAfterSuccess`, backtracking.
4. **Configure hydra** — load `references/hydra.md` for adaptive branching, persistent memory, Cloud requirement, `maxBacktracks`.
5. **Configure goblin** — load `references/goblin.md` for IICL-inspired exploration, encoding shifts.
6. **Configure goat/mischievous-user** — load `references/goat-mischievous.md` for GOAT and mischievous user configs.
7. **Unblocking feature** — load `references/unblocking.md` for handling clarifying questions from the target.
8. **Checklist** — run `references/checklist.md` before declaring done.

## 🎯 Core principles (summary)
- **Multi-turn = highest ASR (70-90%) but highest cost** — use for stateful apps where single-turn strategies aren't enough.
- **`crescendo`** — gradual escalation inspired by Microsoft Research. Starts benign, increases harm each turn. Backtracks on refusals.
- **`hydra` (recommended for multi-turn)** — adaptive branching with persistent scan-wide memory. Pivots to different approaches. Requires Cloud. Best for stateful agents with evasive defenses.
- **`goblin`** — Hydra mechanics with IICL-inspired attacker prompt (abstract few-shot pattern completion, encoding shifts).
- **`goat`** — Meta's GOAT (Generalized Offensive Adversarial Testing) research. Iteratively refines attack templates over multiple turns.
- **`mischievous-user`** — simulates a persistent, creative user trying different phrasings over several turns. Lower ASR (10-20%).
- **`stateful: true` sends only the newest turn**; `stateful: false` (default) replays full transcript. Choose based on your target's session handling.
- **Backtracking only in stateless mode** — on refusal, rewinds and tries a different approach up to `maxBacktracks` times.
- **`continueAfterSuccess: true`** finds additional attack vectors beyond the first success.

## 📦 Strategy catalog

| Strategy | ID | ASR Increase | Cost | Cloud? | Description |
|---|---|---|---|---|---|
| Crescendo | `crescendo` | 70-90% | High | No | Gradual escalation with backtracking |
| Hydra | `jailbreak:hydra` | 70-90% | High | Yes | Adaptive multi-turn branching with persistent memory |
| Goblin | `jailbreak:goblin` | 70-90% | High | Yes | IICL-inspired encoding/math/logic exploration |
| GOAT | `goat` | 70-90% | High | No | Generative Offensive Agent Tester (Meta research) |
| Mischievous User | `mischievous-user` | 10-20% | High | No | Persistent creative user simulations |

## References
- `references/strategy-selection.md` — decision matrix: which multi-turn strategy for which goal
- `references/stateful-mode.md` — `stateful: true` vs `false`, `conversationId`, session management, provider config
- `references/crescendo.md` — gradual escalation config, `maxTurns`, `continueAfterSuccess`, backtracking, example scenario
- `references/hydra.md` — adaptive branching, persistent memory, Cloud requirement, `maxBacktracks`, config options
- `references/goblin.md` — IICL-inspired exploration, encoding shifts, when to use
- `references/goat-mischievous.md` — GOAT and mischievous user configs, `maxTurns`, `continueAfterSuccess`
- `references/unblocking.md` — handling clarifying questions, `PROMPTFOO_ENABLE_UNBLOCKING=true`, tradeoffs
- `references/checklist.md` — strategy selection, stateful mode, config, cost, post-run checklist