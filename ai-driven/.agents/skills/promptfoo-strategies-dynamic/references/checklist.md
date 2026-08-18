# Checklist

Run before declaring dynamic strategy red team done.

## Strategy Selection
- [ ] Strategy chosen based on goal (broad coverage → `jailbreak:meta`; deep refinement → `jailbreak`; technique chaining → `jailbreak:composite`)
- [ ] Cloud availability checked (`jailbreak:meta` requires Cloud; `jailbreak`, `jailbreak:tree` don't)
- [ ] Cost tier acceptable (High: `jailbreak`, `jailbreak:meta`, `jailbreak:tree`, `best-of-n`, `gcg`; Medium: `jailbreak:composite`, `citation`, `likert`, `math-prompt`)

## Configuration
- [ ] `numIterations` set appropriately (default 4 for `jailbreak`, 10 for `jailbreak:meta`)
- [ ] `PROMPTFOO_NUM_JAILBREAK_ITERATIONS` env var set if overriding globally
- [ ] Plugin targeting configured (if scoping strategies to specific plugins)
- [ ] Token budget tracked (strategies stop on budget exhaustion or success)
- [ ] Session management: `transformVars: '{ ...vars, sessionId: context.uuid }'` if needed

## Cloud (if using `jailbreak:meta`)
- [ ] `PROMPTFOO_REMOTE_GENERATION_URL` set OR logged into Promptfoo Cloud
- [ ] Persistent memory and strategic reasoning available

## Cost Management
- [ ] Started with smaller test/plugin count before full run
- [ ] Cost estimate: dynamic strategies make multiple API calls per test (attacker + target)
- [ ] Recommended starting point: `jailbreak:meta` + `jailbreak:composite` (or `jailbreak` + `jailbreak:tree` if no Cloud)

## Academic Strategies (if used)
- [ ] `citation` — academic authority bias framing
- [ ] `likert` — Likert-scale evaluation framework
- [ ] `math-prompt` — mathematical notation attacks
- [ ] `authoritative-markup-injection` — structured format authority
- [ ] `best-of-n` — parallel sampling (highest cost, plan accordingly)

## GCG (if used)
- [ ] Understand GCG has 0-10% ASR — research use, not primary testing
- [ ] High cost accepted
- [ ] Included for completeness, not as primary attack vector

## Post-Run
- [ ] Per-strategy ASR compared (which dynamic strategies found which vulnerabilities?)
- [ ] `jailbreak:meta` broad coverage results reviewed (which attack types worked?)
- [ ] `jailbreak` deep refinement results reviewed (which single approach was most effective?)
- [ ] Cost per finding calculated (tokens spent / vulnerabilities found)
- [ ] Mitigations documented for each vulnerability class found
- [ ] Re-run after mitigations to verify fixes