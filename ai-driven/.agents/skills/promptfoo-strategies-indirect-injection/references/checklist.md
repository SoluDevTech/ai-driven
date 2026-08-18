# Checklist

Run before declaring indirect injection red team done.

## Requirements
- [ ] Target agent has web browsing/fetch capability (tools, MCP, or built-in browser)
- [ ] Promptfoo Cloud configured (`PROMPTFOO_REMOTE_GENERATION_URL` or signed in)
- [ ] Server-side page generation and exfil tracking available

## Test Mode
- [ ] **Data exfiltration** — `data-exfil` plugin selected for deterministic server-side tracking
- [ ] **Behavior manipulation** — other plugins selected (`harmful:*`, `hijacking`, `pii:*`, `contracts`) for LLM grading
- [ ] **Both** — if testing both data exfil and behavior manipulation, include `data-exfil` + other plugins

## Layering (if combining with jailbreak)
- [ ] `layer` strategy configured with `jailbreak:meta` (single-turn) or `jailbreak:hydra` (multi-turn) first
- [ ] `indirect-web-pwn` is the LAST step in the layer
- [ ] No invalid patterns (indirect-web-pwn not last, multiple agentic strategies)

## Multi-Turn (if using hydra + indirect-web-pwn)
- [ ] `jailbreak:hydra` + `indirect-web-pwn` layered for persistent multi-turn attacks
- [ ] Embedding rotation understood — page content and injection location change each turn
- [ ] Cloud available (both hydra and indirect-web-pwn require it)
- [ ] Target maintains state across turns (for stateful mode) or receives full transcript (replay mode)

## Configuration
- [ ] `numTests` set appropriately (start with 1 for data-exfil, more for other plugins)
- [ ] Plugin targeting configured if scoping to specific plugins

## Post-Run
- [ ] Data exfiltration results reviewed (did the agent send data to the tracking endpoint?)
- [ ] Behavior manipulation results reviewed (did the agent follow injected harmful instructions?)
- [ ] Per-plugin ASR compared (which injection goals succeeded?)
- [ ] Layered attack results compared to non-layered (did jailbreak + web injection find more vulnerabilities?)
- [ ] Mitigations documented:
  - [ ] Web content sanitization before processing
  - [ ] URL allowlisting for agent web browsing
  - [ ] Instruction hierarchy enforcement (user > fetched content)
  - [ ] Data exfiltration detection (outbound request monitoring)
- [ ] Re-run after mitigations to verify fixes