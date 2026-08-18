# Composite and Tree-based Jailbreaks

Load when configuring `jailbreak:composite` or `jailbreak:tree`. 60-80% ASR.

## Composite Jailbreaks (`jailbreak:composite`)

Chains multiple jailbreak techniques from research papers to create more sophisticated attacks.

```yaml
strategies:
  - jailbreak:composite
```

**ASR**: 60-80% | **Cost**: Medium | **Cloud**: Yes (remote inference)

**When to use**: when single techniques aren't enough and you want research-backed technique chaining. Recommended as a complementary strategy to `jailbreak:meta`.

## Tree-based Jailbreaks (`jailbreak:tree`)

Creates a tree of attack variations based on the Tree of Attacks research paper (Mehrotra et al., 2023, arXiv:2312.02119).

```yaml
strategies:
  - jailbreak:tree
```

**ASR**: 60-80% | **Cost**: High | **Cloud**: No

**When to use**: when you want branching exploration without Cloud access, or the Tree of Attacks approach fits your needs.

## Plugin Targeting

Both strategies support plugin targeting:

```yaml
strategies:
  - id: jailbreak:tree
    config:
      plugins:
        - harmful:hate  # Only apply to harmful:hate plugin
```

## Combining with Other Strategies

### Quick Start (Recommended)
```yaml
redteam:
  strategies:
    - jailbreak:meta       # Broad coverage
    - jailbreak:composite  # Technique chaining
```

### With Static Encoding
Layer composite with encoding for obfuscated attacks:
```yaml
strategies:
  - id: layer
    config:
      steps:
        - jailbreak:composite
        - base64
```

See `promptfoo-strategies-custom-regression` skill for full `layer` documentation.

## Research References

- **Tree of Attacks**: Mehrotra, A., et al. (2023). "Tree of Attacks: Jailbreaking Black-Box LLMs Automatically". arXiv:2312.02119
- Composite chains techniques from multiple published jailbreak research papers.