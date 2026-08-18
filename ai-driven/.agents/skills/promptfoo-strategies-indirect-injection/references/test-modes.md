# Test Modes

Load when choosing between data exfiltration and behavior manipulation testing.

## Two Test Modes

### Data Exfiltration Detection
Test whether injected instructions can trick the agent into leaking sensitive data to external URLs.

```yaml
redteam:
  plugins:
    - data-exfil
  strategies:
    - indirect-web-pwn
```

- **Detection**: server-side HTTP request tracking
- **Deterministic**: binary pass/fail — did the agent send data to the tracking endpoint?
- **Data captured**: query parameters, request body, headers containing sensitive data

### Indirect Prompt Injection (Behavior Manipulation)
Test whether injected instructions can manipulate the agent's behavior or output.

```yaml
redteam:
  plugins:
    - harmful:violent-crime
    - hijacking
    - pii:direct
  strategies:
    - indirect-web-pwn
```

- **Detection**: LLM-based response analysis
- **Not deterministic**: LLM grader evaluates whether the response violates the plugin's criteria
- **Context-aware**: grader considers the injected instruction and response content

## Decision

| Goal | Mode | Plugin |
|---|---|---|
| Test if agent leaks data to external URLs | Data exfiltration | `data-exfil` |
| Test if agent follows harmful injected instructions | Behavior manipulation | `harmful:*`, `hijacking`, `pii:*`, `contracts`, etc. |
| Test both | Both | Include `data-exfil` + other plugins |

## Architecture

1. **Promptfoo CLI** requests a web page from the Promptfoo server
2. **Promptfoo Server** dynamically generates HTML with the prompt injection embedded
3. **Generated page** is hosted and contains realistic content matching your target's purpose
4. **Agent fetches** the page via web fetch tool call
5. **Injection payload** is delivered to the agent through the page content
6. **Grading** occurs via server-side tracking (data-exfil) or LLM analysis (other plugins)