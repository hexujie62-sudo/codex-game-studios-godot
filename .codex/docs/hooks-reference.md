# Codex And Git Hooks

Codex hooks are configured in `.codex/hooks.json`. They are intentionally
lightweight: session context, obvious route gaps, dangerous-command protection,
skill-change reminders, and compaction recovery. Stronger checks live in
`.githooks/` and CI.

Git checkpoint and research branch policy lives in
`.codex/docs/git-checkpoint-workflow.md`.

## Active Codex Hooks

| Hook | Event | Trigger | Action |
| ---- | ----- | ------- | ------ |
| `session-start.sh` | SessionStart | New Codex thread/session | Emits JSON `additionalContext` with branch, stage, active state file, registered lane restore commands, hook reminders, dirty worktree count, and low-frequency checkpoint hints |
| `detect-gaps-lite.sh` | SessionStart | New Codex thread/session | Emits JSON `additionalContext` for obvious missing route artifacts only |
| `dangerous-command-policy.sh` | PreToolUse | `Bash` or `apply_patch` | Blocks force push, hard reset, checkout discard, and high-risk recursive deletion of core folders |
| `skill-change-reminder.sh` | PostToolUse | `Write`, `Edit`, or `apply_patch` | Detects `.agents/skills/*/SKILL.md` changes and reminds `/skill-create-cfg`; also writes `production/session-state/hook-reminders.md` |
| `post-compact-restore.sh` | PostCompact | After context compaction | Emits JSON `systemMessage` reminding Codex to read `production/session-state/active.md` and restore the correct lane with `/window-cfg <lane-id>` |

## Git Hooks

Enable local Git hooks with:

```bash
git config core.hooksPath .githooks
```

| Hook | Trigger | Action |
| ---- | ------- | ------ |
| `.githooks/pre-commit` | `git commit` | Blocks invalid JSON, untracked lane files, and duplicate lane Active Files; warns on multi-domain staged changes, GDD section gaps, gameplay hardcoded values, TODO owner format, asset naming, and skill edits |
| `.githooks/pre-push` | `git push` | Blocks direct pushes to `main`, `master`, and `develop` |

## Legacy Scripts

Previous CCGS hook scripts are legacy compatibility material. If present, they are not
wired in `.codex/hooks.json` and should not be treated as active Codex safety
checks. See `docs/ccgs-codex-hook-adaptation-plan.md` for the migration
rationale.

Hook input schema documentation: `.codex/docs/hooks-reference/hook-input-schemas.md`

