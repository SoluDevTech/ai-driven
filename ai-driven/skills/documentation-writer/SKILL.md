---
name: documentation-writer
description: Use to write the README.md documentation for a projet, Invoke it every time you change the code on a project.
---

Analyze this codebase and update (or create) the README.md file. Follow these steps:

1. **Explore the project structure** - Look at the directory layout, key files, and organization

2. **Identify the tech stack** - Languages, frameworks, libraries, and dependencies (check package.json, requirements.txt, Cargo.toml, go.mod, etc.)

3. **Understand the purpose** - Read existing documentation, comments, and code to determine what this project does

4. **If this is an API, document ALL endpoints:**
   - Find every route/endpoint in the codebase (check routes, controllers, handlers, decorators like @app.get, @router.post, etc.)
   - For EACH endpoint, provide a working curl example including:
     - HTTP method (GET, POST, PUT, PATCH, DELETE)
     - Full URL with path parameters shown as placeholders
     - Required headers (Content-Type, Authorization, etc.)
     - Request body example with realistic sample data
     - Query parameters if applicable
   - Group endpoints logically (by resource or feature)
   - Note authentication requirements for each endpoint
   - Include example successful responses where possible

   Example format:
```bash
   # Create a new user
   curl -X POST http://localhost:3000/api/users \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer <token>" \
     -d '{
       "name": "John Doe",
       "email": "john@example.com",
       "password": "securepassword123"
     }'
```

5. **Update the README with these sections:**
   - **Project Title & Description** - Clear, concise explanation of what it does
   - **Features** - Key capabilities
   - **Prerequisites** - Required software/tools
   - **Installation** - Step-by-step setup instructions
   - **Configuration** - Environment variables, config files (especially API keys, database URLs, ports)
   - **Running the Server** - How to start the API (dev and production)
   - **API Documentation** - All endpoints with curl examples (grouped by resource)
   - **Authentication** - How auth works, how to obtain tokens
   - **Project Structure** - Brief overview of key directories/files
   - **Testing** - How to run tests
   - **Contributing** - How others can contribute (if applicable)
   - **License** - If one exists

6. **Be thorough with curls** - A developer should be able to copy-paste every curl and test the entire API without reading the source code

Preserve any existing content that's still accurate. Write in a clear, professional tone.

---

## MANDATORY ADDITIONAL OUTPUT: Loop session report (`loop-report.html`)

When this skill is invoked as step 11 (Docs) of a feature-implementation loop, you MUST ALSO generate a standalone HTML report of the loop session and save it INSIDE the loop directory.

### 1. Detect the loop directory

- Look for a `LOOP_DIR: <absolute-path>` pointer line in the conversation/task arguments.
- Or extract it from a `SPEC_FILE: <absolute-path>` pointer line by stripping `/specs/<slug>.md` from the tail.
- Or detect the most recently modified directory matching `~/.config/opencode/loops/loop-*` that contains a `loop-trace.md`.
- If none found → skip the report (plain README task) and state it explicitly.

### 2. Gather the data (read in full)

- `<LOOP_DIR>/loop-trace.md` — the authoritative event log (timeline, steps, agents/skills, statuses, details, loop-backs).
- `<LOOP_DIR>/specs/*.md` — the spec(s) implemented this session.
- `<LOOP_DIR>/code-reviews/*.md` — review verdicts and scores (if present).
- `<LOOP_DIR>/bug-reports/*.md` — QA bug reports (if present).
- Do NOT invent content: everything in the report must come from these files.

### 3. Generate `<LOOP_DIR>/loop-report.html`

A single self-contained HTML file (no external dependencies, inline CSS/JS), showing:

1. **Header**: loop_id, session date range (first/last trace timestamps), stack, repos touched, final outcome (PR created / QA green / review score).
2. **Big-picture schema**: a visual flow diagram of the whole loop session — built as styled HTML/CSS boxes+arrows (or inline SVG) showing the pipeline steps (1 TDD → 2 Impl → 3 Tests → 4 Review → 5-9 quality gates → 10 QA → 11 Docs → 12 PR) with color-coded status per step (green=passed, orange=iterated/loop-back, red=failed), including loop-back arrows drawn between review/impl/QA when iterations happened. Annotate each box with the agent/skill name, event count and final status.
3. **Step-by-step timeline** (from loop-trace.md): one expandable section (native `<details>`/`<summary>`) per workflow step, ordered chronologically. Each section shows: step number/title, agent or skill name, all trace events as a mini-table (timestamp, target, status, detail), and a summary of the artifact produced (test files, impl files, review score, bug count). Loop-back events must be clearly highlighted.
4. **Artifacts & files section**: lists specs, code reviews, bug reports (linked by filename) and repo file paths touched (TEST_FILES/IMPL_FILES found in trace details).
   - **Mandatory: full markdown embed** — for EVERY markdown file gathered in step 2 (`loop-trace.md`, `specs/*.md`, `code-reviews/*.md`, `bug-reports/*.md`), render its FULL content inside the report as a dedicated expandable `<details>`/`<summary>` section (summary = filename + type). Render the markdown to HTML (inline converter or minimal regex-based renderer: headings, code blocks, tables, lists, bold/inline code) so it is readable directly in the browser — do NOT only link the files, their content must be readable in the report.
   - **Mandatory: app-changes schema** — add a visual diagram (styled HTML/CSS boxes+arrows or inline SVG, same techniques as the big-picture schema) representing the changes made in the APP itself: layers/modules touched (e.g. router → use case → port → adapter/repo for hexagonal, or components/hooks/pages for frontend), with each touched file mapped onto its layer box (colored: new file vs modified file) and arrows showing data/control flow impacted. Build it from IMPL_FILES/TEST_FILES paths in the trace and the spec description — never invent files. Place it right after the big-picture loop schema.
5. Styling: dark or light clean theme, monospace timestamps, readable tables, works when opened directly with `file://` — no server needed.

### 4. Trace the report generation

- Print `LOOP_REPORT: file://<LOOP_DIR>/loop-report.html` (clickable `file://` link) at the END of the step output, as the last line after `SKILL_CONFIRM`.
- End the step output with the standard `SKILL_CONFIRM` line, mentioning the report was written.

### 5. Fallbacks

- If `loop-trace.md` exists but is a free-form markdown trace (not a table), parse its step sections the same way.
- If data for section 2 (big-picture schema) is missing, draw the schema from the events actually present — never fabricate steps that were not traced.