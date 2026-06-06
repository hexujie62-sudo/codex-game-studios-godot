# Skill Test Spec: /help

## Skill Summary

`/help` analyzes what has been done and what comes next in the project workflow.
It runs on the Haiku model (read-only, formatting task) and reads `production/stage.txt`,
the active sprint file, and recent session state to produce a concise situational
guidance summary. The skill optionally accepts a context query (e.g., `/help testing`)
to surface relevant skills for a specific topic.

The output is always informational — no files are written and no director gates
are invoked. The verdict is always HELP COMPLETE. The skill serves as a workflow
navigator, suggesting 2-3 next skills based on the current project state.

---

## Static Assertions (Structural)

Verified automatically by `/skill-create-ccgs` internal static check — no fixture needed.

- [ ] Has required frontmatter fields: `name`, `description`, `argument-hint`, `user-invocable`, `allowed-tools`
- [ ] Has ≥2 phase headings
- [ ] Contains verdict keyword: HELP COMPLETE
- [ ] Does NOT contain "May I write" language (skill is read-only)
- [ ] Has a next-step handoff (suggests 2-3 relevant skills based on state)

---

## Director Gate Checks

None. `/help` is a read-only navigation skill. No director gates apply.

---

## Test Cases

### Case 1: Happy Path — Production stage with active sprint

**Fixture:**
- `production/stage.txt` contains `Production`
- `production/sprints/sprint-004.md` exists with in-progress stories
- `production/session-state/active.md` has a recent checkpoint

**Input:** `/help`

**Expected behavior:**
1. Skill reads stage.txt and active sprint
2. Skill identifies current sprint number and in-progress story count
3. Skill outputs: current stage, sprint summary, and 2-3 suggested core skills
   (e.g., `/sprint-plan`, `/dev-story`, `/story-done`)
4. Suggestions are ranked by relevance to current sprint state
5. Verdict is HELP COMPLETE

**Assertions:**
- [ ] Current stage is shown (Production)
- [ ] Active sprint number and story count are mentioned
- [ ] Exactly 2-3 next-skill suggestions are given (not a list of all skills)
- [ ] Suggestions are appropriate for Production stage
- [ ] Verdict is HELP COMPLETE
- [ ] No files are written

---

### Case 2: Concept Stage — Shows concept-to-systems-design workflow path

**Fixture:**
- `production/stage.txt` contains `Concept`
- No sprint files, no GDD files
- `technical-preferences.md` is configured (engine selected)

**Input:** `/help`

**Expected behavior:**
1. Skill reads stage.txt — detects Concept stage
2. Skill outputs the Concept-stage workflow: brainstorm → design-system
3. Suggested skills are: `/brainstorm`, `/design-system` (if concept exists)
4. Current progress is noted: "Engine configured, concept not yet created"

**Assertions:**
- [ ] Stage is identified as Concept
- [ ] Workflow path shows the expected sequence for this stage
- [ ] Suggestions do not include Production-stage skills (e.g., `/dev-story`)
- [ ] Verdict is HELP COMPLETE

---

### Case 3: No stage.txt — Shows full workflow overview

**Fixture:**
- No `production/stage.txt`
- No sprint files
- `technical-preferences.md` has placeholders

**Input:** `/help`

**Expected behavior:**
1. Skill cannot determine stage from stage.txt
2. Skill runs absorbed stage-detection logic to infer stage from artifacts
3. If stage cannot be inferred: outputs the full workflow overview from
   Concept through Release as a reference map
4. Primary suggestion is `/start` to begin configuration

**Assertions:**
- [ ] Skill does not crash when stage.txt is absent
- [ ] Full workflow overview is shown when stage cannot be determined
- [ ] `/start` or `/help` stage-detection guidance is a top suggestion
- [ ] Verdict is HELP COMPLETE

---

### Case 4: Context Query — User asks for help with testing

**Fixture:**
- `production/stage.txt` contains `Production`
- Active sprint has a story with `Status: In Review`

**Input:** `/help testing`

**Expected behavior:**
1. Skill reads context query: "testing"
2. Skill surfaces core skills relevant to testing: `/smoke-check`,
   `/story-done`, `/setup-engine`, and `/bug-report` when defects are involved
3. Output is focused on testing workflow, not general sprint navigation
4. Currently in-review story is highlighted as a testing candidate

**Assertions:**
- [ ] Context query is acknowledged in output ("Help topic: testing")
- [ ] At least 3 testing-relevant skills are listed
- [ ] General sprint skills (e.g., `/sprint-plan`) are not the primary suggestions
- [ ] Verdict is HELP COMPLETE

---

### Case 5: Director Gate Check — No gate; help is read-only navigation

**Fixture:**
- Any project state

**Input:** `/help`

**Expected behavior:**
1. Skill produces workflow guidance summary
2. No director agents are spawned
3. No gate IDs appear in output
4. No write tool is called

**Assertions:**
- [ ] No director gate is invoked
- [ ] No write tool is called
- [ ] No gate skip messages appear
- [ ] Verdict is HELP COMPLETE without any gate check

---

### Case 6: Registered Windows — 常驻展示所有已注册 lane

**Fixture:**
- `production/session-state/active.md` contains a Multi-Window Coordination table.
- `production/session-state/windows/Z-platform.md` exists.
- No `A-producer.md`, `B-dev.md`, `C-art.md`, or `D-qa.md` exists.

**Input:** `/help`

**Expected behavior:**
1. Skill reads `active.md`.
2. Skill scans `production/session-state/windows/*.md`.
3. Output includes a `Registered Windows` block.
4. Output lists `Z-platform` because its lane file exists.
5. Output does not claim A/B/C/D are registered when their lane files are missing.
6. Output always includes the window command block:
   - `/window-ccgs <lane-id>`
   - `/window-ccgs update <lane-id>`

**Assertions:**
- [ ] Registered windows are based on actual lane files, not a fixed A/B/C/D/Z list.
- [ ] `Window commands` appears even when only one lane is registered.
- [ ] Registry mismatches between `active.md` and lane files are shown as concerns.
- [ ] No files are written.

---

### Case 7: File Conflicts — 展示窗口文件占用冲突

**Fixture:**
- `production/session-state/windows/systems-design.md` exists.
- `production/session-state/windows/B-dev.md` exists.
- Both lane files list `` `design/gdd/combat.md` `` in `Active Files`.

**Input:** `/help`

**Expected behavior:**
1. Skill scans registered lane files.
2. Skill extracts paths from each lane's `Active Files`.
3. Output includes a `File conflicts` block.
4. Output recommends `/window-ccgs audit` before continuing edits.
5. No files are written.

**Assertions:**
- [ ] File conflicts are visible in `/help`.
- [ ] The same path in multiple lanes is treated as a conflict.
- [ ] `/help` does not try to resolve the conflict automatically.

---

### Case 8: Parallel Routing — 推荐 Skill 的同时推荐 lane

**Fixture:**
- `production/stage.txt` contains `Pre-Production`.
- `production/session-state/windows/Z-platform.md` exists.
- User asks: "我要继续处理 CCGS Skill 和 Hook 路由。"

**Input:** `/help CCGS Skill 和 Hook 路由`

**Expected behavior:**
1. Skill reads stage, route index, active.md, and registered lane files.
2. Skill recommends the relevant Skill for the work.
3. Skill outputs `Parallel routing`.
4. Skill recommends `Z-platform` because the task is CCGS bottom-layer work.
5. Skill includes `/window-ccgs Z` or `/window-ccgs update Z` depending on lane state.

**Assertions:**
- [ ] `/help` does not only recommend a Skill; it also recommends a lane.
- [ ] Registered lane is used when available.
- [ ] Missing lane results in `/window-ccgs <lane-id>` guidance.
- [ ] Cross-lane tasks are routed to A-producer or a custom coordinating lane before implementation.

---

### Case 9: Checkpoint Readiness — 建议提交但不提交

**Fixture:**
- `production/session-state/windows/Z-platform.md` exists.
- `git status --short` shows changes under `.agents/skills/`, `.codex/docs/`,
  `.githooks/`, and `production/session-state/windows/Z-platform.md`.
- The user asks: "现在可以提交了吗？"

**Input:** `/help 可以提交了吗`

**Expected behavior:**
1. Skill reads `.codex/docs/git-checkpoint-workflow.md`.
2. Skill reads registered lane files and checks for file conflicts.
3. Output includes a `Checkpoint / 提交检查点` block.
4. Output recommends `/window-ccgs checkpoint Z-platform`.
5. Output explains that `/help` is read-only and does not stage or commit.

**Assertions:**
- [ ] Checkpoint recommendation is tied to a lane.
- [ ] If dirty files span multiple owner domains, `/help` recommends
  `/window-ccgs audit` or A-producer scope split first.
- [ ] No files are written and no git command mutates the repository.

---

## Protocol Compliance

- [ ] Reads stage, sprint, and session state before generating suggestions
- [ ] Reads registered window lane files before presenting output
- [ ] Always displays `Registered Windows` and `Window commands`
- [ ] Displays file conflicts when multiple lanes list the same Active File
- [ ] Displays parallel routing with a recommended lane and window command
- [ ] Displays checkpoint readiness when the worktree has a clear rollback-sized unit
- [ ] Suggestions are specific to the current project state (not generic)
- [ ] Context query (if provided) narrows the suggestion set
- [ ] Does not write any files
- [ ] Verdict is HELP COMPLETE in all cases

---

## Coverage Notes

- The case where the active sprint is complete (all stories Done) is not
  separately tested; the skill would suggest `/sprint-plan` for the next sprint.
- The `/help` skill does not validate whether suggested skills are available —
  it assumes standard skill catalog availability.
- Stage detection fallback (when stage.txt is absent) uses the absorbed
  project-stage-detect behavior and is not re-tested here in detail.

