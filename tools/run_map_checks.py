#!/usr/bin/env python3
"""Finite acceptance run for the new map plus all preserved regression fixtures.

Uses Python's standard library only; require Godot 4.7.2 and keep logs/summary.
"""
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
    root = Path(__file__).resolve().parents[1]
    output = (args.output or Path(tempfile.mkdtemp(prefix='false-world-map-'))).resolve()
    output.mkdir(parents=True, exist_ok=True)
    summary = output / 'acceptance.json'
    summary.unlink(missing_ok=True)
    rows = []
    # High-core cloud hosts can exhaust Jolt's finite job pool even in old fixtures.
    # Bound test scheduling without changing any project/physics/movement setting.
    if hasattr(os, 'sched_getaffinity') and hasattr(os, 'sched_setaffinity'):
        os.sched_setaffinity(0, sorted(os.sched_getaffinity(0))[:4])

    def run(name, command, completion=None, timeout=120):
        try:
            process = subprocess.run(command, cwd=root, capture_output=True, text=True, timeout=timeout)
            log = process.stdout + process.stderr
            code = process.returncode
        except subprocess.TimeoutExpired as error:
            log = str(error) + '\nPROCESS TIMEOUT\n'
            code = 124
        except OSError as error:
            log = str(error)
            code = 2
        (output / (name + '.log')).write_text(log, encoding='utf-8')
        warning_lines = [line for line in log.splitlines() if line.startswith('WARNING:')]
        # This exact engine warning also occurs in preserved M1/Stage 3D fixtures.
        # Record it explicitly; it is not a script/engine error or failed assertion.
        known = [line for line in warning_lines if line.startswith(
            'WARNING: Jolt Physics job system exceeded the maximum number of jobs.')]
        passed = code == 0 and not any(marker in log for marker in ('ERROR:', 'SCRIPT ERROR:'))
        passed = passed and len(warning_lines) == len(known)
        if completion:
            passed = passed and bool(re.search(completion, log))
        rows.append({'check': name, 'exit': code, 'passed': passed, 'engine_warnings': warning_lines})
        suffix = ' (Jolt engine warning; see log)' if known else ''
        print(f'{"PASS" if passed else "FAIL"}: {name}{suffix}', flush=True)
        if not passed:
            print(log[-3000:], file=sys.stderr)
        return passed

    # Pace accelerated fixed-step runs; unthrottled headless runs also triggered
    # Jolt job-pool warnings in unchanged legacy scenes on this host.
    engine = [args.godot, '--headless', '--max-fps', '600', '--path', str(root)]
    ok = run('version', [args.godot, '--headless', '--version'], r'4\.7\.2\.stable\.official\.ed1daf0bf')
    ok = run('import', engine + ['--editor', '--import']) and ok
    scripts = [
        ('map-walk', 'tests/map/test_map_foundation.gd', 40, 180),
        ('map-ai', 'tests/map/test_map_ai.gd', 18, 60),
        ('m1-camera', 'tests/m1/test_camera_clearance.gd', 15, 60),
        ('m1-graybox', 'tests/m1/test_graybox.gd', 31, 60),
        ('stage3a', 'tests/stage3a/test_foundation.gd', 39, 60),
        ('stage3a1', 'tests/stage3a1/test_exploration.gd', 25, 60),
        ('stage3b1', 'tests/stage3b1/test_observation_decisions.gd', 45, 60),
        ('stage3b2', 'tests/stage3b2/test_ai_debug.gd', 33, 60),
        ('stage3c', 'tests/stage3c/test_coordination.gd', 35, 60),
    ]
    for name, script, count, timeout in scripts:
        command = engine + ['--fixed-fps', '60', '--quit-after', '65000', '--script', 'res://' + script]
        if name == 'map-walk':
            report = output / 'walks.json'
            report.unlink(missing_ok=True)
            command += ['--', '--output=' + str(report)]
        ok = run(name, command, rf'{count} checks, 0 failures', timeout) and ok
    try:
        data = json.loads((output / 'walks.json').read_text())
        valid = (data['complete'] is True and data['success'] is True and len(data['walks']) == 10
                 and all(walk['completed'] and walk['physics_ticks'] > 0 for walk in data['walks']))
    except (OSError, ValueError, KeyError):
        valid = False
    rows.append({'check': 'walk-report', 'passed': valid})
    ok = ok and valid
    scenarios = output / 'scenarios'
    scenarios.mkdir(exist_ok=True)
    (scenarios / 'summary.json').unlink(missing_ok=True)
    ok = run('stage3d', engine + ['--fixed-fps', '60', '--quit-after', '40000',
                                '--script', 'res://tests/scenarios/run_ai_scenarios.gd', '--',
                                '--seed=431', '--repeat=2', '--scenario=all', '--output=' + str(scenarios)],
             r'AI scenarios: 16/16 passed; complete=true', 150) and ok
    try:
        data = json.loads((scenarios / 'summary.json').read_text())
        results = data['results']
        hashes = {}
        valid = data['complete'] is True and data['success'] is True and len(results) == 16
        for row in results:
            valid = valid and row['passed'] is True and row['seed'] == 431
            hashes.setdefault(row['scenario'], []).append(row['semantic_sha256'])
        valid = valid and len(hashes) == 8 and all(len(pair) == 2 and pair[0] == pair[1] for pair in hashes.values())
    except (OSError, ValueError, KeyError):
        valid = False
    rows.append({'check': 'scenario-report', 'passed': valid})
    ok = ok and valid
    for name, scene in [('map-startup', None), ('stage3c-startup', 'res://scenes/prototype/stage3c_coordination.tscn'),
                        ('m1-startup', 'res://scenes/prototype/m1_graybox.tscn')]:
        command = engine + ['--fixed-fps', '60', '--quit-after', '1800']
        if scene:
            command.append(scene)
        ok = run(name, command, timeout=60) and ok
    summary.write_text(json.dumps({'complete': True, 'success': ok, 'results': rows}, indent=2) + '\n')
    print(f'Acceptance complete: success={ok}; {summary}')
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
