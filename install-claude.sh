#!/usr/bin/env bash
set -euo pipefail
base="https://raw.githubusercontent.com/issa-diallo/statusline/main"
dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
mkdir -p "$dir"
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
curl -fsSL "$base/statusline.py" -o "$tmp"
python3 -m py_compile "$tmp"
install -m 755 "$tmp" "$dir/statusline.py"
python3 - "$dir" <<'PY'
import json, pathlib, shlex, shutil, sys
d = pathlib.Path(sys.argv[1]); p = d / 'settings.json'
data = json.loads(p.read_text()) if p.exists() else {}
if not isinstance(data, dict): raise SystemExit('settings.json must contain a JSON object')
if p.exists(): shutil.copy2(p, p.with_suffix('.json.bak'))
data['statusLine'] = {'type': 'command', 'command': 'python3 ' + shlex.quote(str(d / 'statusline.py'))}
p.write_text(json.dumps(data, indent=2, ensure_ascii=False) + '\n')
print('Claude status line installed. Restart Claude Code.')
PY
