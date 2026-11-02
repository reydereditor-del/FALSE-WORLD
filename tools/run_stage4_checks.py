#!/usr/bin/env python3
"""Stage 4's finite acceptance set; runs preserved visual/map/gameplay tests unchanged."""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', required=True)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    output = (args.output or Path(tempfile.mkdtemp(prefix='false-world-stage4-'))).resolve()
    output.mkdir(parents=True, exist_ok=True)
    summary = output / 'summary.json'
    summary.unlink(missing_ok=True)
    if hasattr(os, 'sched_setaffinity'):
        os.sched_setaffinity(0, sorted(os.sched_getaffinity(0))[:4])
    rows = []

    def run(name, command, completion=None, timeout=120):
        try:
            process = subprocess.run(command, cwd=repo, capture_output=True, text=True, timeout=timeout)
            log, code = process.stdout + process.stderr, process.returncode
        except subprocess.TimeoutExpired as error:
            log, code = str(error) + '\nPROCESS TIMEOUT', 124
        except OSError as error:
            log, code = str(error), 2
        (output / (name + '.log')).write_text(log, encoding='utf-8')
        warnings = [line for line in log.splitlines() if line.startswith('WARNING:')]
        unexpected = [line for line in warnings if not line.startswith('WARNING: Jolt Physics job system exceeded the maximum number of jobs.')]
        passed = code == 0 and 'ERROR:' not in log and not unexpected
        if completion:
            passed = passed and bool(re.search(completion, log))
        rows.append({'check': name, 'exit': code, 'passed': passed, 'engine_warnings': warnings})
        print(f'{"PASS" if passed else "FAIL"}: {name}', flush=True)
        if not passed:
            print(log[-5000:], file=sys.stderr)
        return passed

    engine = [args.godot, '--headless', '--path', str(repo), '--max-fps', '600']
    ok = run('preserved-regressions', [sys.executable, 'tools/visual/run_checks.py', '--godot', args.godot,
                                     '--output', str(output / 'regressions')],
             r'Visual acceptance complete: success=True;', 600)
    try:
        report = json.loads((output / 'regressions/summary.json').read_text())
        ok = ok and report['complete'] is True and report['success'] is True
    except (OSError, ValueError, KeyError):
        ok = False
    files = sorted((repo / 'scripts/objective').glob('*.gd')) + [repo / 'tools/bake_stage4_navigation.gd']
    for file in files:
        ok = run('parse-' + file.stem, engine + ['--check-only', '--script', 'res://' + str(file.relative_to(repo))]) and ok
    ok = run('signal-rules', engine + ['--script', 'res://tests/stage4/test_signal_rules.gd'],
             r'Signal rules: 27 checks, 0 failures; complete=true') and ok
    ok = run('signal-integration', engine + ['--fixed-fps', '60', '--quit-after', '8500',
                                            '--script', 'res://tests/stage4/test_signal_integration.gd'],
             r'Signal integration: 36 checks, 0 failures; complete=true', 130) and ok
    ok = run('stage4-startup', engine + ['--fixed-fps', '60', '--quit-after', '1800',
                                       'res://scenes/stage4/signal_loop.tscn']) and ok
    summary.write_text(json.dumps({'complete': True, 'success': ok, 'results': rows,
                                   'new_checks': 63, 'preserved_checks': 306, 'ai_scenarios': 16}, indent=2) + '\n')
    print(f'Stage4 acceptance complete: success={ok}; {summary}')
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
