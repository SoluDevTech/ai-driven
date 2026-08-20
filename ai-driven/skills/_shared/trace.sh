#!/usr/bin/env bash
# trace.sh — append one event to the loop trace file.
# Usage: trace.sh <repo-root> <loop_id> <step> <type> <target> <status> <detail>
set -euo pipefail

repo_root="${1:?missing repo-root}"
loop_id="${2:?missing loop_id}"
step="${3:?missing step}"
type="${4:?missing type}"
target="${5:?missing target}"
status="${6:?missing status}"
detail="${7:-}"

trace_dir="${repo_root}/.opencode"
trace_file="${trace_dir}/loop-trace.md"

mkdir -p "${trace_dir}"

if [[ ! -f "${trace_file}" ]]; then
  printf '| timestamp | loop_id | step | type | target | status | detail |\n' > "${trace_file}"
  printf '|-----------|---------|------|------|--------|--------|--------|\n' >> "${trace_file}"
fi

ts="$(date +%Y-%m-%dT%H:%M:%S)"
printf '| %s | %s | %s | %s | %s | %s | %s |\n' \
  "${ts}" "${loop_id}" "${step}" "${type}" "${target}" "${status}" "${detail}" >> "${trace_file}"

cat "${trace_file}"