# Codex Hook Input/Output Schemas

This file documents the schema shapes used by the current CCGS Codex-native
hooks. Codex hook behavior is defined by OpenAI Codex, not by the legacy CCGS
Claude Code hook model.

Reference: https://developers.openai.com/codex/hooks

## Shared Notes

- Project hooks must be trusted through Codex before they run.
- Commands run with the session cwd; repo-local scripts should locate the git
  root before invoking files.
- `PreToolUse`, `PermissionRequest`, `PostToolUse`, `PreCompact`,
  `PostCompact`, `UserPromptSubmit`, `SubagentStop`, and `Stop` run at turn
  scope.
- `SessionStart` and `SubagentStart` run at thread/subagent-start scope.
- Multiple matching hooks can run concurrently.
- Pure text stdout is ignored for several events. Prefer JSON stdout.

## Active Event Inputs

### SessionStart

Used by:

- `.codex/hooks/session-start.sh`
- `.codex/hooks/detect-gaps-lite.sh`

Typical input:

```json
{
  "hookEventName": "SessionStart",
  "source": "startup"
}
```

Expected output:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Context to add to the Codex session."
  }
}
```

### PreToolUse

Used by:

- `.codex/hooks/dangerous-command-policy.sh`

Typical Bash input:

```json
{
  "hookEventName": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": {
    "command": "git reset --hard"
  }
}
```

Typical apply_patch input:

```json
{
  "hookEventName": "PreToolUse",
  "tool_name": "apply_patch",
  "tool_input": {
    "command": "*** Begin Patch\n..."
  }
}
```

Blocking output:

```json
{
  "decision": "block",
  "reason": "Destructive command blocked by hook."
}
```

### PostToolUse

Used by:

- `.codex/hooks/skill-change-reminder.sh`

Typical file-path input:

```json
{
  "hookEventName": "PostToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": ".agents/skills/help/SKILL.md"
  }
}
```

Typical apply_patch input:

```json
{
  "hookEventName": "PostToolUse",
  "tool_name": "apply_patch",
  "tool_input": {
    "command": "*** Begin Patch\n*** Update File: .agents/skills/help/SKILL.md\n..."
  }
}
```

Expected output:

```json
{
  "continue": true,
  "systemMessage": "Reminder shown in Codex."
}
```

The hook also writes persistent reminders to
`production/session-state/hook-reminders.md`.

### PostCompact

Used by:

- `.codex/hooks/post-compact-restore.sh`

Typical input:

```json
{
  "hookEventName": "PostCompact",
  "trigger": "auto"
}
```

Expected output:

```json
{
  "continue": true,
  "systemMessage": "Read production/session-state/active.md to restore context."
}
```

## Events Not Used By Default

These events are supported by Codex but not used by the active CCGS default
configuration:

- `PreCompact`: previous CC behavior depended on dumping text into the
  conversation; Codex requires JSON and file-backed state is more reliable.
- `Stop`: turn scope, not session-close scope. Do not use it for session-end
  logging without a dedicated turn-stop design.
- `SubagentStart` / `SubagentStop`: useful only if the project needs a separate
  agent audit log beyond Codex transcripts.
- `Notification`: not part of the current Codex hook event set used here.

Legacy scripts for these behaviors are archived in `.codex/hooks/legacy/`.
