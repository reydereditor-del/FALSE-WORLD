# M1 — local third-person graybox

A standalone local technical slice, corresponding to handoff §19 stage 2. This is
not a mission or the full game. It contains one character, a bounded 24×24-unit
primitive yard, a central solid obstacle, and one adjustable lever to its left.
No multiplayer, AI, combat, HP, inventory, objectives, extraction, or gameplay UI.
All geometry/materials are original Godot primitives; no imported assets/dependencies.

## Run and controls

Use **Godot 4.7.2 standard** with GDScript. Import root `project.godot`, then F6 with
`scenes/prototype/m1_graybox.tscn` open. F5 now starts the Stage 3B.1 observation demo in the same larger area; see
[STAGE3B1_PROTOTYPE.md](STAGE3B1_PROTOTYPE.md).
From the repository root, the equivalent command is:

```sh
godot --path . res://scenes/prototype/m1_graybox.tscn
```

Ensure `godot --version` is 4.7.2. The cloud's default binary may still be 4.6.3;
the verified cloud binary is
`/workspace/.tools/godot/4.7.2/Godot_v4.7.2-stable_linux.x86_64`.

| Control | Behavior |
| --- | --- |
| W / A / S / D | Walk relative to camera yaw; diagonal speed is bounded |
| Mouse movement | Orbit following camera, with clamped pitch |
| Hold E near lever | Start/continue moving the lever toward its set position |
| Release E | Cancel immediately, retaining partial progress |
| Walk away or behind solid geometry | Cancel; out-of-range/blocked work is rejected |
| Escape | Release cursor and stop movement/work |
| Left click in game window | Capture cursor and resume controls |
| Window loses focus | Release cursor and cancel movement/work |

Walk left around the central box to find the yellow lever on the gray pedestal.
Start near the pedestal and hold E: the handle visibly turns from -45° to +45°.
Release partway; it stays there. Hold again to finish. Completion emits the target's
`completed` signal once and leaves the handle set; it triggers no mission or reward.
It cannot be restarted once complete. Restart the scene to repeat the test.
Progress persists in the running scene only; no save-to-disk system is implemented.
There is no targeting reticle, progress bar or fake mission indicator.

## Prototype tuning and boundaries

All exported tuning is provisional: motor speed 4 units/s, gravity 18 units/s²,
lever duration 3 seconds, interaction radius 2.2 units from actor torso to target,
camera sensitivity 0.003 radians/pixel, pitch -65°…20°, spring length 4 units,
above-head pivot height 3.2 units and spherical camera probe radius 0.2 units.
Change these through the scene Inspector; they are not finalized balance. Duration
and radius must remain positive. The target checks reach/line of sight on every
work request and allows one worker, retaining progress for any later worker.

The only input polling is `local_controller.gd`. `CharacterMotor` accepts world-space
movement intent and handles gravity/collision; `CharacterInteractor` accepts work
intent; `WorkTarget` owns worker/progress/completion and transforms its lever.
`FollowCamera` owns orbit and SpringArm3D collision. References are explicit for the
one target, with no targeting framework, AI/network stubs, or global event bus.

Current Forward Plus/Jolt/D3D12 settings are preserved. Rendering is limited to simple
rough materials, one unshadowed directional light, flat background/ambient light,
and short camera far distance. No new postprocessing, textures, GI or shadow maps.
This limits content cost but does not establish Intel-iGPU performance. A future
renderer change needs its own authorization and measurements. No jumping, sprinting,
controller support, character animation, game menu or persistent save is included.

## Automated validation

Run from repository root with Godot 4.7.2 explicitly selected:

```sh
godot --headless --path . --editor --import
godot --headless --path . --script res://tests/m1/test_graybox.gd
godot --headless --path . --script res://tests/m1/test_camera_clearance.gd
godot --headless --path . res://scenes/prototype/m1_graybox.tscn --quit-after 120
```

The built-in GDScript runner exits nonzero on failed expectations and prints its
check/failure totals. Inspect output for script/engine errors as well as exit status.
Import and instantiation cover scene/resource/script validation; individual scripts
can additionally use `--headless --path . --check-only --script <res://path.gd>`.
The tests exercise real Godot physics, shared commands, synthetic local input,
camera angle bounds and spring collision, and interaction ownership/cancel/resume/
obstruction/completion. The camera regression uses a fixed 1280×720 SubViewport
and asserts its actual size: the headless window itself can reset to 64×64. It tests
336 yard orbits, 48 tall-wall and 48 tall-corner stress poses, both pitch limits,
full arm collapse, camera/near-plane clearance, visibility flags, center-frustum
inclusion, projected whole-body size and continuous small open-space orbit steps.
Character bounds must fit on screen and occupy no more than 80% of either dimension;
camera-to-body-bounds distance must be at least 1.1 units. These are provisional
M1 regression thresholds, not final camera balance. Conservative box projections
are a stronger framing proxy than checking only the character center.
These physics/projection checks are not rendered screenshots or proof of camera
comfort, physical input behavior, unsampled geometry support or GPU performance.

In the cloud, export writable locations before these commands:

```sh
export XDG_CACHE_HOME=/workspace/.cache
export XDG_DATA_HOME=/workspace/.local/share
export XDG_CONFIG_HOME=/workspace/.config
```

Godot editor import needs its local sockets permitted by the execution sandbox.
No network service or external dependency is required by this prototype.

## User-reported graphical verification

The user tested M1 on a Windows laptop using Godot 4.7.2. Reported passes, before
this camera fix: scene launch/rendering, WASD, mouse orbit in all directions,
ground/central-obstacle collision, lever progress while holding E, release retaining
partial progress, resume, completion, out-of-range rejection, solid-geometry
obstruction, camera collision with surrounding walls, and Escape cancel followed by
click-to-restore controls. The earlier observed session reported 0 errors/0 warnings.
These are user reports, not graphical tests rerun by the agent. Tested build SHA,
duration, driver, resolution and detailed laptop specifications were not supplied.
No FPS, GPU, frame-time or memory benchmark or Windows export result was reported.

A subsequent wall-front orbit case exposed camera/character overlap; the first
clearance correction was then reported to produce excessive close-up framing.
Those user-reported failures are not considered graphically resolved by headless
tests. The latest correction below still requires Windows acceptance.

## Camera framing correction

The earlier clearance fix prevented penetration but failed the user's Windows
framing test: near an obstacle, retraction could make the blue character fill the
screen. The 2.1-unit pivot was only 0.3 units above the 1.8-unit mesh. The 0.2-radius
sphere correctly hit nearby geometry, shortening the arm to about 0.18 units in
reproduction. Aiming at the body center kept that point in view while the head was
much nearer the lens; center-in-frustum checks did not prevent extreme magnification.
The 0.1 near plane prevents close geometry being drawn, not third-person framing.
Changing the margin or shrinking the probe alone did not resolve this case.

The minimal runtime correction moves the pivot to **3.2 units** above the feet,
providing 1.4 units above the current capsule. The existing 4-unit arm, 0.2-radius
sphere, 0.2 margin, 0.1 near plane, FOV 70, pitch limits and body-center focus remain
unchanged. The raised orbit origin provides framing clearance even when collision
shortens the arm completely. It is a fixed scene calibration, with no clamp forcing
the camera past a wall, automatic mode switch, FOV zoom, character hiding, or new
camera-control algorithm. Normal SpringArm3D world sweeps still decide the arm
length; taller test walls explicitly force short-arm collision to verify this.

For the sampled M1 yard poses the corrected camera is at least 2.49 units from
conservative body bounds, whose largest screen extent is about 45.4%. Additional
near-zero/zero-arm tests enforce the 1.1-unit clearance and 80% framing budgets.
These are geometric measurements, not measured pixel coverage or graphical acceptance.
The higher origin changes the viewpoint; usability needs Windows revalidation.
Clear paths above the 2-unit walls may retain full arm length without clipping.
The existing wall retraction fixture starts farther from the wall so the requested
arm crosses it at the new height; world geometry and gameplay are unchanged.

This calibration is specific to the M1 capsule, facing marker, current orbit pitch
range and FOV. Revalidate if character size, near plane, aspect/FOV or geometry changes.
No support for arbitrary low ceilings or confined future maps is claimed.

## Remaining graphical checks and Stage 3A regression pass

On Windows with Godot 4.7.2, using this fix branch:

1. Press the character against every wall, then orbit to its front and through a
   full circle at low/middle/high pitch. Repeat at corners and the central obstacle.
   Confirm the camera/near plane stay outside both character and world, the character
   remains rendered, and the full character remains reasonably sized, with usable framing and no jitter
   or sudden jumps. Pay particular attention to downward/front orbits at the lever
   pedestal, central obstacle and tight corners.
2. Move toward/away from walls while orbiting; verify smooth retraction/extension
   and unobstructed following. Check visibility when the camera passes above a wall.
3. Recheck basic WASD and E start/release/resume/completion plus Escape/click after
   the camera adjustment. Explicit window-focus loss, walking-away cancellation,
   dedicated diagonal/perimeter checks and single-completion behavior were not
   separately confirmed in the latest user report; record them if tested.
4. Record actual results/debugger messages. Measure FPS/frame times/RAM separately
   before making performance claims; headless geometry checks cannot establish them.

No graphical display is available to the agent. The later user confirmation below
covers reported M1 controls and removal of extreme magnification, not complete
occlusion/performance acceptance. Stage 3A adds bodies and needs a fresh graphical
regression pass. No larger playable systems are authorized by this checklist.


## Later user confirmation

The user has visually confirmed that the latest M1 camera fix prevents the previous
extreme magnification, and reports passing M1 movement, collision, interaction and
camera controls. These are user reports, not fresh agent graphical tests. Remaining
camera occlusion is not claimed fixed, and FPS/RAM/GPU/frame times remain unmeasured.
Stage 3A adds agents without changing the movement or camera scripts; its new visual
behavior and additional occlusion still require separate graphical verification.
