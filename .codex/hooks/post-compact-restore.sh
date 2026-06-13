#!/usr/bin/env bash
# Codex PostCompact hook: emit JSON reminder to restore file-backed state.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"

ROOT="$(repo_root)"
cd "$ROOT" 2>/dev/null || exit 0

ACTIVE="production/session-state/active.md"
REMINDERS="production/session-state/hook-reminders.md"

{
  echo "Post-compact restore reminder:"
  if [ -f "$ACTIVE" ]; then
    LINES=$(wc -l < "$ACTIVE" 2>/dev/null | tr -d ' ')
    echo "- Read $ACTIVE ($LINES lines) to restore tasks, decisions, and open work."
  else
    echo "- Missing $ACTIVE. If recovery is needed, check production/session-logs/."
  fi

  WINDOW_DIR="production/session-state/windows"
  if [ -d "$WINDOW_DIR" ]; then
    LANE_COUNT=0
    for LANE_FILE in "$WINDOW_DIR"/*.md; do
      [ -f "$LANE_FILE" ] || continue
      LANE_COUNT=$((LANE_COUNT + 1))
    done

    if [ "$LANE_COUNT" -gt 0 ]; then
      echo "- Registered window lanes can be restored:"
      SHOWN=0
      for LANE_FILE in "$WINDOW_DIR"/*.md; do
        [ -f "$LANE_FILE" ] || continue
        LANE_ID=$(basename "$LANE_FILE" .md)
        echo "  - $LANE_ID: state=$LANE_FILE. Restore: /window-cfg $LANE_ID"
        SHOWN=$((SHOWN + 1))
        [ "$SHOWN" -ge 8 ] && break
      done
      if [ "$LANE_COUNT" -gt "$SHOWN" ]; then
        echo "  - $((LANE_COUNT - SHOWN)) more lane(s). Run /help for the full list."
      fi
    else
      echo "- No window lane files found. For parallel work or recovery, run /window-cfg <lane-id>."
    fi
  fi

  if [ -f "$REMINDERS" ]; then
    echo "- Hook reminder file: $REMINDERS."
  fi
} | emit_system_message

exit 0
