# Meta-Agent Jailbreaks (`jailbreak:meta`)

Load when configuring the meta-agent strategy. 70-90% ASR, requires Cloud.

## Implementation

```yaml
# Basic usage
strategies:
  - jailbreak:meta

# With configuration
strategies:
  - id: jailbreak:meta
    config:
      numIterations: 50  # Optional: default is 10
```

Override via env var:
```bash
PROMPTFOO_NUM_JAILBREAK_ITERATIONS=5
```

## Cloud Required

This strategy requires Promptfoo Cloud to maintain persistent memory and strategic reasoning across iterations. Set `PROMPTFOO_REMOTE_GENERATION_URL` or log into Promptfoo Cloud.

## How It Works

Unlike standard `jailbreak` that refines a single prompt, the meta-agent:
1. Builds a custom taxonomy of attack approaches
2. Maintains memory across iterations
3. Adapts strategy based on target responses
4. Pivots to fundamentally different techniques when one approach fails

This provides broader coverage at the cost of more API calls.

## Meta-Agent vs Standard Jailbreak

| Aspect | Meta-Agent | Standard Iterative |
|---|---|---|
| Approach | Explores multiple distinct attack types | Refines variations of single approach |
| Coverage | Broad — tests different attack categories | Deep — exhausts one approach |
| Cost | Higher (more diverse attempts) | Lower (focused refinement) |
| ASR | 70-90% | 60-80% |
| Cloud | Required | Not required |
| Best for | Finding any vulnerability in robust systems | Testing specific attack patterns |

The meta-agent stops when:
- It finds a vulnerability
- Determines the target is secure
- Reaches max iterations

## When to Use

**Use `jailbreak:meta` when:**
- Testing production systems needing comprehensive attack-type coverage
- Guardrails block obvious approaches but may miss alternative angles
- Cost is less critical than finding all potential vulnerabilities
- Cloud access is available

**Use standard `jailbreak` when:**
- Running large-scale tests where API cost is a primary concern
- Testing early-stage systems without sophisticated defenses
- Cloud access is unavailable

## Quick Start (Recommended)

For most applications, pair with `jailbreak:composite`:

```yaml
redteam:
  strategies:
    - jailbreak:meta      # Broad single-turn coverage
    - jailbreak:composite # Deep technique chaining
```