---
name: start
description: "First-session onboarding: confirm Codex production coverage and project state, then route into the full package workflow."
argument-hint: "[no arguments]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion
model: sonnet
---

# Guided Onboarding

This Skill no longer creates or maintains review-mode files. The review standard
is fixed: normal Skills run internal checks, and `/gate-check` owns phase-gate
director review.

This Skill is the entry point for new users. It does not assume that the user
already has a game concept, engine preference, development experience, or
language preference. It first confirms Codex's production-function coverage and
the current project state through two structured questions, then routes the user
to the right full-package workflow.

This Skill also absorbs the old `adopt`, `project-stage-detect`, and part of the
old `reverse-document` entry surface: brownfield adoption, phase relocation, and
missing-artifact detection should enter through `/start` or `/help`, not through
extra user-facing commands.

Preserved CCGS value:

- New project entry should create the initial `A-producer` lane as low-risk
  framework bookkeeping before normal onboarding, unless the user explicitly
  requests single-window/no-file state.
- Existing project entry should distinguish existence gaps from format gaps.
- Adoption plan output, if needed: `docs/adoption-plan-[date].md`.
- Stage report output, if needed: `production/project-stage-report.md`.
- Brownfield checks should inspect `design/`, `docs/architecture/`,
  `production/`, `tests/`, `project.godot`, and source folders before deciding
  the stage.
- If code/prototypes exist without design docs, route to `/design-system` or
  `/create-architecture` retrofit behavior instead of inventing a new command.
- Do not ask the user to choose review modes. The review standard is fixed:
  inline director checks are internal, and `/gate-check` owns phase-gate review.

## Response Language Policy

The Skill source should remain English for public distribution. User-facing
messages should be rendered in the active response language:

1. If `.codex/docs/collaboration-profile.md` already records
   `response_language`, use that language.
2. Otherwise infer the response language from the user's latest message.
3. If the user language is unclear, use the system/app language when it is
   discoverable; otherwise default to English.
4. During `/start`, write the chosen `response_language` to
   `.codex/docs/collaboration-profile.md`.
5. If the user later asks to switch language, update the profile and continue in
   the requested language.

This is a hard runtime rule, not an optional style preference:

- If the active response language is `zh-CN`, do not copy the English prompt
  and option text below into the user-facing answer.
- Translate every user-visible sentence, option label, and option description.
- Keep file paths, command names, lane ids, and status keywords unchanged.
- If `AskUserQuestion` renders options, pass localized labels and descriptions
  to that tool.

## User-Reviewed Artifact Language Contract

During `/start`, also write the active response-language rule into the project's
root `AGENTS.md`. This makes later Skills inherit the rule from normal project
instructions instead of requiring local patches in every authoring Skill.

If `AGENTS.md` exists, preserve the file and insert or update this short block
under `## Collaboration Protocol`. If that heading is missing, append the block
near the top-level project instructions. Use `Edit` for existing files; use
`Write` only when `AGENTS.md` is missing.

```markdown
### User-Reviewed Artifact Language

- Use the project's active user language for conversation and for any document
  content the user is expected to read, review, approve, or continue editing.
  The active language is recorded as `response_language` in
  `.codex/docs/collaboration-profile.md`.
- This applies to GDDs, art bible sections, architecture documents, sprint and
  story plans, QA/review reports, adoption plans, and other user-reviewed
  production docs.
- Keep machine-readable tokens unchanged: file paths, slash commands, code
  identifiers, YAML/frontmatter keys, schema fields, status enum values, test
  names, API names, and externally defined terminology.
```

For `zh-CN`, write the block in Chinese while preserving the machine tokens:

```markdown
### 用户审阅工件语言

- 对话，以及任何需要用户阅读、审阅、批准或继续维护的文档正文，都使用项目的当前用户语言。当前语言记录在 `.codex/docs/collaboration-profile.md` 的 `response_language`。
- 这适用于 GDD、Art Bible 章节、架构文档、冲刺与 Story 计划、QA/审查报告、接手整理计划，以及其他需要用户审阅的生产文档。
- 机器可读内容保持原样：文件路径、斜杠命令、代码标识符、YAML/frontmatter key、schema 字段、状态枚举值、测试名、API 名称和外部定义术语。
```

This AGENTS.md update is part of the `/start` onboarding state package. Do not
ask a separate micro-approval for it after the user has completed the startup
choices. Do not rewrite unrelated AGENTS.md sections.

After the response language is confirmed or inferred, run the frontmatter
localizer so the visible Skill list matches the active language, but only when
both files exist in the current repository:

- `scripts/localize-skill-frontmatter.ps1`
- `.codex/docs/skill-frontmatter-locales.json`

```powershell
pwsh -File scripts/localize-skill-frontmatter.ps1 -Language [en|zh-CN]
```

If the script or catalog is missing, do not block `/start`, do not try a sibling
repository path, and do not open Explorer. Record `response_language` and say in
the active response language that Skill-list localization is unavailable in this
older/incomplete framework copy.

Only skip an available script if shell execution is unavailable. In that case,
record `response_language` and tell the user the exact command to run.

Localized starter copy for `zh-CN`:

- Lane bootstrap sentence: `已建立最小 A-producer lane，用来保存恢复点和后续窗口分流。`
- Coverage prompt: `欢迎使用 Codex Game Studios。先确认一下：这个项目里，Codex 应该覆盖哪些制作职能？`
- Coverage options:
  - `工程与设置` -- Godot、代码、工具、测试、构建和技术文档。
  - `工程 + 设计落地` -- 在工程之外，也参与系统设计、数值、关卡、文案草案和实施方案。
  - `全链路协助` -- 程序、美术方向、音乐/音频方向、文案、数值、关卡、工具、QA 和运营文档都可以介入。
  - `我来定义边界` -- 用户说明 Codex 应该覆盖和不应该覆盖的范围。
- Project-state prompt: `现在选择项目当前的起点。`
- Project-state options:
  - `A) 还没有想法` -- 还没有游戏概念，想先探索做什么。
  - `B) 想法还模糊` -- 有题材、感觉、类型或大方向，但还不是清晰概念。
  - `C) 概念比较清楚` -- 已知道核心想法、类型和基础机制，也许是一句话 pitch，但还没有正式文档。
  - `D) 已有内容` -- 已经有设计文档、原型、代码或有意义的规划，想整理或继续。

## Reference Loading Rules

Do not read `.agents/skills-archive/` during normal use. Old onboarding and
brownfield content has been extracted into `references/brownfield-intake.md`.

Read that reference only when the user is adopting an existing project, asking
for stage detection, or trying to reverse-document code/prototypes into design
or architecture artifacts. Fresh greenfield onboarding can run from this
`SKILL.md` alone.

---

## Phase 0: Low-Friction State Bootstrap

Before asking onboarding questions, check multi-window state:

- `production/session-state/windows/*.md`
- `production/session-state/active.md`

If no lane files exist, the project has not entered the file-backed Codex Game
Studios window system yet. Do not block `/start`, and do not require the user to
run `/window-ccgs A` first. `/start` is the first entry point, so create the
minimal lane state directly and then continue onboarding.

This is low-risk, reversible framework bookkeeping. Do not ask a separate
`May I write...` question. After creation, report one short sentence in the
active response language:

```text
Created the minimal A-producer lane to preserve recovery points and later window routing.
zh-CN: 已建立最小 A-producer lane，用来保存恢复点和后续窗口分流。
```

Write:

- `production/session-state/windows/A-producer.md`
- `production/session-state/active.md`, if it does not already exist.

If the user input explicitly contains `single-window`, `no lane`, `no file
state`, or equivalent wording, skip lane creation, continue to Phase 1, and warn
that recovery and parallel coordination will not be written to a lane. Mention
that `/window-ccgs A` can be run later.

If at least one lane file already exists, continue to Phase 1. Do not require
the lane to be named `A-producer`; a custom lane also counts as lane-enabled
state. If there is no `A-producer` or equivalent control lane, later
recommendations should include a reminder that long-running projects should add
a control lane such as `/window-ccgs A`.

---

## Phase 1: Detect Project State

Before asking the user, quietly gather context to customize the next
recommendation. Do not present this scan as an opening report; use it only for
validation and routing.

Check:

- **Response language?** Read `.codex/docs/collaboration-profile.md` for
  `response_language`. If missing, infer from the latest user message or the
  system/app language.
- **Engine configured?** Read `.codex/docs/technical-preferences.md`. If the
  Engine field contains `[TO BE CONFIGURED]`, the engine is not configured.
- **Game concept exists?** Check `design/gdd/game-concept.md`.
- **Source code exists?** Glob source files in `src/`: `*.gd`, `*.cs`, `*.cpp`,
  `*.h`, `*.rs`, `*.py`, `*.js`, `*.ts`.
- **Prototypes exist?** Check whether `prototypes/` has subdirectories.
- **Design docs exist?** Count markdown files in `design/gdd/`.
- **Production artifacts?** Check `production/sprints/` and
  `production/milestones/`.
- **Collaboration profile?** Read `.codex/docs/collaboration-profile.md` for
  Codex's current production-function coverage.

Keep these results internally to compare against the user's self-assessment and
to adjust the recommended path.

---

## Phase 2: Ask Coverage, Then Project State

This is the first user-visible onboarding content. Ask two separate structured
questions. Do not merge them into one open-ended prompt.

- **Question 1: Production Function Coverage**
  - **Prompt**: `Welcome to Codex Game Studios. First, which production functions should Codex cover in this project?`
  - `Engineering and setup` -- Codex mainly owns Godot, code, tools, tests,
    builds, and technical docs.
  - `Engineering + design landing` -- Codex owns engineering and also helps with
    system design, tuning, levels, writing drafts, and implementation plans.
  - `Full-chain assistance` -- Codex may help with programming, art direction,
    music/audio direction, writing, tuning, level design, tools, QA, and ops
    docs.
  - `I will define the boundary` -- The user describes what Codex should and
    should not cover.

Wait for the user to answer the coverage question. Do not continue and do not
ask project state at the same time.

- **Question 2: Project State**
  - **Prompt**: `Now choose the current starting point for the project.`
  - `A) No idea yet` -- The user has no game concept and wants to explore what
    to make.
  - `B) Fuzzy idea` -- The user has a theme, feeling, genre, or loose direction,
    but not a concrete concept yet.
  - `C) Clear concept` -- The user knows the core idea, genre, and basic
    mechanics, maybe as a one-sentence pitch, but has not formalized it.
  - `D) Existing work` -- The user already has design docs, prototypes, code, or
    meaningful planning and wants to organize or continue it.

Wait for the user to choose a project state before continuing.

If `AskUserQuestion` is unavailable, show the same options as numbered plain
text and wait for the user's reply. Never degrade this phase into a single open
prompt such as "tell me the two startup facts." Free-form description is allowed
only as one option; it must not replace the structured options.

After both answers, write Codex production-function coverage and
`response_language` to `.codex/docs/collaboration-profile.md`, write the
user-reviewed artifact language rule to `AGENTS.md`, write the initial stage to
`production/stage.txt`, and update `production/session-state/active.md`. Treat
these as one onboarding state package; do not ask separate confirmations for
each file.

Then run:

```powershell
pwsh -File scripts/localize-skill-frontmatter.ps1 -Language [response_language]
```

Use `en` for English and `zh-CN` for Simplified Chinese. This script rewrites
only Skill frontmatter `description` and `argument-hint` fields so the visible
Skill list matches the user's language. It must not rewrite Skill bodies,
README, AGENTS.md, design docs, or project state.

Before running, verify the script and locale catalog exist in the current
repository. If either is missing, skip this localization step; never search a
sibling project such as another `Claude-Code-Game-Studios-*` directory.

---

## Phase 3: Route Based On Answer

#### If A: No Idea Yet

The user needs creative exploration first.

1. Say that starting from zero is fine.
2. Briefly explain `/brainstorm`: it uses MDA, player psychology, verb-first
   design, and other professional frameworks for guided concept development.
   Mention two modes: `/brainstorm open` for open exploration and
   `/brainstorm [hint]` for a loose theme such as `space`, `cozy`, or `horror`.
3. Recommend `/brainstorm open`; the user may also provide a hint.
4. Show one primary action and the full-package output, not the entire long CCGS
   phase list.

**Concept phase:**

- Recommended command: `/brainstorm open`
- Target output: a complete concept package covering core fantasy, gameplay
  boundaries, production functions Codex should cover, design/art/audio/tool/QA
  directions, first complete landing scope, and acceptance criteria.

#### If B: Fuzzy Idea

1. Ask the user to share the fuzzy idea; a few words are enough.
2. Confirm that this is a valid starting point. Do not judge or forcibly change
   direction.
3. Recommend `/brainstorm [user hint]` to develop it.
4. Show one primary action and the full-package output.

**Concept phase:**

- Recommended command: `/brainstorm [hint]`
- Target output: a complete concept package that turns the fuzzy theme into
  gameplay, boundaries, first complete landing scope, Codex-owned
  design/engineering/art/audio/QA tasks, and acceptance criteria.

#### If C: Clear Concept

1. Ask the user for a one-sentence concept including genre and core mechanic.
   Use plain text, not `AskUserQuestion`, because the user must be able to
   describe the idea freely.
2. After the concept is confirmed, use `AskUserQuestion` to offer two paths:
   - **Prompt**: `How do you want to continue?`
   - **Options**:
     - `Formalize first` -- Run `/brainstorm [concept]` to structure it into a
       formal game concept document.
     - `Configure engine first` -- Run `/setup-engine` first, then fill in GDD
       work manually later.
3. Show one primary action and the full-package output.

**Concept phase:**

- Recommended command: `/brainstorm [concept]`
- Target output: a complete concept package. Do not drip-feed a tiny MVP; first
  frame a buildable scope, then settle design, tools, resource direction,
  implementation plan, and acceptance criteria.

#### If D: Existing Work

1. Share the Phase 1 scan in the active response language:
   - `I found [X source files / Y design docs / Z prototypes]...`
   - `The current engine is [configured as X / not configured yet]...`

2. **Sub-case D1 -- Early stage**, such as no configured engine or only a game
   concept:
   - If the engine is not configured, recommend `/setup-engine` first.
   - Then recommend `/help` for gap inventory.

3. **Sub-case D2 -- Existing GDDs, ADRs, or stories:**
   - Explain that files existing on disk does not guarantee that the Skills can
     use them directly. GDDs may be missing required sections, and `/start`
     checks this problem.
   - Recommend:
     1. `/help` -- phase detection and existence gaps.
     2. `/start` -- format compliance audit and migration plan.

4. Show the D2 route:
   - `/help` -- phase detection + existence gaps.
   - `/start` -- format compliance audit + migration plan.
   - `/setup-engine` -- if the engine is not configured.
   - `/design-system retrofit [path]` -- fill missing GDD sections.
   - `/create-architecture retrofit [path]` -- fill missing ADR sections.
   - `/create-architecture` -- start the TR requirement registry.
   - `/gate-check` -- verify whether the project can move to the next phase.

---

## Phase 3c: Write Initial Stage File

After the starting path is confirmed, write the initial stage to
`production/stage.txt`. Create `production/` first if needed.

Stage mapping:

- **Path A, B, or C from scratch**: write `Concept`.
- **Path D, existing project but engine not configured or only game concept**:
  write `Concept`.
- **Path D, existing GDDs but no architecture documents**: write
  `Systems Design`.
- **Path D, complete architecture such as ADRs and architecture docs**: write
  `Technical Setup`.

This is part of the onboarding state package; do not ask separately. After
writing, say in the active response language:

```text
I set production/stage.txt to [stage]. This fixes the status line and stage detection source.
zh-CN: 我已把 production/stage.txt 设为 [stage]，这样状态行和阶段检测来源就固定了。
```

---

## Phase 3b: Review Standard

Do not read, create, or normalize `production/review-mode.txt`. That file is
legacy compatibility only and no longer drives active Skills.

Say this in one sentence in the active response language:

```text
Current review standard: normal Skills run internal checks; phase advancement is reviewed through /gate-check.
zh-CN: 当前审查标准：普通 Skill 运行内部检查；阶段推进通过 /gate-check 审查。
```

---

## Phase 4: One Clear Next Step

After showing the recommended route, do not ask one more "do you want to start
there?" question. Output one primary command and one reason:

```text
Next step: `/[recommended command]`
Goal: produce the full package first; after approval, move into execution.
zh-CN:
下一步：`/[recommended command]`
目标：先产出完整方案包；确认后再进入执行。
```

---

## Phase 5: Hand Off

When the user confirms the next step, reply with one short sentence in the
active response language:

```text
Enter [skill command] to start.
zh-CN: 输入 [skill command] 开始。
```

Do not re-explain the Skill or add extra encouragement. `/start` is complete.

Verdict: **COMPLETE** -- onboarding is positioned and handed off to the next
step.
Use **CONCERNS** if project artifacts and user-selected state disagree.
Use **BLOCKED** only if required project-state reads fail repeatedly or the user
explicitly stops onboarding.

---

## Edge Cases

- **User picks D but the project is empty**: gently correct this and ask whether
  Path A or Path B is more accurate.
- **User picks A but the project has code**: point out that `src/` already has
  code and ask whether the user meant D, existing work.
- **User is returning**, for example engine configured and concept exists: skip
  onboarding by default. Summarize current engine, concept file, and fixed
  review standard, then suggest continuing with `/help`, `/design-system`, or
  the current required step.
- **User does not fit any option**: let the user describe the situation in their
  own words, then adapt.

---

## Collaborative Protocol

1. **Ask only the setup facts that matter** -- first Codex production-function
   coverage, then project state A/B/C/D.
2. **Preserve structured choices** -- never collapse startup into one open-ended
   question.
3. **One primary next step** -- do not overwhelm the user with the full CCGS
   phase list.
4. **Package before execution** -- the next Skill should produce a full package
   before implementation.
5. **No micro-approval** -- group low-risk state files, lane bootstrap, stage,
   and profile records into one onboarding package.
6. **Adapt** -- if the user's situation does not fit the template, listen and
   adjust.
