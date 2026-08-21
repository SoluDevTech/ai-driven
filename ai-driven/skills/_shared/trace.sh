#!/usr/bin/env bash
# trace.sh — append one event to the loop trace file.
# Usage: trace.sh <loop-dir> <loop_id> <step> <type> <target> <status> <detail>
# <loop-dir> is the per-loop directory under ~/.config/opencode/loops/loop-<timestamp>
# that also holds specs/ and bug-reports/. The trace file is <loop-dir>/loop-trace.md.
set -euo pipefail

loop_dir="${1:?missing loop-dir}"
loop_id="${2:?missing loop_id}"
step="${3:?missing step}"
type="${4:?missing type}"
target="${5:?missing target}"
status="${6:?missing status}"
detail="${7:-}"

trace_file="${loop_dir}/loop-trace.md"

mkdir -p "${loop_dir}"

if [[ ! -f "${trace_file}" ]]; then
  printf '| timestamp | loop_id | step | type | target | status | detail |\n' > "${trace_file}"
  printf '|-----------|---------|------|------|--------|--------|--------|\n' >> "${trace_file}"
fi

ts="$(date +%Y-%m-%dT%H:%M:%S)"
printf '| %s | %s | %s | %s | %s | %s | %s |\n' \
  "${ts}" "${loop_id}" "${step}" "${type}" "${target}" "${status}" "${detail}" >> "${trace_file}"

cat "${trace_file}"