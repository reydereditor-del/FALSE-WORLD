# Stage 3A.1 — authored exploration and varied movement

This replaces the default rectangular patrol demo with a 100×100 m authored
primitive test area and three independent exploration controllers. It is still a
local navigation/perception prototype, not a deception game, full map or Director.
No dialogue, combat, inventory, extraction, mobs, multiplayer, new UI or dependencies.

## Run and controls

Use Godot **4.7.2**. F5 now starts Stage 3C limited coordination; see
[STAGE3C_PROTOTYPE.md](STAGE3C_PROTOTYPE.md). F6 on
`scenes/prototype/stage3a1_exploration.tscn` retains the exploration-only demo.
Original M1 and Stage 3A scenes remain available directly/F6 for regression checks.

```sh
godot --path . res://scenes/prototype/stage3a1_exploration.tscn
godot --path . res://scenes/prototype/stage3a_local.tscn
godot --path . res://scenes/prototype/m1_graybox.tscn
```

In the cloud, use the explicit 4.7.2 binary and writable XDG paths documented in
STAGE3A_PROTOTYPE.md. WASD, mouse, E hold/release, Escape and click-to-recapture
remain unchanged. The original lever/central obstacle remain near the entry plaza;
new buildings and markers are not functional missions or interactions.

## Authored area

The scene contains a 100 m square floor/perimeter, intersecting lanes, three
roofless abandoned-building shells with wide openings, a low-walled courtyard,
open corners and four rubble blocks. All geometry uses original Godot boxes and
shared rough materials, with the existing unshadowed light. No imported assets.

| Area | Approximate center (x, z), metres | Access |
| --- | --- | --- |
| Entry plaza | (0, 5) | Original human/lever; central crossroads |
| West depot | (-22, -18) | North/south door gaps and east opening |
| East workshop | (22, 14) | West and north openings |
| North ruins | (16, -26) | Multiple broken-wall gaps |
| Low courtyard | (-20, 23) | Open north approach and side access |
| Open junctions/lookouts | Outer lanes and corners to ±35 | Connected exterior paths |

Sixteen Marker3D destinations define static places and their area/purpose metadata
(`transit`, `investigate`, `observe`). They are editor markers, not in-game UI.
“Investigate” means walking to a location and pausing to observe; it does not create
loot, search interactions or a new gameplay system. Roofless shells avoid adding
untested low-ceiling behavior to the existing third-person camera.

## Movement and decision boundary

`ExplorationChoices` consumes only authored sites, the agent's own position, seed,
time and private visit history. It ranks novelty, area change and travel distance,
with seeded variation. The last two visited sites are excluded when enough sites
exist; failed locations have a 900-tick cooldown. This replaces the fixed rectangle
without following an arbitrary random direction each frame. No human transform,
private state, memory report or team strategy is passed to destination selection.

`ExplorationController` alternates travel and wait-observe states. Each agent has a
seeded initial pause and independently varied dwell times; transit pauses are short,
observation stops longer. Perception continues during waits. At most two candidate
paths are validated on a staggered decision update. Off-mesh/disconnected goals are
rejected; stalled travel retries twice, then abandons/cools down that destination.
When no site is currently eligible, the agent waits instead of spinning/requerying.

Movement follows NavigationAgent3D paths through the existing CharacterMotor, with
bounded intent blending and arrival slowdown. Visual facing uses a configurable
angular speed. Shared motor `facing_turn_speed = 0` retains the original M1/legacy
facing behavior; only new exploration agents opt into limited turning. Speed 4,
gravity, capsule, floor/solid collisions and absence of jumping are unchanged.
No teleport, distance shortcut, collision bypass or faster-than-human movement.

Range/cone/LOS perception, independent memory and delayed selective fact sharing
are unchanged. Navigation knows static layout, not unsensed human state. This is
place visitation with observation pauses, not dialogue, deception or pursuit.

## Provisional budgets and rebaking

The checked-in static navmesh has **214 polygons**; cell size 0.25, bake radius 0.5,
height 1.8, max climb 0.2 and slope 45° retain Stage 3A settings. All sixteen sites
are reachable in the automated path check. Three actors remain the limit here.
There is no expensive crowd simulation or dynamic RVO. Dynamic blockers can still
cause waits/retries, and abandonment is recovery rather than a guarantee of progress.

Defaults: seed 431 plus per-agent offsets; staggered 15-tick decisions; initial
pause 15–90 ticks; base dwell 45–180 ticks, shortened for transit and lengthened for
observation; visual turn speed 3.5 rad/s; intent response 5/s. Existing sensing,
memory and report budgets remain unchanged. Settings are provisional and configured
before scene startup. The bounded modules can be reused later, but 22–25-agent or
full-map performance has not been established.

After editing static exploration geometry, run:

```sh
godot --headless --path . --script res://tools/bake_stage3a1_navigation.gd
```

This saves only `stage3a1_navigation.tres`; the original M1/Stage 3A navigation
resources and scenes remain preserved. The map is authored, not runtime procedural.

## Validation and graphical acceptance

```sh
godot --headless --path . --editor --import
godot --headless --path . --script res://tests/stage3a1/test_exploration.gd
godot --headless --path . --script res://tests/stage3a/test_foundation.gd
godot --headless --path . --script res://tests/m1/test_graybox.gd
godot --headless --path . --script res://tests/m1/test_camera_clearance.gd
godot --headless --path . --fixed-fps 60 --quit-after 1800
```

Automated checks cover reachable sites, seeded choices/dwells, varied departure
and destination selection, actual obstacle detour, limited turning/speed, bounded
backtracking, arrival stopping, unreachable rejection, physical blockage and finite
recovery. Existing knowledge/memory/sharing tests and all M1 tests remain required.
Fixed simulation frames, path length and turn-rate assertions do not prove natural
appearance, jitter-free animation or Intel-iGPU FPS/RAM. Characters remain primitive
capsules without locomotion animation. No graphical session was run by the agent.

Next graphical pass on Windows/Godot 4.7.2: walk the depot/workshop/ruins openings
and alternate exterior routes; watch all three agents over several visits and
pauses; block their route temporarily; check corners for bumps, oscillation and
abrupt turns/stops. Recheck human controls, lever, camera occlusion/framing and
rendered visibility in the denser area. Record actual debugger findings and measure
FPS/frame times/RAM separately. Tune only demonstrated navigation/turning issues
before authorizing another feature slice. No dialogue or Director work is begun.
