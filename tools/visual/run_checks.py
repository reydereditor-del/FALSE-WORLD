#!/usr/bin/env python3
"""Finite visual-slice checks plus unchanged map/gameplay acceptance. Standard library only."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import struct
import subprocess
import sys
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', required=True)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[2]
    output = (args.output or Path(tempfile.mkdtemp(prefix='false-world-visual-'))).resolve()
    output.mkdir(parents=True, exist_ok=True)
    summary_path = output / 'summary.json'
    summary_path.unlink(missing_ok=True)
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
        unknown = [line for line in warnings if not line.startswith('WARNING: Jolt Physics job system exceeded the maximum number of jobs.')]
        passed = code == 0 and not unknown and 'ERROR:' not in log
        if completion:
            passed = passed and bool(re.search(completion, log))
        rows.append({'check': name, 'exit': code, 'passed': passed, 'engine_warnings': warnings})
        print(f'{"PASS" if passed else "FAIL"}: {name}', flush=True)
        if not passed:
            print(log[-4000:], file=sys.stderr)
        return passed

    engine = [args.godot, '--headless', '--max-fps', '600', '--path', str(repo)]
    ok = run('gameplay-regressions', [sys.executable, 'tools/run_map_checks.py', '--godot', args.godot,
                                    '--output', str(output / 'regressions')],
             r'Acceptance complete: success=True;', timeout=600)
    try:
        regression = json.loads((output / 'regressions/acceptance.json').read_text())
        ok = ok and regression['complete'] is True and regression['success'] is True
    except (OSError, ValueError, KeyError):
        ok = False
    for file in sorted((repo / 'scripts/visual').glob('*.gd')) + sorted((repo / 'tools/visual').glob('*.gd')):
        ok = run('parse-' + file.stem, engine + ['--check-only', '--script', 'res://' + str(file.relative_to(repo))]) and ok
    ok = run('showcase-integration', engine + ['--fixed-fps', '60', '--quit-after', '6500', '--script',
                                             'res://tests/visual/test_showcase.gd'],
             r'Visual slice: 25 checks, 0 failures; complete=true', timeout=100) and ok
    ok = run('showcase-startup', engine + ['--fixed-fps', '60', '--quit-after', '1800',
                                          'res://scenes/visual/visual_vertical_slice.tscn']) and ok
    ok = run('graybox-fallback-startup', engine + ['--fixed-fps', '60', '--quit-after', '1800',
                                                  'res://scenes/world/map_foundation.tscn']) and ok
    # Validate actual GLB contents, retained notices and committed texture checksums.
    asset_ok = True
    manifest = json.loads((repo / 'assets/visual/manifest.json').read_text())
    for item in manifest['files']:
        file = repo / item['path']
        asset_ok = asset_ok and file.exists() and hashlib.sha256(file.read_bytes()).hexdigest() == item['sha256']
    worker = (repo / 'assets/visual/models/worker.glb').read_bytes()
    gltf = json.loads(worker[20:20 + struct.unpack_from('<I', worker, 12)[0]])
    asset_ok = asset_ok and worker[:4] == b'glTF' and len(gltf.get('skins', [])) == 1
    asset_ok = asset_ok and len(gltf.get('animations', [])) > 0 and not gltf.get('images')
    asset_ok = asset_ok and 'COLOR_0' in gltf['meshes'][0]['primitives'][0]['attributes']
    for name in ('CC0-1.0.txt', 'CC-BY-4.0.txt', 'Lantern-LICENSE.md', 'BoomBox-LICENSE.md', 'CesiumMan-LICENSE.md'):
        asset_ok = asset_ok and (repo / 'assets/licenses' / name).is_file()
    rows.append({'check': 'licensed-assets-and-unbranded-worker', 'passed': asset_ok})
    ok = ok and asset_ok
    summary_path.write_text(json.dumps({'complete': True, 'success': ok, 'checks': rows,
                                       'new_assertions': 25, 'legacy_map_assertions': 281,
                                       'legacy_scenarios': 16}, indent=2) + '\n')
    print(f'Visual acceptance complete: success={ok}; {summary_path}')
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
