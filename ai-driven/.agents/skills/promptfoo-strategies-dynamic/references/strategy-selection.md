# Strategy Selection

Load when choosing a dynamic strategy. Decision matrix by goal, cost, and coverage.

## Quick Start (Recommended)

For most applications, this provides comprehensive single-turn coverage:

```yaml
redteam:
  strategies:
    - jailbreak:meta      # Single-turn agentic attacks (broad)
    - jailbreak:composite # Combined research techniques (deep)
```

## Decision Matrix

| Goal | Strategy | ASR | Cost | Cloud? |
|---|---|---|---|---|
| Find any vulnerability (broad) | `jailbreak:meta` | 70-90% | High | Yes |
| Deep refinement of one approach | `jailbreak` | 60-80% | High | No |
| Chain research techniques | `jailbreak:composite` | 60-80% | Medium | Yes |
| Branching exploration | `jailbreak:tree` | 60-80% | High | No |
| Anthropic research method | `best-of-n` | 40-60% | High | Yes |
| Academic authority bias | `citation` or `likert` | 40-60% | Medium | Yes |
| Math notation attacks | `math-prompt` | 40-60% | Medium | Yes |
| Structured markup authority | `authoritative-markup-injection` | 40-60% | Medium | Yes |
| Gradient-based research | `gcg` | 0-10% | High | Yes |

## Meta vs Standard Jailbreak

| Aspect | Meta-Agent (`jailbreak:meta`) | Standard (`jailbreak`) |
|---|---|---|
| Approach | Explores multiple distinct attack types | Refines variations of single approach |
| Coverage | Broad — tests different attack categories | Deep — exhausts one approach |
| Cost | Higher (more diverse attempts) | Lower (focused refinement) |
| ASR | 70-90% | 60-80% |
| Cloud required | Yes | No |
| Best for | Finding any vulnerability in robust systems | Testing specific attack patterns, no Cloud |

## When to Use Each

**Use `jailbreak:meta` when:**
- Testing production systems needing comprehensive coverage
- Guardrails block obvious approaches but may miss alternative angles
- Cost is less critical than finding all vulnerabilities
- Cloud access is available

**Use `jailbreak` when:**
- Running large-scale tests where API cost is a primary concern
- Testing early-stage systems without sophisticated defenses
- Cloud access is unavailable

**Use `jailbreak:composite` when:**
- You want research-backed technique chaining
- Single techniques aren't enough
- Medium cost is acceptable

**Use `jailbreak:tree` when:**
- You want branching exploration without Cloud
- Tree of Attacks research approach fits your needs

## Cost Tiers

| Tier | Strategies | When to use |
|---|---|---|
| Low cost | Static strategies (see `promptfoo-strategies-static`) | Baseline, quick screening |
| Medium cost | `jailbreak:composite`, `citation`, `likert`, `math-prompt`, `authoritative-markup-injection` | Balanced coverage |
| High cost | `jailbreak`, `jailbreak:meta`, `jailbreak:tree`, `best-of-n`, `gcg` | Deep assessment, production readiness |