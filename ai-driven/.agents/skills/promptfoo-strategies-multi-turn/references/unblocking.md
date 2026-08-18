# Unblocking Feature

Load when testing conversational agents that ask clarifying questions. Disabled by default.

## The Problem

Multi-turn strategies may stall when the target asks clarifying questions:
- Target: "What industry are you in?"
- Target: "Can you provide more details?"
- Target: "Which country are you located in?"

These block conversation progress, preventing the attacker from reaching the harmful request.

## Configuration

Enable unblocking via environment variable:

```bash
export PROMPTFOO_ENABLE_UNBLOCKING=true
promptfoo redteam run
```

## How It Works

When unblocking is enabled and the target asks a clarifying question, the strategy automatically provides a plausible answer to unblock the conversation:

- Target: "What industry are you in?" → Unblocking: "I work in healthcare"
- Target: "Can you provide more details?" → Unblocking: "I need this for [specific use case]"
- Target: "Which country are you located in?" → Unblocking: "United States"

## When to Enable

Enable unblocking when testing:
- **Conversational agents** that frequently ask clarifying questions
- **Customer service bots** that require context before proceeding
- **Domain-specific assistants** that need additional information
- Systems where realistic multi-turn interactions are critical

## When to Keep Disabled (Default)

Keep disabled when:
- Testing simple question-answering systems
- Optimizing for evaluation speed and lower costs
- Measuring how well the target handles ambiguous queries

## Tradeoffs

### Benefits
- More realistic adversarial conversations
- Better coverage for conversational systems
- Surfaces multi-turn vulnerabilities that require context

### Costs
- Additional API calls for each blocking detection
- Increased evaluation time
- Higher token usage and costs

## Tip

Start with unblocking disabled to establish a baseline, then enable it if you notice your target frequently asks clarifying questions during red team attacks.