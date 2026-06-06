# Skill Spec: /window-ccgs

> **Category**: utility
> **Priority**: critical
> **Spec written**: 2026-06-06

## Skill Summary

`/window-ccgs` is the single CCGS multi-window entrypoint. It starts, restores,
creates, updates, audits, compacts, generates checkpoint plans, and manages
research worktree preflights for lane state files under
`production/session-state/windows/`. It absorbs the old `window-start-ccgs` and
`window-handoff-ccgs` routes so users do not need to remember separate window
commands.

---

## Static Assertions

- [ ] Frontmatter has all required fields (`name`, `description`,
  `argument-hint`, `user-invocable`, `allowed-tools`)
- [ ] 2+ phase headings found
- [ ] At least one verdict keyword present (`PASS`, `FAIL`, `CONCERNS`,
  `BLOCKED`, `COMPLETE`, `READY`)
- [ ] Because `allowed-tools` includes Write/Edit, `"May I write"`,
  `"May I update"`, or `"May I archive"` language is present
- [ ] If checkpoint/research behavior is present, shell/git use is constrained
  to non-destructive commands and does not permit `git add .`, force push, hard
  reset, or checkout discard
- [ ] Next-step handoff section present at end

---

## Director Gate Checks

N/A. This is a context-management Skill. It never triggers director gates and
cannot advance project stage.

---

## Test Cases

### Case 1: Restore Existing Lane

**Fixture**:
- User invokes `/window-ccgs Z`
- `production/session-state/windows/Z-platform.md` exists
- `production/session-state/active.md` registers `Z-platform`

**Expected behavior**:
1. Maps `Z` to `Z-platform`.
2. Reads `AGENTS.md`, context-management docs, multi-window workflow,
   `active.md`, and the lane file.
3. Outputs role, lane path, current objective, next step, avoid-touch paths,
   registry status, and `READY`.

**Assertions**:
- [ ] Does not rely on old conversation history.
- [ ] Does not ask the user to copy a long restart prompt.
- [ ] Does not write files in restore mode.

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 2: Create Missing Lane

**Fixture**:
- User invokes `/window-ccgs B`
- `production/session-state/windows/B-dev.md` does not exist

**Expected behavior**:
1. Maps `B` to `B-dev`.
2. Drafts the missing lane file with default B-dev responsibility and scope.
3. Drafts the matching `active.md` registry update.
4. Asks: `May I write the missing lane file to production/session-state/windows/B-dev.md and register it in production/session-state/active.md?`

**Assertions**:
- [ ] Does not write without approval.
- [ ] Registry update is prepared with the lane file.
- [ ] If declined, outputs manual recovery guidance and `CONCERNS`.

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 3: Update Lane Handoff

**Fixture**:
- User invokes `/window-ccgs update Z`
- `production/session-state/windows/Z-platform.md` exists
- The current window completed a Skill governance change

**Expected behavior**:
1. Reads the target lane and `active.md`.
2. Shows update scope before writing:
   - Lane body update / append / unchanged
   - Handoff replacement / unchanged
   - Sections intentionally not changed
   - Old handoff handling
3. Asks: `May I update production/session-state/windows/Z-platform.md with this handoff?`

**Assertions**:
- [ ] Does not overwrite `Responsibility` or `Scope` unless explicitly requested.
- [ ] Preserves still-valid old handoff information by migrating it or naming it obsolete.
- [ ] Does not write full chat logs or large diffs into lane state.

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 4: Audit All Lanes

**Fixture**:
- User invokes `/window-ccgs audit`
- Multiple lane files exist, including at least one custom lane

**Expected behavior**:
1. Reads all `production/session-state/windows/*.md`.
2. Checks required sections and handoff freshness.
3. Checks registry mismatches against `active.md`.
4. Checks active-file conflicts using only paths in each lane's
   `## Active Files` block.
5. Outputs `PASS`, `CONCERNS`, or `FAIL`.

**Assertions**:
- [ ] Does not hardcode only A/B/C/D/Z.
- [ ] Audit mode is read-only.
- [ ] File conflicts are reported but not auto-resolved.

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 5: Compact Long Lane

**Fixture**:
- User invokes `/window-ccgs compact Z`
- `Z-platform.md` is over the hard threshold

**Expected behavior**:
1. Creates an archive path proposal under
   `production/session-state/windows/archive/`.
2. Drafts a compacted lane retaining responsibility, current objective, scope,
   active files, recent decisions, blockers, current handoff, and archive link.
3. Asks: `May I archive and compact production/session-state/windows/Z-platform.md?`

**Assertions**:
- [ ] Full old lane content is preserved in the archive draft.
- [ ] No archive or rewrite happens without approval.
- [ ] Verdict is `COMPLETE` or `CONCERNS`.

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 6: Checkpoint Plan — single-lane rollback unit

**Fixture**:
- User invokes `/window-ccgs checkpoint Z`
- `production/session-state/windows/Z-platform.md` exists
- `git status --short` includes changes under `.agents/skills/`,
  `.codex/docs/`, `.githooks/`, and the Z-platform lane file
- `/window-ccgs audit` has no file conflicts

**Expected behavior**:
1. Reads `.codex/docs/git-checkpoint-workflow.md`.
2. Reads the Z-platform lane and current git status.
3. Produces a checkpoint candidate with `Stage only`, `Leave unstaged`,
   suggested Conventional Commit subject, and body fields:
   `Lane:`, `Scope:`, `Verification:`, `Rollback:`.
4. Does not run `git add .`.
5. Does not commit unless the user explicitly asks or the lane records
   `auto_checkpoint: true`.

**Assertions**:
- [ ] Commit recommendation is tied to one lane.
- [ ] Rollback path uses `git revert <sha>`, not reset.
- [ ] Unrelated dirty files are left unstaged.
- [ ] Verdict is `READY`, `CONCERNS`, or `BLOCKED`.

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 7: Research Worktree — isolated branch creation

**Fixture**:
- User invokes `/window-ccgs research Z skill-slim-cleanup`
- Current branch is `main-work`
- Current HEAD is `abc1234`
- Current worktree has no uncheckpointed Z-platform owner changes

**Expected behavior**:
1. Sanitizes slug to lowercase dash form.
2. Drafts branch `codex/research/z-platform-skill-slim-cleanup-YYYYMMDD`.
3. Drafts worktree `../ccgs-worktrees/z-platform-skill-slim-cleanup`.
4. Records base SHA, merge target, and removal command.
5. Uses `git worktree add -b ...` only after confirming no path/branch conflict.
6. Updates the lane with branch/worktree/base/merge target if creation succeeds.

**Assertions**:
- [ ] Does not switch the shared worktree branch.
- [ ] Blocks when current dirty changes overlap the lane owner path.
- [ ] Does not commit, push, force, reset, or discard changes during creation.

**Case Verdict**: PASS / FAIL / PARTIAL

---

### Case 8: Research Merge — clean-only automation

**Fixture**:
- User invokes `/window-ccgs merge Z`
- Z-platform lane records research branch, worktree, base SHA, merge target, and
  `auto_merge: clean-only`
- Research worktree status is clean
- Non-destructive merge preflight reports no conflicts

**Expected behavior**:
1. Reads the lane branch/worktree metadata.
2. Verifies main worktree cleanliness for overlapping paths.
3. Verifies research worktree status is clean.
4. Compares merge-base to the recorded base SHA or reports drift.
5. Runs a non-destructive merge conflict check before any merge.
6. If all preflight checks pass and `auto_merge: clean-only` is present, merge
   may proceed; otherwise it outputs a merge plan and asks approval.
7. Reports merge SHA and rollback command `git revert -m 1 <merge-sha>` after a
   successful merge.

**Assertions**:
- [ ] Dirty research worktree blocks merge.
- [ ] Merge conflicts block automation.
- [ ] No force push, reset, or checkout discard is used.
- [ ] Rollback path is documented.

**Case Verdict**: PASS / FAIL / PARTIAL

---

## Protocol Compliance

- [ ] Uses `"May I write"`, `"May I update"`, or `"May I archive"` before file writes
- [ ] Presents draft/scope before requesting approval
- [ ] Ends with a recommended next action
- [ ] Does not auto-create, auto-register, or auto-compact lanes without approval
- [ ] Checkpoint commits stage only named files and include lane, scope,
  verification, and rollback information
- [ ] Research work uses separate worktrees and clean-only auto-merge rules

---

## Coverage Notes

This spec replaces the old `window-start-ccgs` and `window-handoff-ccgs` specs
as the active catalog target. Those old specs may remain as historical reference
but should not appear in `catalog.yaml`.
