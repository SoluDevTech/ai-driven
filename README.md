# AI-Driven Development Workflow

A multi-tool AI coding assistant configuration system that standardizes software development workflows across Claude Code, OpenCode, and GitHub Copilot.

## Overview

This repository provides unified AI agent and skill configurations designed to:

- **Standardize development workflows** across multiple AI coding assistants
- **Enforce architectural best practices** (Hexagonal Architecture, SOLID, TDD)
- **Provide specialized agents** for each phase of software development
- **Integrate external tools** via MCP (Model Context Protocol)
- **Support multiple technology stacks** (FastAPI, NestJS, React, K3s)

## Supported AI Tools

| Tool | Configuration | Status |
|------|--------------|--------|
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | `ai-driven/claude/` | Full support |
| [OpenCode AI](https://opencode.ai) | `ai-driven/opencode/` | Full support |
| [GitHub Copilot](https://github.com/features/copilot) | `ai-driven/copilot/` | Full support |

## Repository Structure

```
prompt-rules/
├── README.md
├── .gitignore
├── ai-driven/
│   ├── agents/                         # Shared agent definitions (source of truth)
│   │   ├── product-owner.md
│   │   ├── test-writer-python.md
│   │   ├── test-writer-nestjs.md
│   │   ├── test-writer-react.md
│   │   ├── fastapi-hexagonal.md
│   │   ├── nestjs-hexagonal.md
│   │   ├── react-hexagonal.md
│   │   ├── code-reviewer.md
│   │   ├── code-simplifier.md
│   │   ├── documentation-writer.md
│   │   ├── tester-qa.md
│   │   └── k3s-devops.md
│   │
│   ├── claude/                         # Claude Code configuration
│   │   ├── .claude.example.json        # MCP server config template
│   │   └── .claude/
│   │       ├── CLAUDE.md               # Main workflow instructions
│   │       ├── settings.json           # Permissions (deny list)
│   │       ├── COPY_AGENTS_FOLDER_HERE # Marker: copy agents/ here
│   │       └── COPY_SKILLS_FOLDER_HERE # Marker: copy skills/ here
│   │
│   ├── copilot/                        # GitHub Copilot configuration
│   │   ├── mcp.json                    # MCP server config
│   │   └── .github/
│   │       ├── copilot-instructions.md # Main workflow instructions
│   │       ├── COPY_AGENTS_FOLDER_HERE # Marker: copy agents/ here
│   │       └── COPY_SKILLS_FOLDER_HERE # Marker: copy skills/ here
│   │
│   ├── opencode/                       # OpenCode AI configuration
│   │   ├── COPY_SKILLS_FOLDER_HERE     # Marker: copy skills/ here
│   │   └── .opencode/
│   │       ├── opencode.example.json   # Agent registry & MCP config template
│   │       ├── AGENTS.md               # Workflow instructions
│   │       ├── package.json            # Plugin dependencies (@opencode-ai/plugin)
│   │       └── COPY_AGENTS_FOLDER_HERE # Marker: copy agents/ here
│   │
│   └── mcp/                            # MCP server infrastructure
│       ├── docker-compose.yml          # Atlassian + Context7 services
│       └── env.atlassian.example       # Atlassian env template
│
└── skills/                             # Shared skill definitions (source of truth)
    ├── brainstorming/                  # Design-first brainstorming with visual companion
    │   ├── SKILL.md
    │   ├── spec-document-reviewer-prompt.md
    │   ├── visual-companion.md
    │   └── scripts/                    # Browser-based visual companion server
    ├── feature-implementation/         # Orchestrator: 6-phase dev workflow
    ├── githubpr/                       # Full PR lifecycle (branch → CI → merge)
    ├── sonarfix/                       # SonarQube issue remediation
    ├── trivyfix/                       # Trivy vulnerability remediation
    ├── dbanalyze/                      # Database schema analysis (SchemaCrawler)
    ├── popeyescan/                     # Kubernetes cluster health audit (Popeye)
    └── frontend-design/                # Production-grade UI design
```

### Source of truth and copy convention

Agents live in `ai-driven/agents/` and skills in `skills/`. Each tool-specific directory contains `COPY_AGENTS_FOLDER_HERE` and `COPY_SKILLS_FOLDER_HERE` marker files indicating where to copy them. The `.gitignore` excludes tool-specific copies so the shared directories remain the single source of truth.

## Specialized Agents

12 agents, each designed for a specific phase of development:

| Agent | Purpose |
|-------|---------|
| `product-owner` | Requirements analysis, acceptance criteria, user stories |
| `test-writer-python` | TDD with pytest, real implementations, mock only external boundaries |
| `test-writer-nestjs` | Jest + Supertest, SQLite in-memory, real implementations |
| `test-writer-react` | Vitest + React Testing Library, real implementations |
| `fastapi-hexagonal` | FastAPI backend with hexagonal architecture |
| `nestjs-hexagonal` | NestJS backend with hexagonal architecture |
| `react-hexagonal` | React frontend with hexagonal architecture |
| `code-reviewer` | Code review (correctness, security, performance, maintainability, testability, architecture) |
| `code-simplifier` | Refactoring for clarity and maintainability |
| `documentation-writer` | README and API documentation with curl examples |
| `tester-qa` | E2E testing with Playwright (QA mode + Bug Hunt mode) |
| `k3s-devops` | K3s/Flux CD infrastructure management (GitOps) |

All agents declare `model: opus` in their frontmatter. Tools like OpenCode can override the model per-agent in their configuration.

## Skills

8 skills providing specialized capabilities:

| Skill | Purpose |
|-------|---------|
| `brainstorming` | Design-first workflow: explore context, ask questions, propose approaches, write spec, review loop, then hand off to implementation |
| `feature-implementation` | Master orchestrator: 6-phase workflow (Requirements → TDD → Implementation → QA → Docs → PR/Merge) |
| `githubpr` | Full PR lifecycle: branch naming (`<JIRA-ID>/description`), draft PR, CI polling, merge |
| `sonarfix` | SonarQube remediation: retrieve issues, group by severity, fix in batches, verify tests |
| `trivyfix` | Trivy remediation: scan (fs/image/repo), group by severity and type, fix in batches, verify |
| `dbanalyze` | Database schema analysis: SchemaCrawler lint + information_schema extraction + normalization analysis (1NF/2NF/3NF) + Alembic migration generation |
| `popeyescan` | Kubernetes cluster health: Popeye scan with K3s noise filtering, prioritized action plan (P1/P2/P3) |
| `frontend-design` | Production-grade UI: distinctive design, bold aesthetics, no generic AI look |

## Development Workflow

The `feature-implementation` skill orchestrates the full development cycle through 6 sequential phases:

```
  PHASE 1: REQUIREMENTS
  ┌──────────────────────────────────────────────────────────────────┐
  │ product-owner                                                    │
  │ Clarify requirements, acceptance criteria, edge cases            │
  └──────────────────────────────┬───────────────────────────────────┘
                                 │
                                 ▼
  PHASE 2: TEST-FIRST DEVELOPMENT
  ┌──────────────────────────────────────────────────────────────────┐
  │ test-writer-python / test-writer-nestjs / test-writer-react      │
  │ Write failing tests (TDD Red-Green-Refactor)                     │
  └──────────────────────────────┬───────────────────────────────────┘
                                 │
                                 ▼
  PHASE 3: IMPLEMENTATION
  ┌──────────────────────────────────────────────────────────────────┐
  │ fastapi-hexagonal / nestjs-hexagonal / react-hexagonal           │
  │ Implement using hexagonal architecture, make tests pass          │
  └──────────────────────────────┬───────────────────────────────────┘
                                 │
                                 ▼
  PHASE 4: QUALITY ASSURANCE
  ┌──────────────────────────────────────────────────────────────────┐
  │ code-reviewer → code-simplifier → sonarfix → trivyfix            │
  │ Review, simplify, fix static analysis issues, fix vulnerabilities│
  └──────────────────────────────┬───────────────────────────────────┘
                                 │
                                 ▼
  PHASE 5: DOCUMENTATION & VERIFICATION
  ┌──────────────────────────────────────────────────────────────────┐
  │ tester-qa → documentation-writer                                 │
  │ E2E testing (Playwright), update docs                            │
  └──────────────────────────────┬───────────────────────────────────┘
                                 │
                                 ▼
  PHASE 6: OPEN PR & MERGE
  ┌──────────────────────────────────────────────────────────────────┐
  │ githubpr                                                         │
  │ Branch → Push → Draft PR → CI polling → Ready → Merge            │
  └──────────────────────────────────────────────────────────────────┘
```

Phase 4 includes feedback loops: if sonarfix or trivyfix find issues, iterate back to implementation and re-run the check.

### Brainstorming workflow (optional, before implementation)

For new features or creative work, invoke `brainstorming` before `feature-implementation`:

1. Explore project context
2. Ask clarifying questions (one at a time)
3. Propose 2-3 approaches with trade-offs
4. Present design sections, get user approval
5. Write spec to `docs/specs/YYYY-MM-DD-<topic>-design.md`
6. Automated spec review loop (subagent, max 5 iterations)
7. User reviews written spec
8. Hand off to `feature-implementation`

Includes an optional visual companion (browser-based) for mockups and diagrams during brainstorming.

## Architecture & Principles

All implementation agents enforce:

### Hexagonal Architecture (Ports & Adapters)

```
┌───────────────────────────────────────────────────┐
│  INFRASTRUCTURE                                     │
│  (adapters: REST, DB, email, external services)     │
│                                                     │
│  ┌───────────────────────────────────────────────┐  │
│  │  APPLICATION                                   │  │
│  │  (use cases, DTOs, routes/controllers)         │  │
│  │                                                │  │
│  │  ┌─────────────────────────────────────────┐   │  │
│  │  │  DOMAIN                                  │   │  │
│  │  │  (entities, ports, services)             │   │  │
│  │  │  Pure language — zero external imports   │   │  │
│  │  └─────────────────────────────────────────┘   │  │
│  └───────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────┘
```

### SOLID + KISS

- **SRP**: 1 class = 1 responsibility, 1 use case = 1 business action
- **OCP**: Extension via new adapters, never modify ports
- **LSP**: All implementations respect their port's contract
- **ISP**: Small, focused interfaces
- **DIP**: Use cases depend on ports (abstractions), never on adapters
- **KISS**: Direct transformations, no unnecessary abstractions, readable code over clever code

### Testing Philosophy

- **Real implementations** for all internal components (repositories, services, use cases)
- **Mocks only** for outbound adapters toward external systems (APIs, email, S3, Stripe)
- **TDD**: Write failing tests before implementation
- **Coverage targets**: 80% backend, 70% frontend

## Supported Technology Stacks

### FastAPI (Python)

| Component | Technology |
|-----------|------------|
| Runtime | Python 3.11+ |
| Package Manager | UV |
| Validation | Pydantic V2 |
| Testing | pytest, pytest-asyncio |
| Domain | Pure Python + Pydantic |

### NestJS (TypeScript)

| Component | Technology |
|-----------|------------|
| Runtime | Node.js 20+ |
| Package Manager | pnpm |
| Validation | Zod |
| Testing | Jest, Supertest |
| DI | Injection tokens, abstract classes as ports |

### React (TypeScript)

| Component | Technology |
|-----------|------------|
| Runtime | Bun |
| Build | Vite or Next.js |
| Styling | Tailwind CSS |
| Data Fetching | TanStack Query |
| Validation | Zod |
| Testing | Vitest, React Testing Library |
| Linting | Biome |

### K3s Infrastructure

| Component | Technology |
|-----------|------------|
| Kubernetes | K3s |
| GitOps | Flux CD |
| Identity | Logto (OIDC/OAuth2) |
| Auth Gateway | OAuth2 Proxy |
| Secrets | OpenBao |
| Storage | MinIO |
| Observability | OpenObserve |
| DNS/Access | Cloudflare Tunnels |
| CI/CD | GitHub Actions |

## MCP Integrations

External tool integrations via Model Context Protocol, served through Docker Compose:

### Atlassian (Jira + Confluence)

Issue management and documentation. Runs on port 9000.

```bash
# Start the MCP services
cd ai-driven/mcp
cp env.atlassian.example .env.atlassian  # Fill in your credentials
docker compose up -d
```

### Context7

Library documentation and code examples lookup. Runs on port 9021.

### Chrome DevTools (Claude Code only)

Browser inspection and E2E testing via Chrome DevTools Protocol. Runs as a local npx command, configured in `.claude.json`.

## Installation

### Prerequisites

- [Docker](https://docker.com) and Docker Compose
- Access to one of the supported AI tools

### 1. Start MCP services

```bash
cd ai-driven/mcp
cp env.atlassian.example .env.atlassian
# Edit .env.atlassian with your Jira/Confluence credentials
docker compose up -d
```

### 2. Set up your AI tool

#### Claude Code

```bash
# Copy the .claude directory to your project
cp -r ai-driven/claude/.claude /path/to/your/project/

# Copy MCP config template
cp ai-driven/claude/.claude.example.json /path/to/your/project/.claude.json

# Copy shared agents into the .claude directory
cp ai-driven/agents/*.md /path/to/your/project/.claude/agents/

# Copy shared skills into the .claude directory
cp -r skills/* /path/to/your/project/.claude/skills/
```

#### OpenCode

```bash
# Copy the .opencode directory to your project
cp -r ai-driven/opencode/.opencode /path/to/your/project/

# Copy shared agents
cp ai-driven/agents/*.md /path/to/your/project/.opencode/agents/

# Copy shared skills
cp -r skills/* /path/to/your/project/.opencode/skills/

# Install plugin dependencies
cd /path/to/your/project/.opencode && bun install
```

#### GitHub Copilot

```bash
# Copy .github directory to your project
cp -r ai-driven/copilot/.github /path/to/your/project/

# Copy MCP config
cp ai-driven/copilot/mcp.json /path/to/your/project/

# Copy shared agents
cp ai-driven/agents/*.md /path/to/your/project/.github/agents/

# Copy shared skills
cp -r skills/* /path/to/your/project/.github/skills/
```

### 3. Usage

```bash
# In your AI coding tool, say:
"Implement ticket PROJ-123"

# Or invoke specific skills:
"/brainstorming"             # Design-first workflow
"/sonarfix"                  # Fix SonarQube issues
"/trivyfix"                  # Fix Trivy vulnerabilities
"/dbanalyze"                 # Audit database schema
"/popeyescan"                # Audit K3s cluster health
```

## Customization

### Adding a new agent

Create a markdown file in `ai-driven/agents/`:

```markdown
---
name: my-agent
description: What this agent does
model: opus
---

# My Agent

Instructions...
```

Then copy it to the relevant tool directories.

### Adding a new skill

Create a directory in `skills/` with a `SKILL.md`:

```markdown
---
name: my-skill
description: What this skill does
---

# My Skill

Workflow and instructions...
```

Then copy it to the relevant tool directories.

## Resources

- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [OpenCode Documentation](https://opencode.ai/docs)
- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [Model Context Protocol](https://modelcontextprotocol.io/)
