#!/usr/bin/env bash
# Codex SessionStart hook: provide compact project context as additionalContext.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"

ROOT="$(repo_root)"
cd "$ROOT" 2>/dev/null || exit 0

{
  echo "CFG session context:"

  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  [ -n "$BRANCH" ] && echo "- Git branch: $BRANCH"

  if [ -f "production/stage.txt" ]; then
    STAGE=$(tr -d '[:space:]' < production/stage.txt 2>/dev/null)
    [ -n "$STAGE" ] && echo "- Current stage: $STAGE"
  fi

  WORK_ORDER_COUNT=$(ls production/work-orders/*.md 2>/dev/null | wc -l | tr -d ' ')
  if [ "$WORK_ORDER_COUNT" -gt 0 ] 2>/dev/null; then
    LATEST_WORK_ORDER=$(ls -t production/work-orders/*.md 2>/dev/null | head -1)
    [ -n "$LATEST_WORK_ORDER" ] && echo "- Work orders: $WORK_ORDER_COUNT total; latest=$(basename "$LATEST_WORK_ORDER")"
  fi

  LATEST_MILESTONE=$(ls -t production/milestones/*.md 2>/dev/null | head -1)
  [ -n "$LATEST_MILESTONE" ] && echo "- Active milestone: $(basename "$LATEST_MILESTONE" .md)"

  STATE_FILE="production/session-state/active.md"
  if [ -f "$STATE_FILE" ]; then
    STATE_LINES=$(wc -l < "$STATE_FILE" 2>/dev/null | tr -d ' ')
    echo "- State file: $STATE_FILE ($STATE_LINES lines). Read it before continuing important work."
  fi

  WINDOW_DIR="production/session-state/windows"
  if [ -d "$WINDOW_DIR" ]; then
    LANE_COUNT=0
    for LANE_FILE in "$WINDOW_DIR"/*.md; do
      [ -f "$LANE_FILE" ] || continue
      LANE_COUNT=$((LANE_COUNT + 1))
    done

    if [ "$LANE_COUNT" -gt 0 ]; then
      echo "- Registered window lanes:"
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
      echo "- No window lane files found. First project entry: /start. Manual lane start: /window-cfg <lane-id>."
    fi
  else
    echo "- No window lane directory found. First project entry: /start."
  fi

  REMINDERS="production/session-state/hook-reminders.md"
  if [ -f "$REMINDERS" ]; then
    echo "- Hook reminder file: $REMINDERS. Read it if this turn touches Skills, assets, or commits."
  fi

  CHANGED_COUNT=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
  STAGED_COUNT=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
  if [ "$CHANGED_COUNT" -gt 0 ] 2>/dev/null; then
    echo "- Dirty worktree: $CHANGED_COUNT change(s). Do not overwrite unrelated user changes."
    if [ "$STAGED_COUNT" -gt 0 ] 2>/dev/null; then
      echo "- Checkpoint: $STAGED_COUNT staged file(s). Commit body should include Lane, Scope, Verification, and Rollback."
    elif [ "$CHANGED_COUNT" -ge 20 ] 2>/dev/null; then
      echo "- Checkpoint suggested: dirty worktree is large. Run /window-cfg checkpoint <lane-id> before switching lanes or compacting."
    fi
  else
    echo "- Worktree clean."
  fi
} | emit_session_context

exit 0
