# Stateful vs Stateless Mode

Load when configuring session handling for multi-turn strategies.

## Two Modes

| Mode | `stateful` | Behavior | Use when |
|---|---|---|---|
| Replay (default) | `false` | Sends full conversation transcript each turn | Target is stateless or expects full history |
| Target-managed session | `true` | Sends only the newest turn; target preserves earlier turns | Target maintains server-side session state |

## Configuration

### Stateless (Default) — Replay Mode
```yaml
redteam:
  strategies:
    - id: crescendo
      config:
        stateful: false  # Default — replays full transcript each turn
```

### Stateful — Target-Managed Session
```yaml
redteam:
  strategies:
    - id: jailbreak:hydra
      config:
        stateful: true  # Sends only newest turn; target must preserve session
```

## When to Use Each

### Stateless (Replay Mode)
- Each test starts fresh
- Can "rewind" conversations when blocked (backtracking)
- Better for exploring different paths
- **Use when**: testing various approaches, target is stateless

### Stateful (Target-Managed Session)
- Maintains conversation history on the target side
- No rewinding — always moves forward
- Preserves session data between turns
- **Use when**: testing stateful applications (chatbots with memory), specific conversation flows
- `maxBacktracks` is automatically set to `0` (no backtracking possible)

## Session Management with conversationId

For stateful targets, inject a unique `conversationId` per test:

```yaml
defaultTest:
  options:
    transformVars: '{ ...vars, conversationId: context.uuid }'
```

This links messages in a conversation, enabling the target to track state across multiple messages.

## Provider Configuration for Stateful Mode

### HTTP Targets
Use [HTTP session management](https://promptfoo.dev/docs/providers/http/#server-side-session-management) — cookies or server-side sessions.

### OpenAI Agents SDK
Use [stateful OpenAI Agents sessions](https://promptfoo.dev/docs/providers/openai-agents/#stateful-red-team-runs) — session factory preserves earlier turns.

## Backtracking (Stateless Mode Only)

On refusal:
1. Conversation "rewinds" to before the refused question
2. Attacker tries a different approach
3. Continues up to `maxBacktracks` times

```yaml
redteam:
  strategies:
    - id: crescendo
      config:
        stateful: false  # Required for backtracking
        maxBacktracks: 5  # Default: 10 (hydra/goblin), 5 (crescendo/goat)
```

## Cloud Note

In Promptfoo Cloud, Hydra can derive the mode from the target configuration. In the open-source CLI/UI, set `stateful: true` only after you configure sessions in the provider.