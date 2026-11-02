# FALSE WORLD — progress

Updated: 2026-11-02 (Asia/Tashkent).

## Current status — Stage 3D deterministic AI scenarios and tool evaluation

Completed an isolated Godot/GDScript eight-case scenario harness and an upstream
LimboAI/GUT evaluation. Runtime remains the existing Stage 3C 1-human/3-AI foundation;
no production script, decision tuning, scene, navmesh, control, camera, interaction,
project setting or old test was changed. No full Director, dialogue, new character,
map expansion, multiplayer, combat, inventory, mobs, extraction or paid service.
No addon installed; no native binary/third-party asset imported. Cost remains 0 UZS.
Handoff-approved rules and provisional balance remain unchanged.

Inspected clean `30f6adc`/Stage 3C history, fetched main merge `d9c2da8` (same tree),
read required rules/skills, handoff, design, architecture/progress and all AI prototype
guides, then branched `test/stage3d-ai-scenarios` from that main commit. Prior M1 and
verification history is retained. The task authorizes commit/automatic branch push
and remote-HEAD verification, never merge into main.

## Completed Stage 3D work

- Added `tests/scenarios/{run_ai_scenarios,scenario_fixture,scenario_cases}.gd` with
  Godot-generated UID sidecars. Uses real Stage 3C scene, physical rays/collision,
  native navigation and shared movement, existing private memory/delayed channels,
  coordination and state machine. Fixed initial poses/seeds/clock, explicit assertions,
  finite waits/timeouts, bounded work and independent per-tick evidence provenance
  audits replace visual guessing for these exercised behavior invariants.
- Added compact PASS/FAIL output, JSON event/evidence/state/destination/reason traces,
  semantic repeat hashes and error exits. Optional standard-library Python launcher
  saves logs, rejects missing/incomplete reports/engine errors and enforces an external
  process deadline; direct Godot usage remains supported without Python.
- Added [AI_TESTING_AND_TOOL_EVALUATION.md](AI_TESTING_AND_TOOL_EVALUATION.md): exact
  run/Windows commands, controlled cases/test-only settings/topology, negative controls,
  assertions/results/limits, official navigation/debug guidance, pinned tool support,
  license/third-party obligations, package/source size evidence and adoption decision.
  Updated architecture with isolated test boundaries and the tool rationale.
- Keep existing runtime AI. LimboAI v1.8.1 publishes exact Godot 4.7.2 module builds,
  plus 4.6+ GDExtension support, but native/custom-editor/export coupling does not yet
  justify replacing four tested states. GUT v9.7.1 targets 4.7.x and is a lower-cost
  future test-only trial for fixtures/assertions/JUnit. Neither was installed/run or
  exported here. No nonfunctional demonstration scene is added without its addon.

## Stage 3D checks actually performed

Engine: `/workspace/.tools/godot/4.7.2/Godot_v4.7.2-stable_linux.x86_64`;
`--headless --version` returned `4.7.2.stable.official.ed1daf0bf`. XDG cache/data/config
used `/workspace/.cache`, `/workspace/.local/share`, `/workspace/.config`.
GODOT below means this explicit binary, with permitted local editor socket access.

- `$GODOT --headless --path . --editor --import`: exit 0. All three new GDScripts
  parsed with `--headless --path . --check-only --script res://PATH`: exit 0.
- `python tools/run_ai_scenarios.py --godot GODOT --output /tmp/false-world-stage3d-final`:
  exit 0, **16/16 cases, 98 explicit assertions, 6,886 audited ticks** (eight cases
  twice, seed 431); **all eight semantic hashes matched across repeats**. Actual
  visibility, solid-wall rejection, hidden movement/frozen old goal, delayed receipt,
  independent report recipients, expiry during real travel, finite physical blocker
  recovery and repeat suppression all passed. No unexpected failed/skipped case.
  Per-phase path/decision/assessment and queue/memory bounds are audited, not CPU timed.
- Same launcher with `--seed 432 --repeat 1 --output /tmp/false-world-stage3d-seed432`:
  exit 0, **8/8 cases, 49 assertions, 3,413 audited ticks**, no unexpected failures.
- Expected negative control `--scenario lost_moving --repeat 1 --audit-probe`:
  exit **1**, rejected deliberately forged fixture-only hidden-position evidence with
  `UNSEEN_FACT: no actual observation for K72:F11:21`. `--timeout 0.001` returned
  **124**, recorded `PROCESS TIMEOUT`; `--scenario unknown --repeat 1` returned **2**,
  invalid selector and missing completion rejected. These are successful failure-path
  checks, not passing gameplay scenarios. No runtime decision was altered to pass.
- All seven unchanged suites rerun with `$GODOT --headless --path . --script res://PATH`:
  `tests/stage3c/test_coordination.gd` **35/0**;
  `tests/stage3b2/test_ai_debug.gd` **33/0**;
  `tests/stage3b1/test_observation_decisions.gd` **45/0**;
  `tests/stage3a1/test_exploration.gd` **25/0**;
  `tests/stage3a/test_foundation.gd` **39/0**;
  `tests/m1/test_graybox.gd` **31/0**;
  `tests/m1/test_camera_clearance.gd` **15/0**. **223 checks, 0 failures**, all exit 0.
  Logs `/tmp/stage3d-{coordination,debug,observation,exploration,foundation,m1,camera}.log`.
- Default startup `--headless --path . --fixed-fps 60 --quit-after 1800`: exit 0,
  one initial Jolt job-capacity warning while other validation was running; isolated
  repeat exit 0 with no warning/error (`/tmp/stage3d-startup-isolated.log`). Its cause
  is not established; this is not evidence of target-laptop performance. Standalone
  M1 startup with `--quit-after 120 res://scenes/prototype/m1_graybox.tscn`: exit 0,
  no error/warning. Existing startup-only logic is unmodified.
- During development, an incorrect harness guard expecting engine-consumed
  `--fixed-fps` in `OS.get_cmdline_args()` exited 2; corrected only the test runner.
  Final invocations still supply fixed-fps. No ordinary final scenario failed.
- Reviewed official Godot 4.7 documentation source at `9adca4c`, LimboAI v1.8.1 at
  `e45e60e`, GUT v9.7.1 at `aeb5d4f`, upstream release assets and source archive/font
  license metadata. Website/API proxy 403s were handled using official GitHub source
  and release HTML; no policy bypass. Published compatibility is clearly separated
  from unperformed local addon/Windows/export validation. No dependency installed.

- Standard-library repository validation: exact intended scope (**2 modified + 8 new
  files**), **87 other tracked files byte-preserved** against pre-edit SHA-256 hashes,
  including all runtime/scenes/settings, handoff, rules/skills and old tests. Local
  Markdown links, formatting, skill metadata, script UID pairs/uniqueness, optional
  launcher syntax, no runtime reference to the harness, report totals/repeat hashes
  and retained `6803e0b` ancestry all passed. `git diff --check` passed.

Scenario summaries/full traces are in `/tmp/false-world-stage3d-{final,seed432,negative}/`;
engine/parser/import and failure-control logs are `/tmp/stage3d-*.log`. Artifacts are
cloud-session temporary files, not committed results or shipped gameplay telemetry.

## Stage 3D limitations and exact next step

The fanout fixture uses two existing one-recipient channels, not a production broadcast.
Expiry/stall durations are shortened only in isolated fixtures; repeated-sighting
stress uses actual rays/planning with a stationary body. Real travel, solid collision,
detours and unreachable rejection are covered elsewhere. Work counters do not measure
all native navigation CPU work. Repeat hashes establish semantic repeatability here,
not cross-platform deterministic physics or a general proof against every future leak.

No new Windows/graphical session, addon execution/export, FPS/frame-time/RAM or target
hardware benchmark was performed. Existing reported M1 passes remain user evidence;
remaining camera occlusion and unmeasured performance remain open. The earlier Windows
Stage 3B.1 last-seen travel report was inconclusive; Stage 3D now asserts that path in
controlled headless integration, without claiming graphical acceptance or human-like
behavior. The complete deception system and full Director remain unfinished.

**Exact next step:** on Windows/Godot 4.7.2, import and run the eight-case harness with
`--scenario=all --repeat=2 --seed=431` using the command in the new testing guide.
Save console output/exit code and `summary.json`; require all 16 cases, no engine
errors and matching repeats on that machine. Inspect Linux/Windows trace differences
before changing code/assertions. Then do a short unchanged Stage 3C/F3 and M1 graphical
sanity pass; measure laptop performance separately. Tool installation/migration and
any gameplay expansion require a later scoped task; no next gameplay milestone starts.

## Historical Stage 3C delivery record

The following preserves earlier completion/checks and then-current next steps.
The Stage 3D status/next step above supersedes them.

### Stage 3C limited coordination foundation

The same 1-human/3-AI, 100×100 m prototype now optionally assesses delayed reports
for relevance and affordable area responses. A recipient can preserve exploration,
pause nearby or check a seeded approach around an old reported location. Selected
observation time/point/source stay frozen; no live hidden-human position is supplied.
F3 explains the local decision and legitimate uncertain report source/age.

This remains a small handoff §19 stage-3 foundation, not a completed deception
system. No full Director, strategic dialogue, networking, combat, inventory, mobs,
extraction, additional agents/map, runtime LLM/API, asset, dependency or paid service.
Cost remains 0 UZS. Approved gameplay rules and provisional balance remain preserved.

Inspected clean `7fb372b`, read the authoritative handoff, rules/skills and all current
architecture/progress/prototype documents, fetched main merge `1a11e60`, and created
`feat/stage3c-limited-coordination`. Previous implementation and M1 verification
history is preserved. This task authorizes automatic branch push/remote verification,
never merging into main.

Prior Windows/Godot 4.7.2 Stage 3B.1 report remains scoped: movement, observation,
navigation, controls and interactions appeared functional, but a last-seen trip
behind a building was inconclusive. No new graphical Stage 3B.2/3C or performance
pass is inferred from it. All new graphical acceptance below remains pending.

## Completed Stage 3C work

- Added a value-only local ReportCoordination policy accepting only delivered
  private-memory facts, own position/speed, seed/tick and configured budgets. It
  checks original age, range and time for pause/travel; a legitimate observation
  is explicitly uncertain about current occupancy. No peer state/position, world
  registry, hidden human transform, inventory or intention enters the policy.
- Added nearby pause versus reported-area approach responses, or continued normal
  exploration for old/distant/unaffordable/handled evidence. Eligible direct local
  evidence takes precedence. A separate frozen approach intent does not replace
  the reported point/source/tick in selected evidence.
- Consecutive seeds select three approach sectors and additional response delays.
  The original one-recipient delayed ring remains unchanged; no broadcast, relay
  chain, assignment/acknowledgement system or shared live target is introduced.
  This is limited information-based coordination, not strategic team planning.
- Reused Explore/Observe/Investigate/Resume, private memory, actual LOS, cooldowns,
  eight-record repeat suppression, staggered phases and finite physical recovery.
  New facts cannot switch a committed goal or extend its original lifetime/deadline.
- Added optional true path-length validation to the existing path-start query,
  using remaining evidence time/timeout at normal motor speed. Legacy callers keep
  the infinite default. No second path query, offset-search loop, teleport or
  movement advantage; unreachable/long-detour targets fail and resume exploration.
- Added a tiny inherited Stage 3C scene/composition and startup setting, preserving
  all authored geometry/navmesh and previous standalone scenes. Original observation
  compositions retain a null coordination policy and their previous behavior.
- Extended read-only F3 diagnostics with coordination decision/reason, actual
  reporting ID, original age and an explicit uncertain-last-seen label. The existing
  developer gate, hidden zero-refresh behavior, controls and overlay lifecycle are
  unchanged. Added tests and [STAGE3C_PROTOTYPE.md](STAGE3C_PROTOTYPE.md); updated
  technical/design status and older run instructions. All tuning is provisional.

## Stage 3C checks actually performed

Commands used `/workspace/.tools/godot/4.7.2/Godot_v4.7.2-stable_linux.x86_64` with
`XDG_CACHE_HOME=/workspace/.cache`, `XDG_DATA_HOME=/workspace/.local/share`,
`XDG_CONFIG_HOME=/workspace/.config`. `--headless --version` confirmed
`4.7.2.stable.official.ed1daf0bf`; GODOT below means this explicit binary.

- `$GODOT --headless --path . --editor --import`: PASS, exit 0, clean output
  (`/tmp/stage3c-import.log`), with permitted editor local socket access. Initial
  import also passed; no parser/behavior failure was encountered in this increment.
- `$GODOT --headless --path . --check-only --script res://PATH`: PASS for seven
  changed/new scripts: exploration/observation controllers, observation decisions,
  report coordination, Stage 3C composition, debug adapter and coordination suite.
  Commands/exit codes recorded by `/tmp/check_stage3c_engine.py`; parser logs under
  `/tmp/stage3c-parser-*.log`.
- `$GODOT --headless --path . --script res://tests/stage3c/test_coordination.gd`:
  **35 checks, 0 failures**, exit 0, clean output (`/tmp/stage3c-coordination.log`).
  Initial 35-check run also passed. Covers actual sensor/relay delay/provenance,
  independent memories and selective receipt, fresh/old/future/distant/ETA assessment,
  nearby pause, direct priority, seeded approaches/timing, stationary-loop suppression,
  expiry, capped assessments/cadence, genuine newer reports not retargeting the old
  goal, uncertainty in F3 data, physical approach arrival at shared speed/ground rules,
  true detour budgeting, unreachable offset and finite blocked-route recovery.
- All six existing unchanged suites rerun with the same `--headless --path . --script`:
  `res://tests/stage3b2/test_ai_debug.gd` **33/0**;
  `res://tests/stage3b1/test_observation_decisions.gd` **45/0**;
  `res://tests/stage3a1/test_exploration.gd` **25/0**;
  `res://tests/stage3a/test_foundation.gd` **39/0**;
  `res://tests/m1/test_graybox.gd` **31/0**;
  `res://tests/m1/test_camera_clearance.gd` **15/0**.
  All exit 0 with clean logs (`/tmp/stage3c-{debug,observation,exploration,foundation,m1,camera}.log`).
  **223 checks passed, 0 failed** in the final seven suites; no existing test edited.
  Existing navigation tests exercise the actual preserved mesh/sites/obstacle detour;
  the new suite also exercises the Stage 3C composition and physical report travel.
- `$GODOT --headless --path . --fixed-fps 60 --quit-after 1800`: PASS, exit 0, clean
  current default scene startup (`/tmp/stage3c-startup.log`), 30 simulated seconds,
  not a real-time CPU/FPS benchmark. Explicit standalone M1 startup with
  `--quit-after 120` also passed (`/tmp/stage3c-m1-startup.log`).

- `python /tmp/validate_false_world_stage3c.py`: PASS, exact intended scope
  (12 modified + 8 new files), 69 other tracked files byte-preserved against pre-edit
  SHA-256 hashes, startup-only configuration change, preserved existing path-follower/
  arrival/recovery bodies, tiny inherited scene with no geometry, valid local links/
  resources, UID pairs/uniqueness, skill metadata, empty markers, text formatting,
  clean final engine logs and retained prior history. `git diff --check` also passed.

## Stage 3C limitations and then-current next step

No agent-run graphical session, Windows export or measured FPS/frame-time/RAM/CPU
result was performed. Bounded operation counts and headless physics do not establish
believable movement, visual readability, input feel, camera occlusion or laptop/full
population performance. The F3 panel and new coordination need graphical acceptance.

Fixed ring routing is not relevance-aware Director dispatch. Multiple genuine
observations can still prompt independent nearby agents; there is no global lease,
hard concurrency cap beyond the three-agent setup or dynamic crowd deconfliction.
The three seed profiles repeat at larger populations. Local direct evidence priority
and age/ETA limits are provisional heuristics, not proof of reporter reliability or
current occupancy. Offsets can be invalid; they are rejected rather than endlessly
searched. Static navigation/congestion, evidence expiry during travel and 10 Hz
panel sampling remain existing limits. The complete deception proof is unfinished.

**Next exact step:** in Windows/Godot 4.7.2, run F5 and F3. Enter an agent's forward
view near a solid corner, then hide during its Observe pause. Follow a ring recipient's
Coordination decision/reason and Report source/age: confirm continued exploration,
Pause nearby or Check area is supported by actual delivered evidence. Compare frozen
Selected evidence with the nearby Nav approach; continue moving unseen and verify
neither follows you or changes under newer reports. Check independent timing, expiry,
stationary repeat suppression and physical blocking/recovery. Toggle F3 off and
recheck WASD/camera, E cancel/resume/completion, Escape/click and debugger. Record
commit/IDs/states/ages/coordinates and readability findings; measure performance
separately. Fix demonstrated issues before another explicitly scoped feature task.

## Historical Stage 3B.2 and earlier records

The following preserves prior increments and their then-current limits/next steps.
Current coordination behavior and graphical acceptance are recorded above.

### Current status — Stage 3B.2 developer debugging/validation

Stage 3B.2 adds an off-by-default F3 developer panel to the existing observation
prototype, without changing AI decisions, movement, camera, controls, interaction,
map, navmesh or population. It shows existing per-agent state/goal/knowledge source
and age, plus existing navigation stall/retry flags. It is gated to an editor-feature
debug binary; normal exported games cannot enable it. No dialogue, Director strategy,
combat, multiplayer, inventory, extraction, mobs, extra agents or external dependency/
paid service was added. Cost remains 0 UZS.

User report (Windows/Godot 4.7.2, preceding Stage 3B.1 session): movement, observation
behavior, navigation, controls and interactions appear functional. A last-seen
investigation behind a building could not be conclusively distinguished from ordinary
exploration. This is scoped user-reported evidence, not a confirmed wall-memory test,
new panel acceptance, debugger clean-session claim or FPS/RAM measurement.

Inspected clean checkout `e38b85f`, read authoritative handoff/rules/design/architecture/
progress and relevant development/AI/testing skills and current prototype guide.
Fetched main merge `621b7fb` and created dedicated
`feat/stage3b2-ai-debug-validation`. Prior verification/implementation history remains
preserved. This task authorizes automatic branch push and remote-HEAD verification,
never merging into main.

### Completed Stage 3B.2 work

- Added a small removable read-only adapter and native text overlay under
  `scripts/debug/`, wired through one CanvasLayer in the existing 3B.1 scene.
  F3 toggles it; repeat keys are ignored. All three internal IDs, existing decision
  state, navigation destination, direct observation/age, selected source/age/frozen
  point, and Waiting/Moving/Blocked/Recovering status are shown.
- Latest-sample vision and older last-seen memory are labeled separately. A delayed
  report never becomes direct sight; selected evidence stays separate from the
  latest direct observation. Expired usable points disappear, with selected source
  briefly labeled expired during Resume. Retained inactive nav goals are labeled.
- Added only a nonmutating `LocalMemory.inspect(now)` query. The existing snapshot
  method performs expiry, so using it from a renderer could alter knowledge timing.
  Inspection copies fresh legitimate facts without expiring, refreshing or editing
  storage; no second debug observation history or separate AI logic is introduced.
- The overlay reads only own controller/goal/counters, private memory and selected
  evidence. No human/target transform, scene actor registry, sensor candidate, pending
  report queue, hidden role, health, inventory or intention is read.
- Showing creates a text panel and 0.1 s refresh timer, bounded to three agents.
  Hiding clears/destroys panel/timer and stops all reads/rendering; no per-frame
  polling runs. The developer key listener remains, with no mouse capture or pause.
  No 3D markers were added. Project settings/InputMap are byte-preserved.
- Added focused adapter/UI-lifecycle/behavior tests; updated architecture and the
  existing Stage 3B.1 guide with exact display semantics, removal/build gate and
  Windows reproduction steps. All AI tuning stays provisional and unchanged.

### Stage 3B.2 checks actually performed

Used `/workspace/.tools/godot/4.7.2/Godot_v4.7.2-stable_linux.x86_64`, with
`XDG_CACHE_HOME=/workspace/.cache`, `XDG_DATA_HOME=/workspace/.local/share`,
`XDG_CONFIG_HOME=/workspace/.config`. `--headless --version` confirmed
`4.7.2.stable.official.ed1daf0bf`; GODOT below denotes this explicit binary.

- `$GODOT --headless --path . --editor --import`: final PASS, exit 0, clean output
  (`/tmp/stage3b2-import-final.log`), with permitted local editor socket access.
  First import/test attempt hit a GDScript inference error on a dictionary-derived
  boolean expression in the new adapter. Added an explicit bool annotation. The
  first test ran partially with compile/call failures and was stopped; it was not
  accepted as a completed passing run. Final import and suite below are clean.
- `$GODOT --headless --path . --check-only --script res://PATH`: PASS for all four
  changed/new scripts: local memory, debug adapter, overlay and focused suite.
  `/tmp/check_stage3b2_engine.py` recorded commands/exit codes and four parser logs.
- `$GODOT --headless --path . --script res://tests/stage3b2/test_ai_debug.gd`:
  **33 checks, 0 failures**, exit 0, no errors/warnings (`/tmp/stage3b2-tests-final.log`).
  Tests feature-gate combinations; copied/nonmutating exact-boundary memory views;
  actual F3 dispatch, echo rejection, hidden zero-refresh and UI/timer removal;
  all-agent IDs, visible-panel Escape/click pass-through, control-mode/pause preservation, real LOS loss behind an in-range
  solid obstacle, direct versus historical labeling, delayed selective report source/
  age, no read-induced decisions/path queries, frozen destination despite a newer
  report, expiry/Resume/Explore display, absence of forbidden world/role fields,
  actual physical stall/retry/abandonment and solid collision. Headless UI nodes/
  text and synthetic key dispatch are not a graphical/pixel/comfort test.
- All five unchanged existing suites rerun with the same `--headless --path . --script`:
  `res://tests/stage3b1/test_observation_decisions.gd` **45/0**;
  `res://tests/stage3a1/test_exploration.gd` **25/0**;
  `res://tests/stage3a/test_foundation.gd` **39/0**;
  `res://tests/m1/test_graybox.gd` **31/0**;
  `res://tests/m1/test_camera_clearance.gd` **15/0**.
  All exit 0, clean logs (`/tmp/stage3b2-{observation,exploration,foundation,m1,camera}.log`).
  Final total: **188 passed, 0 failed**. No existing test was edited/weakened.
- `$GODOT --headless --path . --fixed-fps 60 --quit-after 1800`: PASS, exit 0, clean
  default scene startup (`/tmp/stage3b2-startup.log`), 30 simulated seconds rather
  than a performance benchmark. Explicit standalone M1 startup with `--quit-after 120`
  also passed (`/tmp/stage3b2-m1-startup.log`).

- `python /tmp/validate_false_world_stage3b2.py`: PASS, exact intended scope
  (5 modified + 6 new files), 70 other tracked files byte-preserved against pre-edit
  SHA-256 hashes, existing memory methods unchanged, scene adds only debug resource/
  child, valid local resource/Markdown links, skill metadata, unique UID pairs,
  empty markers, UTF-8/whitespace, clean final engine logs and preserved prior
  implementation/verification ancestry. `git diff --check` also passed.

### Current limits and exact next step

The panel is sampled at 10 Hz; brief transitions may be missed/late. Latest-sample
labeling follows the existing sensing/decision phase, not a continuously verified
LOS ray. Last direct can concern a different observed ID than selected evidence.
Blocked/Recovering describe existing counters, not new AI states; recovery may stay
labeled while a retried path moves. Inactive retained nav goals may outlive evidence,
clearly labeled. No separate debug sensing, target tracking or behavior tuning occurs.

Build-gate feature combinations are tested; no actual Windows exported artifact,
new graphical session, rendered layout/readability, hardware keyboard feel, camera
occlusion or CPU/FPS/frame-time/RAM measurement was performed. This is developer
instrumentation, not a security sandbox against someone modifying an editor binary.
The new panel remains graphically unverified. Existing static-navigation/congestion
limits remain; no human-like AI or 22–25-agent performance claim follows.

**Next exact step:** on Windows/Godot 4.7.2, run F5, confirm diagnostics absent, then
press F3. Follow the same agent ID from Explore to Observe near a solid building
corner, record its selected direct-vision point, and hide behind the wall during
that pause. Verify last-seen age increases, Investigate uses the frozen point despite
your hidden movement, then Resume/Explore occurs. Check delayed-report source/age
on a recipient, stationary repeat suppression and blocked/recovering behavior.
Toggle off/on and recheck WASD/camera, E cancel/resume/completion, Escape/click,
panel readability and debugger output. Record actual states/coordinates/ages/commit;
measure performance separately. Exact steps and legitimate no-investigation cases
are in STAGE3B1_PROTOTYPE.md. Fix only demonstrated defects before further features.

### Historical Stage 3B.1 and earlier records

The following preserves prior increments, then-current limits and next steps.
Current user evidence, diagnostics and acceptance instructions are recorded above.

### Current status — Stage 3B.1 observation decisions

The same 100×100 m local graybox now runs a small explore/observe/investigate/resume
layer for exactly three agents. It can respond to actual local or properly delivered
observations and physically visit a frozen last-seen point, then resume authored
exploration. This remains a technical subset of handoff §19 stage 3, not a completed
deception proof or evidence of human-like AI. No dialogue, full Director, combat,
inventory, mobs, objectives/extraction, multiplayer, new UI, asset, dependency,
runtime LLM or paid service was added. Cost remains 0 UZS.

Inspected clean checkout `f8cf18c`, read project authority/rules/skills and prototype
docs, fetched main merge `7ecf0c6`, and created dedicated branch
`feat/stage3b1-observation-decisions` from it. The prior Stage 3A.1 commit and all M1
verification history are preserved. This task authorizes automatic branch push and
remote-HEAD verification, never a merge into main.

### Completed Stage 3B.1 work

- Added a small value-only decision module accepting copied private memory facts,
  own position, seed/tick and execution feedback. No live actor, registry, sensor
  candidates, authoritative human position or hidden-state input enters it.
- Added explicit explore, bounded observation pause, old-location investigation,
  and resume states. Evidence stays frozen throughout a response; updates cannot
  silently redirect the agent behind walls. Continued direct sight ends observation
  without pursuit. Arrival, stale evidence, unreachable paths, blocked travel and
  timeout return to exploration through a short pause.
- Added global/subject/location cooldowns, newer-evidence plus displacement gates,
  bounded suppression history, minimum dwell and duplicate-call frequency guards.
  Seeded variation affects timing. Known teammates are filtered to avoid mutual
  investigation loops; no visual role-classification system was added.
- Added an adapter wired to exactly its own existing sensor memory. Perception,
  memory validation/expiry and selective delayed report channel are byte-unchanged.
  Reports retain original age/position; no automatic sharing or strategic assignment.
- Extracted path-start/arrival hooks in the existing exploration executor so the
  new adapter reuses path validity, steering, physical blocking/retries and arrival
  rules. Existing motor, camera, input and interaction scripts are unchanged.
- Added a tiny scene inheriting the unchanged Stage 3A.1 map/navmesh, changed only
  project startup to it, and retained original exploration/M1 scenes for direct run.
  Added focused tests and [STAGE3B1_PROTOTYPE.md](STAGE3B1_PROTOTYPE.md); updated
  architecture, design status and older run guides. All timing/range tuning remains
  provisional; no physics/speed/collision or approved gameplay change.

### Stage 3B.1 checks actually performed

Used explicit `/workspace/.tools/godot/4.7.2/Godot_v4.7.2-stable_linux.x86_64` with
`XDG_CACHE_HOME=/workspace/.cache`, `XDG_DATA_HOME=/workspace/.local/share`,
`XDG_CONFIG_HOME=/workspace/.config`. Version check confirmed
`4.7.2.stable.official.ed1daf0bf`. An initial version-only probe without these paths
emitted a Fontconfig cache warning; the subsequent configured probe was clean.
`GODOT` below means that explicit binary, not the default system executable.

- `$GODOT --headless --path . --editor --import`: PASS, exit 0, clean final output
  (`/tmp/stage3b1-import-final.log`), with permitted local editor socket access.
- `$GODOT --headless --path . --check-only --script res://PATH`: PASS for all five
  changed/new GDScript files: exploration executor, observation decisions/controller,
  Stage 3B.1 composition and its regression suite. Exact invocations/results were
  recorded by `/tmp/check_stage3b1_engine.py`; five parser logs are under
  `/tmp/stage3b1-parser-*.log`.
- `$GODOT --headless --path . --script res://tests/stage3b1/test_observation_decisions.gd`:
  PASS, **45 checks, 0 failures**, exit 0 (`/tmp/stage3b1-tests-expanded.log`). The
  initial 39-check suite passed; six additional cases also passed. Coverage includes
  observation-triggered transitions, held dwell, frozen evidence, actual LOS loss,
  original last-seen travel, continued-sight suppression, exact expiry/future rejection,
  global/subject/location cooldowns, repeat suppression, seeded duration variation,
  selective delayed delivery, stale receipt, private memory wiring, bounded counted
  work/frequency, actual arrival/resume, off-mesh failure and physical-block recovery.
- All four unchanged suites rerun using the same `--headless --path . --script`:
  `res://tests/stage3a1/test_exploration.gd` **25/0**;
  `res://tests/stage3a/test_foundation.gd` **39/0**;
  `res://tests/m1/test_graybox.gd` **31/0**;
  `res://tests/m1/test_camera_clearance.gd` **15/0**.
  All exit 0 without errors/warnings (`/tmp/stage3b1-exploration.log`,
  `/tmp/stage3b1-foundation.log`, `/tmp/stage3b1-m1.log`, `/tmp/stage3b1-camera.log`).
  Final suite total: **155 passed, 0 failed**. No existing test was weakened/edited.
- `$GODOT --headless --path . --fixed-fps 60 --quit-after 1800`: PASS, exit 0, clean
  new default scene startup (`/tmp/stage3b1-startup.log`). This is 30 simulated seconds,
  not an FPS/CPU benchmark. Explicit standalone M1 scene startup with `--quit-after 120`
  also passed (`/tmp/stage3b1-m1-startup.log`).

- `python /tmp/validate_false_world_stage3b1.py`: PASS, exact intended scope
  (8 modified + 10 new files), 57 previous tracked files byte-preserved against
  pre-edit SHA-256 hashes, startup-only configuration change, unchanged existing
  path-follower/abandonment bodies, local resource/Markdown links, skill metadata,
  unique UID pairs, empty directory markers, text formatting, completed engine
  logs and preserved prior commit ancestry. `git diff --check` also passed.

### Current limitations and exact next step

No graphical test, Windows export or measured CPU/FPS/frame-time/RAM result was run.
Operation counts prove bounded work, not target-laptop scaling. The existing reported
M1 manual passes remain historical evidence; new behavior/expanded-map occlusion is
not graphically accepted. Primitive capsules have no locomotion animation and no
claim of natural/human-like movement follows from headless checks.

There is no coordination strategy: a nearby recipient may independently investigate
an appropriately delivered report, and no all-agent assignment/deconfliction exists.
Only eight candidate facts and eight suppression records are used by a decision;
larger populations need relevance/eviction reassessment. Current sight means a direct
fact from that scheduled sensing tick. Frozen evidence can expire before travel ends;
there is intentionally no live pursuit or mid-trip retargeting. Static navigation,
body congestion and lack of dynamic RVO remain existing limits. All tuning needs
actual play observation/profile evidence before population or map expansion.

**Next exact step:** on Windows/Godot 4.7.2, run F5; enter an agent's forward view,
then move behind a solid building corner. Observe the short pause, possible visit
to the old point and return to exploration; confirm it does not follow your hidden
movement. Stay visible/stationary to check repeated-sighting suppression, then
repeat from a genuinely new location and watch independent agent timing. Temporarily
block a route; recheck WASD, camera framing/occlusion, E cancel/resume/completion,
Escape/click and debugger output. Record actual findings; measure FPS/frame times/
RAM separately. Fix demonstrated defects before another separately scoped feature
increment; no dialogue or Director strategy is begun here.

### Historical Stage 3A.1 and earlier records

The following preserves earlier increments and their then-current next steps.
The current startup/decision layer and graphical validation step are recorded above.

### Current status — Stage 3A.1 authored exploration

The default local prototype now has a 100×100 m authored primitive environment,
sixteen meaningful destinations and three independently seeded exploration agents.
They travel, briefly observe and change areas using private visit history, rather
than repeating a rectangle. This remains the movement/knowledge foundation of
handoff §19 stage 3; dialogue, deception and later gameplay are not implemented.
No new UI, external asset, dependency, service or expenditure was added (0 UZS).

Inspected clean `feat/stage3a-local-ai` at `a355c50`, fetched main merge `df36c80`,
and created dedicated `feat/stage3a1-exploration` from that main commit. Previous M1
and verification history is preserved. The user authorizes this branch's push;
main must not be merged or overwritten.

The existing user-reported Windows/Godot 4.7.2 M1 checks remain recorded below:
movement, collision, interaction and camera controls passed, and the extreme camera
magnification was resolved. Remaining camera occlusion is not claimed solved.
No graphical session or FPS/frame-time/GPU/RAM measurement was performed here.
The expanded environment and new movement require a new graphical acceptance pass.

### Completed Stage 3A.1 work

- Authored a separate inherited scene with three roofless building shells, wide
  openings, intersecting lanes, courtyard, open corners and rubble using boxes and
  shared materials. Sixteen static destination markers identify transit,
  investigation and observation places; these labels create no new interaction.
- Baked a separate 214-polygon static navigation resource using Godot's existing
  collider parsing/Recast APIs, with the previous radius/height/climb settings.
  M1 and original Stage 3A scenes/navmesh remain byte-preserved and directly runnable.
  Only the project's startup-scene setting changed.
- Added a bounded static-site selector using novelty, area change, distance,
  private visit history and seeded variation. Agents vary departure, destination
  and dwell timing. No human transform, actor registry or perception memory is
  passed to destination selection. LOS, separate memories and the delayed selective
  observed-fact interface remain unchanged.
- Added replaceable travel/wait control with candidate path validation, arrival
  slowdown, bounded intent blending, finite stall retries and failed-site cooldowns.
  No teleport, wall bypass, extra movement speed, crowd simulation or dynamic RVO.
  Base composition exposes starts/route/controller creation with old defaults intact.
- Added an opt-in visual turn-rate limit to the shared motor, default zero for
  original human/M1/legacy behavior. New AI turn at a configurable bounded rate;
  speed, gravity, capsule and movement/collision equations remain unchanged.
- Added focused regression coverage, Godot-only rebake tooling and
  [STAGE3A1_PROTOTYPE.md](STAGE3A1_PROTOTYPE.md). Updated architecture/design status
  and both older prototype run guides. All new tuning values remain provisional.

### Checks actually performed for Stage 3A.1

All engine commands used `/workspace/.tools/godot/4.7.2/Godot_v4.7.2-stable_linux.x86_64`
with `XDG_CACHE_HOME=/workspace/.cache`, `XDG_DATA_HOME=/workspace/.local/share`,
`XDG_CONFIG_HOME=/workspace/.config`. `--headless --version` confirmed
`4.7.2.stable.official.ed1daf0bf`. `GODOT` below denotes this explicit binary.

- `$GODOT --headless --path /workspace/FALSE-WORLD --script
  res://tools/bake_stage3a1_navigation.gd`: PASS, 214 polygons, save status 0, exit 0.
- `$GODOT --headless --path /workspace/FALSE-WORLD --editor --import`: final PASS,
  exit 0, no errors/warnings (`/tmp/stage3a1-import.log`). Initial sandbox import
  reported denied local editor sockets; rerunning with sandbox escalation succeeded.
- `$GODOT --headless --path /workspace/FALSE-WORLD --check-only --script PATH`:
  PASS for seven changed/new scripts: character motor, Stage 3A composition,
  Stage 3A.1 composition, exploration selector/controller, rebake tool and test.
- `$GODOT --headless --path /workspace/FALSE-WORLD --script
  res://tests/stage3a1/test_exploration.gd`: PASS, **25 checks, 0 failures**,
  exit 0 (`/tmp/stage3a1-tests.log`). Covers reachable destinations, bounded navmesh,
  reproducible varied choices/dwells, staggered departures, distinct initial goals,
  physical obstacle detour, shared speed/no teleport, limited yaw, bounded path
  backtracking, stationary arrival wait, unreachable rejection, bounded queries
  and collision-blocked finite recovery. An initial 23-check run had one fixture
  failure: it checked arrival before the controller threshold and advanced its
  injected clock past the wait. Corrected the fixture's threshold/monotonic clock
  and added backtracking/stationary checks; the final 25-check run passed.
- Existing unchanged suites rerun: `res://tests/stage3a/test_foundation.gd`
  **39/0**, `res://tests/m1/test_graybox.gd` **31/0**, and
  `res://tests/m1/test_camera_clearance.gd` **15/0**, all exit 0 without errors/warnings
  (`/tmp/stage3a1-legacy-ai.log`, `/tmp/stage3a1-m1.log`, `/tmp/stage3a1-camera.log`).
  Total final automated assertions: **110 passed, 0 failed**.
- `$GODOT --headless --path /workspace/FALSE-WORLD --fixed-fps 60 --quit-after 1800`:
  PASS, exit 0, no errors/warnings (`/tmp/stage3a1-startup.log`). This runs 30
  simulated seconds; it is not a real-time rendering/performance benchmark.

- Standard-library repository validator `/tmp/validate_false_world_stage3a1.py`:
  PASS, exact intended scope (8 modified + 13 new files), 44 other existing tracked
  files byte-preserved against pre-edit SHA-256 hashes, configuration changed only
  at startup scene, motor diff confined to opt-in visual facing, valid local
  Markdown/resource paths, skill metadata, empty markers, unique script UIDs,
  UTF-8/newlines/whitespace, final saved engine logs and prior commit ancestry.
  A first validator run interpreted an existing documentation placeholder
  `res://path.gd` as a real resource; narrowed resource existence checks to code/
  scene resources and retained Markdown link checks. Final validator and
  `git diff --check` passed.

### Unresolved details and exact next step

Natural appearance, stop/turn smoothness, corner jitter and usability cannot be
accepted from path/angle assertions alone. The capsules have no locomotion animation.
Dynamic blockers use physics plus retry/abandon rather than dynamic avoidance;
this can still cause temporary congestion. Static geometry edits require rebaking.
No 22–25-agent or full-map performance has been measured. Expanded-map camera
occlusion, Intel-iGPU FPS/frame times and RAM remain unverified.

**Next exact step:** in Windows Godot 4.7.2, run the Stage 3A.1 scene; walk through
the depot/workshop/ruins openings and alternate exterior routes, watch all three AI
across several destination visits/observation pauses, temporarily block a route,
and check corner turns, stopping, collision recovery and independent timing.
Recheck human movement, lever and camera framing/occlusion plus the debugger.
Record actual results and measure FPS/frame times/RAM separately. Fix only observed
movement defects before a separately authorized next feature increment; do not
start dialogue, Director strategy, M2 or other gameplay.

### Historical Stage 3A record

The following records describe the preceding increment; current startup and optional
motor facing changes are documented above and in the prototype guides.

### Current status — Stage 3A local AI foundation

Stage 3A adds one local human and exactly three local agents with shared character
physics/model, built-in waypoint navigation, bounded LOS perception, separate memory
and delayed selective observed-fact sharing. This is only the foundation of handoff
§19 stage 3, not a completed deception proof. No dialogue, deception decisions,
combat, inventory, mission/extraction, mobs, multiplayer, external service or UI.

The user visually confirmed the latest M1 camera prevents the previous extreme
magnification and reported M1 movement/collision/interaction/camera controls passing
on Windows/Godot 4.7.2. This is user-reported evidence, not an agent rerun. Remaining
camera occlusion is not claimed solved, and FPS/GPU/frame-time/RAM remain unmeasured.
New Stage 3A agents and their additional blocking/occlusion need graphical validation.

Inspected a clean checkout at `d5fc70b`, fetched main merge `811db0e`, and created
`feat/stage3a-local-ai` from it. Prior M1/verification commits are preserved. This
user task explicitly authorizes the Stage 3A branch push; no merge into main.

### Completed Stage 3A work

- Extracted preserved M1 mesh/material/capsule/motor composition to
  `scenes/character/shared_character.tscn`. M1 now instances it, retaining its exact
  camera/input/interactor hierarchy. All existing character, camera and interaction
  GDScript files are unchanged; no movement rewrite or new physical ability.
- Added `scenes/prototype/stage3a_local.tscn`, inheriting the small M1 yard. The scene
  composes exactly three agent bodies through `scripts/ai/stage3a_local.gd`, while
  the M1 human and lever remain functional. F5 starts Stage 3A; original M1 still
  runs directly/F6. Only the project's startup-scene setting changed.
- Added a built-in static navigation resource (24 polygons), a Godot-only rebake
  tool, and waypoint controllers using NavigationAgent3D. All motion goes through
  the unchanged CharacterMotor. Static obstacles route paths; physics remains final
  collision authority. Stalled routes retry twice then abandon their waypoint.
- Added range/cone/LOS sensing, one LocalMemory per agent, and seven-field observed
  snapshots: observer, subject, event, position, tick, confidence, source. No role,
  HP, inventory, intentions, mission state or live target references in memory.
- Added a small delayed channel wired only to actual perception signals matching
  their sensor memory. Fixed selective ring routing, bounded queue, one delivery per
  tick, no rebroadcast. Pending reports retain the original snapshot/due time;
  recipient freshness uses observation time. Provenance validation is a pure lookup
  and cannot alter observer memory based on an incoming report tick.
- Patrol decisions only: shared facts do not drive behavior yet. No strategic
  Director or dialogue system is represented as implemented. Three staggered
  sensor/planning phases, seeded initial waypoint choices and injectable simulation
  ticks make the current rules configurable/testable and keep work bounded.
- Added Stage 3A tests and run/settings/manual-check documentation. Updated design,
  architecture, M1 launch instructions and the AI skill's stale docs-only wording.
  No dependency, paid service, imported asset, gameplay UI or full map added.

### Checks actually performed in this increment

All Godot commands ran from `/workspace/FALSE-WORLD` using explicit
`/workspace/.tools/godot/4.7.2/Godot_v4.7.2-stable_linux.x86_64` (version verified:
`4.7.2.stable.official.ed1daf0bf`) with `XDG_CACHE_HOME=/workspace/.cache`,
`XDG_DATA_HOME=/workspace/.local/share`, `XDG_CONFIG_HOME=/workspace/.config`.
Here `GODOT` denotes that explicit binary, not the older default system executable.

- `$GODOT --headless --path /workspace/FALSE-WORLD --script
  res://tools/bake_stage3a_navigation.gd`: PASS, 24 navigation polygons saved, exit 0.
  The actual navigation bake ran; no plugin or dependency installation was needed.
- `$GODOT --headless --path /workspace/FALSE-WORLD --editor --import`: final PASS,
  exit 0, no engine/script errors (`/tmp/stage3a-import.log`). Initial sandbox import
  emitted local-socket errors; permitted editor-socket validation succeeded.
- `$GODOT --headless --path /workspace/FALSE-WORLD --check-only --script res://<path>`:
  PASS for all five new AI scripts, the navigation bake tool and Stage 3A test
  (seven parser checks). The initial test script had an inference parse error for a
  dynamically loaded world; corrected before running its behavioral checks.
- `$GODOT --headless --path /workspace/FALSE-WORLD --script
  res://tests/stage3a/test_foundation.gd`: **39 checks, 0 failures**, exit 0, clean
  engine output (`/tmp/stage3a-tests.log`). Tests cover actual agent traversal,
  identical model/collider resources, common speed/ground rules, staggered updates,
  blocked/range/cone vision, stable last-seen, capacity/expiry/isolation, delayed
  selective sharing, original provenance, unsupported-fact rejection without memory
  mutation, two observations overflowing a one-entry queue, perception work budget,
  physical detour around the central obstacle, seeded waypoint choice and finite
  stalled-route retries. The test uses real physics plus injected-tick rule checks.
- Existing `$GODOT --headless --path /workspace/FALSE-WORLD --script
  res://tests/m1/test_graybox.gd`: **31 checks, 0 failures**, exit 0
  (`/tmp/stage3a-m1-tests.log`). Existing `res://tests/m1/test_camera_clearance.gd`:
  **15 checks, 0 failures**, exit 0 (`/tmp/stage3a-camera-tests.log`).
- Startup default Stage 3A with `--headless --path /workspace/FALSE-WORLD
  --fixed-fps 60 --quit-after 600`: PASS, exit 0, no errors
  (`/tmp/stage3a-startup.log`). This runs fixed simulation frames, not a hardware
  performance benchmark. Explicit original M1 scene startup with `--quit-after 120`
  also passed (`/tmp/stage3a-m1-startup.log`).
- `python3 /tmp/validate_false_world_stage3a.py`: PASS for exact intended file scope,
  protected-file SHA-256 equality, preserved original character resource definitions,
  only intended startup configuration change, local references/format/skill metadata,
  UID pairs and original directory markers, clean logs and completed test counts.
- `git diff --check`, `git diff --cached --check` and staged diff review: PASS.
  No protected handoff, unrelated project setting, camera/movement/interaction code,
  existing tests or third-party asset changes.

### Known limits and unresolved technical details

No agent-observed graphical Stage 3A session, target-laptop performance test, Windows
export or real-human deception playtest was run. The prior user M1 confirmation
does not verify this new scene or prove all camera occlusion resolved. Confirm the
three models, navigation/collision, camera visibility and lever controls on Windows.

The navmesh is static and must be rebaked after static M1 geometry changes. RVO/
dynamic crowd avoidance is disabled; agents may physically block each other or the
human before bounded retry/waypoint abandonment. Longer-run path behavior needs
manual observation. No general map generator, dynamic navigation, multi-tier AI,
visual-ID recognition, human-role classification, strategy or dialogue is implemented.
The small private tracking IDs are not a full player-facing identity system.

Rules/settings are provisional: seed 431, 15-tick sensing/planning interval with
three offsets, 30-tick report delay, 300-tick freshness, 8 memory entries, 12 queued
reports, four candidates, range 8 and FOV 120°. At 60 physics ticks/s that is 4 Hz
per agent, 0.5 s report delay and 5 s freshness. Defaults are Inspector-configurable
on the stage root. Tick-time logic/seeded choices are repeatable; bitwise physics/
navigation behavior across platforms is not guaranteed. No full 22–25-AI or 1×1 km
capacity/performance claim follows from this small foundation.

### Exact next step

Run the Stage 3A graphical checklist in `docs/STAGE3A_PROTOTYPE.md` on Windows with
Godot 4.7.2: observe three identical agents traversing the yard, test human blocking/
agent recovery and obstacle collision, recheck camera occlusion/framing and E/
Escape/click behavior, and record actual debugger/visual outcomes. Fix demonstrated
foundation defects within scope; measure FPS/RAM separately before scaling.

Only after that acceptance and a new scoped task, implement the next Stage 3B
slice: a minimal deterministic decision layer consuming fresh local/reported facts
through the existing action interfaces. Dialogue/deception remains a separately
scoped next part of the approved proof, not something implemented by Stage 3A.
Do not proceed to the larger playable or other excluded systems in this increment.

### Historical M1 record (before Stage 3A)

The following records earlier increments, including then-pending verification and
then-planned next steps. The current Stage 3A status and latest user M1 confirmation
above supersede those historical status statements, not the recorded test evidence.

Updated: 2026-11-02 (Asia/Tashkent).

### Current status — M1 local graybox

M1 runtime implementation is complete as a local technical slice, corresponding to
handoff §19 stage 2. Automated checks passed in the implementation increment.
The user has reported Windows/Godot 4.7.2 manual passes and two camera failures.
The earlier clearance fix did not preserve graphical third-person framing. The
latest framing calibration passes the strengthened automated checks below; Windows
acceptance of its higher viewpoint and all performance measurements remain pending.
There is no multiplayer, AI, combat, HP, inventory, mission/extraction, or gameplay
UI. The full game remains planned. Approved handoff v1.0 rules remain unchanged.

Original M1 implementation base: fetched `origin/main` at merge `2d0effe`
(includes `4e05ce9`). Verified with `git merge-base --is-ancestor 2d0effe HEAD` after creating dedicated branch
`feat/m1-local-graybox`. The initial working tree was clean. No push or merge is
part of this increment. Use `git log -1 --oneline` for the resulting M1 commit ID.

### Completed M1 work

- Added `scenes/prototype/m1_graybox.tscn`: 24×24-unit primitive yard, collision floor,
  central obstacle, perimeter, one capsule character, follow camera and adjustable
  lever. One unshadowed light and simple materials; preserved renderer and physics.
- Added five modular GDScript files under `scripts/character/` and
  `scripts/interaction/`: world-space motor intent, local WASD/mouse adapter,
  collision-retracting orbit camera, interaction intent adapter, target-owned
  resumable work. No AI/network code or new dependencies/assets.
- Hold E starts/continues local lever work; release, range/line-of-sight loss, Escape,
  or application focus loss cancels without clearing progress. A later worker may
  resume. Completion turns and leaves the lever set, emitting once; no fake mission,
  resource, reward or extraction is connected. Progress is scene-lifetime only.
- Added startup scene and six input actions to `project.godot`; unrelated settings
  retained. Added built-in Godot tests at `tests/m1/test_graybox.gd`, and included
  engine-generated `.gd.uid` files for all six scripts.
- Added `docs/M1_PROTOTYPE.md` with controls, launch/test commands, provisional
  settings, boundaries and manual checklist. Updated architecture/design status
  and made the old docs-only restriction conditional in AGENTS.md and the
  godot-development skill; this user task explicitly authorizes M1 implementation.
  All other skills and the handoff are preserved.

### M1 verification actually performed

Engine: explicit
`/workspace/.tools/godot/4.7.2/Godot_v4.7.2-stable_linux.x86_64`, reporting
`4.7.2.stable.official.ed1daf0bf`. Commands ran from `/workspace/FALSE-WORLD` with
`XDG_CACHE_HOME=/workspace/.cache`, `XDG_DATA_HOME=/workspace/.local/share`, and
`XDG_CONFIG_HOME=/workspace/.config`. In the commands below `GODOT` denotes that
explicit binary, not the older default system executable.

- `$GODOT --headless --path /workspace/FALSE-WORLD --editor --import`: final PASS,
  exit 0 with no script/engine errors. Initial sandboxed import logged local socket
  errors; rerunning with the permitted editor socket access succeeded. Final import
  output retained at `/tmp/m1-import.log` in this instance.
- `$GODOT --headless --path /workspace/FALSE-WORLD --check-only --script res://<path>`:
  PASS for each of `scripts/character/{character_motor,follow_camera,local_controller}.gd`,
  `scripts/interaction/{character_interactor,work_target}.gd` and
  `tests/m1/test_graybox.gd` (six parser checks, all exit 0, no errors).
- `$GODOT --headless --path /workspace/FALSE-WORLD --script res://tests/m1/test_graybox.gd`:
  final PASS, **31 checks, 0 failures**, exit 0. Tests instantiate the actual scene;
  exercise ground and obstacle collision, diagonal speed/stop, camera bounds/yaw
  and spring collision, synthetic local W/E commands, Escape/focus cancellation,
  lever visual progress, cancellation persistence/resume, ownership, range and
  obstruction rejection, worker removal recovery, negative time and single completion.
  Synthetic input and transform assertions are not manual input or visual tests.
- Initial automated run failed 4 of 30 checks. Diagnosis found a real range-loss
  cancellation lock bug (fixed in the interactor), a test worker overlapping the
  player's collider (fixture moved), and headless mouse capture reporting visible
  despite a capture request (adapter now tracks active controls separately from the
  display driver). Reran after corrections; expanded focus-loss coverage passed.
- `$GODOT --headless --path /workspace/FALSE-WORLD --quit-after 120`: PASS, exit 0,
  startup scene instantiates/runs without runtime errors. Output retained at
  `/tmp/m1-startup.log`. This is not a graphical playtest or performance measurement.
- `python3 /tmp/validate_false_world_m1.py`: PASS, protected-file SHA-256 comparison
  against the clean baseline, only intended pre-existing modifications, unchanged
  handoff and unrelated Godot settings, valid resource/local-document references,
  skill metadata, original markers, new-script UID pairs and whitespace checks.
- Engine constant inspection with `/tmp/m1_environment_constants.gd` confirmed
  COLOR ambient = 2 and DISABLED reflection = 1; the scene uses those flat-lighting
  settings rather than requesting an absent sky. This is not visual validation.
- `git diff --check`, `git diff --cached --check` and staged diff review: PASS.
  Only intended M1 source/scene/test/configuration/docs files included.

### Latest framing failure and correction

Recorded: 2026-11-02 (Asia/Tashkent). The user reports that the previous fix is not
fully successful on Windows/Godot 4.7.2: near obstacles, downward/front orbit retracts
the camera until the blue character nearly fills the screen. Avoiding penetration
alone did not preserve third-person framing. No new successful graphical acceptance
or performance result is inferred from this report.

Inspected clean checkout `de5b6a6`, then fetched latest main `39938fd`, which merges
that fix and includes verification commit `6803e0b`. Created dedicated branch
`fix/m1-camera-framing` from that main commit. No rewriting of prior commits, merge
into main, M2, new dependency, external asset or gameplay behavior change.

Cause and diagnosis:

- The sphere sweep is legitimately obstructed near 2-unit geometry. The old 2.1-unit
  pivot was only 0.3 units above the 1.8-unit capsule. With an arm hit length as
  short as 0.178 units, the camera could remain physically outside the character
  but only 0.183 units from its bounds. Looking at the body center kept that point
  framed while near head surfaces were heavily magnified.
- The 0.1 near plane is a clipping limit, not a framing constraint. Controlled tests
  of margin 0.2 versus 0.02, and sphere radius 0.2 versus 0.16, did not solve the
  close-up at the old pivot. Evidence: `/tmp/m1-probe-diagnosis-detail.log`, generated
  with Godot `--headless --path /workspace/FALSE-WORLD --script
  /tmp/m1_probe_diagnosis.gd`. Those margin/probe experiments were not saved.
- Previous tests checked penetration and center-frustum inclusion, not whole-body
  projected size or useful lens-to-mesh clearance. Their assumed 1280×720 window
  was also unreliable: headless reset the window to 64×64 with a square stretched
  viewport. The new harness uses an explicit 1280×720 SubViewport, asserts its
  actual visible size and measures projections against that viewport's dimensions.
  Earlier nominal viewport coverage should not be treated as verified widescreen
  coverage; the recorded earlier check counts remain historical outcomes.

Minimal production correction:

- The only runtime change is the scene's camera pivot height: **2.1 → 3.2 units**,
  now 1.4 above the capsule. This reserves usable framing clearance even at zero
  arm length and through the existing pitch range. No minimum-distance clamp pushes
  the camera through a wall; the original sphere sweep still controls arm length.
- Sphere radius 0.2, margin 0.2, near plane 0.1, FOV 70, arm length 4, pitch limits,
  body-center focus, visibility and control scripts are unchanged. No first-person
  mode, FOV zoom, mesh hiding, new smoothing/control algorithm or world change.
- Tests now require at least 1.1 units from conservative character bounds and
  whole-body bounds on screen occupying at most 80% of either dimension. These
  are provisional M1 acceptance proxies, not final gameplay balance or rendered
  pixel measurements. Existing wall-retraction fixtures start farther away to
  intersect the same 2-unit wall from the higher pivot instead of passing above it.

Checks actually performed with Godot **4.7.2.stable.official.ed1daf0bf** using
`/workspace/.tools/godot/4.7.2/Godot_v4.7.2-stable_linux.x86_64` from
`/workspace/FALSE-WORLD`, with the writable XDG paths documented below:

- Before correction, strengthened camera regression: **11 checks, 2 failures**,
  exit 1 (`/tmp/m1-framing-before.log`). Surface clearance and projected size failed;
  prior overlap and center-frustum checks still passed. Conservative box projection
  exceeded the viewport dimension (about 259%), reproducing the missing constraint.
- Final `--headless --path /workspace/FALSE-WORLD --script
  res://tests/m1/test_camera_clearance.gd`: **15 checks, 0 failures**, exit 0, no
  engine errors (`/tmp/m1-framing-final.log`). All existing camera checks retained.
  Includes 336 yard poses, 48 tall-wall and 48 tall-corner stress poses, steep pitch
  limits, under-0.5-unit arm retraction and forced zero-length-arm framing. Tall
  colliders exist only in the test. No camera/near-plane bounds intersect sampled
  geometry or character bounds; mesh visibility remains enabled.
- In the 336 actual-yard poses, minimum body-bounds distance was **2.4978 units**,
  maximum projected screen extent **45.4%**, and shortest arm **3.1406 units**.
  Short-arm/tall-wall/corner/zero-arm checks also satisfy the 1.1-unit/80% budgets.
  These are physics/projection results, not camera comfort or GPU measurements.
- Final `--headless --path /workspace/FALSE-WORLD --script
  res://tests/m1/test_graybox.gd`: **31 checks, 0 failures**, exit 0, no engine errors
  (`/tmp/m1-framing-graybox.log`). Movement, collision and interaction tests pass.
- `--headless --path /workspace/FALSE-WORLD --editor --import`: PASS, exit 0 with
  permitted local editor sockets, no errors (`/tmp/m1-framing-import.log`).
  `--headless --path /workspace/FALSE-WORLD --quit-after 120`: PASS, exit 0, no errors
  (`/tmp/m1-framing-startup.log`). Version was explicitly checked with `--headless
  --version`. `--check-only --script res://<path>` passed for both M1 test scripts.
- `python3 /tmp/validate_false_world_framing.py`, `git diff --check` and
  `git diff --cached --check`: PASS. Reviewed six intended files: scene, two test
  scripts, M1_PROTOTYPE.md, PROGRESS.md and ARCHITECTURE.md. Verified unchanged
  handoff, project settings, runtime GDScript/gameplay, skills, UID files and assets;
  valid references/format and retained prior commit ancestry. No new files.

Graphical limits: the agent has no graphical display. The higher viewpoint still
needs Windows acceptance while orbiting steeply down/front, moving into/out of
walls and corners, and approaching the central obstacle/lever pedestal. Verify
whole-character size, rendering, smoothness and input/interaction preservation.
No FPS/GPU/frame-time/RAM, export, arbitrary low-ceiling or future-map guarantee.

### Previous clearance correction (historical)

Recorded: 2026-11-02 (Asia/Tashkent). The user reports the following additional
passes on their Windows laptop with Godot 4.7.2, before this camera fix:

- Holding E until the end completes the interaction.
- Interaction is rejected outside the allowed range and blocked by solid geometry.
- The camera avoids clipping through the surrounding walls in the tested cases.
- Escape during interaction stops work; clicking again restores control.
- Previously confirmed WASD, mouse camera rotation, ground/obstacle collision and
  retained partial interaction progress continue to be reported as passing.

These are user-reported observations, not agent-observed graphical tests. The prior
session's 0 errors/0 warnings report remains scoped to that session. No additional
performance numbers, build SHA, resolution, driver or detailed hardware were given.
The newly reported failure is separate: when pressed against a wall and orbiting
to the character's front, the camera can enter the visible character mesh.

Repository inspection: clean local `docs/m1-manual-verification` at `6803e0b`.
Fetched latest main `fb77ab0` (M1 merge); its runtime files match that checkout,
with only PROGRESS.md differing. Created dedicated `fix/m1-camera-clearance` from
`6803e0b`, preserving that verification commit as an ancestor rather than resetting
or recreating it. This task authorizes pushing the completed fix branch; it does
not authorize merging main or beginning M2.

Analysis and minimal fix:

- Reproduced front-wall camera overlap in Godot 4.7.2 using the real M1 scene.
  The old spring pivot was 1.5 units above the feet, inside the 1.8-unit capsule.
  Its character collision exclusion allowed walls to retract the camera into it.
- Changed the camera configuration in the scene: pivot height 2.1 units (0.3 above
  the capsule), and an explicit 0.2-unit sphere for SpringArm3D world sweeps. The
  sphere protects the origin and near plane; the default camera-shaped cast could
  leave the camera origin slightly inside a wall in sampled cases. Raising the
  pivot alone removed self-overlap but did not satisfy this world-clearance check.
- Preserved arm length, margin, orbit/pitch controls, character visibility and
  character collision exclusion. No forced minimum arm, mesh hiding/fading,
  first-person mode, camera input/smoothing feature, or unrelated gameplay change.
  `follow_camera.gd` now keeps the existing body center in view after the spring
  update; a yaw-relative up vector avoids a singular look-at at full compression.
  This keeps the raised pivot from merely moving the character out of frame.
  Moving the pivot above a 2-unit wall allows full extension on clear paths above
  it, while the sphere still retracts the arm on obstructed paths.
- Added `tests/m1/test_camera_clearance.gd` and its UID. Updated the original wall
  regression to aim down toward the wall: the old horizontal ray clears a 2-unit
  wall from the new above-head pivot. Updated M1_PROTOTYPE.md and architecture notes.

Automated checks actually performed from `/workspace/FALSE-WORLD`, using explicit
`/workspace/.tools/godot/4.7.2/Godot_v4.7.2-stable_linux.x86_64` (version output
`4.7.2.stable.official.ed1daf0bf`) with the same writable XDG paths as the M1 checks:

- Before the fix, the first camera regression ran 6 checks with 3 failures (exit 1):
  the reported front-wall overlap, other sampled self-overlaps and world-clearance
  violations. Evidence is retained in `/tmp/m1-camera-before.log`. These are
  conservative geometric enclosures, not graphical observations of every sample.
- After the scene correction, the expanded camera regression ran **9 checks,
  0 failures** (exit 0), via `--headless --path /workspace/FALSE-WORLD --script
  res://tests/m1/test_camera_clearance.gd`. Tested 336 orbit configurations across
  seven positions (four walls, two corners, central obstacle), twelve yaw samples
  and four pitches including both limits. Camera origin/near-plane bounds plus a
  0.02-unit safety margin had zero self/world overlaps. Logical mesh visibility,
  obstructed arm retraction, small-step open-space orbit continuity, character-center
  frustum inclusion and fully collapsed-arm clearance/framing passed. Final output:
  `/tmp/m1-camera-final.log`.
- A framing extension of the regression initially failed 2 of 9 checks after
  the scene-only correction: clearance alone could leave the character out of view.
  Keeping the existing body center as the follow-camera focus fixed both geometric
  framing failures; final results above include these assertions. Intermediate
  evidence: `/tmp/m1-camera-framing-before.log`.
- Existing `--headless --path /workspace/FALSE-WORLD --script
  res://tests/m1/test_graybox.gd`: **31 checks, 0 failures**, exit 0, no engine errors.
  Output: `/tmp/m1-camera-graybox.log`. These tests use physics/synthetic input.
- `--headless --path /workspace/FALSE-WORLD --editor --import`: PASS, exit 0,
  no script/engine errors (permitted editor local sockets); output retained in
  `/tmp/m1-camera-import.log`. `--headless --path /workspace/FALSE-WORLD
  --quit-after 120`: PASS, exit 0, no errors (`/tmp/m1-camera-startup.log`).
- `--headless --path /workspace/FALSE-WORLD --check-only --script res://<path>`:
  PASS for the camera runtime script and both camera/original graybox test scripts.
  Import also validates the referenced scene resources and runtime scripts.
- `python3 /tmp/validate_false_world_camera.py`, `git diff --check`, and
  `git diff --cached --check`: PASS. Reviewed the intended eight-file staged diff;
  checked links/format/UID, exact file scope, preserved handoff/project configuration/
  unrelated runtime scripts and retained `6803e0b` ancestry. No new dependency or asset.

No graphical display is available to the agent. The correction needs a Windows
Godot 4.7.2 recheck of front/side/rear wall and corner orbits, both pitch limits,
wall approach/retreat, camera framing, mesh rendering and retraction/extension
smoothness. Tests check geometric clearance and visibility flags, not actual
rendered visibility or comfort. Sampled coverage is not a guarantee for arbitrary
future geometry, low ceilings, FOV/aspect ratios or altered characters. No FPS,
GPU, frame-time, RAM, Windows export or full-game performance result is claimed.

### User-reported M1 manual verification (first report)

Recorded: 2026-11-02 (Asia/Tashkent), on branch `docs/m1-manual-verification`,
based on clean checkout `9230c71`. Source: the user's report of testing M1 on their
Windows laptop with Godot 4.7.2. These are user-reported observations, not tests
rerun or independently observed by the agent. The exact tested build SHA, session
duration, laptop specifications, resolution and driver were not supplied.

Confirmed by the user in the observed session:

- The 3D scene launches and renders.
- WASD movement works.
- Mouse-controlled camera rotation works in all directions.
- The character cannot pass through the central solid obstacle.
- Holding E moves the interaction lever.
- Releasing E stops interaction and retains partial progress.
- Holding E again resumes progress from the previous position.
- Godot showed **0 errors and 0 warnings** in that observed session.

At the time of this first report, completion/single completion, range/obstruction
rejection, walking-away cancellation, Escape/focus loss, click-to-recapture, dedicated
diagonal/ground/perimeter tests and wall clipping were not separately established.
The latest report above supersedes the corresponding omissions, while unreported
cases and post-fix graphical behavior remain unverified. Prior automated coverage
remains distinct. No FPS, frame-time, GPU, RAM or other
performance measurement, Windows export, or full-game result was reported.

This update changes only `docs/PROGRESS.md`; no gameplay, scene, configuration or
M2 work is included. Documentation verification performed for this update:

- Python standard-library checks: PASS for UTF-8/newline/trailing whitespace,
  local Markdown links, required project paths, three skill metadata headers and
  original empty directory markers; checked the recorded confirmations against
  the user's report and retained explicit untested/performance limits.
- `git diff --name-only` and byte comparisons against HEAD: PASS; only
  `docs/PROGRESS.md` changed, with every other tracked file unchanged and no new
  untracked files. Handoff, Godot configuration, scripts and scenes are preserved.
- `git diff --check`, `git diff --cached --check` and staged diff review: PASS.
  No engine invocation, gameplay test or benchmark was run in this docs-only update.

### M1 limitations and provisional details

The agent implementation environment had no graphical display or Xvfb. The user
reports above provide the listed Windows M1 passes and identify the camera bug.
The latest higher-pivot framing calibration still needs graphical revalidation. Window-focus loss,
walking-away cancellation, dedicated diagonal/perimeter and single-completion
checks were not separately confirmed in the latest report. No Windows export,
Intel-iGPU FPS/frame times/RAM or laptop benchmarks were reported. Neither the observed rendering nor the earlier
headless physics/synthetic input establishes target-hardware performance.

Tuning is provisional: speed 4, gravity 18, work duration 3 seconds, range 2.2 units,
mouse sensitivity 0.003, pitch -65°…20°, spring length 4, pivot height 3.2 and
spherical camera probe radius 0.2; values are prototype tuning for current geometry.
The single target is explicitly wired, with no general targeting framework. No
jump/sprint, save-to-disk, animation, settings/menu UI, damage interruption or later
systems were implemented. Saved partial progress means in-memory progress across
cancel/resume in the same scene. Runtime values do not finalize handoff balance.
All remaining full-game technical questions in the historical record remain open.

### Exact next step

Graphically revalidate **this framing fix branch** on Windows with Godot 4.7.2.
Press against the central obstacle, pedestal, walls and corners; orbit steeply
downward and toward the character's front, then move away while orbiting. Confirm
that the full character remains reasonably sized and visible, without wall/mesh
penetration, jitter or abrupt close-ups; assess the higher viewpoint's usability.
Recheck WASD, E progress/cancel/resume/completion and Escape/click behavior. Record
actual outcomes and debugger messages in PROGRESS.md. Do not begin M2 before a new
scoped task; performance claims require separate measurements.

Only after that validation and a new scoped task, follow the approved next handoff
stage (1 human + 3 AI perception/memory/Director/local-dialogue proof); full survival
and rescue systems remain later work. No AI proof or M2 implementation has begun.

### Historical reconciliation record (before M1)

The following preserves the previous documentation increment's evidence and planned
next step as history. Its statements about absent runtime code and docs-only scope
refer to that earlier increment; the M1 status above supersedes them.

Updated: 2026-11-02 (Asia/Tashkent).

### Current status and authority

Documentation is reconciled with preserved `FALSE_WORLD_HANDOFF.md` v1.0.
Approved gameplay rules are specified, not implemented. There are still no gameplay
scenes, scripts, UI, networking, imported assets, or executable behavior tests.
The root Godot project has no main scene. This is not yet a playable game.

Reconciliation base: `e3eb47e` (`Add finalized game logic handoff`), verified clean
on local branch `work` (not `main`). Dedicated branch: `docs/reconcile-handoff-v1`.
The reconciliation commit contains this record; use `git log -1 --oneline` after
commit for its ID. No push or merge is authorized or performed.

### Completed in this increment

Read AGENTS.md, the complete handoff, GAME_DESIGN.md, ARCHITECTURE.md, this progress
record and all three skills before editing. Changed only these seven existing files:
AGENTS.md; docs/GAME_DESIGN.md; docs/ARCHITECTURE.md; docs/PROGRESS.md; and the
`godot-development`, `game-ai`, `game-testing` SKILL.md files.

- Made v1.0 the gameplay authority, separating approved mechanics, provisional
  values, current implementation status and authorization to write code.
- Replaced summit-arrival/shared-win proposals with individual extraction after
  call/wait, independent beacon and battery/radio routes, persistent sent calls,
  repeat calls, per-human results, deadline ties and one match finalization.
- Replaced combat/inventory exclusions with shared combat/HP/slow regen/medkits,
  finite ammo, permanent death, bounded inventory, full death/escape loot and
  transactional critical-item protection. Kept sabotage local, repairable and bounded.
- Replaced match-wide chat and unresolved bot participation with send-time proximity
  text shared by human/AI, local device information and no global live role roster.
- Documented private final direct-human-damage scoring, pairwise self-defense,
  forgiveness accumulation and no live score/role leak; no persistent Elo/ranked.
- Replaced instantaneous shared AI knowledge with perception/local memory and
  delayed/limited Director reports, provenance/freshness and relevant assignments.
  Added tiers, local dialogue adapters, separate role-blind mobs, spectator limits,
  balanced authored random starts, bounded reconnect and technical host-loss ending.
- Replaced the earlier M0–M5 roadmap with handoff §19's small-first stages, retaining
  the approved full target of four humans, varying 22–25 AI and 1×1 km as unmeasured.
- Aligned all skills and project rules with those boundaries and the current
  docs-only scope. Added no new document, dependency, code, service or asset.

### Verification in this increment

- `git status -sb`, `git log -1 --oneline`: clean starting tree at expected e3eb47e;
  checked out `docs/reconcile-handoff-v1` before edits.
- `python3 /tmp/validate_false_world_reconciliation.py`: PASS. Standard-library
  structural checks verify exactly seven intended tracked edits, no untracked
  additions, SHA-256 equality of every other tracked file (including the handoff,
  project.godot and original root settings), UTF-8/newlines/trailing whitespace,
  local Markdown links, three portable skill names/descriptions, four empty directory
  markers, and handoff-section traceability markers in the reconciled design.
  These checks do not automatically prove semantic equivalence of translated rules.
- Manual source-to-document review against handoff §§1–20: checked each mechanics
  section and the 16 future acceptance scenarios, authority precedence, approved
  constants versus provisional examples, audience privacy and small-first ordering.
  The handoff's historical “repository unverified” statement remains unchanged;
  current verified status is recorded here rather than editing the source.
- `git diff --check` and `git diff --cached --check`: PASS. Reviewed the staged
  seven-file diff for docs-only scope and absence of runtime/configuration edits.
- No engine invocation, import, gameplay test, network session, graphical run or
  performance measurement was executed in this documentation increment. The runtime
  acceptance scenarios are requirements for later work, not passing tests today.

### Historical evidence and limitations

The original M0 foundation increment added rules, design/architecture/progress,
three portable skills and four directory markers, retaining the six original files.
Its recorded checks were `git status --short --branch`, `git ls-files`,
`godot --version`, `python3 /workspace/work/validate_false_world_foundation.py`,
`git diff --cached --check` and manual documentation review. Those are historical
records, not commands rerun for this reconciliation. Its old gameplay proposals and
M0–M5 implementation roadmap are superseded by v1.0 and the new design stages.

Foundation inspection recorded default Godot 4.6.3 versus project feature 4.7.
Separate cloud onboarding in this conversation installed checksum-verified 4.7.2
at `/workspace/.tools/godot/4.7.2/Godot_v4.7.2-stable_linux.x86_64`, completed headless
import with writable XDG directories and local editor socket permission, verified
tracked-file preservation and saved environment installation/start instructions.
That prior import is not a runtime test of new code, a graphical/Windows export
check, or verified publication/restoration. Select and recheck the engine explicitly.
Existing Forward Plus/Jolt/D3D12/application/.NET settings remain unchanged.

No actual movement/camera/interaction, objective, combat, regen, inventory, score,
AI, mob, spectator, chat, reconnect, four-human match or laptop benchmark is validated.
No assets have been added/licensed; create the attribution ledger with the first
verified asset in a later task. Agent auto-discovery/integration is untested; skills
are portable files read explicitly. Human-like dialogue, 22–25-agent/map performance
and free public internet hosting remain unproven.

### Unresolved technical details

Approved gameplay should not be reopened as missing design. Handoff §17 leaves
prototype choices: HP/damage/reach/hit zones/aim reaction/medkit values; regen delay
and initial maximum-HP/120-second rate tuning; weapon classification/ammo/general
capacity; match/action/repair/sabotage/call/wait/repeat timing and resume/cooldown
behavior; base score/deduction/self-defense/forgiveness values and abuse handling;
chat radius/history/rate/input/UI; loot/copy counts and spawn distances/probabilities;
AI ratios/report delay/expiry/dispatch/weights/dialogue scope; mob model/count/senses/
leash/damage; reconnect window/session binding, network/host method and technical
termination display; map layout/jump/slope/collision, extraction presentation,
assets and benchmarks. Exact atomic action conflict/event ordering and spectator
camera/history handling must preserve the approved privacy and resource invariants.
Use configurable provisional values during later authorized prototypes. No paid
service, new major mechanic or unapproved cost is implied by these open details.

### Exact next implementation step

Under a subsequent scoped implementation task, perform handoff §19 stage 2:
verify the selected Godot engine against feature 4.7 and create one isolated small
3D primitive-graybox scene with one locally controlled third-person GDScript
character, follow camera, ground, obstacle and a minimal real interaction target.
Validate walking, ground/obstacle collision, camera behavior and interaction
start/cancel/completion without runtime script errors; record a manual run and any
applicable engine checks. Preserve existing project settings unless that task
explicitly permits a necessary change. Keep AI, networking, rescue loops, combat,
inventory, chat and other later systems out of this first slice. Interaction timing
and traversal details may use clearly provisional configurable values. Do not claim
this technical slice is the full game.

Then follow GAME_DESIGN.md's handoff-aligned stages: 1 human + 3 AI local deception
proof, 6–8 AI one-route small playable with survival systems, four-human networking,
then both routes/full-map/22–25-AI expansion and stabilization. Each requires its own
scope and actual validation; none is implemented by this documentation task.
