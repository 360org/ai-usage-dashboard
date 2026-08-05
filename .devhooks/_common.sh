#!/usr/bin/env bash
# Tiện ích chung cho các git hook của DevTrack.
# Tìm devtrack.py theo thứ tự: $DEVTRACK_HOME → đường dẫn base skill mặc định.
# In ra path hoặc rỗng (hook tự quyết định no-op nếu rỗng → không bao giờ chặn
# commit chỉ vì thiếu tool).

find_devtrack() {
  local candidates=(
    "${DEVTRACK_HOME:-}/devtrack.py"
    "/Volumes/DATA/DEV/SKILLS/dev-workflow-skills/scripts/devtrack.py"
    "$HOME/.claude/skills/dev-workflow-skills/scripts/devtrack.py"
  )
  local c
  for c in "${candidates[@]}"; do
    [ -n "$c" ] && [ -f "$c" ] && { echo "$c"; return 0; }
  done
  return 1
}

devtrack_python() {
  command -v python3 >/dev/null 2>&1 && { echo python3; return; }
  command -v python  >/dev/null 2>&1 && { echo python; return; }
  echo ""
}
