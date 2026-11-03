# Focused character and camera fixes — 2026-11-03

Scope: existing worker presentation, playable visual-scene settings and focused tests.
No asset, map, movement/collision, AI architecture or extraction-rule changes.

## Causes and corrections

- Human motor `facing_turn_speed` was zero, selecting the instantaneous facing branch.
  AI already used 3.5 rad/s. The visual composition now opts the human into that same
  rate. Body translation remains immediate at 4 m/s with existing collision/gravity
  and camera-relative input. Original capsule fixtures retain their legacy defaults;
  `character_motor.gd` and AI turn tuning are unchanged.
- Idle copied the first imported walking frame and reset only the legs. Opposite
  arm swings were therefore frozen into Idle. Presentation now starts from the rig's
  rest pose and rotates each shoulder/elbow chain toward downward, slightly outward
  symmetric directions, converting to the imported bones' parent spaces. It records
  that actual skeleton pose in Idle, retaining chest breathing and the 0.18 s Walk/
  Idle crossfade. Imported walk/model files and movement are unchanged. This is an
  actual pose correction, not a renamed animation.
- The playable rig used the legacy -65 degree pivot endpoint. The inherited visual
  composition now permits -80 degrees for a steeper downward view, leaving the +20
  upward limit, spring length, 3.2 m pivot, probe, focus and camera algorithm intact.
  This was accepted only after real Stage 4 clearance/framing sampling. Global
  `follow_camera.gd` defaults and old scene regression configurations are unchanged.

Stage 4 inherits this visual composition, so all fixes are active in its current F5
scene. All four humanoids share the corrected Idle; AI retains its existing turn rate.

## Verification

Godot 4.7.2 import and explicit Stage 4 120-frame startup: exit 0, no script/engine
errors. `tests/visual/test_character_fixes.gd` failed four of seven checks before the
fix and passed **7/7** after. It exercises left/right/back input, bounded intermediate
heading changes, actual symmetric/downward shoulder/elbow/wrist positions on all
four rigs, per-frame animation blending and **144** open/door/corner camera orbits.
Camera enclosure includes origin/near plane plus 2 cm margin; world overlap must be
zero, body clearance >=1.1 m, projected whole-body bounds <=80% of either dimension.
Both new downward samples (-80/-75) and existing endpoint samples are covered.

Relevant unchanged tests passed: visual integration **25**, M1 camera **15**, M1
movement/camera/interaction **31**, AI exploration/turning **25**, Stage 4 rules **27**,
Stage 4 real-scene integration **36**, replay audit **10**. Including new tests:
**176 checks, zero failures**, expected completion counts and error scans, with
external 130-second limits and finite frame ceilings. Logs `/tmp/character-fix-*.log`.
Full unrelated suites/Stage 3D were not rerun for this focused task. No new rendered
or Windows playtest was performed; mathematical headless checks do not establish
natural-looking movement, lack of skin clipping, camera comfort or FPS. Windows
visual validation is still required. No new asset or paid dependency was introduced.

Stage 4 integration confirms its existing arrival-yard success/retry logic. No
extraction defect was reproduced and no extraction source/settings were changed.

## Windows check

```powershell
cd C:\Projects\FALSE-WORLD
git fetch origin
git switch fix/character-idle-turn-camera
$Godot = 'C:\Godot\Godot_v4.7.2-stable_win64_console.exe'
& $Godot --headless --path . --editor --import
& $Godot --path . res://scenes/stage4/signal_loop.tscn
```

Adjust the executable path. Tap/hold A/D/S and reverse directions: translation must
stay responsive while facing turns smoothly. Stop and inspect both arms from front
and sides; check no opposite frozen swing or snapping through Walk/Idle. Observe AI
using the same Idle. Orbit steeply downward in the open, against door corners and
under the partial roof; check whole-character visibility, clipping and spring recovery.

For extraction: collect the workbench module, hold E at the cabinet for four seconds,
then leave it and enter the outlined yard at (220,140) before the five-second wait
ends. Walk around the sign via (220,132). Expect PROTOTYPE EXTRACTION COMPLETE.
Staying at the cabinet misses arrival and permits another call. R restarts the test.
Next step: report these Windows pose/turn/camera observations before further tuning.
