# Layered Testing

Load before configuring agent red teams. Three layers for agents with state/tools.

## The Car Analogy

- **Black-box testing** = the test drive: does it get you from A to B safely?
- **Component testing** = checking the engine, brakes, and steering individually in the shop.
- **Trace-based testing** = hooking up a diagnostic computer during the drive.

All three are necessary for agents with state and tools.

## Layer 1: Black-Box (End-to-End)

Test the complete agent system as users would interact with it.

```yaml
targets:
  - id: 'my-agent-endpoint'
    config:
      url: 'https://api.mycompany.com/agent'
redteam:
  plugins:
    - agentic:memory-poisoning
    - tool-discovery
    - excessive-agency
```

**Best for**: production readiness, compliance testing, understanding emergent behaviors.

## Layer 2: Component (Direct Hooks)

Test individual agent components in isolation using custom providers.

```yaml
targets:
  - 'file://agent.py:do_planning'  # Test just planning
redteam:
  purpose: 'Customer service agent with read-only database access'
```

**Best for**: debugging specific vulnerabilities, rapid iteration, understanding failure modes.

### Component Provider Example (Tool Selection)

```python
# agent_tool_selection_provider.py
def call_api(prompt, options, context):
    try:
        available_tools = your_agent_module.get_available_tools()
        selected_tool = your_agent_module.select_tool(prompt, available_tools)
        return {"output": f"Selected tool: {selected_tool}"}
    except Exception as e:
        return {"error": str(e)}
```

### Component-Specific Plugin Selection

```yaml
redteam:
  # For testing tool selection
  plugins:
    - rbac
    - bola
  # For testing reasoning
  plugins:
    - hallucination
    - excessive-agency
  # For testing execution
  plugins:
    - ssrf
    - sql-injection
```

## Layer 3: Trace-Based (Glass Box)

OpenTelemetry tracing gives Promptfoo evidence about what the agent actually did. See `references/tracing.md` for full config.

```yaml
tracing:
  enabled: true
  otlp:
    http:
      enabled: true
targets:
  - 'http://localhost:3000/agent'
redteam:
  tracing:
    enabled: true
    includeInAttack: true
    includeInGrading: true
    spanFilter:
      - 'chat*'
      - '*tool*'
      - '*guardrail*'
  plugins:
    - excessive-agency
    - rbac
    - tool-discovery
  strategies:
    - jailbreak:meta
    - jailbreak:hydra
```

**Best for**: understanding attack propagation, validating defense-in-depth, assessing information leakage, turning findings into trajectory-based regression evals.

## When to Use Each Layer

| Situation | Layer(s) |
|---|---|
| First assessment / compliance | Black-box |
| Debugging a specific failure | Component |
| Adaptive attacks needing feedback | Trace-based (`includeInAttack: true`) |
| Evidence for grading only | Trace-based (`includeInAttack: false`, `includeInGrading: true`) |
| Full agent security assessment | All three |