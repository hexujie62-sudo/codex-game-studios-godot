# GitHub 发布说明

这份文档用于把当前 CCGS/Codex/Godot 魔改版发布到 GitHub。

## 推荐命名

推荐仓库名：

```text
codex-game-studios-godot
```

推荐项目名：

```text
Codex Game Studios for Godot
```

推荐 GitHub Description：

```text
Unofficial Codex-first Godot game development workflow kit, adapted from Claude Code Game Studios.
```

这个命名方式保留了 Codex 的核心地位，同时用 `Unofficial`、`for Godot`、`adapted from` 明确说明它不是官方 OpenAI 项目，也不是原 CCGS 的原版仓库。

不建议使用：

```text
OpenAI Codex Game Studios
Official Codex Game Studios
Claude Code Game Studios Codex Edition
```

这些名字容易让人误以为项目获得 OpenAI、Anthropic 或原作者官方背书。

## Topics

建议在 GitHub 仓库设置中添加：

```text
codex
godot
gamedev
ai-assisted-development
skills
agents
workflow
gdscript
indie-game-development
automation
```

更多可直接复制的仓库简介、Release notes 和社区发布文案见：

```text
docs/GITHUB-LISTING-COPY.md
```

## 常驻上传方案

本项目使用 GitHub CLI 作为常驻上传通道。Token 不写进仓库、不写进 remote URL，也不需要每次复制到对话里。

第一次只需要在本机登录一次：

```powershell
pwsh -File scripts/setup-github-auth.ps1
```

如果网页登录失败，也可以把 PAT 写入 GitHub CLI 的本机凭据存储：

```powershell
pwsh -File scripts/setup-github-auth.ps1 -UseToken
```

这会在终端里用安全输入提示读取 PAT，不会写进仓库，也不会写进 git remote URL。

之后任何窗口或 Agent 都可以调用：

```powershell
pwsh -File scripts/publish-to-github.ps1
```

## 本机排障结论

这台机器上 GitHub 发布失败主要不是权限问题，而是两个机制问题：

- `gh auth login --with-token` 必须从标准输入读取 token；如果脚本没有显式写入并关闭 stdin，命令可能一直等待输入。GitHub CLI 官方手册也把 `--with-token` 定义为从 stdin 读取 token。
- `GH_TOKEN` / `GITHUB_TOKEN` 会优先于已经保存的本机凭据，适合临时自动化，但不能替代常驻 keyring 登录。
- 本机系统代理是 `127.0.0.1:7890`，PowerShell、Git 和 GitHub CLI 不一定完整继承 GUI 里的系统代理设置；Git 官方文档说明 `http.proxy` 可以覆盖 HTTP 代理，所以发布脚本会自动检测该端口，并给 `git push` 显式加上 `http.proxy` / `https.proxy`。

因此当前脚本的固定策略是：

- 认证脚本用子进程写入 token、关闭 stdin，并设置 60 秒超时；
- 发布脚本自动检测 `127.0.0.1:7890`，同时设置 `HTTP_PROXY` / `HTTPS_PROXY` / `ALL_PROXY`；
- 所有 `git` 网络操作额外带 `-c http.proxy=... -c https.proxy=...`，避免只靠环境变量。

默认会发布到：

```text
codex-game-studios-godot
```

默认行为：

- 生成 staging 发布包；
- 同步到仓库外的 `..\codex-game-studios-godot-public`，保留其中的 `.git`；
- 自动创建 GitHub 仓库，如果仓库已存在则复用；
- 设置 description 和 topics；
- push `main`；
- 创建 `v0.1.0-alpha` release，如果 release 已存在则跳过。

可选参数：

```powershell
pwsh -File scripts/publish-to-github.ps1 -Owner <github-user-or-org>
pwsh -File scripts/publish-to-github.ps1 -RepoName codex-game-studios-godot
pwsh -File scripts/publish-to-github.ps1 -Visibility public
pwsh -File scripts/publish-to-github.ps1 -SkipRelease
pwsh -File scripts/publish-to-github.ps1 -OpenInBrowser
```

如果当前 shell 找不到 `gh`，脚本会自动尝试：

```text
C:\Program Files\GitHub CLI\gh.exe
```

## 发布前检查

发布前不要直接 `git add .`，也不要直接把当前工作仓库推到 GitHub。

当前仓库是工作仓库，可能同时包含：

- CCGS/Codex/Godot 底层；
- 你的具体游戏设计；
- Godot 原型；
- 生产状态；
- 多窗口 session state；
- 本地路径或私人上下文。

公开发布版应该从白名单生成，而不是从当前工作仓库手动删减。

## 生成 public release 目录

推荐先运行：

```powershell
pwsh -File scripts/build-public-release.ps1
```

如果你的系统同时存在 WindowsApps/MSIX `pwsh.exe` 和独立安装的 PowerShell 7，优先使用可稳定执行脚本的 PowerShell 7 路径。示例：

```powershell
pwsh -NoLogo -NoProfile -File scripts/build-public-release.ps1
```

默认输出目录：

```text
..\codex-game-studios-godot-public
```

如果输出目录已经存在且非空，脚本会拒绝覆盖。确认要重新生成时再运行：

```powershell
pwsh -File scripts/build-public-release.ps1 -Clean
```

也可以指定输出位置：

```powershell
pwsh -File scripts/build-public-release.ps1 -OutputPath ..\my-public-release
```

脚本会拒绝把发布目录写在当前工作仓库内部，避免发布目录被误提交回工作仓库。

生成后先检查：

```powershell
cd ..\codex-game-studios-godot-public
git status --short
```

第一次生成的目录默认还不是 git 仓库，`git status` 可能提示不是仓库，这是正常的。你可以先人工检查目录内容。

脚本会生成：

```text
PUBLIC-RELEASE-MANIFEST.md
```

这个文件列出本次复制了哪些白名单路径，以及哪些工作仓库根目录被明确阻止复制。

## 工作仓库手动检查

先确认仓库状态：

```powershell
git status --short
```

脚本白名单大致包括：

```text
AGENTS.md
LICENSE
NOTICE.md
README.md
CONTRIBUTING.md
SECURITY.md
UPGRADING.md
.agents/skills/
.codex/agents/
.codex/docs/
.codex/hooks.json
.codex/hooks/ 中的 Codex-only 轻量 hook
.codex/hooks/lib/
.codex/rules/
.githooks/
CCGS Skill Testing Framework/
docs/ccgs-codex-architecture.md
docs/ccgs-codex-hook-adaptation-plan.md
docs/COLLABORATIVE-DESIGN-PRINCIPLE.md
docs/GITHUB-LISTING-COPY.md
docs/WORKFLOW-GUIDE.md
docs/GITHUB-PUBLISHING.md
docs/engine-reference/godot/
scripts/build-public-release.ps1
scripts/publish-to-github.ps1
scripts/setup-github-auth.ps1
```

脚本默认阻止复制：

```text
production/session-state/
production/session-logs/
design/
prototypes/
src/
.git/
.claude/
.env
*.key
credentials.json
secrets.json
```

如果你希望公开一个纯工具仓库，不要把自己的具体游戏设计、原型代码、生产状态、私人上下文一起发布。

## 建议发布流程

进入生成出的 public release 目录：

```powershell
cd ..\codex-game-studios-godot-public
```

初始化 Git：

```powershell
git init
git add .
git status --short
git diff --cached --stat
```

确认暂存内容只包含 public release 白名单文件后提交：

```powershell
git commit -m "chore: publish Codex Game Studios for Godot"
```

也可以在工作仓库里创建发布分支，但这不是首选方案，因为工作仓库包含私有项目内容。确实需要分支方案时，再使用：

```powershell
git switch -c codex/public-release
```

只添加公开底座文件：

```powershell
git add AGENTS.md LICENSE NOTICE.md README.md CONTRIBUTING.md SECURITY.md UPGRADING.md
git add .agents .codex .githooks
git add "CCGS Skill Testing Framework"
git add docs/ccgs-codex-architecture.md docs/ccgs-codex-hook-adaptation-plan.md
git add docs/COLLABORATIVE-DESIGN-PRINCIPLE.md docs/GITHUB-LISTING-COPY.md docs/WORKFLOW-GUIDE.md docs/GITHUB-PUBLISHING.md
```

再次检查暂存内容：

```powershell
git status --short
git diff --cached --stat
```

提交：

```powershell
git commit -m "chore: prepare public Codex Game Studios for Godot release"
```

在 GitHub 创建一个空仓库，仓库名使用：

```text
codex-game-studios-godot
```

不要在 GitHub 页面勾选自动创建 README、LICENSE 或 `.gitignore`，避免和本地文件冲突。

添加 remote 并推送：

```powershell
git remote add origin https://github.com/<your-name>/codex-game-studios-godot.git
git branch -M main
git push -u origin main
```

如果本地已经有 `origin`，先查看：

```powershell
git remote -v
```

必要时使用新的 remote 名称：

```powershell
git remote add public https://github.com/<your-name>/codex-game-studios-godot.git
git branch -M main
git push -u public main
```

## Release 建议

首次公开建议使用：

```text
v0.1.0-alpha
```

Release 标题：

```text
Codex Game Studios for Godot v0.1.0-alpha
```

Release 说明可以写：

```md
First public alpha of Codex Game Studios for Godot.

This release includes:

- Codex-first CCGS workflow conversion
- Godot-focused technical defaults
- 76 Skills and 49 agent definitions
- Lightweight Codex Hooks and Git hooks
- Multi-window lane workflow
- File-backed session state and handoff guidance
- Skill route index and CCGS Skill Testing Framework

This is an unofficial MIT-licensed derivative of Claude Code Game Studios.
```

## 对外介绍

中文短介绍：

```text
我把 Claude Code Game Studios 深度改造成了一个 Codex-first、Godot-focused 的 AI 游戏开发工作流工具包，加入了多窗口 lane、文件化状态恢复、Skill 路由、Hook 轻量治理和 Skill 测试框架。
```

英文短介绍：

```text
I rebuilt Claude Code Game Studios into an unofficial Codex-first workflow kit for Godot game development, with multi-window lanes, file-backed session state, Skill routing, lightweight hooks, and a Skill testing framework.
```

可以发布到：

- GitHub Discussions；
- Godot 社区；
- AI-assisted development 社区；
- indie gamedev 社区；
- 你的博客、知乎、B 站动态或微博。

## 合规提醒

发布时必须保留 `LICENSE` 和原始版权声明。

README 或 NOTICE 中必须说明：

- 本项目基于原 CCGS 修改；
- 原项目采用 MIT License；
- 本项目不是 OpenAI、Anthropic、Claude、Codex、Godot 或原作者的官方项目；
- 第三方品牌名称只用于描述兼容性和来源。
