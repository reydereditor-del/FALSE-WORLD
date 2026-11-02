# Map foundation

## Layout proposal (recorded before implementation)

All positions, heights, counts and routes below are provisional layout choices.
The task explicitly brings the 1 km footprint forward; detail and AI stay bounded.

| Zone | World X/Z metres | Layout intention |
| --- | --- | --- |
| Summit | -280 / -260 | 64 m high, broad gentle slopes, 80 m plateau; east and south approaches |
| Old works | -80 / 20 | Roofless concrete shells, broken walls; bypass on both sides |
| Crossroads / water tower | 80 / 40 | Meeting landmark; road loop prevents a compulsory choke |
| Station | 220 / 140 | Open future extraction yard, east and west approaches, no rescue mechanics |
| Station quarter | 220 / 140 ± 45 | Detailed local building cluster, forest edge; only three existing AI |
| Forest | 100 / -110 and 310 / 240 | Bounded clusters, solid trunks/crowns break sightlines, clear lanes |

```text
North (-Z)
  Summit ===== north road ==== forest
    |   \                       |
 west    old works ==== crossroads ==== east loop
 road          \               |            |
    \========== south road === station =====/
South (+Z)                station forest edge
```

The terrain fills X/Z [-500,500], with four physical boundary berm/walls.
No jumping is needed. Mountain rise is spread over ~190 m (about 19 degrees),
with two marked walking approaches. Roads form loops and open terrain allows
additional bypasses. Initial road estimates: station–crossroads ~172 m;
crossroads–old works ~161 m; station–summit via east approach ~760 m.
At the unchanged 4 m/s these imply ~43 s, ~40 s, ~190 s before turns/slopes;
these are estimates, not timed playtests. Tests and exact route lengths follow below.

## Implemented composition

F5 now runs `scenes/world/map_foundation.tscn`. It is a separate editable PackedScene;
all old prototype scenes/navmeshes and runtime modules remain unchanged.
`tools/build_map_foundation.gd` is an explicit authoring tool, not runtime generation.
It writes only the new scene. `MapLayout` in `scripts/world/map_layout.gd` holds
provisional coordinates and matches the terrain's two-triangle cell interpolation.
No new AI strategy or replacement controller is introduced.

The `LocalArea` node is translated to (220,0,140) and uses the existing
`stage3c_local.gd` → 3B.1 → 3A.1 → 3A composition. It creates the real three shared
characters, `ObservationController`, `ExplorationChoices`, `LocalPerception`,
private `LocalMemory`, selective `ObservedFactChannel` and `ReportCoordination`.
Ten local authored sites include the storehouse/workshop interiors. Existing 8 m
sensing, timing, capacity, speed and recovery tuning are retained. No goal points
at the distant summit or reads unknown mission state. AI cover only this quarter;
they do not populate or navigate the rest of the kilometre map.

The human instances the unchanged shared character. The authoring tool reuses only
M1's input, camera and interactor children and real lever, rebinding their explicit
references to this scene. It does not copy the old yard. The camera far plane is
1400 m here to see distant terrain; original camera behavior/rig tuning and all old
scene settings are retained. The working E lever is signed as an M1 workbench test,
not a rescue device. Summit mast and station radio cabinet are static landmarks.
No call, timer, part collection, extraction, victory or new interaction is implied.

`AuthoringMarkers/Start0..3` and `Drop0..3` are editor-only candidates. The fixed
human start is (220,0.1,154), outside the reserved station yard and off devices.
They do not implement loot, critical-item recovery or balanced/random spawning.
The 24×24 m station yard and broad summit plateau reserve future space; both have
independent clear approaches and reaching either has no gameplay outcome.

## Resource boundaries and original art

Inventory from the saved scene before runtime AI creation: **750 nodes, 214 mesh
instances, 200 static bodies, 12,914 visual triangles, one unshadowed directional
light**. Three AI add their existing small character/controller/sensor trees at
runtime. Terrain is one 5,000-triangle static trimesh with a 20 m grid, not a giant
noncolliding backdrop. Nine road meshes follow it; roads do not add raised collision
steps. Four shells have 4 m ground-level entrances. There are 66 low-poly pines in
bounded groves, with trunk/crown collision for real sightline breaks and lanes left
clear. The rest deliberately stays sparse; much is open field, not a detailed forest.
No per-frame geometry generation, full-map scans, dynamic lights, large textures,
addons or external services. These counts are content budgets, not FPS measurements.

Navigation is only the station AABB X [175,265], Z [95,185], Y [-2,12], with 244
polygons: agent radius 0.5, height 1.8, climb 0.2, cell size 0.25, cell height 0.1.
The region cancels its parent's translation because the bake contains world-space
coordinates. Roof surfaces may exist in the bounded bake but are not authored AI
sites; every authored site is verified reachable from the yard. No whole-map navmesh.

All new meshes/materials/signs are original simple layout art. The focused external
asset access comparison and original provenance are recorded in
[assets/ATTRIBUTION.md](../assets/ATTRIBUTION.md). Three original pages returned 403;
no third-party rights or download could be verified, so no external art was imported.
No license or performance claims are inferred from a pack name. Cost: 0 UZS.
Capsules remain identical test representations, not finished characters/animation.

## Authoring, launch and controls

Use Godot **4.7.2 stable standard/GDScript**, not the older default cloud binary.
From the repository root (replace `godot` with the verified explicit executable):

```sh
godot --headless --path . --editor --import
# Only after intentionally editing map authoring data/geometry:
godot --headless --path . --script res://tools/build_map_foundation.gd
godot --headless --path . --script res://tools/bake_map_navigation.gd
godot --headless --path . --script res://tools/build_map_foundation.gd
# Last build attaches the saved navigation resource to the new scene.
godot --path . res://scenes/world/map_foundation.tscn
godot --path . res://scenes/prototype/stage3c_coordination.tscn
godot --path . res://scenes/prototype/m1_graybox.tscn
```

The bake tool saves only `scenes/world/station_navigation.tres`. Rebuild/rebake after
geometry changes affecting that region; do not rebake or stretch old test fixtures.
Generated node/resource IDs may change on rebuild; geometry/coordinates are authored.
Check the intended diff before keeping regenerated files. No regeneration is needed
to launch the committed scene.

WASD walks at the existing 4 m/s, mouse orbits, Escape releases cursor/stops movement,
left click recaptures, and losing focus releases controls. E operates only the signed
M1 lever at (216,1,158); release cancels while preserving partial in-memory progress.
F3 uses the unchanged editor-debug-only overlay under LocalArea, disabled/idle by
default. There are no jump/sprint keys or role-specific visuals.

Cloud: use `/workspace/.tools/godot/4.7.2/Godot_v4.7.2-stable_linux.x86_64` and export
`XDG_CACHE_HOME=/workspace/.cache`, `XDG_DATA_HOME=/workspace/.local/share`,
`XDG_CONFIG_HOME=/workspace/.config`. Permit the editor's local sockets through the
supported command sandbox flow; do not disable TLS or change project settings.

## Validation commands and coverage

```sh
python3 tools/run_map_checks.py --godot /path/to/Godot-4.7.2 --output /tmp/map-acceptance
```

This standard-library runner verifies the exact engine, imports resources, runs both
new tests, all seven unchanged suites, the unchanged Stage 3D GDScript harness with
seed 431/repeat 2 and the documented direct-engine route, plus 1,800-frame startup
runs for F5 map, explicit Stage 3C and explicit M1. Every subprocess has an external
timeout; GDScript tests also have finite budgets and nonzero failure/incomplete exits.
Logs must have no engine/script errors or unknown warnings; test-count completion text
must match, and fresh JSON completion/success and matching scenario repeats are checked.
The exact reproduced Jolt job-pool warning is retained in logs and the summary as
`engine_warnings`; it does not turn passing assertions into failures or hide errors.
`acceptance.json`, `walks.json` and `scenarios/summary.json` are written in the chosen
directory. The existing optional `tools/run_ai_scenarios.py` remains available and
unchanged; the combined runner invokes the same GDScript harness directly so it can
pace the rendering loop at 600 fps with fixed 60 Hz physics.

On Linux the runner limits CPU affinity to at most four CPUs and caps headless render
iterations at 600/s. Unpaced high-speed runs emitted Jolt job-pool warnings in both
new and unchanged legacy scenes. Neither CPU affinity nor pacing reliably eliminated
that warning. They bound test
scheduling, not motor speed, physics timestep, project threading settings or assertions.
The warning remains an engine limitation, not a claimed performance fix. Matching
official engine source uses a fixed job pool and waits/reclaims when it fills; its
underlying trigger here is unresolved. No engine modification or physics override
was made, and the runner records this exact warning separately from errors.

`test_map_foundation.gd` uses the real saved scene, unchanged CharacterMotor, actual
collision and a fixed 1280×720 SubViewport for geometric camera projection. It samples
750 road-centerline positions at <=5 m spacing plus 25 distributed footprint points;
checks a character capsule envelope clear of static obstacles, all eight candidate
markers, four physical bounds, building entrance/corner, forest, both station approaches,
both summit ascent/descent approaches and a terrain triangle seam. Each separate
walk sets up its start once, then uses only normal movement intent until its last
checkpoint; no teleport/speed increase occurs within a measured walk. Per-tick step,
grounding and periodic deep-penetration checks accompany arrivals. A 1 cm support-ray
footprint handles a Jolt ray precision miss exactly on a triangle edge; a continuous
walk additionally tests support across that seam. Four ticks is the maximum allowed
unsupported interval, not a claim of arbitrary terrain coverage.

Camera tests exercise 192 orbit poses at new building corners and mountain slopes,
both pitch limits, world clearance of the near-plane/origin enclosure, self-clearance,
whole-body framing <=80% of either viewport dimension and actual wall retraction.
The working lever also receives real begin/advance/cancel requests.

`test_map_ai.gd` audits 1,200 real autonomous ticks against independent actual
ray/range/cone observation witnesses, private-memory provenance/delay/expiry and queue
bounds. It checks all ten sites, synchronization, each AI's real movement and local
coverage, off/default diagnostics, a real new obstacle causing <=2 retries then
abandonment, the new storehouse's wall occlusion, legitimate observation/delayed
receipt, frozen last-seen point after hidden movement and expiry. Privileged fixture
poses/extra obstacle are test-only; no production policy or tuning was changed.

## Measured travel versus estimates

Fresh Linux/Godot 4.7.2 results (2026-11-02): **40 map checks + 18 new-map AI
checks + all 223 existing checks = 281 checks, zero failed assertions**, plus Stage 3D
**16/16 cases, 98 assertions, 6,886 audited ticks**, seed 431/repeat 2 and all eight
repeat hashes equal. Import/version and all three explicit startup runs passed.
No script/engine errors; the known Jolt warning described above is retained separately.
See [recorded acceptance data](validation/map_foundation_acceptance.json).
Physics tick counts / 60 give **simulated traversal duration** at the real production
motor speed; they are not wall-clock playtest time or a 60 FPS performance result.
Centerline polyline distance and `distance / 4` estimates omit turning, arrival
tolerance, collision and uphill/downhill projection effects. Tests cover finite paths
and samples, not every square metre or every possible camera/actor configuration.

| Continuous walk | Actual distance (m) | Physics ticks | Measured simulation duration (s) |
| --- | --- | --- | --- |
| StationWest | 204.4 | 3066 | 51.10 |
| StationEast | 119.8 | 1797 | 29.95 |
| SummitEast | 584.3 | 8926 | 148.77 |
| SummitEastDescent | 584.3 | 8608 | 143.47 |
| SummitSouth | 579.7 | 8857 | 147.62 |
| SummitSouthDescent | 579.7 | 8539 | 142.32 |
| ForestPath | 133.5 | 2002 | 33.37 |
| BuildingEntrance | 22.8 | 342 | 5.70 |
| BuildingCorner | 37.4 | 561 | 9.35 |
| TerrainSeam | 19.8 | 297 | 4.95 |

Input-polyline estimates at 4 m/s: StationWest 204.9 m / 51.2 s; StationEast
120 m / 30 s; SummitEast 584.4 m / 146.1 s; SummitSouth 577.0 m / 144.2 s;
ForestPath 133.6 m / 33.4 s. These sum endpoint-to-endpoint straight segments and
can undercount intermediate terrain elevation. StationLink 240 m, WorksLink 180 m,
SouthLoop 1,030.9 m and EastLoop 520 m were sampled for support/static clearance,
not continuously walked end-to-end by the test. Other untested off-road routes
remain for manual exploration. The initial proposal estimates above were rough
planning values; this section records the actual authored routes and fresh checks.

Development failures repaired: southern road crossed a solid shell; a junction sign
blocked the extended western station road; copied exported node references and
instance ownership caused a generation error/shutdown leaks. Geometry/wiring/ownership
were corrected, not the old fixtures or motor. The initial report-delay test used
the channel registration API incorrectly and was corrected to match the existing
selective relay. Test start settling was made long enough for a 0.2 m initial drop.
The final tests preserve checkpoint, speed, collision, sensing and framing assertions.

## Visual limits and Windows acceptance

A temporary Xorg dummy display allowed actual software-OpenGL images of the initial
player view, station cluster and whole footprint. Inspected road/terrain continuity,
recognizable shells/groves, character representation and sparse layout; these remain
early geometry, not final art. The unchanged default Forward Plus launch could not
create the required Vulkan surface extension and **automatically fell back** to
Mesa llvmpipe Compatibility; it also lacked a real audio device. No project renderer
or physics setting was changed. This attempted graphical run is **not** a clean
Forward Plus pass, target-driver validation, a traversal playtest or a performance
measurement. Headless acceptance is separate; Windows Forward Plus/D3D12 visuals,
controls, camera comfort, FPS/frame time/RAM and exports remain unverified here.

From Windows PowerShell (use your actual Godot executable path):

```powershell
Set-Location C:\Projects\FALSE-WORLD
git fetch origin
git switch --track origin/feat/map-foundation
$Godot = 'C:\Godot\Godot_v4.7.2-stable_win64_console.exe'
& $Godot --version
& $Godot --headless --path . --editor --import
& $Godot --path . --editor
# F5 launches the map; F6 launches the open scene.
& $Godot --path . res://scenes/world/map_foundation.tscn
& $Godot --path . res://scenes/prototype/stage3c_coordination.tscn
& $Godot --path . res://scenes/prototype/m1_graybox.tscn
# Optional full automated run if Python 3 is installed:
python tools/run_map_checks.py --godot $Godot --output "$env:TEMP\false-world-map"
```

If the local branch already exists, use `git switch feat/map-foundation` instead.
Import `project.godot` through Godot's project manager if preferred. Preserve local
changes before switching branches; do not reset/clean them.

Manual checklist: walk the station yard from west and east; enter both buildings
from either door and orbit at corners; follow the forest path around solid trees;
use the road loops past the water tower/old works; climb and descend both signed
summit routes without jumping; confirm no victory/call controls; test E lever
cancel/resume and Escape/click/focus; toggle/hide developer F3 and check debugger.
Record branch SHA, Godot/driver/hardware, route problems and debugger messages.
Measure laptop performance separately before adding detail/population.

Next scoped work: a **common human/AI rigged visual model and locomotion** with equal
physical capabilities, then station gameplay on this tested layout. Neither is
implemented here. No combat, HP, mobs, parts, extraction, chat, spectators, scoring,
networking, runtime LLM or full Director is introduced by this map task.
