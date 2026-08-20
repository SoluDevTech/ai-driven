#!/usr/bin/env bash
# verify-step.sh — verify that a step event exists in the trace file.
# Usage: verify-step.sh <repo-root> <loop_id> <step> <type> <target>
# Exit 0 = OK (step recorded as loaded/delegated/done).
# Exit 1 = missing or failed.
set -euo pipefail

repo_root="${1:?missing repo-root}"
loop_id="${2:?missing loop_id}"
step="${3:?missing step}"
type="${4:?missing type}"
target="${5:?missing target}"

trace_file="${repo_root}/.opencode/loop-trace.md"

if [[ ! -f "${trace_file}" ]]; then
  printf 'VERIFY FAIL: trace file missing (%s)\n' "${trace_file}" >&2
  exit 1
fi

# Match a row where loop_id, step, type, target all match AND status is a success status.
match=$(grep -E "\| ${loop_id} \| ${step} \| ${type} \| ${target} \| (loaded|delegated|done) \|" "${trace_file}" || true)

if [[ -z "${match}" ]]; then
  printf 'VERIFY FAIL: step %s (%s %s) not recorded as done for loop %s\n' \
    "${step}" "${type}" "${target}" "${loop_id}" >&2
  printf 'Matching rows so far:\n%s\n' "${match}" >&2
  exit 1
fi

printf 'VERIFY OK: %s\n' "${match}"
exit 0