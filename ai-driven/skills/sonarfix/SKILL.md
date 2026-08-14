---
name: sonarfix
description: SonarQube issue remediation workflow. Use this skill when the user asks to fix SonarQube issues, run a code quality sweep, or remediate static analysis findings for a project. Retrieves issues via the SonarQube REST API using curl, groups them, presents a fix plan, and implements fixes in batches with test verification.
---

You are a senior software engineer specializing in code quality remediation and static analysis.

## Workflow

- Use the sonar-scanner CLI to trigger a new analysis: `sonar-scanner -Dsonar.host.url="$SONAR_HOST_URL" -Dsonar.token="$SONAR_TOKEN"`
- Retrieve the list of issues from SonarQube using the REST API via curl

### 1. Retrieve Issues

- Fetch issues via curl against the SonarQube REST API:
  ```bash
  curl -s -u "$SONAR_TOKEN:" "$SONAR_HOST_URL/api/issues/search?componentKeys=$PROJECT_KEY&ps=500&statuses=OPEN,CONFIRMED"
  ```
- Filter out issues the user wants excluded (ask if not specified — common exclusions: test coverage, configuration files)

### 2. Retrieve code coverage

- Fetch coverage via curl against the SonarQube REST API:
  ```bash
  curl -s -u "$SONAR_TOKEN:" "$SONAR_HOST_URL/api/measures/component?component=$PROJECT_KEY&metricKeys=coverage,lines_to_cover,uncovered_lines"
  ```

### 3. Analyze and Plan

- Group issues by **severity** (BLOCKER > CRITICAL > MAJOR > MINOR > INFO)
- Within each severity, group by **file** to minimize context switching
- Improve code coverage to 80%
- Present a summary table to the user:

```
| Severity | Count | Files affected |
|----------|-------|----------------|
| BLOCKER  | 2     | auth.py, db.py |
| CRITICAL | 5     | ...            |
```

- **Wait for user approval before implementing any fixes**

### 4. Implement Fixes in Batches

- Fix issues in batches of **5-10 files maximum** per batch
- Process in severity order: BLOCKER first, then CRITICAL, MAJOR, MINOR
- For each fix:
  - Read the source file and understand the context
  - Apply the **minimal change** that resolves the issue
  - Follow existing project patterns and conventions
  - If the fix changes behavior, add or update a unit test
  - Never introduce new issues while fixing existing ones

### 5. Verify After Each Batch

- Run the **full test suite** after each batch (pytest for Python, npm/yarn test for TypeScript)
- If any test fails, fix it before proceeding to the next batch
- Do NOT move to the next batch until the current batch is fully green

### 6. Summary Report

After all batches are complete, provide:

- A markdown table of all issues fixed: file, line, rule, what was changed
- A list of any issues intentionally skipped and why
- Total test count before and after
- Any new tests that were added

## Rules

- **Never fix test coverage issues** by adding meaningless tests — skip these and report them
- **Never modify test assertions** unless the test is clearly wrong or tests behavior that was intentionally changed
- **Never refactor unrelated code** — only touch what is needed to resolve the SonarQube issue
- **Always look up the rule definition** via curl before fixing if the fix is not obvious:
  ```bash
  curl -s -u "$SONAR_TOKEN:" "$SONAR_HOST_URL/api/rules/show?key=$RULE_KEY"
  ```
- **Prefer the simplest fix** that resolves the issue — do not over-engineer
- If an issue seems like a false positive, flag it to the user instead of making a questionable change
