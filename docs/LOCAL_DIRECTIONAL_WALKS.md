# Locally authored directional walks — 2026-11-04

2026-11-05 follow-up: the user authorized slower backward/lateral evaluation.
[Moving speed comparison](DIRECTIONAL_SPEED_EXPERIMENT.md) measures the actual clips
and renders three speed profiles with transitions on a fixed world grid. Cardinal
cadence improves at 1.10/0.85 m/s, but forward-diagonal contact still fails; production
remains unchanged. The former requirement to match every direction to 4 m/s below
is historical and no longer the remaining blocker.

**Stage 1 delivered as editable preview work. Stage 2 is not accepted or integrated.**
These three new clips contain real independently authored footwork on the existing
worker rig. The isolated authored-pace renders show alternating contact/swing and
separated feet. However, they do not yet meet convincing walking quality at the
unchanged 4 m/s gameplay speed. Runtime locomotion remains byte-preserved, including
its previously documented directional glide; this task does not claim to fix it.
No new idle/forward substitute has been wired into gameplay. Diagonal blending,
locomotion transitions and final Stage 4 new-animation acceptance remain pending.

External asset research is stopped. No download, subscription, paid tool, new
runtime dependency, model replacement or re-rigging was used. Cost: 0 UZS.

## Editable outputs and reproducible authoring

- `assets/visual/animations/backward_walk.tres`
- `assets/visual/animations/strafe_left.tres`
- `assets/visual/animations/strafe_right.tres`
- `tools/visual/author_directional_walks.gd`: deterministic offline Godot authoring.
- `scenes/preview/directional_walks.tscn`: isolated review scene; no gameplay/AI.
- `tools/visual/directional_walk_preview.gd`: three views, moving checker ground,
  authored/4 m/s comparison and finite frame-capture mode.

Each Animation is editable in Godot, with 19 bone position/rotation pairs sampled
at 100 Hz over a 0.9-second loop. Tracks bind to the original
`Z_UP/Armature/Skeleton3D` hierarchy. Reusable means on this worker skeleton;
these are not generic humanoid retarget resources. Edit the authoring parameters
and regenerate, or duplicate a resource before editing its keys manually:
regeneration intentionally replaces only these three generated `.tres` files.

From the repository root, with Godot 4.7.2:

```sh
godot --headless --path . --script res://tools/visual/author_directional_walks.gd
godot --headless --path . --script res://tests/visual/test_local_walk_resources.gd
godot --path . res://scenes/preview/directional_walks.tscn
```

In this cloud machine use the explicit executable
`/workspace/.tools/godot/4.7.2/Godot_v4.7.2-stable_linux.x86_64`, with
`XDG_CACHE_HOME=/workspace/.cache/false-world`,
`XDG_DATA_HOME=/workspace/.local/share/false-world`, and
`XDG_CONFIG_HOME=/workspace/.config/false-world`. Interactive preview needs a display.

## Rig inspection and construction

Inspected the actual 19-bone worker's rest transforms, global joint locations,
bone roll and imported forward clip, rather than relying on anatomical axes
matching bone-local axes. In presentation space the standing pelvis is approximately
0.815 m high, hips 0.737 m, knees 0.422 m and ankles 0.103 m; upper/lower legs
are approximately 0.319/0.331 m. The imported forward clip is 2.0 seconds with
25 tracks. Sampled its quarter-cycle hip/knee/ankle/toe positions to establish
alternating leg phases, stride scale, knee bend and restrained opposing arm motion
as references. No source channel was copied or reversed.

The new backward gait has a distinct backward contact/swing trajectory. Strafes
open with the leading leg and follow with the trailing leg, keeping separate foot
lanes. They are not rotated forward clips. Authoring solves hip/knee rotations
against desired ankle positions in character space, then converts through the
actual parent bases. Skin, bone hierarchy, rest transforms, lengths, model scale
and mesh remain unchanged. IK runs only in the offline baker; runtime resources
contain ordinary keys.

Each foot has a 60% stance phase and 40% swing. Stance moves linearly against the
treadmill; Hermite swing matches horizontal contact velocity and adds 6.5 cm of
smooth clearance. Ankle/toe roll joins the toe-off boundary continuously. Original
arm authoring hangs the arms with small opposing swing and elbow bend. Pelvis
motion is bounded to about 2.4 cm lateral sway and 1.6 cm bob, with restrained
torso counter-rotation and no accumulating root displacement. Loop endpoints match
exactly. The separate authored-pace videos show stepping, not sliding an idle pose.

## Rendered evidence and unresolved speed quality

Actual Godot 4.7.2 renders on an isolated Xorg display, using automatic software
OpenGL/Mesa llvmpipe after Vulkan `VK_KHR_surface` initialization failed. Project
renderer settings were not changed. This is not Windows Forward Plus/D3D12 or
Intel-iGPU performance evidence.

- [Backward: front, side, three-quarter; three cycles](evidence/directional_local/BackwardWalk.mp4)
- [Left strafe: same views and duration](evidence/directional_local/StrafeLeft.mp4)
- [Right strafe: same views and duration](evidence/directional_local/StrafeRight.mp4)
- [Contact-sheet poses](evidence/directional_local/contact-sheet.png)
- [4 m/s comparison — not accepted](evidence/directional_local/gameplay-speed-unaccepted.mp4)

Captured 657 authored-pace frames (three clips × three views × 73 frames) and
543 speed-comparison frames (three clips × 181 frames). Inspected sampled rendered
poses across contact, swing and loop boundaries; no obvious leg crossing or gross
joint deformation was seen. The authored-pace MP4s encode at 80/3 fps, preserving
0.9-second cycles; the comparison is 60 fps for three seconds. Video frame counts
and dimensions were verified with ffprobe. Evidence is excluded from Godot imports.

| Clip | Travel represented per cycle | Authored pace | Required playback at 4 m/s |
| --- | ---: | ---: | ---: |
| Backward | 0.733 m | 0.815 m/s | 4.91×; 5.45 cycles/s |
| Left/right strafe | 0.467 m | 0.519 m/s | 7.71×; 8.57 cycles/s |

At authored cadence the feet can remain planted against the moving reference
ground. At 4 m/s, speed matching produces visibly implausible rapid stepping;
keeping authored cadence would produce severe sliding. Enlarging key amplitudes
enough to cover that speed at a walking cadence exceeds this short-legged rig's
reachable, noncrossing walking stance. No speed reduction, scale increase, controller
rewrite, running substitution or unverified gameplay blend was introduced to hide
this problem. The current authored clips are useful editable work, not accepted
final gameplay animation. This is a limitation of this authored gait at the required
speed, not a proof that no better animation solution can exist.

The next work is improving the gait/stride and evaluating the 4 m/s comparison
until convincing quality is reached within the existing constraints. Only then
should shared WorkerPresentation gain local-velocity selection, phase-aware diagonal
blends and idle/direction transitions. Current preservation tests are not proof of
those unimplemented changes.

## Verification performed

- New `tests/visual/test_local_walk_resources.gd`: **16 checks, zero failures** on
  the actual skeleton/resources: loop endpoints, finite bone poses, knee ordering,
  foot separation/clearance, bounded root motion and planted-ankle travel. Worst
  stance displacement error was under **0.06 mm per sampled tick**; maximum lift
  6.50 cm; minimum ankle separation 18.84 cm backward and 12.67 cm lateral.
  These metrics validate joint trajectories, not perfect skinned-sole locking or
  subjective naturalness.
- Regenerated twice and compared SHA-256: identical outputs for all three clips.
- One final `python3 tools/run_stage4_checks.py --godot GODOT --output
  /tmp/local-walks-regression`: **369 checks and 16/16 AI scenario runs passed**,
  including actual import, map/visual regressions, camera, movement, interaction,
  AI and Stage 4 startup/integration. Fresh nested completion/success reports read.
- Existing direct Option B **36/0**, character-fixes **7/0**, replay-audit **10/0**.
  Total: **438 ordinary checks including the 16 new checks**, plus 16 scenario runs.
  No existing test or expected fallback was changed. No full-suite loop during
  authoring adjustments.
- Actual preview and comparison renders completed. The first seek-capture attempt
  retained a crossfade; corrected capture disables that blend. Final evidence uses
  the corrected captures and the final continuous toe-off resources. An initial
  sandbox editor socket failure was superseded by the successful permitted import
  in the final regression run.
- Git preservation and whitespace checked. Original worker, gameplay scripts,
  camera, scenes, existing tests, AI, navigation and project settings are unchanged.
  Pre-existing research/documentation work is retained. No staging, commit, push
  or merge.

Saved result summaries and focused logs are alongside the videos under
`docs/evidence/directional_local/`. No new-animation gameplay integration, diagonal
blend, Windows acceptance or performance test is claimed.

## Windows preview and remaining manual review

In PowerShell, change to the repository root and use your actual engine path:

```powershell
$Godot = 'C:\Godot\Godot_v4.7.2-stable_win64_console.exe'
& $Godot --path . 'res://scenes/preview/directional_walks.tscn'
```

1. Press **1/2/3** for backward/left/right. Press **F1/F2/F3** for front/side/
   three-quarter. Watch several cycles at authored speed, including contact and
   loop seams; inspect ankles, knees, arms, torso and foot separation.
2. Press **Space** to compare the preserved **4 m/s** requirement. Assess cadence
   and skin/sole contact; this speed is explicitly unaccepted in the current work.
3. Do not treat F5 as a test of these new clips: gameplay still uses its existing
   presentation. After future integration, test all diagonals, stopping, reversals,
   camera rotation, collision, AI movement and the Stage 4 module/cabinet/yard flow.

No asset download is needed for this local authoring approach.
