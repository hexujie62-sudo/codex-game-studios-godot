#!/usr/bin/env bash
# Codex SessionStart hook: report only obvious route gaps.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"

ROOT="$(repo_root)"
cd "$ROOT" 2>/dev/null || exit 0

MESSAGES=""

if [ ! -f ".codex/docs/technical-preferences.md" ]; then
  MESSAGES="$MESSAGES\n- 缺少技术偏好: 运行 /setup-engine 固定引擎和版本。"
elif grep -q "TO BE CONFIGURED" ".codex/docs/technical-preferences.md" 2>/dev/null; then
  MESSAGES="$MESSAGES\n- 技术偏好尚未配置: 运行 /setup-engine。"
fi

if [ ! -f "design/gdd/game-concept.md" ]; then
  MESSAGES="$MESSAGES\n- 缺少游戏概念文档: 运行 /start 或 /brainstorm。"
fi

if [ ! -f "design/gdd/systems-index.md" ]; then
  MESSAGES="$MESSAGES\n- 缺少系统索引: 概念明确后运行 /design-system。"
fi

if [ -n "$MESSAGES" ]; then
  {
    echo "CFG 明显缺口提醒："
    printf '%b\n' "$MESSAGES"
    echo "轻量下一步请运行 /help；阶段推进判断请运行 /gate-check。"
  } | emit_session_context
fi

exit 0
