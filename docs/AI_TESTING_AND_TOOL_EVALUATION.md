# FALSE WORLD — Stage 3D AI testing and tooling evaluation

Updated: 2026-11-02 (Asia/Tashkent). Engine: Godot 4.7.2, GDScript.

## Decision and scope

Keep the existing tested runtime AI. Stage 3D adds an isolated, unattended scenario
harness and a source/release evaluation of LimboAI and GUT. Neither addon is installed,
loaded, migrated to, or included in exports. No production decision, perception,
reporting, movement, camera, interaction, scene, navmesh, startup or project setting
changes. The handoff remains authoritative; all prototype tuning is provisional.
Cost is 0 UZS. No gameplay expansion, external asset, native binary or new runtime
dependency is introduced.

The harness reduces reliance on visual guesses for information flow and state
correctness. It does not establish human-like behavior, deception, graphical camera
quality, deterministic cross-platform physics, or Intel iGPU performance.

## Running the scenarios

From the repository root, use the exact Godot 4.7.2 binary, not an unspecified older
system installation. Import once before executing scripts that use project classes:

```sh
godot --headless --path . --editor --import
godot --headless --path . --fixed-fps 60 --quit-after 40000 --script res://tests/scenarios/run_ai_scenarios.gd -- --scenario=all --repeat=2 --seed=431
```

Replace `godot` with your installed binary path. PowerShell, for example:

```powershell
$Godot = 'C:\Godot\Godot_v4.7.2-stable_win64_console.exe'
& $Godot --headless --path . --editor --import
& $Godot --headless --path . --fixed-fps 60 --quit-after 40000 --script res://tests/scenarios/run_ai_scenarios.gd -- --scenario=all --repeat=2 --seed=431
$LASTEXITCODE
```

The default report is `user://ai-scenarios/summary.json` (Godot's project user-data
folder, not the repository). `--output=/absolute/path/to/results` overrides it.
`--scenario=lost_moving` selects one case. `--repeat=1..3` and `--seed=INTEGER` are
supported. Use `--fixed-fps 60`: it accelerates a fixed-step simulation; it is not a
60 FPS performance measurement. Require exit 0, `complete: true`, `success: true`,
the expected case count, and no engine/script errors. An engine import succeeding
alone is insufficient. Keep the console log alongside JSON, especially on failure.

An optional Python 3 standard-library launcher adds an independent process deadline,
saves `runner.log`, rejects engine errors and incomplete JSON, and clears its previous
summary before launch. Python is not needed for the GDScript runner or game:

```sh
python tools/run_ai_scenarios.py --godot /path/to/Godot-4.7.2 --output /tmp/false-world-ai --repeat 2 --seed 431
```

The launcher defaults to a 120-second process timeout (`--timeout`, greater than 0,
maximum 600 seconds). Exit 124 means process timeout; invalid arguments/launch setup
use 2; scenario/assertion/completion failures are nonzero. It invokes Godot without
a shell. A direct engine invocation still has the runner's 120-second wall watchdog
and the command's finite 40,000 rendered-frame ceiling. Per scenario: maximum 3,600
controlled physics ticks, 15 seconds wall time, 512 observation events and 2,048 trace
entries. A slow machine can legitimately fail a watchdog: retain diagnostics rather
than raising production budgets or weakening assertions.

## Harness boundaries and reproducibility

- `tests/scenarios/run_ai_scenarios.gd`: CLI selection, fresh fixtures, repeats,
  watchdog, compact stdout, JSON diagnostics, failure exit codes and semantic hashes.
- `scenario_fixture.gd`: instantiates the real Stage 3C scene with its authored map,
  actual PhysicsServer collision/rays, NavigationServer map and CharacterMotor.
  It disables only that instance's composition scheduler and local player input.
  An integer clock starts at zero; the existing staggered sensor/decision phases
  are invoked once per controlled physics step. Native physics and enabled followers
  still run. Navigation synchronization is awaited before assertions.
- `scenario_cases.gd`: controlled initial poses, seed, visibility, actions, deadlines
  and explicit assertions for each case. Enabling a follower uses the existing
  executor, not a mocked motion/path implementation.

Only the privileged test fixture can move the human directly or inspect fixture
truth. None of these modules is referenced by runtime scenes/scripts/startup, and
none sends those transforms to decision code. There is still one human and three AI;
uninvolved controllers are parked/unscheduled to isolate each causal case. This
is controlled integration testing, not a real-time full-population simulation.

A separate ledger witnesses each actual sensor signal against a physical ray,
range, forward cone, current fixture position and original tick/ID/source/event.
Every controlled tick audits all three private memories and selected evidence against
that ledger. Indirect facts must follow an allowed route after its minimum delay,
retain the original time/point, and be labeled `team_report`. Committed investigation
destinations must stay fixed; active path targets must match them within the existing
projection tolerance. Exploration targets must be authored static sites. No hidden
live target may appear as a new fact, refresh an old fact, or replace a committed goal.

This is an executable invariant for the exercised paths, not a proof against every
possible future leak. Fixture truth is recorded in developer-only artifacts; do not
present these artifacts to living players or replicate them as gameplay state.

Traces record observations, memory receipt, each scheduled decision's before/after
state, evidence time/point/source, selected navigation destination, retry/path counters,
previous deadline/execution feedback, coordination assessment/reason and a read-only
transition explanation. The explanation classifies completed transitions; it cannot
control AI. JSON retains the full bounded trace; stdout prints a short case result
and the last 12 events plus failures when a case fails.

Per scheduled phase, assertions cap explicit path requests at two, decision steps at
one and coordination assessments at eight. Queue/private-memory capacities are also
checked. These are work-count bounds, not a measurement of all NavigationServer CPU
work or an FPS/RAM claim.

Repeats compare SHA-256 over ordered observation and state-transition events, original
evidence ticks, IDs and committed destinations (coordinates snapped to 1 mm). This
checks repeatable logical outcomes on this engine/environment. It deliberately does
not compare continuous body trajectories, native map RIDs or wall-clock durations.
Godot physics is not promised bit-identical on Windows/Linux or other CPUs. A different
Windows hash is a diagnostic to inspect, not permission to update a golden value blindly.

## Scenario coverage and measured results

Final seed 431 run, repeated twice: **16/16 cases, 98 explicit assertions, 6,886 audited
ticks, 0 unexpected failures**; all eight semantic hashes matched between repetitions.
Seed 432: **8/8 cases, 49 assertions, 3,413 audited ticks, 0 unexpected failures**.
These totals exclude the independent existing regression suites below.

| CLI ID | Controlled case and measurable acceptance | Seed 431 assertions / ticks per repetition |
| --- | --- | --- |
| `visible` | Clear physical LOS emits a real observation, selects vision-backed Observe at the witnessed point, then ends its bounded pause without pursuit. | 6 / 135 |
| `wall` | In-range, forward human behind the central solid box: blocked ray, no observations, no memory fact, continued Explore. | 5 / 123 |
| `lost_moving` | First genuinely seen, then moved twice behind the solid box: old time/point and path goal stay frozen; real follower reaches old point and enters Resume. Every tick rejects unsupported live facts. | 9 / 195 |
| `delayed_report` | One real sighting, hidden human, normal ring delivery: no recipient fact before 30 ticks, then original point/time and indirect source, independent response, unaddressed third memory empty. | 6 / 55 |
| `independent_reports` | One actual sensor signal sent through two independent one-recipient test channels: separate memory objects, same legitimate old evidence, distinct seeded approach points/deadlines, copied views cannot mutate peers. | 7 / 55 |
| `expires_travel` | Real travel with fixture-only freshness 100 ticks: starts Investigate, expires before arrival, enters Resume and removes actionable expired memory. | 6 / 120 |
| `blocked` | Observe a valid destination, then add a solid physical blocker: existing follower stalls, retries at most twice and abandons to Resume without crossing it. | 5 / 240 |
| `repeated` | Stationary fixture, 81 actual ray-based sightings with eight visible/hidden cycles across 2,520 ticks: one finite investigation, exactly four transitions, no restart at the same location across cooldown windows. | 5 / 2,520 |

Every row includes navigation-sync assertion and the common per-tick provenance/work
checks. The blocked case uses fixture-only `stall_timeout_ticks=30` to exercise finite
physical retry/abandonment before ordinary evidence expiry; production values remain
unchanged. Existing suites separately cover off-navmesh/unreachable paths and detours.
The expiry case's 100-tick lifetime is also test-only, not finalized balance.

The two-recipient case is deliberately a test topology. Production retains its
one-recipient ring; this does not add a broadcast feature. Its recipients run the
real memory, delayed channel, coordination and decision code. The repeated-sighting
case leaves the follower disabled to isolate sighting suppression; actual travel and
physics are covered by the other cases and existing suites.

Negative controls, intentionally failing:

- `python tools/run_ai_scenarios.py --godot GODOT --scenario lost_moving --repeat 1 --audit-probe`:
  exit **1**, `UNSEEN_FACT: no actual observation for K72:F11:21`. This flag deliberately
  corrupts fixture memory with a hidden current point/new tick; no production AI changes.
- Launcher `--timeout 0.001`: exit **124**, `PROCESS TIMEOUT` recorded; no stale success.
- Launcher `--scenario unknown --repeat 1`: exit **2**, invalid-selector diagnostic and
  missing completion rejected.

No ordinary scenario failed in the final runs. During harness development an initial
CLI guard incorrectly expected Godot to retain `--fixed-fps` in `OS.get_cmdline_args()`;
Godot consumes it. That guard exited 2 and was removed. All documented commands still
pass the engine flag. This was a test-runner setup error, not an AI behavior fix.

## Existing engine/regression validation

Actual binary: `/workspace/.tools/godot/4.7.2/Godot_v4.7.2-stable_linux.x86_64`,
`4.7.2.stable.official.ed1daf0bf`. Cloud XDG directories were `/workspace/.cache`,
`/workspace/.local/share`, `/workspace/.config` for cache/data/config respectively.

- Headless editor import: exit 0. `--check-only --script res://PATH` for all three
  scenario GDScripts: exit 0.
- Existing `--headless --path . --script res://PATH` suites, unchanged:

| Script under `tests/` | Checks | Failures |
| --- | ---: | ---: |
| `stage3c/test_coordination.gd` | 35 | 0 |
| `stage3b2/test_ai_debug.gd` | 33 | 0 |
| `stage3b1/test_observation_decisions.gd` | 45 | 0 |
| `stage3a1/test_exploration.gd` | 25 | 0 |
| `stage3a/test_foundation.gd` | 39 | 0 |
| `m1/test_graybox.gd` | 31 | 0 |
| `m1/test_camera_clearance.gd` | 15 | 0 |
| **Total** | **223** | **0** |

- Default Stage 3C startup: `--headless --path . --fixed-fps 60 --quit-after 1800`,
  exit 0. One run emitted a Jolt job-system capacity warning during overlapping
  validation; an isolated repeat exited 0 with no warning/error. Cause is unproven.
  This is not a graphical/performance pass.
- Standalone M1 startup: same command with `--quit-after 120 res://scenes/prototype/m1_graybox.tscn`,
  exit 0. Headless tests preserve tested controls/interaction/camera logic but cannot
  demonstrate mouse feel, camera visibility, rendering or performance.

Cloud artifacts are ephemeral, not shipped logs: `/tmp/false-world-stage3d-final/`
(summary + console), `/tmp/false-world-stage3d-seed432/`, `/tmp/false-world-stage3d-negative/`,
`/tmp/false-world-stage3d-timeout/`, and `/tmp/stage3d-*.log` (engine/regression checks).

## Official Godot guidance applied

Reviewed the official **4.7 documentation source**, pinned at
`9adca4c1c72917bfe1b7be3108abed5ce26696a6`, retrieved 2026-11-02:

- [Using NavigationAgents](https://github.com/godotengine/godot-docs/blob/9adca4c1c72917bfe1b7be3108abed5ce26696a6/tutorials/navigation/navigation_using_navigationagents.rst):
  wait for map synchronization; setting targets repeatedly can cause dancing;
  call path progression only during active travel, and move the actual character
  with physics. Avoidance is optional and does not replace physical collision.
- [Navigation debug tools](https://github.com/godotengine/godot-docs/blob/9adca4c1c72917bfe1b7be3108abed5ce26696a6/tutorials/navigation/navigation_debug_tools.rst):
  visible navigation/avoidance and server debug toggles assist manual diagnosis.
  The navigation process-time monitor **excludes pathfinding cost**; do not call it
  total navigation CPU cost. Native debug drawing is for debug builds.
- [Debugging tools](https://github.com/godotengine/godot-docs/blob/9adca4c1c72917bfe1b7be3108abed5ce26696a6/tutorials/scripting/debug/overview_of_debugging_tools.rst):
  debugger/profilers and visible collision/navigation complement assertions; they
  cannot assert private evidence provenance without project instrumentation.
- [Command line](https://github.com/godotengine/godot-docs/blob/9adca4c1c72917bfe1b7be3108abed5ce26696a6/tutorials/editor/command_line_tutorial.rst):
  headless script execution, import, fixed step and finite quit options enable
  unattended integration checks.

The documentation website and GitHub API requests were blocked by the cloud proxy
(403). Official GitHub source, refs and release/asset HTML were accessible and used
instead; no network policy bypass or fabricated compatibility test occurred.

## Tool comparison: upstream support versus locally verified compatibility

Source/release review date: 2026-11-02. No addon was executed on Linux or Windows,
and no addon export was built. Published support is not a local smoke-test result.

| Topic | LimboAI | GUT |
| --- | --- | --- |
| Pin reviewed | **v1.8.1**, commit `e45e60e976dafab7f2c15cc341ae366e4cf3352b` | **v9.7.1**, commit `aeb5d4f3f7f0a6c9b5e178876d6c99b791fda605`, `godot_4_7` branch |
| Godot 4.7.2 | Upstream 1.8.x table supports GDExtension on 4.6+, module on 4.7; release publishes explicit **4.7.2** editors/export templates. The GDExtension asset is named 4.6 and covered by the 4.6+ claim, not locally tested here. | Pinned README explicitly maps 9.7.1 to **4.7.x**, covering 4.7.2. Main still targets 4.6.x. No local 4.7.2 addon execution/export test here. |
| Useful features | Native behavior trees, editor, composites/decorators/custom GDScript tasks, scoped blackboards/plans, HSM with LimboState/BTState, visual debugger and monitors. HSM setup is code-based, not a promised graphical HSM editor. | GDScript assertions, fixture lifecycle, parameterized/inner test classes, doubles/stubs/spies, CLI runner and JUnit XML reporting. It is a test framework, not AI/navigation tooling. |
| Repository benefit | Could improve authoring/debugging when behavior complexity materially grows. Does not supply this project's bounded LOS, memory privacy, report latency, physical rules or scenario assertions. | Could standardize existing custom suites, setup/teardown and CI reports while retaining actual integration fixtures and provenance audits. |
| Migration cost | Adapt four states/action boundaries, preserve per-agent information scopes, revalidate all scenarios, native packaging/upgrade matrix. A shared unrestricted blackboard would violate approved knowledge rules. | Port assertions/fixtures incrementally; headless async timeout/completion safeguards and project-specific scenarios still needed. Avoid replacing real integration checks with doubles. |
| Windows/export | GDExtension uses stock Godot plus matching Windows DLLs for editor/debug/release and target architecture. Module requires the custom LimboAI editor **and matching export templates**, rather than stock templates. | Pure GDScript addon: no custom engine, native DLL or C# requirement. Keep developer test assets/scripts out of production export where feasible and check export filters in a future adoption task. |
| Build/maintenance | Prebuilt binaries available; source builds need C++/SCons and matching Godot/godot-cpp. Update native libraries/templates together and smoke-test Windows/export on every upgrade. GDExtension lacks documentation tooltips and the BBParam convenience editor listed by upstream. | Version-pin 9.7.1 for this engine; maintain addon updates, async test semantics and notices. Lower packaging cost, still extra code to maintain. |
| Recommendation now | **Do not migrate.** Four tested states do not yet justify native/export coupling. | **Do not install in Stage 3D.** Prefer a later small test-only trial if standardized reports/fixtures justify it. |

LimboAI's README headline says Godot 4.6 while its detailed compatibility table and
v1.8.1 release assets provide the above finer distinction. Its `.gdextension` descriptor
also says minimum 4.2; that permissive loader field is not evidence that this release
supports every engine from 4.2. Pin the release/table/build tuple, not the headline
or descriptor alone. Neither upstream support claim proves laptop performance.

### Size and packaging evidence

Source archives were inspected in temporary research storage only, not copied into
the repository or loaded as addons. ZIP lengths and uncompressed file sums measured:

| Evidence | Size / implication |
| --- | --- |
| LimboAI pinned source ZIP | 8,602,196 bytes compressed; 719 files, 10,156,535 uncompressed bytes including docs/demo; no native binary in this source ZIP. |
| GUT pinned source ZIP | 1,136,993 bytes compressed; 259 files, 2,545,856 uncompressed bytes under `addons/gut`; no native binaries. This source archive contains addon files, not repository docs. |
| LimboAI v1.8.1 GDExtension 4.6 asset | Release page displays **30.8 MB**, a prebuilt package, not measured game RAM. |
| LimboAI v1.8.1 Godot 4.7.2 Windows x86_64 editor | Release page displays **83.9 MB** ZIP, replacing the stock editor for module use. |
| Matching Godot 4.7.2 all-platform export templates | Release page displays **1.2 GB** ZIP; bundle size is not the size of a single Windows export. |

The prebuilt packages were not downloaded, installed or run. Displayed release sizes
are distinct from measured source byte counts; neither establishes imported footprint,
final export size, startup cost or runtime RAM. GDScript needs no .NET editor build.

### Licenses and third-party obligations

- LimboAI code: MIT, copyright 2023–2025 Serhii Snitsaruk and contributors. Retain
  copyright and permission notice when redistributing code/binaries. No paid service
  or commercial-use fee is required by that license.
- LimboAI logo: CC BY 4.0, Aleksandra Snitsaruk. Demo PNG/SVG assets have a separate
  CC BY 4.0 notice (2024 Aleksandra Snitsaruk). If imported later, retain attribution,
  license link and indicate changes; do not assume the MIT code license covers art.
  Demo font metadata identifies Junction Bold (Caroline Hadilaksono, SIL OFL) and
  Knewave (Tyler Finck, SIL OFL 1.1); preserve the applicable font notices/license
  and reserved-name restrictions if redistributed.
- GUT code: MIT, copyright 2018 Tom “Butch” Wesley; retain copyright/permission text.
  Its bundled Anonymous Pro (Mark Simonson), Courier Prime (Courier Prime Project
  Authors) and Lobster Two (Pablo Impallari) font metadata identifies **SIL OFL 1.1**.
  Preserve font copyright/OFL notices, do not sell fonts alone, and respect reserved
  font names for modifications. The MIT code notice is not a blanket font license.
- Neither source archive installs assets here. A future import must record exact
  selected files/licenses/source/changes in `assets/ATTRIBUTION.md`, retain required
  texts, and review shipped native/engine notices and export contents. This review
  does not claim a full binary-distribution license audit.

### Sources for tool claims

- [LimboAI pinned README/support/features](https://github.com/limbonaut/limboai/blob/e45e60e976dafab7f2c15cc341ae366e4cf3352b/README.md),
  [v1.8.1 release/assets](https://github.com/limbonaut/limboai/releases/tag/v1.8.1),
  [installation and export implications](https://github.com/limbonaut/limboai/blob/e45e60e976dafab7f2c15cc341ae366e4cf3352b/doc/source/getting-started/getting-limboai.rst),
  [GDExtension descriptor](https://github.com/limbonaut/limboai/blob/e45e60e976dafab7f2c15cc341ae366e4cf3352b/gdextension/limboai.gdextension),
  [MIT notice](https://github.com/limbonaut/limboai/blob/e45e60e976dafab7f2c15cc341ae366e4cf3352b/LICENSE.md),
  [logo notice](https://github.com/limbonaut/limboai/blob/e45e60e976dafab7f2c15cc341ae366e4cf3352b/LOGO_LICENSE.md),
  [demo asset notice](https://github.com/limbonaut/limboai/blob/e45e60e976dafab7f2c15cc341ae366e4cf3352b/demo/LICENSE_ASSETS.md).
- [GUT pinned README/support/features](https://github.com/bitwes/Gut/blob/aeb5d4f3f7f0a6c9b5e178876d6c99b791fda605/README.md),
  [v9.7.1 release](https://github.com/bitwes/Gut/releases/tag/v9.7.1),
  [addon MIT notice](https://github.com/bitwes/Gut/blob/aeb5d4f3f7f0a6c9b5e178876d6c99b791fda605/addons/gut/LICENSE.md),
  [bundled fonts](https://github.com/bitwes/Gut/tree/aeb5d4f3f7f0a6c9b5e178876d6c99b791fda605/addons/gut/fonts).

No LimboAI demonstration scene is added: without loading its native addon it would
not demonstrate the tool, and installation is explicitly excluded from this task.
A paper mapping is sufficient at this stage: Explore/Observe/Investigate/Resume could
map to four LimboState children of an HSM; existing perception/private-memory/channel
adapters and shared executor would remain the only fact/action boundaries. This is
an evaluation sketch, not executable migration code or a feature commitment.

## Next validation and adoption gate

Exact next step: run the default eight-case/two-repeat command on the user's Windows
Godot 4.7.2 installation and retain exit code, console log and JSON. Check all 16 rows,
compare repeat hashes on that machine, and inspect any difference from Linux using
its detailed trace before changing assertions or runtime behavior.

Then use the unchanged Stage 3C scene/F3 overlay for a short graphical sanity check
of old-location travel, obstacle recovery, smooth motion and M1 input/interaction.
Remaining camera occlusion/readability and FPS/frame time/RAM on the target laptop
remain unmeasured here. Do not infer that this task resolves them or validates full
population/deception. Before scaling, profile actual AI/pathfinding as well as GPU
cost using the documented target-hardware procedure.

Only a later scoped task should trial GUT 9.7.1 against one existing suite and one
scenario with unchanged invariants, or trial LimboAI 1.8.1 in a separate project with
Windows stock-4.7.2 GDExtension loading and debug/release export smoke tests. Measure
integration/maintenance benefit before replacing tested code. No gameplay expansion
or tool migration is started by Stage 3D.
