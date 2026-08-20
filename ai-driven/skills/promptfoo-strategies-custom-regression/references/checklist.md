# Checklist

Run before declaring custom/regression strategy red team done.

## Approach Selection
- [ ] Approach chosen: custom text (no coding), custom script (JS), layer (composition), or retry (regression)
- [ ] If layer: agentic first (max 1), text transforms middle, multimodal last (max 1)
- [ ] If retry: target label is consistent across runs

## Custom Text Strategy (if used)
- [ ] `strategyText` written with clear, specific instructions
- [ ] Instructions based on manual testing discoveries
- [ ] `maxTurns` set appropriately (start small, increase if needed)
- [ ] `stateful: true` if testing stateful apps; `false` (default) for backtracking
- [ ] `continueAfterSuccess: true` if finding multiple attack vectors
- [ ] Named variants created for different approaches (`custom:aggressive`, `custom:subtle`)
- [ ] Strategy tested with small `maxTurns` before deployment
- [ ] Debugged: not too vague, not too rigid, not too aggressive, not too subtle

## Custom Script Strategy (if used)
- [ ] JavaScript `action(testCases, injectVar, config)` function implemented
- [ ] `strategyId` added to metadata while preserving original `pluginId` via spread
- [ ] `file://custom-strategy.js` referenced in config
- [ ] Config options passed via `config` object
- [ ] Script tested individually before combining in layer

## Layer Strategy (if used)
- [ ] `steps` array ordered correctly: agentic first, text transforms middle, multimodal last
- [ ] No invalid patterns: agentic not first, multimodal not last, multiple agentic, multiple multimodal
- [ ] `label` set for each layer strategy if using multiple in the same config
- [ ] Step-level plugin targeting configured if needed
- [ ] Advanced config (object-based steps with individual configs) used where needed
- [ ] Test case multiplication accounted for (plan test counts)
- [ ] Tested small before scaling up

## Retry Strategy (if used)
- [ ] `id: retry` added to strategies (runs first in pipeline)
- [ ] Target label consistent across runs (retry is target-specific)
- [ ] `numTests` set (max historical test cases per plugin)
- [ ] `plugins` list set if scoping to specific plugins
- [ ] Previous red team scan graded before running retry
- [ ] Combined with other strategies for maximum coverage (retry first, then jailbreak/etc.)

## Custom Provider for Multimodal (if using layer + audio/image)
- [ ] Custom provider handles `_promptfoo_audio_hybrid` flag
- [ ] History extracted from `parsed.history` as text messages
- [ ] Current turn extracted from `parsed.currentTurn` with audio/image data
- [ ] Fallback to plain text if parsing fails
- [ ] Data URL wrapping for images (`data:image/png;base64,...`)
- [ ] Audio format defaults to `mp3` if not specified

## Post-Run
- [ ] Custom strategy results reviewed (did the conversation pattern bypass defenses?)
- [ ] Layer results compared to individual strategies (did composition find more vulnerabilities?)
- [ ] Retry results reviewed (are past failures still failing, or are they now fixed?)
- [ ] Per-strategy ASR compared
- [ ] Mitigations documented for each vulnerability found
- [ ] Re-run after mitigations to verify fixes
- [ ] Retry strategy will learn from this run's failures for next time