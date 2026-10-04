# PR Template and Full Agent Flow

## PR creation

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

## Full agent flow

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

# 6. Report and STOP — no automatic merge. The user decides when to merge.
if [ $CI_EXIT -eq 0 ]; then
  echo "CI green on $TICKET — PR ready: $PR_URL (merge only on explicit user request)"
else
  echo "CI failed on $TICKET — skipping"
fi
```