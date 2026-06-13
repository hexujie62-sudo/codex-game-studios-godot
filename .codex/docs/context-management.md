# Context Management

Context is the most critical resource in a Codex session. Manage it actively.

## File-Backed State (Primary Strategy)

**The file is the memory, not the conversation.** Conversations are ephemeral and
will be compacted or lost. Files on disk persist across compactions and session crashes.

## Shell Command Hygiene

All windows use PowerShell 7 from the project-pinned path:

`C:\tmp\pwsh-7.6.2-msix-extracted\x64\pwsh.exe`

Do not use WindowsApps/MSIX `pwsh.exe` launch targets.

Most shell work should stay simple:

- Prefer `rg`, `Get-Content -Raw`, `Select-String`, `Get-ChildItem`, and direct `git` commands.
- Avoid packing complex parsing, regex, `$variables`, `$_`, and backticks into one nested command string.
- If using `-Command` with `$`, `$_`, regex, or backticks, prefer single quotes around the command body:
  `-Command '$items | ForEach-Object { $_.Line }'`
- Avoid nested double-quoted `-Command "..."` for complex PowerShell because the outer shell can expand `$` or `$_` before PowerShell 7 receives the script.
- For hook logic or repeated parsing, prefer a small script file or simple POSIX sh in `.githooks/` over heavily nested inline PowerShell.

Z-platform owns this rule. If a Skill, Hook, or lane workflow needs complex shell
automation, update the shared rule here instead of inventing a local command style.

## Git Checkpoints And Research Worktrees

Use `.codex/docs/git-checkpoint-workflow.md` for commit checkpoints, rollback
messages, multi-window commit conflict rules, and research worktree handling.

Natural checkpoint points are the same places as natural compaction points:
after writing a phase artifact, after updating a lane handoff, after completing
a work-order/review/evidence unit, before switching lanes, and before starting research
work.

Default policy is to recommend a checkpoint, not silently commit. Automatic
checkpoint commits require an explicit lane policy such as
`auto_checkpoint: true` and must still stage only the files named in the
checkpoint plan. Research branches should use `git worktree` instead of
switching the shared worktree branch.

### Session State File

Maintain `production/session-state/active.md` as a living checkpoint. Update it
after each significant milestone:

- Design section approved and written to file
- Architecture decision made
- Implementation milestone reached
- Test results obtained

The state file should contain: current task, progress checklist, key decisions
made, files being worked on, and open questions.

### Multi-Window State

For parallel Codex windows, use `.codex/docs/multi-window-workflow.md`.

`active.md` is the project overview. Each long-running window keeps its own lane
file under `production/session-state/windows/<window-id>.md`.

Default windows:

- `A-producer` — project control, scope, phase, cross-window coordination
- `B-dev` — implementation, tests, runtime evidence
- `C-art` — art direction, asset specs, asset audit
- `D-director` — project-level verdicts, work orders, canon
- `Z-platform` — CFG bottom layer: Skills, Hooks, route index, test framework, docs

`D` is the shortcut for `D-director`. `qa` is not a default shortcut. B-dev and
C-art keep their current smoke/validation duties until a formal independent QA
lane is explicitly created.

Do not copy a full conversation into a new window. Start the new window by
running `/window-cfg [A|B|C|D|Z]`. If that Skill is unavailable, read
`active.md`, the relevant lane file, and `multi-window-workflow.md` manually.

D-director must also read `production/project-canon.md` and
`.agents/skills/director-review/SKILL.md` before verdict work.

After taking over a window, Codex refreshes the lane state at each milestone,
before closing the window, and before context reaches the danger zone. Use
`/window-cfg audit` from A-producer to verify lanes are current. Use
`/window-cfg compact [A|B|C|D|Z]` when a lane grows too long.

### Status Line Block (Production+ only)

When the project is in Production, Polish, or Release stage, include a structured
status block in `active.md` that the status line script can parse:

```markdown
<!-- STATUS -->
WorkOrder: GA06-START
Owner: B-dev
Task: Implement hitbox detection
<!-- /STATUS -->
```

- All fields are optional — include only what applies
- Update this block when switching focus areas
- The status line displays it as a breadcrumb such as `GA06-START > B-dev > Hitboxes`
- Remove or empty the block when no active work focus exists

After any disruption (compaction, crash, `/clear`), read the state file first.

### Incremental File Writing Within An Approved Package

When creating multi-section documents (design docs, architecture docs, lore entries):

1. First present and approve the complete document/package scope: purpose,
   sections, design decisions to settle, files to write, and acceptance criteria.
2. Create the file with a skeleton after that package is approved.
3. Draft and write sections incrementally to protect context, but do not ask for
   a new write approval for every section if the section stays inside the
   approved package.
4. Ask again only if a section changes direction, crosses scope, or introduces a
   high-risk decision not covered by the package.
5. Update the session state file after each meaningful section or milestone.
6. After writing a section, previous discussion about that section can be safely
   compacted — the decisions are in the file

This keeps the context window holding only the *current* section's discussion
(~3-5k tokens) instead of the entire document's conversation history (~30-50k tokens).

## Proactive Compaction

- **Compact proactively** at ~60-70% context usage, not reactively at the limit
- **Use `/clear`** between unrelated tasks, or after 2+ failed correction attempts
- **Natural compaction points:** after writing a section to file, after creating
  a checkpoint commit, after completing a task, before starting a new topic
- **Focused compaction:** `/compact Focus on [current task] — sections 1-3 are
  written to file, working on section 4`

## Context Budgets by Task Type

- Light (read/review): ~3k tokens startup
- Medium (implement feature): ~8k tokens
- Heavy (multi-system refactor): ~15k tokens

## Subagent Delegation

Use subagents for research and exploration to keep the main session clean.
Subagents run in their own context window and return only summaries:

- **Use subagents** when investigating across multiple files, exploring unfamiliar code,
  or doing research that would consume >5k tokens of file reads
- **Use direct reads** when you know exactly which 1-2 files to check
- Subagents do not inherit conversation history — provide full context in the prompt

## Compaction Instructions

When context is compacted, preserve the following in the summary:

- Reference to `production/session-state/active.md` (read it to recover state)
- List of files modified in this session and their purpose
- Any architectural decisions made and their rationale
- Active work orders and their current status
- Agent invocations and their outcomes (success/failure/blocked)
- Test results (pass/fail counts, specific failures)
- Unresolved blockers or questions awaiting user input
- The current task and what step we are on
- Which sections of the current document are written to file vs. still in progress

**After compaction:** Read `production/session-state/active.md` and any files being
actively worked on to recover full context. The files contain the decisions; the
conversation history is secondary.

## Recovery After Session Crash

If a session dies ("prompt too long") or you start a new session to continue work:

1. The `session-start.sh` hook will detect and preview `active.md` automatically
2. Read the full state file for context
3. Read the partially-completed file(s) listed in the state
4. Continue from the next incomplete section or task
