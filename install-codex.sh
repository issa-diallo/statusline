#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PY'
import pathlib, re, shutil, sys
try: import tomllib
except ImportError: raise SystemExit('Python 3.11 or newer is required')
p = pathlib.Path.home() / '.codex' / 'config.toml'
p.parent.mkdir(parents=True, exist_ok=True)
old = p.read_text() if p.exists() else ''
try: parsed = tomllib.loads(old)
except tomllib.TOMLDecodeError as e: raise SystemExit(f'Invalid config.toml: {e}')
setting = 'status_line = ["model-with-reasoning", "current-dir", "git-branch", "context-used", "five-hour-limit", "weekly-limit", "used-tokens"]'
if 'tui' in parsed and not isinstance(parsed['tui'], dict): raise SystemExit('Unsupported tui configuration')
matches = list(re.finditer(r'(?m)^\s*\[tui\]\s*(?:#.*)?$', old))
if 'tui' in parsed and len(matches) != 1: raise SystemExit('Complex tui configuration: set status_line manually (see README)')
if matches:
    start = matches[0].end()
    end_match = re.search(r'(?m)^\s*\[', old[start:])
    end = start + end_match.start() if end_match else len(old)
    section = old[start:end]
    if 'status_line' in parsed['tui']:
        pattern = r'(?m)^\s*status_line\s*=\s*\[[^\]]*\][^\n]*'
        if not re.search(pattern, section): raise SystemExit('Complex status_line: set it manually (see README)')
        section = re.sub(pattern, '\n' + setting, section, count=1)
    else: section = '\n' + setting + '\n' + section
    new = old[:start] + section + old[end:]
else: new = old.rstrip() + '\n\n[tui]\n' + setting + '\n'
try: tomllib.loads(new)
except tomllib.TOMLDecodeError as e: raise SystemExit(f'Refusing invalid configuration: {e}')
if p.exists(): shutil.copy2(p, p.with_suffix('.toml.bak'))
p.write_text(new)
print('Codex status line installed. Restart Codex.')
PY
