#!/usr/bin/env bash
# Codex PreToolUse hook: block clearly dangerous shell operations.

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
  COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
else
  COMMAND=$(printf '%s' "$INPUT" | grep -oE '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/^[^:]*:[[:space:]]*"//; s/"$//')
fi

[ -z "$COMMAND" ] && exit 0

LOWER=$(printf '%s' "$COMMAND" | tr '[:upper:]' '[:lower:]')
REASON=""

if printf '%s' "$LOWER" | grep -qE 'git[[:space:]]+push([^|;&]*)(--force|--force-with-lease|-f)([[:space:]]|$)'; then
  REASON="阻止 git force push。请先让用户明确批准。"
elif printf '%s' "$LOWER" | grep -qE 'git[[:space:]]+reset[[:space:]]+--hard'; then
  REASON="阻止 git reset --hard。它会丢弃工作树改动。"
elif printf '%s' "$LOWER" | grep -qE 'git[[:space:]]+checkout[[:space:]]+--'; then
  REASON="阻止 git checkout --。它会丢弃指定文件的本地改动。"
elif printf '%s' "$LOWER" | grep -qE 'rm[[:space:]]+-[^|;&]*r[^|;&]*(\\.codex|\\.agents|\\.git|/)[[:space:]]*($|[|;&])'; then
  REASON="阻止高风险递归删除。"
elif printf '%s' "$LOWER" | grep -qE 'remove-item[^|;&]*-recurse[^|;&]*(\\.codex|\\.agents|\\.git)'; then
  REASON="阻止高风险 Remove-Item -Recurse。"
elif printf '%s' "$LOWER" | grep -qE 'rmdir[^|;&]*/s[^|;&]*(\\.codex|\\.agents|\\.git)'; then
  REASON="阻止高风险 rmdir /s。"
fi

if [ -n "$REASON" ]; then
  printf '{"decision":"block","reason":'
  printf '%s' "$REASON" | sed 's/\\/\\\\/g; s/"/\\"/g' | awk 'BEGIN{printf "\""} {printf "%s",$0} END{printf "\""}'
  printf '}\n'
  exit 2
fi

exit 0
