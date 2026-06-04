#!/usr/bin/env bash
# Shared helpers for Codex-native hooks.

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || pwd
}

json_string() {
  if command -v python >/dev/null 2>&1; then
    python -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
  elif command -v py >/dev/null 2>&1; then
    py -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
  else
    sed 's/\\/\\\\/g; s/"/\\"/g' | awk 'BEGIN{printf "\""} {printf "%s\\n",$0} END{printf "\""}'
  fi
}

emit_session_context() {
  local message
  message=$(cat)
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":'
  printf '%s' "$message" | json_string
  printf '}}\n'
}

emit_system_message() {
  local message
  message=$(cat)
  printf '{"continue":true,"systemMessage":'
  printf '%s' "$message" | json_string
  printf '}\n'
}

json_get_string() {
  local input="$1"
  local field="$2"
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$input" | jq -r "$field // empty" 2>/dev/null
  else
    local key
    key=$(printf '%s' "$field" | sed 's/^\.//; s/\./"[^{}]*"*:{"*/g; s/\//\\\//g')
    # Fallback is intentionally shallow; hooks also handle empty results safely.
    printf '%s' "$input" | grep -oE '"[^"]+"[[:space:]]*:[[:space:]]*"[^"]*"' | \
      grep -E "\"$(printf '%s' "$field" | sed 's/.*\.//')\"" | head -1 | \
      sed 's/^[^:]*:[[:space:]]*"//; s/"$//'
  fi
}
