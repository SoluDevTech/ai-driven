---
name: githubpr
description: Manage the full GitHub PR lifecycle from a Jira ticket create a branch with the format <JIRA-ID>/<simple-description>, push, open a PR for review, poll CI, and merge when green. Use this skill whenever the user mentions creating a PR, opening a pull request, pushing a branch for review, or linking a Jira ticket to a GitHub PR. Also trigger when the user asks to wait for CI, merge a PR or manage the git workflow around a Jira ticket.
---

# GitHub PR Skill

Full lifecycle: branch → push → PR → CI → merge.

---

## 1. Branch naming convention

```
<JIRA-ID>/<simple-description>
```

Rules:
- `JIRA-ID`: exact ticket ID, uppercase — e.g. `PROJ-123`
- `simple-description`: 2–5 words, kebab-case, lowercase, no articles — e.g. `add-user-auth`
- Separator: `/`

Valid examples:
```
PROJ-123/add-user-auth
PROJ-456/fix-null-pointer-login
PROJ-789/update-dependencies
```

Create and switch to the branch:
```bash
git checkout main && git pull origin main
git checkout -b PROJ-123/add-user-auth
```

---

## 2. Create the PR

```bash
gh pr create \
  --title "PROJ-123: <short ticket summary>" \
  --body "$(cat <<'EOF'
## Jira
[PROJ-123](https://soludevtech.atlassian.net/browse/PROJ-123)

## Changes
- <point 1>
- <point 2>

## Tests
- [ ] Unit tests
- [ ] Integration tests
EOF
)" \
  --base main \
  --draft
```

> Always open as **draft** by default. Mark as "ready for review" only once the CI is green and the code is finalized.

Mark as ready for review:
```bash
gh pr ready <PR_NUMBER>
```

---

## 3. Check CI status

```bash
# Quick overview
gh pr checks <PR_NUMBER>

# JSON output for agent parsing
gh pr checks <PR_NUMBER> --json name,state,conclusion
```

Possible states:
- `SUCCESS` → ✅
- `IN_PROGRESS` / `QUEUED` → ⏳ wait
- `FAILURE` → ❌ stop, investigate

---

## 4. CI polling (agent script)

Use this script to wait for CI in an automated workflow:

```bash
#!/bin/bash
# wait-ci.sh <PR_NUMBER> [TIMEOUT_SECONDS]
PR=$1
TIMEOUT=${2:-1800}   # 30 min default
INTERVAL=60

echo "Polling CI for PR #$PR..."
for i in $(seq 1 $((TIMEOUT/INTERVAL))); do
  CHECKS=$(gh pr checks $PR --json name,state,conclusion 2>/dev/null)

  IN_PROGRESS=$(echo $CHECKS | jq '[.[] | select(.state == "IN_PROGRESS" or .state == "QUEUED")] | length')
  FAILURES=$(echo $CHECKS | jq '[.[] | select(.conclusion == "FAILURE")] | length')

  echo "[$(date '+%H:%M:%S')] in_progress=$IN_PROGRESS failures=$FAILURES"

  if [ "$FAILURES" -gt 0 ]; then
    echo "❌ CI FAILED"
    exit 1
  fi

  if [ "$IN_PROGRESS" -eq 0 ]; then
    echo "✅ CI PASSED"
    exit 0
  fi

  sleep $INTERVAL
done

echo "⏱ TIMEOUT"
exit 3
```

Exit codes:
| Code | Meaning |
|------|---------|
| `0` | CI green → safe to merge |
| `1` | CI red → stop, investigate |
| `3` | Timeout → check manually |

---

## 5. Merge

### Two distinct merge scenarios

The merge method depends on whether the target is a **feature branch**
(deleted after merge) or a **long-lived integration branch** (`dev`, `main`).

#### A. Feature branch → `dev` (or `main` if no `dev` exists)

Use the GitHub UI / `gh` CLI with **rebase and merge**. The feature branch
is deleted after, so commit-hash rewriting is harmless.

```bash
gh pr merge <PR_NUMBER> --rebase --delete-branch
```

#### B. `dev` → `main` (long-lived branch → long-lived branch)

**NEVER use the GitHub merge button** (`--rebase`, `--squash`, or `--merge`).
All three rewrite commit hashes, which breaks `dev`: it is no longer an
ancestor of `main`, causing conflicts and requiring force-pushes on the
next `dev → main` cycle.

Instead, merge in CLI with a **true fast-forward**:

```bash
git fetch origin main dev
git checkout main
git pull --ff-only origin main
git merge --ff-only dev
git push origin main
```

This advances `main` to `dev`'s commit **without rewriting hashes**.
`dev` remains an exact ancestor of `main` → zero conflicts, zero
force-push, on every subsequent cycle.

> The PR `dev → main` is created for CI + review, but **merged via CLI**.
> Once `main` is pushed, the PR closes automatically. Do not
> `--delete-branch` — `dev` is long-lived.

If `dev` is not a strict ancestor of `main` (someone committed directly
to `main`), `--ff-only` will refuse. Fix by rebasing `dev` onto `main`
first, then retry the fast-forward.

After merge, both branches point to the same commit — no resync needed.

---

## 6. Full agent flow

```bash
TICKET="PROJ-123"
DESC="add-user-auth"
BRANCH="${TICKET}/${DESC}"

# 1. Branch
git checkout main && git pull origin main
git checkout -b $BRANCH

# 2. [Dev / Tests / Sonar / Trivy here]

# 3. Push + PR
git push origin $BRANCH
PR_URL=$(gh pr create --title "$TICKET: ..." --body "..." --base main --draft)
PR_NUMBER=$(gh pr view --json number -q .number)

# 4. Ready for review
gh pr ready $PR_NUMBER

# 5. Wait for CI
bash wait-ci.sh $PR_NUMBER
CI_EXIT=$?

# 6. Merge if green
if [ $CI_EXIT -eq 0 ]; then
  # Feature → dev: rebase merge + delete branch
  gh pr merge $PR_NUMBER --rebase --delete-branch

  # dev → main: CLI fast-forward (see section 5B) — do NOT use gh pr merge
  git checkout main && git pull --ff-only origin main
  git merge --ff-only dev
  git push origin main
else
  echo "CI failed on $TICKET — skipping"
fi
```

---

## Agent rules

- **Never merge** if `wait-ci.sh` exit code != 0
- **Feature → `dev`**: use `gh pr merge --rebase --delete-branch`
- **`dev` → `main`**: **never use `gh pr merge`**. Use CLI `git merge --ff-only dev` + `git push origin main` (see section 5B)
- **Never `--delete-branch` on `dev` or `main`** — they are long-lived
- **Never force-push `dev` or `main`**
- On CI failure: log the ticket and **continue** to the next one — do not block the pipeline
- PR title must always start with the ticket ID: `PROJ-123: ...`