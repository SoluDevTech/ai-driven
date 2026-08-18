# Checklist

Run before declaring multi-turn strategy red team done.

## Strategy Selection
- [ ] Strategy chosen based on goal (hydra for adaptive branching; crescendo for gradual escalation; goat for Meta research; goblin for IICL exploration; mischievous-user for creative user persona)
- [ ] Cloud availability checked (`jailbreak:hydra` and `jailbreak:goblin` require Cloud; `crescendo`, `goat`, `mischievous-user` don't)
- [ ] Target is stateful (multi-turn strategies require stateful applications)

## Stateful Mode
- [ ] `stateful: true` if target maintains server-side session (sends only newest turn)
- [ ] `stateful: false` (default) if target is stateless (replays full transcript)
- [ ] `conversationId` injected via `transformVars: '{ ...vars, conversationId: context.uuid }'` if stateful
- [ ] Provider configured for session management (HTTP cookies, OpenAI Agents session factory) if `stateful: true`
- [ ] Backtracking disabled (`maxBacktracks: 0` auto-set) if `stateful: true`

## Configuration
- [ ] `maxTurns` set appropriately (default 10 for hydra/goblin, 5 for crescendo/goat/mischievous-user)
- [ ] `maxBacktracks` set (default 10 for hydra/goblin, 5 for crescendo/goat) — only in stateless mode
- [ ] `continueAfterSuccess: true` if finding multiple attack vectors (default `false`)
- [ ] Plugin targeting configured if scoping to specific plugins

## Cloud (if using hydra/goblin)
- [ ] `PROMPTFOO_REMOTE_GENERATION_URL` set OR logged into Promptfoo Cloud
- [ ] Persistent scan-wide memory available

## Unblocking Feature
- [ ] `PROMPTFOO_ENABLE_UNBLOCKING=true` if testing conversational agents that ask clarifying questions
- [ ] Start with disabled (default) for baseline, enable if target blocks with questions
- [ ] Additional API calls and cost accounted for if enabled

## Cost Management
- [ ] Multi-turn strategies are the MOST resource-intensive — run on smaller test/plugin counts
- [ ] Consider a cheaper provider for the attacker model
- [ ] Prefer simpler iterative strategy if cost is a primary concern
- [ ] `maxTurns` and `maxBacktracks` tuned — increasing makes more aggressive but slower/costlier

## Post-Run
- [ ] Per-strategy ASR compared (which multi-turn strategies found which vulnerabilities?)
- [ ] Hydra scan-wide memory results reviewed (which tactics were reused across tests?)
- [ ] Crescendo escalation paths reviewed (which conversation sequences bypassed defenses?)
- [ ] Backtracking effectiveness checked (which alternative paths succeeded after refusal?)
- [ ] Mitigations documented:
  - [ ] Conversation length limits
  - [ ] Escalation detection
  - [ ] Refusal consistency across turns
  - [ ] Session-based rate limiting
- [ ] Re-run after mitigations to verify fixes