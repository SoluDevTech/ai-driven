# Checklist

Run end-to-end before declaring a red team done. Each item must be checked.

## Pre-Flight
- [ ] Node.js `>=22.22.0` installed
- [ ] `promptfooconfig.yaml` exists (via `redteam init` or manual)
- [ ] `prompts:` configured (inline, `file://prompt.json`, or `file://agent.py:get_prompt`)
- [ ] At least one `targets:` entry (LLM API, custom flow, or HTTP endpoint)
- [ ] Each target has a distinct `label` (if multiple targets for comparison)
- [ ] `redteam.purpose` set describing the app's intended behavior and security boundaries
- [ ] Grader available (default `gpt-5` with `OPENAI_API_KEY`, or override via `defaultTest.options.provider`)
- [ ] API keys for targets set in env vars

## Plugin Scope
- [ ] Default plugins cover the OWASP LLM01/08/09 + harmful categories
- [ ] `--plugins` scoping applied if only a subset is needed (saves time)
- [ ] `numTests` tuned per plugin (5-10 iterative, 20+ benchmarks)
- [ ] Custom `policy` plugin added for domain-specific rules (finance, healthcare, etc.)

## Strategy Selection
- [ ] `jailbreak-templates` + `jailbreak` for default coverage
- [ ] `jailbreak:composite` for maximum effectiveness
- [ ] Stateful strategies (`goat`, `crescendo`, `mischievous-user`) have `stateful: true` if multi-turn
- [ ] `translation` + `misspelling` added for guardrail evasion testing

## Run
- [ ] `npx promptfoo@latest redteam run` completed without errors
- [ ] Generation took ~5 min, eval took ~15 min (default plugins)
- [ ] Results saved to `--output results.json` if needed for drift baseline

## Post-Run
- [ ] `npx promptfoo@latest redteam report` reviewed
- [ ] Vulnerability Report checked for critical/high findings
- [ ] Failure cases investigated in the web viewer (`npx promptfoo@latest view`)
- [ ] Mitigations documented for each critical finding
- [ ] Re-run after mitigations to verify fixes

## CI/CD (if applicable)
- [ ] Red team runs on schedule or on push
- [ ] ASR threshold set (e.g. fail CI if `ASR > 15%`)
- [ ] Results uploaded as artifacts
- [ ] Slack/email alert on regression (see `promptfoo-redteam-supply-chain`)