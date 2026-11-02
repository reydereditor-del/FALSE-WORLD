# Stage 3C — limited local coordination

This is a local report-assessment foundation within handoff §19 stage 3, not the
complete deception system. One human and three agents use the unchanged 100×100 m
primitive map, navigation resource, controls and character physics. No Director
strategy, dialogue, multiplayer, combat, inventory, mobs, extraction, runtime LLM,
API, dependency, paid service or asset is added. Cost: 0 UZS.

## Run

Use **Godot 4.7.2 standard / GDScript**. F5 starts
`scenes/prototype/stage3c_coordination.tscn`, inheriting Stage 3B.1 and its F3 overlay.
WASD, mouse orbit, E hold/release, Escape/click and window-focus handling are unchanged.
F3 remains off by default and available only in the editor-feature debug binary.

```sh
godot --path .
# Previous observation-only composition:
godot --path . res://scenes/prototype/stage3b1_observation.tscn
# Original standalone M1:
godot --path . res://scenes/prototype/m1_graybox.tscn
```

See [STAGE3A1_PROTOTYPE.md](STAGE3A1_PROTOTYPE.md) for the retained map/routes and
[STAGE3B1_PROTOTYPE.md](STAGE3B1_PROTOTYPE.md) for direct-observation states and
F3 display semantics/build gate/removal. Earlier standalone scenes remain runnable.

## Report decisions and knowledge limits

The existing ring relay K72 → B14 → D09 → K72 is unchanged: one configured recipient,
30-tick minimum delay, original observer/point/timestamp, no rebroadcast, bounded
queue and recipient memory expiry. It accepts actual sensor observations matching
the observer's private memory. It does not provide current target transforms.

`ReportCoordination` receives only a delivered fact from the agent's private memory,
own position, own movement speed, seed and simulation tick. It assesses age,
distance and remaining time for observation/travel. A valid historical observation
is not proof that someone still occupies that area. There is no new claim of lie
or spoof detection, learned reporter reliability, or knowledge of hidden intentions.

| Assessment | Local behavior |
| --- | --- |
| No relevant evidence / old / distant / insufficient time / already handled | Preserve ordinary exploration and existing route handling |
| Fresh relevant report, recipient already nearby | Brief existing Observe pause, then Resume; no redundant area trip |
| Fresh relevant report with affordable travel | Seeded Observe pause, then Investigate one nearby approach to the old reported area; Resume after arrival/failure/expiry/deadline |
| Eligible direct observation | Prefer the existing direct-observation response over indirect evidence |

The original reported point/time/source remain frozen in selected evidence. The
approach is a separate navigation intent, not a guessed live human position. Newer
reports do not redirect an active response or reset its age/deadline. If the subject
is actually seen locally at the end of the observation pause, the agent resumes
without pursuing a report. All travel uses the same validated NavigationAgent3D
path, shared motor, speed, collision, steering and finite blocked-route recovery.

This is limited coordination through selective information and complementary local
area responses. There are no assignments, acknowledgements, global planner/leases,
shared live target, automatic all-agent broadcast or strategic swarm. Different
actual observations can still prompt independent nearby agents; hard global
concurrency and physical crowd deconfliction are not promised.

## Provisional timing, relevance and work bounds

- Existing 15-tick staggered decisions, 300-tick memory lifetime, 30-tick report
  delay, eight-entry default private memories and 12-entry report queue remain.
- New response acceptance requires report age below 120 ticks and distance within
  the existing 12 m response range. Old facts may remain in memory without being
  useful for a new response. An accepted response still expires at its original
  300-tick lifetime; the 120-tick threshold is an acceptance threshold.
- A conservative pause allowance, estimated travel at own normal speed and a
  30-tick reserve must fit before expiry. The actual baked path length is checked
  at travel entry against remaining lifetime and the existing investigation timeout.
  It uses the existing validation query, not an additional query or speed advantage.
- Nearby threshold 2.5 m; approach radius 1.5 m. Consecutive agent seeds select one
  of three sectors around the report and add 15/30/45 ticks to the existing seeded
  45–90-tick observation pause. Seed profiles are simple provisional variation,
  not a new capability tier or guarantee for a larger population.
- Existing global cooldown, 900-tick subject/location suppression and at least
  3 m changed evidence prevent repeated visits. New timestamps alone do not bypass
  suppression. Failed offsets do not trigger a loop of alternate path requests.
- At most eight facts/assessments per eligible decision phase, one path validation
  on investigation entry and the same at-most-two stall retries. During committed
  responses no new report assessment/goal selection occurs. Rejected reports can
  be cheaply reassessed at the existing cadence if own travel changes relevance.
- All values remain configurable prototype tuning. At 60 physics ticks/s, 120 ticks
  is 2 s, 300 is 5 s and the reserve is 0.5 s. Timing rules are injected/testable;
  cross-platform bitwise physics determinism is not claimed.

An offset may fall inside/behind solid geometry or require an unaffordable detour.
Validation rejects it once, then the existing response/cooldown returns to exploration.
There is no offset-search loop, teleport, wall bypass, expanded map or extra agents.

## F3 coordination explanations

The existing panel adds Coordination decision/reason and the original reporting ID,
report age and an explicit **uncertain last-seen** label. It reads the committed or
most recent local assessment, not the relay queue or another agent's current state.
Selected evidence still shows the old report point; active Nav destination shows
its separate approach. An expired report has no actionable diagnostic coordinates.
A retained inactive nav goal can remain visible with its existing inactive label.

Coordination explanations are read-only; hiding F3 still removes all rendering and
refresh work. No new normal-gameplay UI, role badge, target marker or log is added.
The 10 Hz panel may show a brief state late/miss it; appearance needs Windows testing.

## Automated validation

Select the explicit cloud binary/XDG directories documented in the M1 guide, or
verify the local `godot --version` is 4.7.2. Run all seven suites:

```sh
godot --headless --path . --editor --import
godot --headless --path . --script res://tests/stage3c/test_coordination.gd
godot --headless --path . --script res://tests/stage3b2/test_ai_debug.gd
godot --headless --path . --script res://tests/stage3b1/test_observation_decisions.gd
godot --headless --path . --script res://tests/stage3a1/test_exploration.gd
godot --headless --path . --script res://tests/stage3a/test_foundation.gd
godot --headless --path . --script res://tests/m1/test_graybox.gd
godot --headless --path . --script res://tests/m1/test_camera_clearance.gd
godot --headless --path . --fixed-fps 60 --quit-after 1800
```

The new suite tests actual sensor → delayed relay → private memory → assessment →
physical area visit, plus frozen goals under newer genuine reports, uncertainty in
F3 data, independent recipients, seed/timing variation, expiry/relevance/cooldowns,
counted work, unaffordable detours, unreachable offsets and actual physical blockage.
Fixtures move actors/add a blocker only for testing. Runtime movement never teleports.
See [PROGRESS.md](PROGRESS.md) for exact results; counted work is not a CPU benchmark.

## Next Windows graphical pass

1. Run F5 on Windows/Godot 4.7.2; confirm the same map and three bodies. Toggle F3;
   check existing controls, panel readability, debugger and off/on behavior.
2. Near a solid corner, enter an agent's forward view, then hide during Observe.
   Record its direct evidence point. Watch the ring recipient's Coordination field:
   it may preserve exploration, Pause nearby, or Check area for a delivered report.
3. For Check area, compare Selected evidence (original old point/source/age) with
   Nav destination (nearby approach). Move unseen: neither may follow you. Newer
   reports must not replace a committed goal. Different agents' timing/approaches
   should vary; they must obey the same physical obstacles and speed.
4. Remain stationary/repeat the same report area: it must not repeatedly trigger
   trips. Move to a genuinely different observed place after cooldown or restart
   for a fresh seed. Old/distant/unaffordable reports should preserve exploration.
5. Temporarily block a route; inspect existing Blocked/Recovering then Resume or
   expiry. Some responses legitimately expire before arrival or are rejected by
   path validation. Natural sessions may not reproduce every report case; use the
   automated delay/provenance tests for exact evidence rather than guessing from motion.
6. Hide F3 and recheck WASD, camera/wall framing, E cancel/resume/completion and
   Escape/click. Record commit, IDs, states, sources, ages, coordinates and debugger.

No agent-run graphical/Windows export or measured FPS/frame-time/RAM/CPU result is
claimed. Remaining camera occlusion, static-navigation congestion, repeated seed
profiles at larger populations and target-laptop performance need evaluation.
This increment does not establish human-like behavior or complete deception.
