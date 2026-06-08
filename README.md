# CodexForGodot

> Full-pipeline AI game development framework for indie devs. From concept to ship — one person + Codex, finish a commercial-quality game.

Evolved from [Claude Code Game Studios](https://github.com/Donchitos/Claude-Code-Game-Studios). Codex-native. Godot-focused.

[中文说明](README_ZH.md) · [Quick Start](#quick-start-5-minutes)

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"></a>
  <a href="https://godotengine.org/"><img src="https://img.shields.io/badge/Godot-4.x-478cbf" alt="Godot"></a>
  <a href="https://openai.com/index/codex/"><img src="https://img.shields.io/badge/Codex-required-412991" alt="Codex"></a>
  <a href="UPGRADING.md"><img src="https://img.shields.io/badge/from-CCGS%2021K%20%E2%98%85-informational" alt="Evolved from CCGS 21K Stars"></a>
  <img src="https://img.shields.io/badge/pipeline-Concept%20%E2%86%92%20Ship-brightgreen" alt="Full Pipeline: Concept to Ship">
</p>

<p align="center">
  <img src="demo-v5.gif" alt="Built from scratch in 30 minutes — Codex + Godot live demo" width="100%">
  <br>
  <em>Built from scratch in 30 minutes — Codex driving Godot development in real time</em>
</p>

---

## Why This Exists

The biggest problem for indie game developers isn't lack of ideas — it's lack of people. You write the code, paint the art, tune the numbers, find the sound effects, run the tests, write the copy. Every discipline is you, and you're not an expert at any of them.

AI tools have helped with code. But code is only a fraction of game development. Who defines the art direction? Who designs the systems? Who runs QA? Who manages the release checklist? Most AI tools handle one slice of game dev — fine for a demo, not enough for a complete commercial game.

CodexForGodot's goal: **one person + Codex, finish a commercial-quality game.** Not a demo, not a prototype — a shippable game.

How? Codex's multi-modal capabilities go beyond code — it can generate and process art assets, understand design documents, execute test workflows, and orchestrate release checklists. Role-based agents cover every game dev discipline: programming, art, audio, writing, game design, level design, QA, and release. 17 core skills chain from concept to ship. You're no longer a solo dev doing everything yourself — you're the creative director of a full AI team.

<details>
<summary><strong>Relationship with original CCGS</strong></summary>

CodexForGodot is deeply adapted from [Claude Code Game Studios](https://github.com/Donchitos/Claude-Code-Game-Studios) (21K Stars). CCGS provides a great foundation — the 49-agent studio hierarchy, collaboration protocol, and design workflows all come from it.

This fork makes these specific improvements:

- **Cut unnecessary confirmations** — Reports save to disk automatically, lane handoff auto-registers. What we cut are zero-design-value prompts like "can I write this file?" Fewer interruptions, faster development.
- **73 commands consolidated to 17** — CCGS has too many commands, too many steps, too many choices. We merged related ones; old names auto-redirect through the route index. Same coverage, faster onboarding.
- **Multi-window lane system** — Each responsibility (production/dev/art/QA/platform) runs in its own window with its own state file. Parallel work without context pollution.
- **Skill integration thinking** — `/skill-create-ccgs` doesn't just add commands. It evaluates: should this skill exist? Merge with an existing one or create new?
- **Codex-native** — The framework requires Codex's mechanisms to run, leveraging Codex's multi-modal and resource generation capabilities. We want Codex to build a complete game for you, not just help you write code.
- **Godot-focused** — Not a multi-engine template with a Godot option. Everything from agents to skills is built around Godot 4.x + GDScript. We'll provide more debugging tools and asset production workflows.

See [OPS-CHANGELOG.md](OPS-CHANGELOG.md) for detailed changes.

</details>

---

## Full-Pipeline Coverage

> Inspired by [CCGS](https://github.com/Donchitos/Claude-Code-Game-Studios)' Studio Hierarchy — 49 agents organized by discipline, not generic assistants.

Solo game dev means covering every discipline yourself. CodexForGodot breaks game development into role-based tracks, each with dedicated agents and skills:

```
Concept ──→ Design ──→ Build ──→ Test ──→ Ship
 │            │          │         │        │
brainstorm    design    dev-story  smoke   release
art-bible     system    story-done  bug    checklist
              arch      code-review  gate
```

| Discipline | Agent Coverage | Skill |
|-----------|---------------|-------|
| **Concept** | Creative director, game designer | `/brainstorm` — concept, pillars, loop, prototype direction |
| **Systems** | Systems designer, economy designer | `/design-system` — GDD, design review, balance checks |
| **Art** | Art director, technical artist | `/art-bible` — visual identity, asset specs, UX specs |
| **Architecture** | Technical director, lead programmer | `/create-architecture` — architecture docs, ADRs |
| **Development** | Domain programmers | `/dev-story` `/story-done` — implementation, acceptance |
| **QA** | QA lead, testers | `/smoke-check` `/bug-report` `/gate-check` |
| **Release** | Release manager | `/release-checklist` — checklist, changelog |
| **Framework** | Platform engineer | `/skill-create-ccgs` `/setup-engine` |
| **Navigation** | Producer | `/start` `/help` `/window-ccgs` |

Codex's multi-modal capabilities make this work — not just writing GDScript, but processing art assets, generating design materials, and analyzing screenshot feedback.

---

## Compared with CCGS

> Following [OpenCodeGameStudios](https://github.com/striderZA/OpenCodeGameStudios)' approach — show the fork relationship clearly.

| Dimension | CCGS | CodexForGodot |
|-----------|------|---------------|
| **Goal** | AI-assisted game development | One person ships a commercial-quality game |
| **AI Platform** | Claude Code | Codex (requires Codex, leverages multi-modal) |
| **Engine** | Multi-engine template (Godot/Unity/UE) | Godot 4.x + GDScript only |
| **Skills** | 73 commands | 17 core (merged, old names auto-redirect) |
| **Windows** | Single window | Multi-window parallel lanes, independent state |
| **Confirmations** | Frequent write prompts | Auto-save reports, auto-register lanes |
| **Skill addition** | Direct add | Integration thinking (should it exist? merge or new?) |

---

## Quick Start (5 minutes)

> Following [Open-Code-Godot-Studio](https://github.com/gwtt/Open-Code-Godot-Studio)'s pattern — clear time expectation.

```bash
git clone https://github.com/ailess-lab/CodexForGodot.git my-game-studio
cd my-game-studio
codex
```

First session:

```
/start
```

**Try it — a real session looks like this:**

> Following [godot-ai](https://github.com/hi-godot/godot-ai)'s pattern — show, don't tell.

```
You: /brainstorm
Codex: Let's design your game. First — what should the player feel in the first 30 seconds?
You: Lonely exploration, like you're the last person in a ruined city.
     Think Hollow Knight meets Celeste's movement feel.
Codex: Good anchors. Let me explore three directions...

       [deep design interview]

       Complete concept package: core loop diagram / 3 pillars / prototype scope / risk register
       Does the direction feel right?
You: Proceed.

Codex: [Design docs land as system GDDs, architecture docs, sprint plan]

You: /window-ccgs B
Codex: [Dev lane starts — independent window, restores from state file]
You: /window-ccgs C
Codex: [Art lane starts — Codex processes art assets based on visual identity]

       ...code in window B, art in window C, you direct from window A.
```

---

## Multi-Window Lanes

The biggest pain point for solo devs: everything lives in one brain, every task shares one context. You're halfway through coding and remember the art direction isn't settled. You just had an art idea but realize the system design doesn't support it yet.

Multi-window lanes split these responsibilities into separate windows:

| Lane | Role | What it does |
|------|------|-------------|
| A | **Producer** | Scope, priorities, cross-window coordination |
| B | **Development** | Implementation, stories, tests |
| C | **Art** | Visual direction, asset specs |
| D | **QA** | Bugs, smoke tests, release readiness |
| Z | **Platform** | Skills, hooks, route index |

Each window has its own state file. Close it, reopen tomorrow — `/window-ccgs B` picks up where you left off. Custom lanes too: `/window-ccgs ui-polish`

---

## Upgrading from CCGS

Already using CCGS? See [UPGRADING.md](UPGRADING.md) for migration options. Key changes:
- Skill names changed — old names auto-redirect through route index
- `.claude/` → `.codex/` directory structure
- `CLAUDE.md` → `AGENTS.md` configuration

---

## License

MIT License — evolved from [Claude Code Game Studios](https://github.com/Donchitos/Claude-Code-Game-Studios).
