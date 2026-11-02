# Stage 3B.1 — observation-driven local decisions

This increment adds a small decision layer to the same 100×100 m graybox and exactly
three agents. It is still a local technical proof within handoff §19 stage 3.
Dialogue, deception, Director strategy, combat, inventory, mobs, objectives,
extraction, networking and new UI remain absent. It does not prove human-like AI.

## Run

Use Godot **4.7.2 standard / GDScript**. F5 runs
`scenes/prototype/stage3b1_observation.tscn`, which inherits the existing Stage 3A.1
scene without geometry, resource, spawn or population changes. Controls remain
WASD, mouse orbit, hold/release E, Escape and click-to-recapture.

```sh
godot --path .
# Retained exploration-only demo:
godot --path . res://scenes/prototype/stage3a1_exploration.tscn
# Retained M1:
godot --path . res://scenes/prototype/m1_graybox.tscn
```

See [STAGE3A1_PROTOTYPE.md](STAGE3A1_PROTOTYPE.md) for map access routes/rebaking,
and [STAGE3A_PROTOTYPE.md](STAGE3A_PROTOTYPE.md) for perception/report rules.
No new presentation/debug panel or role labels are shown to players.

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
prototype guides when working in the cloud. Run all five suites:

```sh
godot --headless --path . --editor --import
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

## Next graphical acceptance

On Windows/Godot 4.7.2, run F5 and confirm three agents explore the existing layout.
Enter one agent's forward view, then move behind a solid building corner; watch it
pause and possibly visit the old location, then resume exploring rather than track
you behind walls. Stay visible and stationary to check that repeated sightings do
not produce repeated pursuit or state chatter. Repeat after moving to a genuinely
new location; agents should vary timing slightly. Other agents may react later to
selective reports, but exact report age/source needs automated checks, not guesswork
from movement. Walk into a path to test ordinary blocking/recovery.

Recheck WASD/camera, E cancel/resume/completion and Escape/click, plus the debugger.
Record turn/stop comfort, corner jitter and camera occlusion separately. No graphical
session, naturalness acceptance, FPS/frame-time/RAM measurement or Windows export
was performed by the agent. Measure target-laptop performance separately before scaling.
