#!/usr/bin/env bash
# Codex PostCompact hook: emit JSON reminder to restore file-backed state.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"

ROOT="$(repo_root)"
cd "$ROOT" 2>/dev/null || exit 0

ACTIVE="production/session-state/active.md"
REMINDERS="production/session-state/hook-reminders.md"

{
  echo "上下文压缩后恢复提醒："
  if [ -f "$ACTIVE" ]; then
    LINES=$(wc -l < "$ACTIVE" 2>/dev/null | tr -d ' ')
    echo "- 请读取 $ACTIVE（$LINES 行）恢复任务、决策和待办。"
  else
    echo "- 未找到 $ACTIVE；如需恢复，请检查 production/session-logs/。"
  fi
  if [ -f "$REMINDERS" ]; then
    echo "- 还有 Hook 提醒: $REMINDERS。"
  fi
} | emit_system_message

exit 0
