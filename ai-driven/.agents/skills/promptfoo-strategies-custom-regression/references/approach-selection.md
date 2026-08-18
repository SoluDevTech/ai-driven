# Approach Selection

Load when choosing between custom text, custom script, layer, and retry.

## Decision Matrix

| Goal | Strategy | Coding? | When to use |
|---|---|---|---|
| Automate a manual red team discovery | `custom` (text) | No | You found a conversation pattern that works and want to automate it |
| Full programmatic control over test case transformation | Custom script (`file://`) | Yes (JS) | You need to call external APIs, implement custom logic, or create unique attack vectors |
| Chain multiple strategies together | `layer` | No | You want jailbreak → encoding, agentic → multimodal, or double encoding |
| Learn from past failures | `retry` | No | You want regression testing that incorporates previously failed test cases |

## Custom Text vs Custom Script

| Aspect | Custom Text (`custom`) | Custom Script (`file://`) |
|---|---|---|
| Coding required | No — natural language | Yes — JavaScript |
| Flexibility | Limited to conversation patterns | Full programmatic control |
| Multi-turn | Yes — follows instructions across turns | No — transforms test cases (single-turn) |
| External APIs | No | Yes — can call external APIs or models |
| Best for | Automating manual discoveries | Unique attack vectors, custom transformations |

## Layer Use Cases

| Use Case | Steps |
|---|---|
| Double encoding | `[hex, base64]` |
| Progressive obfuscation | `[leetspeak, hex, base64]` |
| Jailbreak + encoding | `[jailbreak-templates, rot13]` |
| Multi-turn + audio | `[jailbreak:hydra, audio]` |
| Multi-turn + image | `[crescendo, image]` |
| Single-turn + audio | `[jailbreak:meta, audio]` |
| Jailbreak + web injection | `[jailbreak:meta, indirect-web-pwn]` |

## Retry Use Cases

| Use Case | Config |
|---|---|
| Basic regression | `strategies: [- id: retry]` |
| Scoped to specific plugins | `strategies: [- id: retry, config: {plugins: [harmful:hate, harmful:illegal]}]` |
| Limit historical cases | `strategies: [- id: retry, config: {numTests: 10}]` |
| Combined with other strategies | `strategies: [- id: retry, - id: jailbreak]` (retry runs first) |