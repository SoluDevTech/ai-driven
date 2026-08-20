# GCG (Gradient-based Optimization)

Load when configuring the GCG strategy. 0-10% ASR, high cost, research use.

## Implementation

```yaml
strategies:
  - gcg
```

**ASR**: 0-10% | **Cost**: High | **Cloud**: Yes (remote inference)

## What It Does

Implements the Greedy Coordinate Gradient attack method for finding adversarial prompts using gradient-based search techniques.

## Why ASR is Low (0-10%)

GCG is:
- **Resource-intensive** — requires many iterations of gradient-based search
- **Often ineffective against modern models** — safety training has adapted
- **Research-oriented** — useful for academic study, not primary testing

## When to Use

- **Academic research** — studying adversarial prompt optimization
- **Model comparison** — comparing GCG resistance across foundation models
- **Completeness** — including in a comprehensive strategy suite for full coverage

## When NOT to Use

- **Primary testing** — use `jailbreak`, `jailbreak:meta`, or `jailbreak:composite` instead (60-80% ASR)
- **Cost-sensitive runs** — GCG is high cost with low return
- **Production readiness** — modern models are largely resistant to GCG

## Configuration

GCG has minimal configuration options — it runs gradient-based optimization automatically:

```yaml
strategies:
  - gcg
```

For most practical red teaming, skip GCG and focus on `jailbreak:meta` (70-90% ASR) or `jailbreak:composite` (60-80% ASR).