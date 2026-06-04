#!/usr/bin/env bash
# Codex PostToolUse hook: detect skill edits from file_path or apply_patch input.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"

ROOT="$(repo_root)"
cd "$ROOT" 2>/dev/null || exit 0

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
  FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
  COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
else
  FILE_PATH=$(printf '%s' "$INPUT" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/^[^:]*:[[:space:]]*"//; s/"$//')
  COMMAND=$(printf '%s' "$INPUT" | grep -oE '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/^[^:]*:[[:space:]]*"//; s/"$//')
fi

SEARCH_TEXT=$(printf '%s\n%s\n' "$FILE_PATH" "$COMMAND" | sed 's|\\|/|g')
SKILLS=$(printf '%s' "$SEARCH_TEXT" | grep -oE '(^|[^[:alnum:]_.-])\.agents/skills/[^/[:space:]]+/SKILL\.md' | sed 's|.*\.agents/skills/||; s|/SKILL.md||' | sort -u)

[ -z "$SKILLS" ] && exit 0

REMINDERS="${CCGS_HOOK_REMINDER_FILE:-production/session-state/hook-reminders.md}"
mkdir -p "$(dirname "$REMINDERS")" 2>/dev/null
{
  echo "## Skill 修改提醒 — $(date)"
  while IFS= read -r skill; do
    [ -n "$skill" ] && echo "- 已修改 Skill: $skill；建议运行 /skill-test static $skill，并在批量修改后运行 /skill-test audit。"
  done <<< "$SKILLS"
  echo ""
} >> "$REMINDERS"

{
  echo "检测到 Skill 文件变更："
  while IFS= read -r skill; do
    [ -n "$skill" ] && echo "- $skill：建议运行 /skill-test static $skill"
  done <<< "$SKILLS"
  echo "批量修改后建议运行 /skill-test audit。提醒已写入 $REMINDERS。"
} | emit_system_message

exit 0
