# Stage 3B.1 — observation-driven local decisions

This increment adds a small decision layer to the same 100×100 m graybox and exactly
three agents. It is still a local technical proof within handoff §19 stage 3.
Dialogue, deception, Director strategy, combat, inventory, mobs, objectives,
extraction, networking and gameplay UI remain absent. Stage 3B.2 adds only the
developer diagnostics below; it does not prove human-like AI.

## Run

Use Godot **4.7.2 standard / GDScript**. F5 now runs limited Stage 3C coordination;
see [STAGE3C_PROTOTYPE.md](STAGE3C_PROTOTYPE.md). F6 on
`scenes/prototype/stage3b1_observation.tscn` retains this observation-only composition,
which inherits the existing Stage 3A.1
scene without geometry, resource, spawn or population changes. Controls remain
WASD, mouse orbit, hold/release E, Escape and click-to-recapture.

```sh
godot --path . res://scenes/prototype/stage3b1_observation.tscn
# Retained exploration-only demo:
godot --path . res://scenes/prototype/stage3a1_exploration.tscn
# Retained M1:
godot --path . res://scenes/prototype/m1_graybox.tscn
```

See [STAGE3A1_PROTOTYPE.md](STAGE3A1_PROTOTYPE.md) for map access routes/rebaking,
and [STAGE3A_PROTOTYPE.md](STAGE3A_PROTOTYPE.md) for perception/report rules.
Normal play shows no AI panel or role labels. F3 deliberately enables developer
diagnostics only when running with the Godot editor debug binary (see below).

## States and evidence

| State | Behavior and exit |
| --- | --- |
| Explore | Existing authored-site navigation/pauses. Eligible fresh evidence can interrupt it. |
| Observe | Ease to a stop for a seeded short pause, retaining one frozen observation. If still directly seen at pause end, resume rather than pursue. Otherwise investigate if the original evidence is still fresh. |
| Investigate | Visit that frozen last-seen point through normal navigation. Never update the goal from newer sightings/reports. Arrival, path failure, deadline or evidence expiry ends the visit. |
| Resume | Brief stationary pause, then return to authored exploration with its existing private visit history. No promise to return to the interrupted destination. |

`ObservationDecisions` is a value-only RefCounted state machine. It receives the
agent's own position, private memory snapshot, injected tick and travel feedback.
It has no scene tree, candidate actor nodes, human position lookup, world registry
or report queue. Only the existing LocalMemory accepts records; the existing channel
still enforces actual observed provenance, selective delayed delivery and original
observation age. The planner never subscribes to another agent's observations.

The existing sensor samples before planning on each agent's staggered phase.
A vision fact stamped with that exact phase tick is direct current evidence;
a team report never counts as current sight. Known teammate IDs are excluded from
response candidates, as permitted by the handoff; this is not a new visual identity
or role-classification system. Other eligible `seen` facts are ranked by recency,
then proximity, within a local response distance. An old point can be investigated
after LOS loss; neither the stored position nor its timestamp follows a hidden actor.

Once chosen, evidence is copied and pinned through the whole response. Different
facts do not preempt the committed response. Continuous sight produces one bounded
look, not following. Reports may independently prompt a nearby recipient, but there
is no assignment, broadcast swarm policy, shared pursuit target or strategic Director.

## Repeat suppression and provisional budgets

All values below are prototype tuning, not finalized gameplay:

- Existing 15-tick staggered sampling/planning interval, 300-tick memory lifetime,
  30-tick report delay and bounded private memory/queue remain unchanged. At default
  60 physics ticks/s these are 4 Hz, 5 s freshness and 0.5 s minimum report delay.
- Observe 45–90 ticks; resume 30–45; global response cooldown 180 plus seeded 0–30;
  per-subject/location cooldown 900; investigation timeout 240; range 12 m.
- Same subject needs a newer fact, expired cooldown and at least 3 m displacement
  from its last handled point. New timestamps alone cannot restart stationary loops.
  Another subject at a recently handled location also cannot chain a repeat visit.
- Eight handled-subject records are retained as suppression history, not actionable
  evidence. They are replaced by subject or evicted oldest at capacity; they never
  refresh memory or supply an expired destination. The current three-agent setup
  cannot overflow this with its one non-teammate. Larger populations need reassessment.
- The selector inspects at most eight memory facts and eight suppression records per
  candidate. The adapter gates duplicate/high-frequency calls before copying memory
  or touching navigation. Decisions make at most one state transition per evaluation.
- An investigation makes one path-validation query on entry, then reuses the existing
  follower, shared motor, collision, turn-rate limit and finite stall/repath logic.
  Authored exploration still validates at most two candidate paths per plan call.
  Decisions do not read target motion every physics frame.

Seed controls response/pause timing, not arbitrary false beliefs or random attacks.
The same seed/tick/value inputs reproduce decisions; physics is not promised to be
bitwise deterministic across platforms. Configuration is applied before scene start.
Timeout/expiry can end travel before reaching a long detour. Static navigation and
lack of dynamic RVO still allow temporary body blocking. No measured CPU/FPS claim
follows from these operation limits; 22–25-agent support remains unestablished.

## Automated validation

Use the explicit 4.7.2 binary and writable XDG directories documented in the older
prototype guides when working in the cloud. Run all six suites:

```sh
godot --headless --path . --editor --import
godot --headless --path . --script res://tests/stage3b2/test_ai_debug.gd
godot --headless --path . --script res://tests/stage3b1/test_observation_decisions.gd
godot --headless --path . --script res://tests/stage3a1/test_exploration.gd
godot --headless --path . --script res://tests/stage3a/test_foundation.gd
godot --headless --path . --script res://tests/m1/test_graybox.gd
godot --headless --path . --script res://tests/m1/test_camera_clearance.gd
godot --headless --path . --fixed-fps 60 --quit-after 1800
```

The new suite combines seeded state-machine checks with actual LOS, channel delivery,
physical travel to a remembered point, stale delivery, unreachable rejection and a
physical blocker. It tests state/cooldown/expiry gates and counted work, not CPU
latency, human-like appearance, rendered visibility or hardware performance.
The test moves actors/creates blockers only in its isolated fixture; runtime agents
use no teleport or movement advantage. See [PROGRESS.md](PROGRESS.md) for actual results.

## Stage 3B.2 developer diagnostics

The user reports that Stage 3B.1 movement, observation behavior, navigation, controls
and interactions appear functional on Windows/Godot 4.7.2. They could not conclusively
distinguish a last-seen investigation from exploration behind a building. This is
user-reported evidence, not a confirmed behind-wall investigation or performance pass.

Run this scene with F6 (or current Stage 3C with F5), then press **F3** to show/hide the developer panel. Keyboard
repeat is ignored. It starts hidden and does not capture the mouse, pause the game,
or change WASD, E, Escape or click controls. There are no 3D markers. Each of three
blocks shows:

- Own internal agent ID, actual Explore / Observe / Investigate / Resume state.
- Actual navigation destination, or none before a path has started. A destination
  can be retained while Waiting; it is labeled retained/inactive, not an active trip.
- Latest available direct observation: observed subject ID, point and original age
  in simulation seconds. It may concern a teammate rather than the selected subject.
  “Latest sample” means direct vision in the most recent scheduled decision/sensing
  phase, not continuous live tracking; “last-seen memory” means an older sample.
- Selected evidence source (Direct vision / Delayed team report / None), original
  age and frozen point. This is separate from the latest direct observation. A newer
  report can replace a direct memory entry; an unexpired selected direct snapshot
  remains available for diagnostics without creating a separate observation history.
- Navigation status from existing executor flags: Waiting (no active travel),
  Blocked (stall counter is nonzero), Recovering (route retry count is nonzero),
  or Moving (active travel without those flags). These are sampled execution flags,
  not a new collision detector. Recovering can persist while a retried route moves.

Only already observed facts/private memory and the agent's own navigation/decision
state are read. The panel reads no target transforms, actor registry, pending report
queue, hidden role, health, inventory or intention. Expired direct/frozen evidence
points are omitted; selected evidence can remain labeled expired briefly during
Resume. A retained inactive nav goal can still show the old point, clearly labeled.
The display refreshes at 10 Hz, so a brief transition may appear late or be missed.
It does not alter AI timing, re-sense the world or issue path queries.

F3 is available only when both the editor feature and debug-build feature are present.
Exported debug/release game binaries lack the editor feature and cannot enable this
panel. The gate is not an anti-tampering boundary for someone running/modifying the
editor binary. Hiding destroys panel/timer nodes, clears text and stops all refresh
work; only the developer key listener remains. No frame polling runs even while
shown. Export gating has feature-combination tests; an actual Windows export has
not been produced/tested here.

The removable module is `scripts/debug/`; one CanvasLayer child/script resource in
`stage3b1_observation.tscn` connects it. Removing that child/resource (and updating
load_steps) removes the diagnostics from production composition. The small
`LocalMemory.inspect(now)` query copies fresh facts without expiring or mutating
storage; it exists because ordinary `snapshot()` performs expiry and must not be
used to change knowledge timing from a renderer.

## Windows graphical validation steps

1. Import this branch with Godot 4.7.2 and run this scene with F6. Before F3, confirm there are no AI
   diagnostics. Press F3 once: three ID blocks should appear; holding F3 must not
   flicker. Recheck mouse orbit/WASD while shown. Toggle off: all text/background
   should disappear, with controls continuing. Check the debugger.
2. Find an agent near a building corner. While it is Explore, enter its forward view
   within the existing 8 m sight range. Identify the ID block changing to Observe;
   record Selected evidence = Direct vision and its frozen point. The Last direct
   age should be near zero while actually sampled, and can update independently.
3. Immediately walk behind a solid wall while that Observe pause is active. Stay
   within plausible viewing distance so this tests wall occlusion, not only range.
   The relevant Last direct point should stop updating and its age increase. A new
   teammate sighting may replace the displayed latest direct fact; use the selected
   evidence's frozen point/source to follow this response.
4. Watch that same ID switch to Investigate. Its active nav destination should be
   close to the recorded frozen point (navmesh projection may adjust it slightly).
   Continue moving out of sight: the active goal and selected point must remain
   fixed. Compare against Explore trips to authored places; state + selected source
   establishes which trip you are watching. Arrival/timeout/expiry should lead to
   Resume, then Explore; continuously visible stationary sightings should not loop.
5. Watch other ID blocks for Delayed team report. They should never label received
   reports as their own direct sight. Default report delay is at least 0.5 simulation
   seconds; displayed age is measured from observation, not delivery. Natural timing
   may not produce this case reliably; use automated provenance/delay tests for proof.
6. Temporarily block an active route. Watch existing Blocked/Recovering flags and
   bounded return to another state/route, without crossing solids. Short stalls and
   deadlines can end before every label is visible; the physical regression tests
   check the complete sequence with injected timing.
7. Recheck E hold/release/cancel/resume/completion and Escape/click with F3 on/off.
   Record branch commit, observed states/coordinates/ages, debugger messages and
   any text clipping/readability issues at the laptop's window size/resolution.

An Observe → Resume transition without Investigate is not automatically a failure:
continued direct sight or expired evidence can legitimately end the response. Repeated
attempts at the same point are suppressed; retry from a sufficiently different
observed location after cooldown, or restart the scene for a fresh seeded session.
Debugging never forces a response or bypasses those rules.

The agent's headless tests cover adapter fields, actual F3 dispatch, visibility/timer
lifecycle, read-only queries, wall LOS loss, source/age, frozen goals, expiry, state
transitions and physical recovery. They do not establish pixel rendering, layout,
keyboard feel, Windows export behavior, camera occlusion, natural-looking AI or
FPS/frame times/RAM. The user report above is scoped to the preceding 3B.1 session;
this new panel still needs graphical acceptance. Measure performance separately.
