# Statusline for Codex and Claude Code

Portable status-line configuration for Codex CLI and Claude Code, inspired by [videvjs/claude-statusline](https://github.com/videvjs/claude-statusline). Install it again on any new machine.

## Install

Requires macOS or Linux, `bash`, `curl`, `git`, and Python. Codex requires Python 3.11+. Claude requires Python 3. Windows users can use WSL; native Windows support is not yet tested.

Codex:

```sh
curl -fsSL https://raw.githubusercontent.com/issa-diallo/statusline/main/install-codex.sh | bash
```

Claude Code:

```sh
curl -fsSL https://raw.githubusercontent.com/issa-diallo/statusline/main/install-claude.sh | bash
```

Restart the relevant CLI. Installers preserve other settings and save a `.bak` copy of the configuration; rerunning replaces that backup. Review scripts before running them if desired. macOS may prompt to install Xcode Command Line Tools for Git; install them and retry.

## What it shows

Claude example: `/project | (main) | Claude Opus | ctx [████░░░░░░] 42% | 5h [██░░░░░░░░] 20% reset 2h30m`

Claude displays the directory, Git branch, model, effort when available, context usage, five-hour usage and reset, and seven-day usage above 30%. Limits appear only when Claude provides them. Percentages are bounded, and missing values are omitted.

Codex uses its native status line: model and reasoning, directory, Git branch, context used, five-hour limit, weekly limit and used tokens. Availability depends on the session and Codex version. Change the selection with `/statusline` in Codex or edit `~/.codex/config.toml`:

```toml
[tui]
status_line = ["model-with-reasoning", "current-dir", "git-branch", "context-used", "five-hour-limit", "weekly-limit", "used-tokens"]
```

If you already have a `[tui]` section, add the `status_line` entry there instead of creating another. The installer refuses complex TOML layouts it cannot safely modify.

## Uninstall

Remove `status_line` from `~/.codex/config.toml` for Codex. For Claude, remove the `statusLine` entry from `~/.claude/settings.json` and delete `~/.claude/statusline.py`. Backups are at `config.toml.bak` and `settings.json.bak` respectively.

