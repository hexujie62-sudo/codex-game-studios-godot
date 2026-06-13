# Git Checkpoint Workflow

This document defines how CFG Codex windows decide when to commit, how they
avoid cross-window conflicts, and how research work gets isolated without
making the user manage Git details.

## Principles

- A commit is a recovery checkpoint, not just a diff bundle.
- Every checkpoint must be easy to explain and easy to revert.
- One checkpoint normally belongs to one lane.
- Multi-lane commits require an A-producer scope decision.
- Research work uses short-lived branches in separate worktrees.
- No `git add .`; stage only the files named in the checkpoint plan.
- No force push, hard reset, or checkout discard as part of this workflow.

## Checkpoint Readiness

`/help` and lane state refresh should recommend a checkpoint when
one of these is true:

- A phase artifact was written or deleted.
- A lane handoff was updated after meaningful work.
- A core Skill, Hook, route index, workflow catalog, test spec, or architecture
  document changed.
- A work-order implementation, review, evidence, or bug triage unit completed.
- The dirty worktree is large enough that recovery would be unclear.
- The user is about to switch lanes, compact context, or start research work.

Do not recommend a checkpoint just because one small typo changed. Use judgment:
the commit should make sense as a rollback unit.

## Checkpoint Plan

Before staging or committing, produce a short plan:

```text
Checkpoint candidate
Lane: [lane-id]
Reason: [why now]
Stage only:
- [file]
- [file]
Leave unstaged:
- [file] — [why unrelated or unsafe]
Suggested commit:
  [type]: [short subject]

Body:
  Lane: [lane-id]
  Scope: [one-line scope]
  Verification: [checks run or not run]
  Rollback: git revert <commit-sha-after-commit>
```

If the user approves a commit, stage only the `Stage only` files. After the
commit succeeds, report the actual SHA and the concrete rollback command:

```text
Rollback: git revert <sha>
```

## Commit Message Shape

Use Conventional Commits in the subject:

- `feat:`
- `fix:`
- `docs:`
- `test:`
- `refactor:`
- `chore:`

The body should include:

```text
Lane: [lane-id]
Scope: [what this checkpoint changes]
Verification: [commands/checks run, or "not run: reason"]
Rollback: git revert <sha-after-commit>
```

If the SHA is not known before commit, write `Rollback: git revert <sha>`, then
report the resolved command after the commit.

## Auto Checkpoint Policy

Default policy is `suggest`.

Automatic commits are allowed only when all conditions are true:

- The lane or user instruction explicitly enables `auto_checkpoint: true`.
- The checkpoint contains files from a single lane owner.
- `/window-cfg audit` has no file conflicts.
- The staged file list is explicit and contains no broad glob.
- The commit message includes lane, scope, verification, and rollback fields.
- The worktree has no unrelated unstaged changes in the same owner path.

If any condition is unclear, fall back to a checkpoint recommendation.

## Multi-Window Conflict Rules

Pre-commit hooks provide hard stops for the most dangerous states:

- Untracked lane files under `production/session-state/windows/`.
- Duplicate paths in lane `Active Files`.

They also warn on suspicious states:

- Staged files span multiple owner domains.
- Staged files include core framework paths without an updated Z-platform lane.
- Staged files include code/test/evidence paths without a matching B-dev lane
  update.
- Staged files include D-director canon or work-order paths without a matching
  D-director lane update.

Warnings do not replace human judgment. They are prompts to run:

```text
/window-cfg audit
/window-cfg checkpoint <lane-id>
```

## D-director Checkpoints

D-director owns:

- `production/project-canon.md`
- `production/work-orders/`
- `production/session-state/windows/D-director.md`

Work order files and canon changes should checkpoint with D-director. Execution
artifacts created because of a work order checkpoint with the execution lane
that owns those artifacts.

## Research Worktrees

Research directions should not switch the shared worktree branch out from under
other windows.

Use:

```text
/window-cfg research <lane-id> <slug>
```

The command drafts or creates:

```text
Branch: codex/research/<normalized-lane-id>-<slug>-YYYYMMDD
Worktree: ../cfg-worktrees/<normalized-lane-id>-<slug>
Base SHA: <current-head>
Merge target: <current-branch>
```

Research creation is blocked if the current worktree has uncheckpointed changes
that overlap the lane owner path. Create a checkpoint first.

The research lane records:

- branch using the normalized lowercase lane id
- worktree path
- base SHA
- merge target
- auto-merge policy
- rollback/removal command

## Research Merge

Use:

```text
/window-cfg merge <lane-id>
```

The merge preflight checks:

- Main worktree is clean or has only unrelated changes.
- Research branch exists.
- Research worktree has no uncommitted changes.
- `git merge-base` matches the recorded base or the drift is explained.
- A non-destructive merge conflict check passes.
- Required tests or manual verification are recorded.

Auto-merge is allowed only when the lane says `auto_merge: clean-only` and the
preflight is clean. Otherwise, produce a merge plan and ask for approval.

After merge, keep the research worktree until the user or lane policy says it
can be removed. Removal command:

```text
git worktree remove <worktree-path>
```

## Rollback

Checkpoint rollback:

```text
git revert <checkpoint-sha>
```

Research branch rollback before merge:

```text
git worktree remove <worktree-path>
git branch -D <research-branch>
```

Research merge rollback:

```text
git revert -m 1 <merge-sha>
```

Never use `git reset --hard` as the default rollback path.
