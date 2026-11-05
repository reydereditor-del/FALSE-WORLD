# Option B — camera-relative movement (2026-11-03)

## Current licensed integration (2026-11-05)

After installing the two user-licensed ZIPs with the new local importer, actual F5
Stage 4 uses retargeted eight-direction walk/run clips on the same worker. Forward
remains 4 m/s; back/side use 1.6 m/s with bounded diagonals and phase-preserving
0.18 s transitions. AI, camera, collision and objectives retain their behavior.
[LICENSED_LOCOMOTION.md](LICENSED_LOCOMOTION.md) gives the exact setup, license
boundary, actual-game renders and passing checks. The feature branch packages
this integration. Public clones without the private asset installation retain the
baseline below; the previously failed authored experiment remains historical.

## Earlier experiments and original baseline

2026-11-05: [bounded moving speed experiment](DIRECTIONAL_SPEED_EXPERIMENT.md)
evaluated slower backward/lateral motion with forward fixed at 4 m/s. Slower
cardinal gait is promising, but forward-diagonal blend contact remains unaccepted.
No gameplay speed or animation integration has been applied; details below remain
the actual production state. The comparison video and failed contact gate are saved.

2026-11-04 local authoring follow-up: [three editable directional clips and
rendered preview](LOCAL_DIRECTIONAL_WALKS.md) are available on the existing rig.
Their authored pace is inspectable, but matching the preserved 4 m/s produces
unacceptable rapid stepping. They are **not integrated**; gameplay and its
documented fallback below remain unchanged. External asset research is stopped.

2026-11-04 follow-up: [directional asset research](DIRECTIONAL_ANIMATION_RESEARCH.md)
records the actual rig, verified CC0 KayKit candidate, rendered source evaluation,
blocked alternative downloads and exact handoff requirements. No complete walking
set was accepted or integrated; the fallback below remains. Fresh regression:
422 ordinary checks and 16 AI scenario runs passed; new locomotion is not validated.

Movement semantics are implemented; directional animation remains incomplete.
Stage 4 and the visual slice enable human camera-facing locomotion. W/S/A/D move
along camera horizontal forward/back/left/right axes; diagonals normalize to the
existing 4 m/s. The body follows horizontal camera yaw at 3.5 rad/s while moving,
independently of translation. Pitch never tilts the body. Releasing input stops
translation and retains the last facing goal. Gravity, collision and camera are
unchanged. AI and old M1 scenes retain movement-facing behavior.

## Animation limitation and provenance

Direct inspection of `assets/visual/models/worker.glb` found one animation,
`Anim_0`, and 19 skeleton bones. It supplies the existing forward Walk; the corrected
rest-based Idle is retained. There are no backward or strafe clips. Existing Cesium
Man derivative attribution/licensing records remain unchanged (CC BY 4.0; see
`ASSET_LICENSES.md` and the asset attribution ledger).

A bounded source investigation of
<https://quaternius.com/packs/universalanimationlibrary.html> returned HTTP 403.
No candidate animation was downloaded, licensed or retargeted; no new asset or
attribution claim is made. Future imports require verified source, commercial
license and rig compatibility. No cost was incurred.

Per the requested fallback, backward/sideways/diagonal movement uses the corrected
resting pose with existing 0.18 s crossfades. Forward Walk plays only when actual
velocity is nearly forward in the visible body's frame. Turning can temporarily
select the fallback. This does not present forward/reversed playback as strafe,
but visibly glides without stepping. Authentic directional animation, diagonal
foot placement and natural locomotion are **not completed**. Compatible licensed
clips and graphical retargeting/blending validation are the next implementation step.

## Verification

Godot `4.7.2.stable.official.ed1daf0bf`: editor import, parser checks for all four
changed production scripts, and 120-frame headless Stage 4 startup passed.
These complete headless suites passed, **212 checks / zero failures**:

| Script under `tests/` | Checks |
| --- | ---: |
| `visual/test_option_b.gd` (new, actual Input events in Stage 4) | 36 |
| `visual/test_character_fixes.gd` | 7 |
| `visual/test_showcase.gd` | 25 |
| `m1/test_camera_clearance.gd` | 15 |
| `m1/test_graybox.gd` | 31 |
| `stage3a1/test_exploration.gd` | 25 |
| `stage4/test_signal_rules.gd` | 27 |
| `stage4/test_signal_integration.gd` | 36 |
| `stage4/test_signal_replay_audit.gd` | 10 |

Run each with `Godot_v4.7.2-stable_win64_console.exe --headless --path . --fixed-fps 60 --quit-after 8500 --script res://tests/<script>`.
Require completion summary and zero exit status; timeout is failure. Existing tests
were not edited. Broader unrelated AI scenario suites were not rerun.

Two real Stage 4 rightward-movement rendered frames were captured and inspected:
the body keeps its orientation and resting arms, confirming the glide limitation.
Vulkan initialization failed (`VK_KHR_surface` unavailable); Godot fell back to Mesa
llvmpipe OpenGL. This is limited rendered inspection, not a Windows Forward Plus
playtest or evidence of natural movement/performance.

## Windows verification

1. Fetch and switch to `feat/option-b-camera-relative`; open `project.godot` in
   Godot 4.7.2, allow import, then F5 (Stage 4 signal loop).
2. In open ground, hold W then S, A and D with unchanged mouse yaw. Translation
   follows camera axes; S must not reverse facing and A/D must not turn it.
   Confirm forward stepping and the documented neutral glide in other directions.
3. Rotate the camera 90 degrees while walking. Facing turns smoothly toward camera
   yaw. Look steeply up/down: torso stays upright. Alternate WASD rapidly, release:
   no speed spike, snap turn or continued translation; idle arms rest.
4. Compare W with W+D: diagonal speed stays equal. Walk into walls, orbit near
   walls and observe AI: existing clearance/collision and AI facing must remain.
5. Collect the service module on the storehouse workbench. Hold E at the cabinet
   for 4 seconds, then walk around the sign into the marked pickup yard before the
   5-second countdown expires. Expect local extraction success. Staying at the
   cabinet yields an empty arrival; R restarts the prototype.

Map, UI, objectives, extraction rules, AI coordination, camera settings and imported
assets are unchanged. This remains the single-route Stage 4 prototype.
