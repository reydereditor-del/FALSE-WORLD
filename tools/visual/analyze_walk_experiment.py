#!/usr/bin/env python3
"""Summarize the moving preview's captured ankle motion; not a sole/quality proof.

Exit 1 when the provisional contact-window drift gate fails. This is a diagnostic
of the experimental blend, not a test to disable when production remains unchanged.
"""
import argparse
import json
import math
from pathlib import Path
import re
import statistics


def vector(text):
    return [float(x) for x in re.findall(r'[-+]?(?:\d*\.\d+|\d+)(?:[eE][-+]?\d+)?', text)]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--trace', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    rows = json.loads(args.trace.read_text())
    windows = [('left', 2.5, 3.3), ('backward', 5.5, 6.3),
               ('backward_diagonal', 7.5, 8.3), ('forward_diagonal', 10.5, 11.3)]
    report = {'complete': True, 'contact_gate_m_per_s': .05,
              'definition': 'Mean horizontal ankle velocity during authored phase .1-.5; not skinned-sole velocity.',
              'frames': len(rows), 'profiles': [], 'production_integration': False}
    for index, (back, side) in enumerate([(1.75, 2.25), (1.10, .85), (.90, .65)]):
        profile = {'backward_speed': back, 'side_speed': side, 'forward_speed': 4,
                   'back_cycles_per_second': back / (.44 / .60),
                   'side_cycles_per_second': side / (.28 / .60), 'windows': []}
        for name, start, end in windows:
            selected = [row for row in rows if start <= row['t'] <= end]
            errors = []
            for a, b in zip(selected, selected[1:]):
                dt = b['t'] - a['t']
                aa, bb = a['actors'][index], b['actors'][index]
                for foot, offset in [('left_ankle', 0), ('right_ankle', .5)]:
                    qa, qb = (aa['phase'] + offset) % 1, (bb['phase'] + offset) % 1
                    if .1 < qa < .5 and .1 < qb < .5:
                        p, q = vector(aa[foot]), vector(bb[foot])
                        errors.append(math.hypot(q[0] - p[0], q[2] - p[2]) / dt)
            if not errors:
                raise ValueError('No contact-window samples: ' + name)
            mean = statistics.mean(errors)
            profile['windows'].append({'stage': name, 'samples': len(errors),
                                       'mean_ankle_drift_m_per_s': mean,
                                       'max_ankle_drift_m_per_s': max(errors),
                                       'contact_gate_passed': mean <= .05})
        profile['contact_gate_passed'] = all(w['contact_gate_passed'] for w in profile['windows'])
        report['profiles'].append(profile)
    report['contact_gate_passed'] = any(p['contact_gate_passed'] for p in report['profiles'])
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    print('Contact-window gate: ' + ('PASS' if report['contact_gate_passed'] else 'FAIL; preview remains unaccepted'))
    for p in report['profiles']:
        print(p['backward_speed'], p['side_speed'], [(w['stage'], round(w['mean_ankle_drift_m_per_s'], 4)) for w in p['windows']])
    return 0 if report['contact_gate_passed'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
