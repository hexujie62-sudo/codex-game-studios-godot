# Skill Test Spec: /start

## Skill Summary

`/start` is the first-session onboarding entry point for Codex Game Studios. It
does not assume that the user already has a game concept, engine preference,
Codex production-function coverage, response-language preference, or current
phase. It first reads project artifacts, then asks two separate structured
questions: Codex production-function coverage first, project state second.

This fork uses multi-window lanes for long-lived state. `/start` must check
window state first. If the project has no
`production/session-state/windows/*.md` files, `/start` should internally create
the minimal `A-producer` control lane, then continue the normal onboarding flow.
It should not ask the user to leave `/start` and run a separate window command,
and it should not interrupt the user with a separate confirmation for low-risk
lane bootstrap.

`/start` may write `production/stage.txt` and
`.codex/docs/collaboration-profile.md`. Those writes may happen only after the
user completes both onboarding choices. `/start` no longer creates, reads, or
normalizes `production/review-mode.txt`; the review standard is fixed and no
longer asks the user to choose full/lean/solo.

Skill source should remain English for public distribution. Runtime replies
should use the active response language, inferred from the collaboration profile,
the user's latest message, or the system/app language. `/start` should record
the chosen `response_language` in `.codex/docs/collaboration-profile.md`.

---

## Static Assertions

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has at least two phase headings
- [ ] Contains `Phase 0: Low-Friction State Bootstrap`
- [ ] Can bootstrap `A-producer` lane before onboarding phases
- [ ] Contains a `single-window` override path
- [ ] Contains verdict keywords: `COMPLETE` and `BLOCKED`
- [ ] Contains the project-state detection inputs: response language, collaboration profile, technical preferences, game concept, source code, prototypes, design docs, production artifacts
- [ ] Asks Codex production-function coverage before project state
- [ ] Presents project state as structured A/B/C/D options
- [ ] Contains a fallback rule that preserves numbered options if `AskUserQuestion` is unavailable
- [ ] Records response language in the collaboration profile
- [ ] Ends with a handoff instead of auto-running the next Skill

---

## Test Cases

### Case 1: Fresh Project With No Lane State

**Fixture:**

- No `production/session-state/windows/*.md`
- No `production/session-state/active.md`
- No `design/gdd/game-concept.md`

**Input:** `/start`

**Expected behavior:**

1. Skill checks lane state before asking about game concept.
2. Skill creates a minimal `A-producer` lane as low-risk framework state.
3. Skill continues into Phase 1 project-state detection.
4. Skill asks a structured Codex production-function coverage question first.
5. After the user answers coverage, Skill asks a separate structured A/B/C/D project-state question.
6. Skill writes `production/stage.txt`, `.codex/docs/collaboration-profile.md`, and session state only after the user makes both onboarding choices.
7. Skill records `response_language` in `.codex/docs/collaboration-profile.md`.
8. Skill does not create or normalize `production/review-mode.txt`.

**Assertions:**

- [ ] `/start` remains the first user entry.
- [ ] No `BLOCKED` verdict is used merely because lane state is missing.
- [ ] Lane creation does not require a separate micro-approval.
- [ ] After lane setup, normal onboarding can continue.
- [ ] The onboarding questions do not collapse into one open-ended prompt.

### Case 2: User Explicitly Chooses Single-Window

**Fixture:**

- No lane files exist.

**Input:** `/start single-window`

**Expected behavior:**

1. Skill skips the lane bootstrap because the user explicitly opted out.
2. Skill warns that recovery and parallel coordination will not be written to a lane.
3. Skill proceeds to normal onboarding.

**Assertions:**

- [ ] Warning mentions `/window-ccgs A` can be run later.
- [ ] The skill still records stage/profile only after the user answers onboarding.
- [ ] No lane file is created by `/start`.

### Case 3: Existing Lane State

**Fixture:**

- `production/session-state/windows/A-producer.md` exists.
- `production/session-state/active.md` may or may not exist.

**Input:** `/start`

**Expected behavior:**

1. Skill recognizes that the project has entered the lane system.
2. Skill continues to project-state detection.
3. Skill asks Codex production-function coverage first.
4. Skill asks project state A/B/C/D only after the coverage answer.

**Assertions:**

- [ ] The lane bootstrap does not block.
- [ ] The function-coverage options and onboarding options A/B/C/D are shown.
- [ ] No duplicate lane creation is suggested as the primary action.
- [ ] If the structured question tool is unavailable, the same options are shown as numbered text rather than replaced by a single open-ended sentence.

### Case 4: Custom Lane Exists But No Producer Lane

**Fixture:**

- `production/session-state/windows/systems-design.md` exists.
- `production/session-state/windows/A-producer.md` does not exist.

**Input:** `/start`

**Expected behavior:**

1. Skill treats the project as lane-enabled.
2. Skill continues onboarding.
3. Skill reminds the user that long-running projects should also have a control lane such as `/window-ccgs A`.

**Assertions:**

- [ ] Custom lane is accepted as valid lane state.
- [ ] `/window-ccgs A` appears as a reminder, not as a blocker.

### Case 5: Returning Project

**Fixture:**

- Engine is configured in `.codex/docs/technical-preferences.md`.
- `design/gdd/game-concept.md` exists.
- At least one lane file exists.

**Input:** `/start`

**Expected behavior:**

1. Skill detects that basic setup already exists.
2. Skill does not restart onboarding by default.
3. Skill summarizes current engine, concept file, and fixed review policy.
4. Skill suggests continuing with an appropriate next command such as `/help`, `/design-system`, or the current required step.

**Assertions:**

- [ ] Existing configuration is not overwritten.
- [ ] The user is not asked to recreate already existing concept work.
- [ ] Verdict is `COMPLETE` or a clear handoff is provided.

### Case 6: Stage Write And Fixed Review Policy

**Fixture:**

- Lane state exists.
- `production/stage.txt` is missing.
- `production/review-mode.txt` is missing.

**Input:** `/start`

**Expected behavior:**

1. Skill only writes `production/stage.txt` after the user chooses an onboarding path.
2. Skill does not create, read, or normalize `production/review-mode.txt`.
3. Skill states the fixed review policy as conversation guidance only.
4. The stage value maps to the documented stage mapping.

**Assertions:**

- [ ] Stage write happens after path selection, not before.
- [ ] No full/lean/solo review-mode prompt appears.
- [ ] Review mode file is not created.
- [ ] No unrelated files are modified.

### Case 7: Response Language Selection

**Fixture:**

- `.codex/docs/collaboration-profile.md` does not exist or has no `response_language`.
- The user's latest message is written in Chinese.

**Input:** `/start`

**Expected behavior:**

1. Skill keeps its source instructions in English.
2. Skill renders user-facing prompts and option labels in Chinese.
3. Skill writes the inferred response language to `.codex/docs/collaboration-profile.md`.

**Assertions:**

- [ ] The user receives localized onboarding prompts.
- [ ] The structured choices keep the same meanings as the English source.
- [ ] Later Skills can read `response_language` from the collaboration profile.

---

## Protocol Compliance

- [ ] `/start` may create the initial `A-producer` lane during first onboarding.
- [ ] `/start` does not auto-run the next Skill.
- [ ] If no lane exists, `/start` bootstraps lane state instead of blocking.
- [ ] If the user explicitly opts into single-window mode, `/start` can proceed but warns about the tradeoff.
- [ ] File writes are limited to documented startup state files; `production/review-mode.txt` is not created or normalized.
- [ ] The first two user questions stay structured and separate.

---

## Coverage Notes

- This spec intentionally treats multi-window lane setup as a first-class entry
  concern because this fork is Codex-first and file-backed.
- The exact content of game concept questions is tested by authoring Skills, not
  by this utility spec.
- `/help` is responsible for ongoing route recommendations after startup.
