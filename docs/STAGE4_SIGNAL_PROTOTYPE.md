# Stage 4 — first signal-device objective loop

A **local single-route prototype**, not the complete handoff Stage 4 milestone or
full game. F5 now starts `scenes/stage4/signal_loop.tscn`, inheriting the unchanged
visual vertical slice. One human and the existing three AI remain; no combat, HP,
multiplayer, general inventory, loot, mobs, scoring, spectator or full extraction meta.

## Scope and handoff compatibility

This task explicitly requests **one test component**. Here it is a service module,
held in one ownership slot and applied when activation work completes. This is a
scoped simplification, **not a replacement** for the final signal station's battery
plus radio module, installable in either order. The final game still has two
independent human rescue routes. The mountain route is not implemented in this stage;
reaching its summit still does not win. `FALSE_WORLD_HANDOFF.md` and GAME_DESIGN
remain unchanged. Full Stage 4's other planned systems are not implicitly authorized.

The final rescue concept is respected within this slice: sending a call is followed
by a wait; leaving does not cancel it; the player must be in the pickup yard at arrival;
AI presence does not block success; an empty arrival rescues nobody and allows a
new call without consuming another component. There is no transport animation,
actor removal, spectator or persistent victory record. Success is explicitly a
local prototype result, not the completed full-game extraction implementation.

## Gameplay flow and controls

1. Start at the improved storehouse entry **(200,0.1,133)**. Find the labeled service
   module on the existing workbench inside at **(194.3,1.23,118.1)**. The nearby BoomBox
   remains decorative clutter; the smaller labeled module is the objective item.
2. Approach the module from the clear side (for example X 195.8, Z 118.1). Hold **E**
   briefly to collect it. The world item disappears once; feedback confirms ownership.
3. Walk outside to the labeled signal control panel at **(230,1.15,124.56)**, on the
   front of the cabinet beside the radio mast. A clear approach is **(228.8,0,125.8)**;
   avoid standing inside the mast at (230,126).
4. Hold **E for 4 seconds of total work**. Releasing E, Escape/focus loss, moving out
   of range or losing line of sight interrupts immediately. Progress stays on the
   device. The carried module is neither consumed nor duplicated during interruption.
   Resume holding E to finish; the physical control lever moves with real progress.
5. Completion installs the module on the cabinet, sends one call and starts a
   **5-second wait**. It is not instant victory. Release E and walk into the outlined
   **10×10 m pickup yard centered at (220,0,140)**. Go around the existing station sign:
   the clear path via **(220,0,132)** then toward the yard avoids its solid board.
6. At arrival, being inside the marked yard produces **PROTOTYPE EXTRACTION COMPLETE**.
   The banner lasts 6 seconds, then becomes “Prototype run complete.” The result is
   emitted once. Movement and other actors continue; no full match lifecycle is added.
7. If the player is outside the yard at arrival, no success is granted. The module
   stays installed; return to the device and complete a new 4-second call, then wait
   in the yard again. There is no second component search for repeat calls.
8. **R** restarts the whole local prototype scene, returning to the entry with one
   fresh world module, three AI and clear progress/result state. This explicit test
   restart is not an in-world way to cancel a sent call or a final-game mechanic.

All durations, positions and counts are provisional prototype tuning, not approved
final balance. The rest of the controls remain unchanged: WASD relative to camera,
mouse orbit, Escape release/stop, click recapture, focus loss release/cancel. F3 remains
the existing off/default editor-debug diagnostics. The original M1 lever at (216,1,158)
remains reachable and works as its signed test, without completing this objective.

## Implementation boundaries

- `scripts/objective/signal_objective.gd`: value-only state/owner/timer rules
  (`SEARCH → CARRYING → WAITING → SUCCESS`, or `WAITING → READY → WAITING` on an empty
  arrival). One owned component, no item slots beyond that identifier or loot system.
  Installed state persists across calls; success count is terminal for this run.
  Time is injected by the composition, so pure tests do not depend on wall clocks.
- `component_pickup.gd` and `signal_activation.gd`: narrow subclasses of the unchanged
  `WorkTarget`. They reuse its worker lock, range/physical LOS, held work, retained
  progress, cancellation, completion and real lever transform. Pickup claims ownership
  once, only at completion. Activation accepts the carrier (or an installed device
  on a repeat call) and installs/sends only after completed physical work.
- `signal_loop.gd`: explicit scene wiring, nearest reachable selection among three
  authored targets, the existing `CharacterInteractor` and local player controller,
  yard membership, reset and one small local feedback panel. At most three known
  target checks per physics tick; this is not a world scan or new input/movement system.
  The panel refreshes at 10 Hz and sits away from the existing F3 panel. Progress and
  countdown appear only at the relevant target/yard; it shows no actor roster, role,
  AI knowledge or scores. No new InputMap/project controls are required for E or R.
- The yard uses its authored box volume and the player's body position at each tick,
  rather than depending on delayed overlap notifications or any AI presence list.
  The prototype assumes its one local player is alive; there is no HP/death system.
- `scenes/stage4/signal_loop.tscn`: small original module/control/yard meshes, signs
  and inherited visual slice. No new third-party art or texture dependencies. Original
  benchmark scenes/assets, shared humanoid, camera/motor, interactions, all AI modules,
  tests, harness and source navigation are byte-preserved.
- `tools/bake_stage4_navigation.gd` writes only the separate
  `scenes/stage4/station_navigation.tres`. The same 90×90 m local area/agent settings
  produce **267 polygons**, with all ten existing AI sites reachable. Module/panel
  colliders overlap the already-blocked workbench/cabinet; other routes remain open.

The local actor's instance ID binds this single component to its actual worker;
these APIs are not network authentication or client-authoritative requests. A later
multiplayer task must add proper authority/session validation. No existing server,
Director, death/reconnect or secure full-game inventory behavior is claimed.

## AI involvement

The three real AI retain ordinary exploration, physical range/cone/LOS perception,
private memory, delayed selective reports and limited coordination. A player working
at the cabinet can actually be seen there; after losing sight, the existing decisions
may investigate that old witnessed area. The Stage 4 integration test reproduces an
actual cabinet-area sighting → Observe → frozen last-seen Investigate transition.

No objective flag, component possession, call time, unsensed device state or live
human position is injected into AI. Candidate bodies, sensing range, report timing,
strategy and population are unchanged. Agents do not autonomously collect the
component, operate the cabinet, sabotage it or fight. Reactions depend on legitimate
observations and geometry, so they are not guaranteed after every activation. This
is the requested limited connection, not a new omniscient objective AI or full Director.

## Validation

Use Godot **4.7.2 standard/GDScript**. From the repository root:

```sh
python3 tools/run_stage4_checks.py --godot /path/to/Godot-4.7.2 --output /tmp/stage4-checks
```

Cloud: explicit `/workspace/.tools/godot/4.7.2/Godot_v4.7.2-stable_linux.x86_64`, with
writable XDG paths as in the earlier prototype docs. Editor import needs supported
local-socket permission; preserve proxy/TLS and renderer settings.

Fresh completed acceptance:

| Check | Result |
| --- | --- |
| Godot version/import + five new script/tool parser checks | Passed |
| Pure objective rules | **27 checks, 0 failures** |
| Real Stage 4 scene integration | **36 checks, 0 failures** |
| Preserved visual/map/gameplay suites | **306 checks, 0 failures** |
| Total ordinary checks | **369 passed, 0 failed** |
| Unchanged Stage 3D, seed 431/repeat 2 | **16/16 scenarios, 98 assertions, 6,886 audited ticks**, all eight repeat hashes match |
| Stage 4, visual benchmark, graybox and old prototype startups | Passed |

The standard-library launcher delegates to the unchanged existing acceptance runners,
then parses/runs the new tests and starts Stage 4. Subprocesses and GDScript test
loops have finite frame/wall timeouts; nonzero exits, errors, unknown warnings,
missing/incomplete reports and missing test completion fail the gate. The previously
reproduced Jolt job-pool warning remains explicitly recorded, including in old scenes.
No physics settings or old test assertions were altered to hide it.

Pure tests cover invalid/duplicate/concurrent ownership requests, installation only
at a legitimate send, invalid clock deltas, no yard-only/instant success, sent-call
persistence after departure, empty arrivals and retained installation, repeat calls,
single success and temporary banner lifetime. Integration uses the actual new scene,
existing CharacterMotor/CharacterInteractor/WorkTarget and three real AI. It checks
actual entry → module → cabinet → yard walking without teleporting within that full
run, interrupted pickup/activation, range and an added solid LOS blocker, release,
focus loss, moving away while E stays held, retained progress, correct one-time
installation, pending-call duplicate rejection, AI presence at arrival, temporary
feedback, real R scene reload without item/actor duplication and an actual repeat-call
cycle. Poses change only between independent fixtures; no movement speed is increased.
The initially attempted straight line crossed an existing solid sign; the test now
walks its clear side rather than changing the benchmark or loosening arrival assertions.

The handoff's other full-game scenarios (combat, death/loot, sabotage, two-route rescue,
real multiplayer, scoring, spectators, reconnect/deadline ordering and laptop profiling)
are **not implemented or passed** by this subset. There is no per-match failure timer,
randomized search/balanced spawn, transport arrival animation, carried-object hand IK,
general inventory/drop system or persistent extraction meta. Basic empty-arrival
failure/retry and explicit prototype reset are the only supporting flows added.

## Visual evidence and Windows acceptance

Actual runtime [search](evidence/stage4/stage4-search.png),
[waiting](evidence/stage4/stage4-waiting.png) and
[success](evidence/stage4/stage4-success.png) screenshots show the inherited benchmark,
minimal panel and marked yard. These are documentation evidence, excluded from Godot
resources by the existing `docs/evidence/.gdignore`. The capture fixture used real
pickup/hold interfaces with setup poses between stages; it is not a human playtest.

The temporary cloud display again failed Vulkan surface initialization and Godot
fell back automatically to Mesa llvmpipe OpenGL. These inspected fallback images
are not a clean Forward Plus/D3D12/Windows pass, nor proof of visual quality, camera
comfort, FPS/RAM or integrated-GPU performance. Preview initialization errors are
separate from the error-free headless checks. Windows checks still required:

```powershell
Set-Location C:\Projects\FALSE-WORLD
git fetch origin
git switch feat/stage4-signal-loop
$Godot = 'C:\Godot\Godot_v4.7.2-stable_win64_console.exe'
& $Godot --version
& $Godot --headless --path . --editor --import
& $Godot --path . --editor
# F5 starts the objective loop. Explicit alternatives:
& $Godot --path . res://scenes/stage4/signal_loop.tscn
& $Godot --path . res://scenes/visual/visual_vertical_slice.tscn
& $Godot --path . res://scenes/world/map_foundation.tscn
& $Godot --path . res://scenes/prototype/stage3c_coordination.tscn
& $Godot --path . res://scenes/prototype/m1_graybox.tscn
# Full automated set, if Python 3 is installed:
python tools/run_stage4_checks.py --godot $Godot --output "$env:TEMP\false-world-stage4"
```

Use the actual Godot path and preserve any unrelated local changes before switching.
Manual steps: try the device without the module; collect the module; interrupt and
resume activation by release, walking away, Escape and focus loss; confirm progress
and ownership persist. Complete work, walk around the sign into the outlined yard,
and observe one temporary success. Restart with R; deliberately wait outside at
arrival, confirm no success, then call again without searching another component.
Recheck original lever, humanoid animations, F3 on/off, camera corners, visual benchmark
materials, and debugger output. Record commit/Godot/driver/hardware and actual results;
measure target-laptop frame time/FPS/RAM separately. No headless test proves those.

Next: Windows playability/timing/feedback review of this one-route subset. Subsequent
scoped tasks can restore final station battery/radio installation and add the remaining
approved survival systems. The independent mountain route remains a future task.
