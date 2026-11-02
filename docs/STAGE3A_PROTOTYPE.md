# Stage 3A — local AI foundation

This is the first foundation slice of handoff §19 stage 3, not a completed deception
proof or a new gameplay milestone. One human and exactly three local agents share
the M1 motor, capsule, blue model and facing marker. The small inherited M1 yard,
obstacle, lever and controls remain available. No dialogue, deception, combat,
inventory, objectives, mobs, extraction, networking, runtime AI service or new UI.

## Run

Use Godot **4.7.2 standard / GDScript**. F5 now starts Stage 3B.1 observation decisions; see
[STAGE3B1_PROTOTYPE.md](STAGE3B1_PROTOTYPE.md). F6 on
`scenes/prototype/stage3a_local.tscn` runs the retained original foundation.
The original `scenes/prototype/m1_graybox.tscn` remains standalone for F6/M1 checks.
From repository root:

```sh
godot --path . res://scenes/prototype/stage3a_local.tscn
# Original local M1 slice:
godot --path . res://scenes/prototype/m1_graybox.tscn
```

Verify `godot --version` is 4.7.2. In this cloud environment use the explicit binary
`/workspace/.tools/godot/4.7.2/Godot_v4.7.2-stable_linux.x86_64`; the default binary
may be older. Writable XDG paths are documented in M1_PROTOTYPE.md.
WASD, mouse orbit, E hold/release, Escape and click-to-recapture are unchanged.
Agents patrol authored ground waypoints; they do not pursue the human, operate the
lever or make deception decisions. Their IDs exist only in local composition/data,
with no role badge or separate visible model. These are stable local tracking IDs,
not a visual-ID recognition system or human-role inference. This is not a full
match/identity UI.

## Modules and knowledge boundary

- `scenes/character/shared_character.tscn` contains the exact M1 mesh, materials,
  capsule collision and existing `CharacterMotor`. M1 and all AI instance it.
  Physics, camera, input and interaction behavior is preserved. Stage 3A.1 adds an
  optional visual turn rate to the shared motor; zero keeps the legacy behavior.
- `waypoint_controller.gd` supplies world-space intent to that motor, following a
  built-in NavigationAgent3D path. A seeded starting index and cyclic waypoint order
  provide repeatable decisions. Static world geometry is known to navigation;
  other characters' live state is not a planner input.
- `local_perception.gd` is the only sensing adapter with candidate node references.
  It gates observations by range, facing cone and a physics ray to the target torso.
  Only successful samples enter that observer's separate `LocalMemory` and emit facts.
- `local_memory.gd` stores bounded copied value snapshots. The only fields are
  observer, subject, event (`seen`), position, simulation tick, confidence, source.
  No HP, inventory, intention, role or mission state. Future/stale/malformed facts
  are rejected; newer facts supersede old, and equal-time local vision is preferred.
  Snapshot callers receive independent copies. Last-seen does not follow a moving
  target and expires using the supplied simulation tick, not wall-clock time.
- `observed_fact_channel.gd` receives only registered perception signals matching
  that sensor's local observation. A bounded queue delivers a copied report after
  its configured delay to one configured peer, not a global blackboard. Current
  routing is a ring K72 → B14 → D09 → K72. Reports are not rebroadcast; recipient/
  observer self-reports are skipped. Repeated sightings keep the original queued
  snapshot/due time, so fresh facts cannot bypass their delay or starve a pending
  report. Original observer, position and observation time survive delivery;
  `source` becomes `team_report`. Recipient freshness is checked at receipt.
- `stage3a_local.gd` composes exactly three agents, injects the seed/settings and
  advances a monotonic physics-tick clock. It staggers sensing/planning among agents;
  the planner does not consult the scene registry or human transforms. There is no
  strategic Director, chat adapter or decision based on received facts in 3A.

These are code boundaries inside a trusted local process, not a security sandbox or
network protocol. Keep future decision logic off candidate/world references. Source
reports are observations, not authority truth. No match/team-role disclosure is
rendered to the player.

## Navigation and update budgets

A checked-in `stage3a_navigation.tres` is baked using Godot's static-collider parser
and Recast bake from the inherited M1 yard. Dynamic character bodies are excluded.
The mesh has 24 polygons. Agent bake radius 0.5 provides clearance for the shared
0.35 capsule; height 1.8, max climb 0.2 and slope 45° are provisional. Physics still
rejects movement independently. No jump, teleport or collision bypass is used.

Regenerate after editing static M1 geometry, from repository root:

```sh
godot --headless --path . --script res://tools/bake_stage3a_navigation.gd
```

The baker saves only the navigation resource. No runtime bake, plugin or new
package is required. The small static mesh is not a full-map navigation solution.
Avoidance/RVO is disabled: dynamic actors stop through ordinary physics. A stuck
agent retries its route twice, then abandons that waypoint instead of retrying
forever. Path-following runs each physics tick, with route selection and perception
scheduled at the lower cadence below. Native path queries update when needed.

All settings remain provisional and testable. Stage root exports seed 431, update
interval 15 ticks, report delay 30, memory lifetime 300, memory capacity 8, queue
capacity 12, sight range 8 and FOV 120°. At the default 60 physics ticks/s this is
4 Hz per agent, 0.5 s report delay and 5 s freshness. Three phase offsets spread
updates (one sensor per due tick); each sensor inspects at most four candidates.
Configure exported settings before starting/restarting the scene. The queue
attempts at most one report delivery per physics tick; backlog may add delivery
latency beyond the configured minimum delay. Agents use the
same motor speed 4, gravity 18 and physical constraints as the human. Seed/time
control makes rule decisions repeatable, not cross-platform deterministic physics.
No Intel-iGPU FPS/RAM result is inferred from these budgets.

## Automated checks

```sh
godot --headless --path . --editor --import
godot --headless --path . --script res://tests/stage3a/test_foundation.gd
godot --headless --path . --script res://tests/m1/test_graybox.gd
godot --headless --path . --script res://tests/m1/test_camera_clearance.gd
godot --headless --path . --fixed-fps 60 --quit-after 600
```

Tests must finish with their counts and exit 0; inspect for engine/script errors too.
Stage 3A tests actual path traversal around the central obstacle, common physical
limits, LOS/range/cone rejection, last-seen expiry, memory isolation/capacity,
delayed selective sharing, queue overflow and bounded work/retries. Pure memory/
channel checks inject ticks; integration uses the real Godot physics world.
The startup command runs 600 fixed simulation frames, not a performance benchmark.

## Reported M1 status and graphical checks still needed

The user reports the latest M1 camera no longer has extreme magnification and that
M1 movement, collision, interaction and camera controls passed the reported manual
checks on Windows/Godot 4.7.2. This is user-reported evidence, not an agent rerun.
Remaining camera occlusion is not claimed solved: world geometry or characters can
still obstruct the view. No FPS, frame-time, GPU or RAM measurement was supplied.

Stage 3A itself has not been graphically verified. On Windows/Godot 4.7.2:

1. Start Stage 3A; confirm three additional identical blue characters walk around
   the yard without clipping the central obstacle, floor or perimeter.
2. Move the human near/through patrol routes; inspect physical blocking, recovery,
   camera occlusion/framing and debugger errors. Test human controls and the lever.
3. Run the automated suite for the nonvisual memory/report invariants; no fake
   knowledge/debug UI has been added. Do not infer deception or human-like behavior
   from patrols or test facts.
4. Record actual visual findings and separately measure target-laptop FPS/RAM before
   scaling up. Full dialogue/deception, dynamic crowd avoidance, longer-run path
   behavior and performance are not established by headless tests.

Next: validate this 3A slice graphically and fix demonstrated foundation defects.
Only a separately authorized Stage 3B task may add the next scoped decision/dialogue
proof; the complete 1-human/3-AI deception proof remains unfinished.
