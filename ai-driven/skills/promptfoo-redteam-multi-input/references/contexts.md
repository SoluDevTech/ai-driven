# Contexts for Role Testing

Load when testing different user roles with the same inputs.

## Configuration

```yaml
targets:
  - id: https
    inputs:
      user_id: 'The user identifier'
      action: 'The requested action'
    config:
      # ... target config
redteam:
  contexts:
    - id: regular_user
      purpose: 'Testing as a regular customer'
      vars:
        user_role: customer
    - id: admin_user
      purpose: 'Testing as an admin user'
      vars:
        user_role: admin
```

## How It Works

Each context runs the same red team plugins with different variable values. This reveals:
- Whether a regular user can perform admin actions
- Whether role boundaries are enforced across all attack vectors
- Whether the same attack succeeds as one role but fails as another

## Use Cases

- **RBAC testing** — verify regular users can't access admin functions
- **Multi-tenant testing** — verify tenant A can't access tenant B's data
- **Privilege escalation** — verify a low-privilege user can't escalate via prompt injection

## Combining with BOLA/BFLA

```yaml
redteam:
  contexts:
    - id: regular_user
      purpose: 'Testing as a regular customer with limited access'
      vars:
        user_role: customer
    - id: admin_user
      purpose: 'Testing as an admin user with full access'
      vars:
        user_role: admin
  plugins:
    - bola
    - bfla
    - rbac
  strategies:
    - jailbreak:composite
    - jailbreak-templates
```