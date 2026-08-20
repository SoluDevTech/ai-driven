# Academic and Authority Strategies

Load when using academic framing or authority bias strategies. 40-60% ASR, medium cost.

## Citation

Tests vulnerability to academic authority bias by framing harmful requests in research contexts.

```yaml
strategies:
  - citation
```

**ASR**: 40-60% | **Cost**: Medium | **Cloud**: Yes

**When to use**: testing if academic framing ("for a research paper", "in an academic context") bypasses safety controls.

## Likert-based Jailbreaks

Leverages academic evaluation frameworks and Likert scales to frame harmful requests within research contexts.

```yaml
strategies:
  - likert
```

**ASR**: 40-60% | **Cost**: Medium | **Cloud**: Yes

**When to use**: testing if Likert-scale evaluation framing bypasses safety controls. Published by Anthropic and Stanford.

## Best-of-N

Tests multiple variations in parallel using the Best-of-N technique from Anthropic research.

```yaml
strategies:
  - best-of-n
```

**ASR**: 40-60% | **Cost**: High | **Cloud**: Yes

**When to use**: when you want to test many variations in parallel. High cost due to parallel sampling. Published by Anthropic and Stanford.

## Math Prompt

Tests resilience against mathematical notation-based attacks using set theory and abstract algebra.

```yaml
strategies:
  - math-prompt
```

**ASR**: 40-60% | **Cost**: Medium | **Cloud**: Yes

**When to use**: testing if mathematical framing (set theory, abstract algebra notation) bypasses safety controls. Useful for STEM-focused LLMs.

## Authoritative Markup Injection

Tests vulnerability to authoritative formatting by embedding prompts in structured markup that exploits trust in formatted content.

```yaml
strategies:
  - authoritative-markup-injection
```

**ASR**: 40-60% | **Cost**: Medium | **Cloud**: Yes

**When to use**: testing if structured formats (XML, JSON, markdown with authority markers) exploit the model's trust in formatted content.

## Combining Academic Strategies

```yaml
redteam:
  strategies:
    - citation
    - likert
    - math-prompt
    - authoritative-markup-injection
```

Each generates its own test cases from plugin payloads, multiplying coverage across academic framing vectors.