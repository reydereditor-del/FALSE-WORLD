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
camera sensitivity 0.003 radians/pixel, pitch -65°…20°, spring length 4 units.
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
godot --headless --path . --quit-after 120
```

The built-in GDScript runner exits nonzero on failed expectations and prints its
check/failure totals. Inspect output for script/engine errors as well as exit status.
Import and instantiation cover scene/resource/script validation; individual scripts
can additionally use `--headless --path . --check-only --script <res://path.gd>`.
The tests exercise real Godot physics, shared commands, synthetic local input,
camera angle bounds and spring collision, and interaction ownership/cancel/resume/
obstruction/completion. They do not establish physical keyboard/mouse behavior,
comfortable camera control, visuals or rendering performance.

In the cloud, export writable locations before these commands:

```sh
export XDG_CACHE_HOME=/workspace/.cache
export XDG_DATA_HOME=/workspace/.local/share
export XDG_CONFIG_HOME=/workspace/.config
```

Godot editor import needs its local sockets permitted by the execution sandbox.
No network service or external dependency is required by this prototype.

## Manual verification still required

Use a graphical Godot 4.7.2 session, preferably on the target Windows Intel i5 /
16 GB / integrated-graphics laptop. Record OS/driver, renderer, resolution and results:

1. F5 opens the yard with visible character, obstacle and lever. Walk all four
   directions, diagonally and into the central box/perimeter; ground remains solid.
2. Orbit while stationary/moving, reach both pitch limits and approach walls from
   several angles. Check camera visibility, clipping, sensitivity and framing.
3. Approach lever, hold E partway, release, wait, and resume to completion. The handle
   must retain partial rotation and finish once. Try from too far away and through
   the central obstacle; no work should advance. Restart the scene for repeat runs.
4. Walk away during work; Escape/focus loss during work must stop it without losing
   progress. Click to recapture and confirm normal movement/work resume.
5. Check Godot debugger/output for runtime errors and measure actual frame times/RAM
   before making performance claims. Headless checks cannot replace this playtest.

No graphical display or Xvfb was available in the implementation environment, so
these scenarios remain unrun. Complete this M1 verification before advancing to
another milestone. Do not begin M2 under the M1 task.
