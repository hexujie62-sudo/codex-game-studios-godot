#!/usr/bin/env bash
# Codex SessionStart hook: provide compact project context as additionalContext.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"

ROOT="$(repo_root)"
cd "$ROOT" 2>/dev/null || exit 0

{
  echo "CCGS 会话上下文："

  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  [ -n "$BRANCH" ] && echo "- Git 分支: $BRANCH"

  if [ -f "production/stage.txt" ]; then
    STAGE=$(tr -d '[:space:]' < production/stage.txt 2>/dev/null)
    [ -n "$STAGE" ] && echo "- 当前阶段: $STAGE"
  fi

  LATEST_SPRINT=$(ls -t production/sprints/sprint-*.md 2>/dev/null | head -1)
  [ -n "$LATEST_SPRINT" ] && echo "- 活跃冲刺: $(basename "$LATEST_SPRINT" .md)"

  LATEST_MILESTONE=$(ls -t production/milestones/*.md 2>/dev/null | head -1)
  [ -n "$LATEST_MILESTONE" ] && echo "- 活跃里程碑: $(basename "$LATEST_MILESTONE" .md)"

  STATE_FILE="production/session-state/active.md"
  if [ -f "$STATE_FILE" ]; then
    STATE_LINES=$(wc -l < "$STATE_FILE" 2>/dev/null | tr -d ' ')
    echo "- 恢复文件: $STATE_FILE ($STATE_LINES 行)。继续重要任务前先读取它。"
  fi

  REMINDERS="production/session-state/hook-reminders.md"
  if [ -f "$REMINDERS" ]; then
    echo "- Hook 提醒文件: $REMINDERS。若本轮涉及 Skill/资源/提交，请读取。"
  fi

  CHANGED_COUNT=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
  if [ "$CHANGED_COUNT" -gt 0 ] 2>/dev/null; then
    echo "- 工作树有 $CHANGED_COUNT 条变更；不要覆盖无关用户改动。"
  else
    echo "- 工作树无未提交变更。"
  fi
} | emit_session_context

exit 0
