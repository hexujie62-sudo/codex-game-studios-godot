# Codex Game Studios for Godot

> Unofficial Codex-first, Godot-focused fork of Claude Code Game Studios.

一个面向 **Codex + Godot** 的 AI 全链路游戏开发工作流工具包。

本项目基于 `Claude Code Game Studios` 的 MIT 许可版本深度改造，重点重建了 Codex 生态下的 Skill、Hook、路由、多窗口协作、上下文恢复和项目状态管理。它不是一个游戏模板，也不是一个官方 OpenAI 项目，而是一套让 AI 参与游戏制作时更可控、更可审计、更容易恢复上下文的工作流底座。

<p>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"></a>
  <a href=".codex/agents"><img src="https://img.shields.io/badge/agents-49-blueviolet" alt="49 Agents"></a>
  <a href=".agents/skills"><img src="https://img.shields.io/badge/skills-76-green" alt="76 Skills"></a>
  <a href=".codex/hooks"><img src="https://img.shields.io/badge/codex%20hooks-5-orange" alt="5 Codex Hooks"></a>
  <a href="https://godotengine.org/"><img src="https://img.shields.io/badge/Godot-4.x-478cbf" alt="Godot 4.x"></a>
</p>

## 项目定位

这个 fork 的核心目标不是“增加更多命令”，而是把原本偏单窗口、偏 Claude Code 的 CCGS 工作流，改造成更适合 Codex 长期使用的体系：

- **Codex-first**：文档、Hooks、Skill 路由、上下文恢复都围绕 Codex 使用方式整理。
- **Godot-focused**：默认技术栈面向 Godot 4.x 和 GDScript，但不把题材、美术风格、2D/3D、输入方式写死。
- **多窗口可恢复**：通过 `production/session-state/` 记录窗口 lane 状态，减少长上下文压缩或新窗口迁移时的信息丢失。
- **Skill 可治理**：通过 route index、测试框架和 `/skill-create-ccgs` 管理新增、修改、合并、审计。
- **Hook 轻量化**：Codex Hooks 作为提醒和恢复辅助，不把它们伪装成完整安全边界；更强的检查交给 Git hooks 和人工审查。

## 和原 CCGS 的差异

| 范围 | 原 CCGS | 本项目 |
|---|---|---|
| 主要生态 | Claude Code | Codex |
| 工作方式 | 单窗口串行优先 | 支持多窗口 lane 并行 |
| 状态恢复 | 更依赖当前对话 | 文件化 session state |
| Skill 管理 | 大量 slash command | route index + Skill 测试 + 专用创建流程 |
| Hook 体系 | Claude/CC 语义为主 | Codex 语义与轻量提醒 |
| 引擎倾向 | 多引擎模板 | Godot-first |
| 项目约束 | 通用游戏开发框架 | 更适合 AI 全链路开发者长期维护 |

## 包含内容

| 类别 | 数量 | 说明 |
|---|---:|---|
| Agents | 49 | 覆盖制作、设计、程序、美术、音频、叙事、QA、发布等职责 |
| Skills | 76 | 从 `/start`、`/help` 到设计、开发、审查、QA、发布和 CCGS 底层维护 |
| Codex Hooks | 5 | 会话启动、上下文恢复、危险命令提醒、Skill 变更提醒等轻量机制 |
| Git Hooks | 2+ | 本地提交前检查、Skill 变更提醒、窗口状态文件基础审计 |
| Docs | 多份 | 架构、协作协议、Hook 改造、目录结构、上下文管理、发布说明 |

## 快速开始

```powershell
git clone https://github.com/<your-name>/codex-game-studios-godot.git my-game-studio
cd my-game-studio
codex
```

第一次进入项目时，建议运行：

```text
/start
```

如果你不知道下一步该做什么：

```text
/help
```

如果你需要开启或恢复一个工作窗口：

```text
/window-start-ccgs Z
```

如果你准备结束当前窗口、切换任务、或担心上下文压缩：

```text
/window-handoff-ccgs Z
```

## 多窗口使用方式

本项目支持用 lane 文件把不同 Codex 窗口的职责分开。默认快捷 lane 是：

| Lane | 建议职责 |
|---|---|
| `A` | 制作总控、阶段、范围、跨窗口协调 |
| `B` | Godot 开发、故事实现、测试 |
| `C` | 美术、资源、视觉规范 |
| `D` | QA、错误、冒烟测试、证据审查 |
| `Z` | CCGS 底层维护：Skill、Hook、路由、测试框架、体系文档 |

这些只是快捷入口，不是硬编码岗位。你也可以注册自定义 lane，例如：

```text
/window-start-ccgs ui-polish
/window-handoff-ccgs ui-polish
```

窗口状态保存在：

```text
production/session-state/
```

## Skill 管理

新增或改造 Skill 时，建议优先运行：

```text
/skill-create-ccgs
```

它会判断这次需求应该是：

- 新增 Skill；
- 修改现有 Skill；
- 只补充 references；
- 只更新 route index；
- 或者因为职责不清而暂缓。

Skill 相关文件通常需要同时更新：

- `.agents/skills/<skill-name>/SKILL.md`
- `CCGS Skill Testing Framework/skills/...`
- `CCGS Skill Testing Framework/catalog.yaml`
- `.codex/docs/skill-route-index.yaml`
- 相关架构或流程文档

## Godot 使用边界

这个项目默认面向 Godot，但不会把你的游戏类型写死。以下内容不应作为常驻 Skill 约束：

- 2D 或 3D；
- 像素、手绘、写实、HD 等美术风格；
- top-down、side-view、first-person 等视角；
- 鼠标、触屏、键盘、手柄等输入方式；
- RPG、防御、动作、叙事等题材或玩法类型。

这些属于具体项目的可变设计事实，应该由 GDD、Art Bible、UX Spec、Story 或当前窗口状态记录，而不是写进底层 Skill 体系。

## 公开发布边界

如果你把这个项目发布到 GitHub，建议公开的是 CCGS/Codex/Godot 工作流底座，而不是你的具体游戏项目。

不要直接从当前工作仓库 `git add .` 发布。当前工作仓库可能同时包含你的游戏设计、原型、生产状态和私人上下文。推荐先生成一个独立 public release 目录：

```powershell
pwsh -File scripts/build-public-release.ps1
```

这个脚本采用白名单复制，只会复制明确适合公开的底座文件，并默认输出到仓库外一层：

```text
..\codex-game-studios-godot-public
```

通常适合公开：

- `.agents/skills/`
- `.codex/agents/`
- `.codex/docs/`
- `.codex/hooks.json`
- `.codex/hooks/` 中的 Codex-only 轻量 hook
- `.codex/hooks/lib/`
- `.codex/rules/`
- `.githooks/`
- `CCGS Skill Testing Framework/`
- `docs/` 中的 CCGS 架构、Hook、流程文档
- `AGENTS.md`
- `LICENSE`
- `NOTICE.md`
- `scripts/build-public-release.ps1`

通常不建议公开：

- 你的真实游戏设计草稿；
- 私人 session state；
- 未公开的原型代码或素材；
- API key、账号、路径、平台 SDK；
- AI 生成素材的未确认授权来源。

更详细的 GitHub 发布流程见：

```text
docs/GITHUB-PUBLISHING.md
```

可直接复制到 GitHub 的简介、Release notes 和社区发布文案见：

```text
docs/GITHUB-LISTING-COPY.md
```

## 许可与来源

本项目基于 `Claude Code Game Studios` 修改，原项目采用 MIT License。

原始版权声明必须保留：

```text
Copyright (c) 2026 Donchitos
```

本项目的本地修改可以由你或你的组织另行声明版权。详细来源说明见：

```text
NOTICE.md
```

## 品牌声明

本项目是非官方项目。

它不是 OpenAI、Anthropic、Claude、Codex 或原 CCGS 作者的官方项目，也不代表这些组织或个人的认可、赞助或背书。

`OpenAI`、`Codex`、`Claude`、`Anthropic`、`Godot` 等名称归各自权利方所有。本项目只在描述兼容性、改造来源和使用场景时提及这些名称。

## 贡献

欢迎提交 Issue、Discussion 或 Pull Request，但建议围绕以下方向：

- Codex 工作流稳定性；
- Godot-first 开发体验；
- Skill 路由和测试覆盖；
- 多窗口上下文恢复；
- Hook 与 Git hook 的轻量治理；
- 文档可理解性。

不建议把具体游戏题材、固定美术风格或某个项目的临时设定写入底层 Skill。

## License

MIT License. See [LICENSE](LICENSE) and [NOTICE.md](NOTICE.md).
