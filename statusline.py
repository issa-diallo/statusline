#!/usr/bin/env python3
import json, os, subprocess, sys, time

def bar(value):
    try:
        n = max(0, min(100, float(value)))
        if n != n: return None
        filled = int(n / 10)
        return f"[{'█' * filled}{'░' * (10 - filled)}] {n:.0f}%"
    except (TypeError, ValueError, OverflowError):
        return None

def main():
    try: data = json.load(sys.stdin)
    except (ValueError, OSError): return
    if not isinstance(data, dict): return
    workspace = data.get('workspace') or {}
    cwd = workspace.get('current_dir') or data.get('cwd')
    parts = []
    if cwd:
        parts.append('/' + os.path.basename(os.path.normpath(cwd)))
        try:
            branch = subprocess.run(['git', '-C', cwd, 'rev-parse', '--abbrev-ref', 'HEAD'], capture_output=True, text=True, timeout=1)
            if branch.returncode == 0:
                name = branch.stdout.strip()
                if name == 'HEAD':
                    name = subprocess.run(['git', '-C', cwd, 'rev-parse', '--short', 'HEAD'], capture_output=True, text=True, timeout=1).stdout.strip()
                if name: parts.append('(' + name + ')')
        except (OSError, subprocess.SubprocessError): pass
    model = data.get('model') or {}
    if model.get('display_name'): parts.append(str(model['display_name']))
    effort = data.get('effort')
    if effort: parts.append('[' + str(effort) + ']')
    context = data.get('context_window') or {}
    ctx = bar(context.get('used_percentage'))
    if ctx: parts.append('ctx ' + ctx)
    limits = data.get('rate_limits') or {}
    for key, label in [('five_hour', '5h'), ('seven_day', '7d')]:
        limit = limits.get(key) or {}
        value = limit.get('used_percentage')
        result = bar(value)
        if not result: continue
        if key == 'seven_day' and float(value) <= 30: continue
        segment = label + ' ' + result
        reset = limit.get('resets_at')
        if reset:
            try:
                seconds = max(0, int(float(reset) - time.time()))
                segment += f' reset {seconds // 3600}h{seconds % 3600 // 60:02}m'
            except (TypeError, ValueError, OverflowError): pass
        parts.append(segment)
    print(' | '.join(parts))

if __name__ == '__main__': main()
