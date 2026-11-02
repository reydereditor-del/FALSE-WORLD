#!/usr/bin/env python3
"""Optional standard-library launcher: process timeout, engine-error and completion checks."""
import argparse
import json
from pathlib import Path
import subprocess
import sys
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', default='godot')
    parser.add_argument('--output', type=Path)
    parser.add_argument('--scenario', default='all')
    parser.add_argument('--repeat', type=int, choices=(1, 2, 3), default=2)
    parser.add_argument('--seed', type=int, default=431)
    parser.add_argument('--timeout', type=float, default=120)
    parser.add_argument('--audit-probe', action='store_true')
    args = parser.parse_args()
    if not 0 < args.timeout <= 600:
        parser.error('--timeout must be greater than zero and at most 600 seconds')
    output = args.output or Path(tempfile.mkdtemp(prefix='false-world-ai-'))
    output = output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    summary = output / 'summary.json'
    summary.unlink(missing_ok=True)
    repo = Path(__file__).resolve().parents[1]
    command = [args.godot, '--headless', '--fixed-fps', '60', '--quit-after', '40000',
               '--path', str(repo), '--script', 'res://tests/scenarios/run_ai_scenarios.gd',
               '--', f'--scenario={args.scenario}', f'--repeat={args.repeat}',
               f'--seed={args.seed}', f'--output={output}']
    if args.audit_probe:
        command.append('--audit-probe')
    try:
        result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                text=True, timeout=args.timeout)
        log = result.stdout
    except subprocess.TimeoutExpired as error:
        log = (error.stdout or b'')
        if isinstance(log, bytes):
            log = log.decode(errors='replace')
        (output / 'runner.log').write_text(log + '\nPROCESS TIMEOUT\n', encoding='utf-8')
        print(f'FAIL: process timeout; {output / "runner.log"}', file=sys.stderr)
        return 124
    except OSError as error:
        print(f'FAIL: cannot launch Godot: {error}', file=sys.stderr)
        return 2
    (output / 'runner.log').write_text(log, encoding='utf-8')
    print(log, end='')
    try:
        data = json.loads(summary.read_text(encoding='utf-8'))
    except (OSError, ValueError) as error:
        print(f'FAIL: missing/invalid completion report: {error}', file=sys.stderr)
        return result.returncode or 1
    valid = (data.get('complete') is True and data.get('success') is True
             and data.get('results') and all(row.get('passed') is True for row in data['results'])
             and not any(marker in log for marker in ('SCRIPT ERROR:', 'ERROR:')))
    return result.returncode or (0 if valid else 1)


if __name__ == '__main__':
    sys.exit(main())
