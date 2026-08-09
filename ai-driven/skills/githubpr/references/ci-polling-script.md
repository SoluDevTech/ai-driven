# CI Polling Script

Use this script to wait for CI in an automated workflow.

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

## Exit codes
| Code | Meaning |
|------|---------|
| `0` | CI green → safe to merge |
| `1` | CI red → stop, investigate |
| `3` | Timeout → check manually |