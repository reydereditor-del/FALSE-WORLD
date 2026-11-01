# FALSE WORLD — progress

Updated: 2026-11-02 (Asia/Tashkent).

## Current status — M1 local graybox

M1 runtime implementation is complete as a local technical slice, corresponding to
handoff §19 stage 2. Automated checks passed in the implementation increment.
The user has now reported a Windows/Godot 4.7.2 manual pass for the cases listed
below; remaining manual cases and performance measurements are still unverified.
There is no multiplayer, AI, combat, HP, inventory, mission/extraction, or gameplay
UI. The full game remains planned. Approved handoff v1.0 rules remain unchanged.

Base: freshly fetched `origin/main` at merge `2d0effe` (includes `4e05ce9`). Verified
with `git merge-base --is-ancestor 2d0effe HEAD` after creating dedicated branch
`feat/m1-local-graybox`. The initial working tree was clean. No push or merge is
part of this increment. Use `git log -1 --oneline` for the resulting M1 commit ID.

## Completed M1 work

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

## M1 verification actually performed

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

## User-reported M1 manual verification

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

The report does not establish completion/single-completion behavior, out-of-range
or blocked interaction rejection, cancellation by moving away, Escape/focus loss,
click-to-recapture, dedicated diagonal-speed/ground/perimeter checks, camera clipping
near walls or comfort over extended play. Those remain pending manual verification;
prior automated coverage remains distinct. No FPS, frame-time, GPU, RAM or other
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

## M1 limitations and provisional details

The agent implementation environment had no graphical display or Xvfb. The later
user report above supplies Windows scene rendering, basic movement/camera, central
obstacle collision and lever start/cancel/resume evidence. Remaining manual cases
listed above are unverified. No Windows export, Intel-iGPU FPS/frame times/RAM or
laptop benchmarks were reported. Neither the observed rendering nor the earlier
headless physics/synthetic input establishes target-hardware performance.

Tuning is provisional: speed 4, gravity 18, work duration 3 seconds, range 2.2 units,
mouse sensitivity 0.003, pitch -65°…20°, spring length 4; values are configurable.
The single target is explicitly wired, with no general targeting framework. No
jump/sprint, save-to-disk, animation, settings/menu UI, damage interruption or later
systems were implemented. Saved partial progress means in-memory progress across
cancel/resume in the same scene. Runtime values do not finalize handoff balance.
All remaining full-game technical questions in the historical record remain open.

## Exact next step

Complete the remaining graphical **M1 acceptance checks** in `docs/M1_PROTOTYPE.md`
using Godot 4.7.2: dedicated diagonal/ground/perimeter checks, camera clipping near
walls, lever completion/single completion, blocked/out-of-range interaction and
walking-away cancellation, Escape/focus loss and click-to-recapture. Record actual
outcomes and any debugger errors; measure performance separately before claiming
FPS/GPU/RAM results. Fix only demonstrated M1 defects in an authorized code task.
The confirmed user-reported cases above do not need to be described as untested.
Do not begin M2 in this documentation update.

Only after that validation and a new scoped task, follow the approved next handoff
stage (1 human + 3 AI perception/memory/Director/local-dialogue proof); full survival
and rescue systems remain later work. No AI proof or M2 implementation has begun.

## Historical reconciliation record (before M1)

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
