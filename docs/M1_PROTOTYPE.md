# M1 — local third-person graybox

A standalone local technical slice, corresponding to handoff §19 stage 2. This is
not a mission or the full game. It contains one character, a bounded 24×24-unit
primitive yard, a central solid obstacle, and one adjustable lever to its left.
No multiplayer, AI, combat, HP, inventory, objectives, extraction, or gameplay UI.
All geometry/materials are original Godot primitives; no imported assets/dependencies.

## Run and controls

Use **Godot 4.7.2 standard** with GDScript. Import root `project.godot`, then F6 with
`scenes/prototype/m1_graybox.tscn` open, or F5 for the configured startup scene.
From the repository root, the equivalent command is:

```sh
godot --path .
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
above-head pivot height 2.1 units and spherical camera probe radius 0.2 units.
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
godot --headless --path . --quit-after 120
```

The built-in GDScript runner exits nonzero on failed expectations and prints its
check/failure totals. Inspect output for script/engine errors as well as exit status.
Import and instantiation cover scene/resource/script validation; individual scripts
can additionally use `--headless --path . --check-only --script <res://path.gd>`.
The tests exercise real Godot physics, shared commands, synthetic local input,
camera angle bounds and spring collision, and interaction ownership/cancel/resume/
obstruction/completion. The camera regression additionally samples 336 wall/corner/
obstacle orbits at 1280×720, checking conservative camera/near-plane bounds against
character meshes and solid yard geometry, visibility flags, arm retraction and
continuous small open-space orbit steps. Frustum checks also require the character
center to stay in view, including complete arm collapse. These are geometric/physics checks, not
rendered screenshots or a guarantee for unsampled geometry/viewports.
They do not establish physical keyboard/mouse behavior,
comfortable camera control, visuals or rendering performance.

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

The later wall-front orbit case exposed a separate camera/character overlap despite
the generally passing wall collision. Do not interpret the reports as approval of
the corrected camera's framing or complete absence of clipping at every angle.

## Camera clearance fix

The original spring origin was at torso/head height (1.5 units), inside the visible
1.8-unit character. The character is excluded from the spring's world collision
query; a wall could therefore retract the camera into the character. Including the
character in that query would start the sweep inside its own collider.

The scene now places the pivot at 2.1 units, 0.3 above the capsule's top. With the
existing pitch limits, this keeps even a fully compressed camera outside the mesh.
An explicit 0.2-unit sphere protects the camera origin and near plane during world
collision sweeps; the default camera-shaped probe could leave the camera origin
slightly inside a wall. The existing arm length, margin, yaw/pitch controls,
character visibility and collision exclusions are retained. The follow camera aims
at the existing character body center after the spring update, keeping it framed
when the raised pivot is compressed. A yaw-relative up vector handles the vertical
view at zero arm length without a look-at singularity. There is no minimum-arm
clamp that could push the camera through a wall, no mesh hiding, new camera mode,
or new smoothing/input behavior. A path above a 2-unit wall may use full arm length
when clear; it must not intersect the wall. The yard and movement are unchanged.

These clearances are provisional for the current capsule, facing marker, FOV and
pitch range. Recheck them if character geometry, camera FOV/aspect or the world
changes; this is not a general arbitrary-character/low-ceiling camera solver.
The existing spring collision test now aims down toward the wall because its
previous horizontal ray clears the 2-unit wall from the raised pivot.

## Graphical recheck required after the fix

On Windows with Godot 4.7.2, using this fix branch:

1. Press the character against every wall, then orbit to its front and through a
   full circle at low/middle/high pitch. Repeat at corners and the central obstacle.
   Confirm the camera/near plane stay outside both character and world, the character
   remains rendered, and the new framing is usable without jitter or sudden jumps.
2. Move toward/away from walls while orbiting; verify smooth retraction/extension
   and unobstructed following. Check visibility when the camera passes above a wall.
3. Recheck basic WASD and E start/release/resume/completion plus Escape/click after
   the camera adjustment. Explicit window-focus loss, walking-away cancellation,
   dedicated diagonal/perimeter checks and single-completion behavior were not
   separately confirmed in the latest user report; record them if tested.
4. Record actual results/debugger messages. Measure FPS/frame times/RAM separately
   before making performance claims; headless geometry checks cannot establish them.

No graphical display is available to the agent. The fix has automated clearance
coverage but has not yet been visually accepted on Windows. Do not start M2 as
part of the camera fix or its verification.
