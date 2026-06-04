# Setup Requirements

This template requires a few tools to be installed for full functionality.
All hooks fail gracefully if tools are missing — nothing will break, but
you'll lose validation features.

## Required

| Tool | Purpose | Install |
| ---- | ---- | ---- |
| **Git** | Version control, branch management | [git-scm.com](https://git-scm.com/) |
| **Codex** | AI agent environment | Codex CLI (`npm install -g @openai/codex`) or Codex Desktop |

## Recommended

| Tool | Used By | Purpose | Install |
| ---- | ---- | ---- | ---- |
| **jq** | Codex hooks | More robust JSON parsing for hook payloads | See below |
| **Python 3** | Git hooks / CI parity | JSON validation and JSON output escaping | [python.org](https://www.python.org/) |
| **Bash** | Codex hooks and `.githooks/` | Shell script execution | Included with Git for Windows |

### Installing jq

**Windows** (any of these):
```
winget install jqlang.jq
choco install jq
scoop install jq
```

**macOS**:
```
brew install jq
```

**Linux**:
```
sudo apt install jq     # Debian/Ubuntu
sudo dnf install jq     # Fedora
sudo pacman -S jq       # Arch
```

## Platform Notes

### Windows
- Git for Windows includes **Git Bash**, used by Codex hooks and `.githooks/`.
- `.codex/hooks.json` includes a Windows command override for
  `C:\Program Files\Git\bin\bash.exe`.
- Enable local Git hooks with:
  ```bash
  git config core.hooksPath .githooks
  ```

### macOS / Linux
- Bash is available natively
- Install `jq` via your package manager for full hook support

## Verifying Your Setup

Run these commands to check prerequisites:

```bash
git --version          # Should show git version
bash --version         # Should show bash version
jq --version           # Should show jq version (optional)
python3 --version      # Should show python version (optional)
```

## What Happens Without Optional Tools

| Missing Tool | Effect |
| ---- | ---- |
| **jq** | Codex hooks use fallback parsing. They still run, but patch/JSON parsing is less precise. |
| **Python 3** | Git hooks fall back to Node for JSON validation when available; Codex hook JSON escaping uses a shell fallback. |
| **Both** | Codex hooks still run with limited parsing. Git JSON validation needs either Python or Node. |

## Recommended IDE

Codex works with any editor, but the template is optimized for:
- **VS Code** with the Codex extension
- **Cursor** (Codex compatible)
- Terminal-based Codex CLI
