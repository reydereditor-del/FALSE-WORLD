# FALSE WORLD — architecture

Status: planned full-game boundaries; M1 local movement/camera/interaction is
implemented as described in [M1_PROTOTYPE.md](M1_PROTOTYPE.md). Stage 3A local AI
foundation is described in [STAGE3A_PROTOTYPE.md](STAGE3A_PROTOTYPE.md). Current local
observation decisions are in [STAGE3B1_PROTOTYPE.md](STAGE3B1_PROTOTYPE.md), with
limited local report coordination in [STAGE3C_PROTOTYPE.md](STAGE3C_PROTOTYPE.md); later systems
and the complete deception proof remain planned. Stage 3D adds isolated integration
scenarios and a tooling review in [AI_TESTING_AND_TOOL_EVALUATION.md](AI_TESTING_AND_TOOL_EVALUATION.md).
[FALSE_WORLD_HANDOFF.md v1.0](FALSE_WORLD_HANDOFF.md) controls approved gameplay;
[GAME_DESIGN.md](GAME_DESIGN.md) reconciles it. Technical choices below are proposals
unless required by that handoff. Implement only the current explicitly scoped task.

## Existing project and preservation

The root `project.godot` declares `4.7`, `Forward Plus`, Jolt 3D physics, a Windows
D3D12 preference, `New Game Project`, and a .NET assembly name. M1 adds the graybox
startup scene and its six input actions; all other settings are retained. Runtime
code uses GDScript. Do not recreate the project,
change renderer, downgrade its feature declaration, or infer a playable game from docs.

Earlier foundation inspection recorded default Godot 4.6.3, older than the declared
4.7. Separate cloud onboarding subsequently installed checksum-verified Godot 4.7.2
under `/workspace/.tools/godot/4.7.2/` and completed headless import. That is prior
session evidence, not a fresh check in this documentation task or proof of graphics,
gameplay, exports, Windows compatibility, or future-machine restoration. Reverify
engine selection before implementation; do not assume the default `godot` changed.

## Repository layout

- `AGENTS.md`: common project rules for Codex and Antigravity.
- `docs/FALSE_WORLD_HANDOFF.md`: preserved authoritative v1.0 gameplay source.
- `docs/GAME_DESIGN.md`: reconciled mechanics, provisional details, delivery stages.
- `docs/ARCHITECTURE.md`: this planned system design.
- `docs/PROGRESS.md`: actual completion, checks, limitations, next task.
- `.agents/skills/{godot-development,game-ai,game-testing}/SKILL.md`: portable skills.
- `scenes/prototype/m1_graybox.tscn`: standalone local yard and character composition.
- `scripts/character/`, `scripts/interaction/`: M1 control, camera, motor and work logic.
- `tests/m1/test_graybox.gd`: built-in Godot headless behavior checks.
- `docs/M1_PROTOTYPE.md`: controls, tuning, validation and manual playtest instructions.
- `assets/`: empty reservation; existing directory markers are retained.

No extra `GAME_LOGIC.md`, services, addons, dependencies, assets, or framework
scaffolding are needed for M1. Add feature directories only with authorized code.

## Modules and dependency direction (handoff §16)

Use small typed GDScript modules, plain data/RefCounted rules where practical, Node
adapters for Godot lifecycle/physics, explicit dependencies and focused signals.
Avoid a global event bus, universal service framework, or one autoload per box.
A small composition root can wire systems later; do not implement empty modules now.
Rules accept validated requests and explicit time/state; they do not reach into
camera/UI paths or require a live network to test.

| Boundary | Owns | Inputs and limits |
| --- | --- | --- |
| Game Manager / match rules | Lifecycle, visible deadline, individual escaped/dead/timed-out results, one finalization | Objective/death/session events and injected clock; extraction wins deadline ties; no overtime or all-AI-dead auto-win |
| Shared Character | Motor, physical constraints, HP/regen/damage, equipment and interaction execution | Replaceable human/local/bot/remote command sources; identical rules and real resources for human/AI |
| Combat / healing rules | Valid attacks, range/hits, finite ammo, reload, medkit and regen timing | Character/inventory interfaces; interruption never grants unfinished ammo/healing items; zero HP is permanent death |
| Inventory / Loot | Unique item ownership, 1 large + 1 small weapon limit, bounded other capacity, pickup/drop, death/escape loot, critical-item recovery | Atomic authority transactions; no hidden reserve weapons, no duplication, no ordinary loot respawn |
| Objective System | Independent beacon and battery/radio station, resumable work, repair/sabotage, sent call, wait and repeat extraction | Validated character/item/proximity/time; sent calls survive sabotage/caller loss, auto-extract living humans in area |
| World / spawn validation | Authored valid points, balanced random starts, reachable critical drop/recovery points, route access | Seed and geometry/navigation constraints; no instant-kill/device/part starts or systematic Advanced-AI placement at humans |
| Perception / Memory | Observations, local beliefs, expiry and provenance | Sensed events or justified reports only; never unrestricted server truth |
| AI Director | Delayed/limited reports, freshness, strategic assignment to relevant agents | Filtered memory and travel/feasibility estimates; no frame-by-frame control or automatic swarm |
| Agent Planner | Basic/Intermediate/Advanced decisions, utility/feasibility, task execution/abandonment | Own knowledge/assignments and shared character actions; risk and self-preservation, no cheating |
| Mob AI | Role-blind sensing, warning, approach, attack, retarget, leash/return | Ordinary local perception; independent of hidden AI team, initially one type and no killed-mob respawn |
| Chat Service / dialogue adapter | Send-time proximity recipients, bounded history/rate/length, local templates/intents | Authority-bound sender and positions; same human/AI delivery, no fabricated system messages |
| Score Service | Direct human-damage ledger, pairwise self-defense windows, small-hit accumulation, final deductions | Private role registry and validated damage events; outputs only at match end, never to AI knowledge |
| Networking / session | Authoritative identity, validation, state routing, reconnect ownership and timeout | Clients request; authority checks movement, damage, range, loot, objectives and AI state; no role leaks |
| Spectator | Living-character camera selection across both roles and allowed local chat | Role-blind view, no hidden inventory/AI state, free flight or signals to living players |
| Presentation | Camera, input, landmarks, local device/call feedback, neutral IDs, eventual UI | Audience-filtered state only; no rule authority or live global human/death/extraction roster |

## Authority, transactions, and match ordering

Keep authoritative truth (roles, damage, items, objective state, outcomes) separate
from both replicated views and AI beliefs. Every client report is a request, not
proof. Bind commands/chat/reconnect to authenticated session ownership rather than
client-supplied actor/sender IDs. Validate range, movement constraints, hit conditions,
resources, target state, and action feasibility on the authority. AI decisions use
the same action interfaces; server residence grants no gameplay omniscience.

Treat item pickup and completion as atomic transitions with stable item identities:
parallel pickups grant once; installation consumes/attaches only at completion;
interrupted installation retains its item; medkits consume only on completion;
incomplete reload grants no ammo. Each repair/install action has one worker, no
multiplayer speed multiplier, resumable progress, cancel/damage interruption. Define
conflicting-action ordering and retry/idempotency behavior before their implementation.
Critical recovery moves the existing item to a reachable safe point without cloning.
Death leaves full loot through match end even after corpse removal; escape leaves
accessible loot at the exit. Both mission parts fit one carrier.

Model each route's device/work, sent-call/wait and extraction cycle independently.
Beacon needs no station parts. Station requires one battery and one radio in either
order, retaining installed parts across repairs and later calls. Sabotage is local,
timed, repairable and bounded; it cannot cancel a sent call or permanently softlock
both routes. Caller death/departure/disconnect does not cancel a sent call. At arrival
extract all living humans in the area automatically, with AI presence harmless to
eligibility. Empty arrivals save nobody and permit another call; later groups may
call again. Exact states, repeat scheduling and visuals remain prototype choices.

Use an explicit simulation clock and event ordering. Complete extraction before
expiry at the identical timestamp, retain earlier individual wins, and finalize
once when all humans are escaped/dead or the deadline is reached. Reconnect timeouts
cannot add overtime. Separate technical host termination from normal gameplay results.

## Networking and audience privacy

Authoritative networking is required; hosting and internet connection method are
unresolved. Godot built-in networking/ENet with a player host is a free candidate for
a local/LAN prototype, not an approved internet deployment or free public server
promise. Host migration is excluded initially; host loss ends the match technically.
A host can inspect its process, so cheating-host resistance is not guaranteed.

Generate unique military-style IDs from one human/AI pool with no nicknames; exact
format is pending. Replicate only what an audience needs: public physical actions,
appropriate equipment visuals, local device/call information, global timer and
per-recipient text. Never broadcast unnecessary `is_ai`, tier, Director memory,
human registry, unsensed mission state, live human list or score ledger. Death,
loot, extraction, disconnect markers and logs accessible to players must not encode
hidden role. Developer diagnostics require deliberate access boundaries. At final
match end reveal human identities and individual outcomes, retaining tier secrecy.
Role-neutral presentation does not promise perfect behavioral indistinguishability.

Deliver text to humans/AI within radius at send time, ignoring walls initially.
Keep bounded recipient history; no past-chat replay to new arrivals or new messages
from departed distant senders. Use identical styling/length/rate limits, literal safe
text, no global/private/voice channels or AI badge. The chat adapter changes how AI
select words, never delivery permissions or rules. Input while typing is a future
UI choice; chat never pauses simulation and closes immediately for defense.

A disconnected character remains with equipment, vulnerable, without AI takeover.
Within a configurable bounded window, reconnect returns to the same actor, or to
spectating if dead. Expiry kills the actor with full loot. Reject new living late
joins; reserved reconnect is permitted. Host-loss display and identity/session
binding details need implementation design; notifications must not reveal humans.

Dead/escaped humans view living human or AI cameras with only normal visuals and
chat received by the watched subject; no human-only selection, free camera, hidden
inventory, or AI internals. Block spectator commands/chat/pings to living players.
Camera switching/history delivery details must respect these limits. External
voice/messaging leaks cannot be fully prevented.

## Restricted AI knowledge and decision flow

AI know their teammate IDs; a visually identified human-like non-teammate can be
classified as human. That does not reveal current position, HP, inventory, intention
or objective status. Even authority-owned agents must obtain those through perception
or justified reports. Observation records contain observer, known subject if any,
event, position, time, confidence and source. Last-seen facts age and expire instead
of silently following a target through walls.

Required flow: perception → local memory → delayed/limited Director report →
freshness check → relevant assignments/information → local planner → shared action
interface. Internal AI coordination is separate from proximity text. Do not give
every agent instantaneous access to all sensed facts or Director/server memory.
Report transport delay/expiry/dispatch/weights are provisional. Assignments account
for travel and available evidence; agents can abandon blocked routes or tasks to
survive, or take calculated risks. Optimize with staggered decisions, bounded
navigation retries and memory, avoiding per-frame all-pairs perception. Cadence is
unmeasured; do not turn earlier 2–5 Hz examples into fixed balance.

Basic majority / Intermediate / rare Advanced are capability tiers, not different
physics or hidden resources. Agents choose help, observation, misdirection, sabotage,
delay, retreat or fighting; seeing a human or being accused does not mandate attack.
No teleport, wall GPS, infinite ammo, perfect aim, collision bypass, invisible
inventory, permanent all-copy hoarding, or magic mob awareness. Repath or abandon
infeasible tasks. Mob AI cannot access team roles or Director coordination and uses
the same sensing/damage rules against both sides, with warnings and bounded pursuit.

Start dialogue with local contextual templates/intents behind a replaceable adapter.
No paid runtime inference, LLM dependency, or training stack. Spoken claims cannot
create mechanics or fake system messages. Human-level free conversation for 22–25
agents on a laptop is not guaranteed. Future model/API use needs separate evaluation.
Use injected seed/time and logs for repeatable logic tests, without claiming
bit-for-bit deterministic physics or networking.

## Private scoring and health boundaries

Combat emits validated direct damage to health and the private Score Service.
Health handles delayed slow living-only regen, reset-on-hit, capped healing and
permanent death equally for humans/AI. Start rate maximum HP / 120 seconds is
provisional; delay and maximum HP are unresolved. Timed interruptible medkits heal
self or a nearby actor faster; no food/regen resource.

Score rules track initiating human-to-human damage, a victim's pairwise temporary
self-defense exemption refreshed by attacker damage, and cumulative small contacts
against a provisional forgiveness threshold. Do not exempt unrelated third-party
attacks or later revenge automatically. No extra kill penalty, AI/mob penalty or
kill bonus; no indirect-blame inference. Deductions affect final score only, not
escape victory. Formula/base scores/windows/threshold need configurable values and
abuse tests. Never emit live score changes, role sounds or messages that confirm
humanity; keep the ledger out of player and AI observation channels.

## Scale, cost, and remaining decisions

Target Windows, Intel i5, integrated graphics and 16 GB RAM. The approved full scope
is 4 humans, varying 22–25 AI and a 1×1 km map; these are design targets, not measured
performance. Follow handoff §19 stages in GAME_DESIGN.md: small traversal/interaction,
1 human + 3 AI, then 6–8 AI with one complete route and survival systems, then four
human networking, then both routes/full map/population, then stabilization. Do not
replace full-scope targets with old exploratory 8/16/24 counts or build everything
in the next task.

Use small authored grayboxes first and bounded content/physics/navigation budgets.
Instancing, modular geometry, LOD and culling are candidate tools; distant-agent
optimization must preserve travel time, knowledge, and items. Compatibility renderer
may be evaluated only in a future authorized task; current Forward Plus is preserved.
Earlier 720p/30 FPS/2 GB examples are provisional experiments, not approved benchmarks.
Measure actual CPU/GPU frame times, RAM, navigation and AI updates on the target laptop;
headless import cannot establish rendering performance.

Budget goal 0 UZS, absolute limit 100,000 UZS; no spending without user permission.
No paid service or mandatory hosting dependency is introduced. Built-in tools,
local AI and primitive geometry reduce cost/dependency overhead. Only free assets
with verified intended/commercial-use rights may later be imported; record source,
author, exact license/version, retrieval date, paths, modifications and obligations
in `assets/ATTRIBUTION.md` when the first asset is added, retaining license text.
Portable Markdown rules/skills require no proprietary agent APIs or runtime agents.

All handoff §17 technical/balance details remain provisional: combat values/hit zones,
regen delay/rate tuning, item classification/ammo/capacity, timers/progress/cooldowns,
scoring, chat/input/UI, copies/loot/spawn distances, AI ratios/reports/planning/dialogue,
mob model/perception/leash, reconnect/hosting/result display, layout/traversal,
extraction visuals/assets and benchmarks. See GAME_DESIGN.md for the complete list.
Choose configurable prototype values within approved rules in later scoped tasks;
new major mechanics or changes to game goals require user agreement.

## Validation boundary

The 16 mandatory scenarios in handoff §18 and GAME_DESIGN.md are future runtime
acceptance requirements, not tests executed by this task. Test rules independently,
then Godot integration, networking/privacy, real four-human play and target-hardware
performance at the relevant stages. Simulated peers are not four-human deception
evidence. Record exact checks, actual outcomes and untested cases in PROGRESS.md.

## M1 implementation decisions

M1 corresponds to handoff §19 stage 2, not the obsolete M0–M5 ordering. The user
explicitly authorized local runtime code plus startup configuration; subsequent
milestones remain outside this increment. Five small modules and one scene implement
only world-space movement, local input, following/orbit camera, and a resumable lever.
The motor's command interface and the interactor's held/released intent do not poll
input; the local adapter can later be replaced without introducing AI now. Target
ownership/progress/completion live on the target with range and line-of-sight checks.
The lever's transform is the real observable result; it creates no fake objective
or extraction logic. Progress lasts for the scene's lifetime, not across restarts.

One unshadowed light, rough primitive geometry and flat ambient background keep
content bounded without changing the user's renderer. No external asset, framework,
paid service, or runtime dependency was added; all new code is GDScript. Scene/input
values are exported or explicitly configured prototype tuning, not finalized rules.
Headless physics/synthetic-input tests cannot validate player camera comfort or GPU
performance; the manual M1 checklist remains a prerequisite to later implementation.

M1 camera framing correction: the spring origin is 3.2 units above the character's
feet (1.4 above its 1.8-unit capsule) and its world sweep uses a 0.2-unit sphere. This
avoids retraction into the excluded character and protects the camera origin/near
plane at walls. The camera keeps looking at the existing body center after spring
updates; a yaw-relative up vector stabilizes the vertical, fully compressed view.
Orbit input/arm behavior and mesh visibility are retained.
No forced minimum distance, mesh fading, or camera mode was added. These are current
M1 geometry/pitch/FOV clearances; future geometry or viewport changes need regression
and graphical rechecks. See M1_PROTOTYPE.md and PROGRESS.md for evidence/limitations.

The previous 2.1-unit origin passed penetration and center-frustum tests but was
reported to lose third-person framing. The fixed higher origin reserves lens-to-mesh
clearance even at zero arm length, without bypassing the world sweep or modifying
movement/interaction. Regression criteria now include projected whole-body screen
size and minimum surface clearance, plus tall-wall/corner compression. A fixed-size
SubViewport replaces the headless window assumption. All values remain M1 tuning;
the user now reports extreme magnification resolved. Remaining occlusion and the
new Stage 3A scene still need graphical validation; no performance claim follows.


## Stage 3A implementation boundaries

The shared character PackedScene contains the preserved M1 geometry/materials,
collision shape and unchanged motor. M1 adds its existing local input, camera and
interactor children; Stage 3A instances three bodies with NavigationAgent3D and
waypoint controllers. The startup scene is now stage3a_local.tscn; M1 remains
standalone. This small scene inherits the M1 yard rather than building a full map.

Built-in static-collider parsing/Recast baking produces a checked-in navigation
resource; an explicit Godot tool rebakes after geometry changes. No plugin, asset,
package or paid service is added. Agent radius exceeds the body radius for static
clearance, while the shared motor retains final collision authority. Dynamic RVO is
not implemented; bounded stall/repath/waypoint-abandonment prevents infinite retries.

Perception alone holds candidate world nodes and samples bounded range/cone/LOS.
Each agent owns separate copied memory with provenance and original simulation tick.
The small report channel subscribes only to actual perception signals matching the
observer's memory, snapshots once, delays, checks recipient freshness and routes to
one configured peer. It never reads actor transforms or authoritative hidden state.
No automatic relay chain, strategic Director, dialogue or target-pursuit behavior
is implemented. The patrol planner reads only authored waypoints/its own body and
navigation agent; reports do not drive decisions in this increment.

Seeded waypoint selection and injected tick-time rules support repeatable tests.
Three staggered low-frequency sensor/plan phases, bounded memory/candidate/queue
sizes and finite route retries keep work bounded. Detailed settings, command paths
and limits are in STAGE3A_PROTOTYPE.md. Physics/navigation are not promised to be
bitwise deterministic across platforms, and no target-hardware performance is yet
measured. M1 user-reported magnification resolution does not establish all camera
occlusion resolved or Stage 3A graphical acceptance. No UI or role labels were added.


## Stage 3A.1 exploration boundaries

The new default scene inherits the retained Stage 3A composition, overrides floor/
perimeter resources, and adds authored primitive shells, lanes, obstacles and sixteen
static destination markers. Its separate baked NavigationMesh has 214 polygons.
M1 and the original 3A scenes/navmesh remain byte-preserved. No renderer change,
external asset, dependency or gameplay UI was added.

The base composition now exposes initial positions/patrol data and a controller
factory; legacy defaults are unchanged. ExplorationChoices ranks static sites using
private visit history, distance/area novelty and seeded variation. ExplorationController
validates bounded candidate paths, travels with blended input, pauses on arrival,
and cools down failed destinations after bounded repaths. No actor registry,
perception memory or human state enters that selector. The existing knowledge
modules and selective delayed reports are unchanged; there is no Director strategy.

The shared motor adds only an opt-in visual turn-speed limit, preserving its zero
legacy default and identical movement/gravity/collision equations. New AI opt in;
human and legacy M1 behavior are preserved. Native physics still constrains actual
motion. Three agents use staggered low-frequency decisions, limited candidate/path
checks and the existing per-tick path follower. Dynamic crowd avoidance is not added.
See STAGE3A1_PROTOTYPE.md for authored access routes, tuning, rebake commands and
manual acceptance. Automated path/angle bounds are not proof of natural-looking
movement or GPU performance; expanded-map occlusion and usability remain unverified.


## Stage 3B.1 observation decision boundary

The new startup scene inherits Stage 3A.1 without geometry/navigation resource,
spawn or population changes. Earlier standalone scenes remain available. Only the
startup setting changes in project.godot; renderer, controls and physics are preserved.
No asset, dependency, service or expenditure (0 UZS) is introduced.

ObservationDecisions is a value-only explore/observe/investigate/resume state machine.
ObservationController owns its private LocalMemory reference, copies snapshots on a
bounded phase, and supplies only its own position/tick and execution feedback. The
pure rule object receives no Node, sensor candidates, actor registry or human lookup.
The composition wires each controller to exactly its own sensor memory and known
teammate IDs. Existing perception, memory validation/expiry and delayed selective
report provenance remain unchanged. No Director strategies or dialogue are added.

The rule selects fresh nearby non-teammate observations by recency/distance, freezes
one record, pauses, and can visit its old point after losing sight. Current direct
vision is identified only by that sensing phase's timestamp/source. Continuing sight
ends the pause without pursuit. Newer facts cannot redirect active travel or extend
its deadline. Expiry, arrival, unreachable paths or finite abandonment lead through
resume to ordinary authored exploration; a remembered point is never live GPS.

An eight-record private suppression history prevents newer timestamps at the same
place from producing loops. Per-subject/location and global cooldowns plus minimum
dwells prevent state chatter. Suppression records never supply actionable expired
facts. Candidate scanning, decision frequency and path queries are bounded; settings
remain provisional. Seeded variation changes reaction/pause timing only.

The existing exploration executor exposes path-start/arrival hooks so investigation
reuses validation, steering, turn limits and bounded physical-block recovery without
changing speed, collider, gravity or M1 controls. Default exploration behavior remains
covered by its unchanged regression suite. Counts establish operation bounds, not
measured CPU/GPU cost or human-like behavior; graphical acceptance and profiling are
still required before scaling beyond three agents.


## Stage 3B.2 developer observation diagnostics

The existing 3B.1 scene adds one removable CanvasLayer with scripts/debug modules.
It is off by default and permits F3 only in an editor-feature debug binary, never
an exported game binary. No project input/settings, map/navmesh, population, camera,
movement, interaction, decisions or report-routing changes are introduced. Cost is
0 UZS, with no dependency, external asset or paid service.

AIDebugState is a read-only adapter over one ObservationController's existing
execution flags, private memory and selected evidence. LocalMemory.inspect provides
copied fresh facts without expiry/mutation; the AI's existing remember/snapshot/
expire behavior is unchanged. The adapter does not hold observation history or
perform new sensing, decisions or path queries. It emits only own ID/state/goal,
legitimate direct observation/source/age, selected frozen evidence/source/age, and
existing stall/retry status. No actor registry, human transform or hidden role,
health, inventory, intentions or global truth is read. Latest-sample labeling uses
the existing controller's scheduled decision tick, not a new visibility test.

AIDebugOverlay creates a native text panel and 0.1 s timer only on explicit F3
activation. Three bounded adapter reads per timer tick update it; no per-frame
polling, markers, mouse capture or gameplay pause is added. Hiding clears/destroys
the UI/timer and stops reads. Only the developer key listener remains. The build
gate is tested as feature combinations, not an actual Windows exported artifact;
this is developer diagnostics, not a security sandbox against editor introspection.
Removing its scene child/resource removes the module from production composition.

A waiting executor can retain an inactive goal; diagnostics label it accordingly.
Selected evidence is independent of latest direct memory and remains frozen through
travel. Expired evidence positions are omitted, while the retained inactive goal
may still show an old coordinate. Blocked/Recovering labels describe existing
counters; they are not new AI states or a separate collision/recovery algorithm.
See STAGE3B1_PROTOTYPE.md for exact interpretation and Windows acceptance scenarios.
Headless state/visibility/count checks do not prove graphical readability or cost.


## Stage 3C limited report coordination

The default scene inherits Stage 3B.1 with a tiny composition subclass opting its
three controllers into ReportCoordination. Original compositions retain the null
policy and their legacy decisions. Map/navmesh, spawn/population, perception,
private memory and selective relay are preserved. Only startup changes in project
settings; human physics, controls, camera and interaction are unchanged. No new
asset, dependency, service or expenditure (0 UZS) is introduced.

ReportCoordination is a local value-only assessment module, not a Director. Inputs
are an actually delivered private-memory snapshot, own position/speed, seed, tick
and configured bounds. Age, distance and observation/travel time can reject a report
while it is still retained in memory. A close recipient pauses nearby; another may
check a seeded approach around the old area. Eligible direct evidence takes priority.
The existing ring relay does not become an all-agent broadcast or assignment system.

The decision state machine pins original report evidence and a separate approach
intent through Observe/Investigate/Resume. New reports do not retarget active work,
refresh its age/deadline or become current occupancy. Existing subject/location
suppression applies across local and coordinated responses. There is no report
rebroadcast, shared live target, peer-position access, role/intent leak or global
strategy/lease. Multiple real observations may still prompt independent responses;
this is not full crowd deconfliction or the completed deception proof.

The shared exploration validator adds an optional path-length budget, default
infinite for legacy callers. Report travel checks actual path length against original
evidence lifetime/timeout at entry using the already required validation query.
No extra path query or movement advantage is used. Invalid/unaffordable offsets
fail once and reuse existing finite recovery/Resume/cooldown. Candidate assessments
stay capped at eight per scheduled phase; committed work ignores fresh reassignments.

F3 extends its read-only adapter with local coordination decision/reason, reporting
ID, original age and uncertainty. It reads the current assessment/commit value only,
never hidden human transforms, another agent's memory or pending report queue. The
existing off/default gate and zero hidden refresh work remain unchanged. The module
uses three seeded profiles; future population/relevance/geometry and performance
need reevaluation. Full Director dispatch, strategic deception and other gameplay
remain future scoped work. See STAGE3C_PROTOTYPE.md for exact tuning and acceptance.


## Stage 3D isolated scenario testing and tool adoption decision

`tests/scenarios/` depends on the existing Stage 3C composition, actual physics/LOS,
NavigationServer, shared motor, memory/channel, coordination and decision executor.
There is no reverse dependency from runtime code/scenes/configuration. No production
code, AI tuning, map/navmesh, input or renderer changes are required. The optional
`tools/run_ai_scenarios.py` uses already available Python standard-library facilities
for a process deadline/log/completion gate; the primary runner is Godot/GDScript.
No addon, native binary, external asset, paid service or runtime dependency is added.

The privileged fixture controls time/seed/poses and owns an independent witnessed
observation ledger. It alone may read fixture truth. Agents still receive only actual
sensor facts and delayed channel delivery. Per-tick audits trace private memory and
committed goals back to original legitimate observations and enforce delay/expiry,
projection, queue/memory and per-phase work bounds. Read-only diagnostic classification
explains completed state changes without altering the decision implementation.
Detailed traces are developer artifacts, not audience-safe gameplay/replication data.

Each scenario starts a fresh world, waits for navigation synchronization and runs
with finite frame/wall/event/trace budgets. Repeats compare logical event/evidence/
committed-goal hashes, not bit-identical native physics. The two-recipient case wires
two existing one-recipient channels inside its fixture only; production remains the
selective ring. Short expiry/stall settings are test-local; repeated-sight suppression
isolates planning with a stationary body. Other cases exercise physical travel and
collision; existing suites retain off-navmesh/detour coverage. See the testing guide
for commands, exact fixtures, negative controls and remaining validation limits.

Evaluated upstream LimboAI 1.8.1 and GUT 9.7.1 without installation. LimboAI publishes
Godot 4.7.2 module editors/templates and claims 4.6+ GDExtension support, but introduces
native/custom-engine packaging and information-boundary migration cost. GUT 9.7.1
explicitly targets 4.7.x and is a lighter pure-GDScript test-only candidate. Neither
addon was locally run/exported; published support is not verified integration.
Keep the four-state runtime and current tests. A later scoped GUT trial can evaluate
reporting/fixture value; LimboAI adoption needs a separate Windows/export smoke trial
and demonstrated authoring benefit. No fake addon demonstration scene is added when
installation is excluded. Pin versions and preserve MIT, separately licensed art and
OFL font notices if any future adoption occurs; source sizes/licenses/links are in
[AI_TESTING_AND_TOOL_EVALUATION.md](AI_TESTING_AND_TOOL_EVALUATION.md). Cost: 0 UZS.

## Map-first foundation (current F5 composition)

The map-first task explicitly authorizes an early 1,000×1,000 m walkable footprint
before further AI refinement. This changes the layout schedule, not the approved
full-game mechanics/population goals. `scenes/world/map_foundation.tscn` now starts
with F5; historical startup statements above and in older prototype guides describe
their increments. All old scenes/navigation and production character/AI/debug modules
are byte-preserved; use their explicit scene paths for regression runs.

`MapLayout` holds provisional authored terrain heights, roads, start/drop candidates.
`tools/build_map_foundation.gd` saves editable geometry, with no runtime generator or
world-wide scan. One continuous 5,000-triangle collider supports the actual footprint;
gentle slopes and ground-level building openings respect the unchanged no-jump motor.
The two summit approaches and station approaches are physically tested. Terrain and
road material variation, roofless shells, pines, custom signs and landmarks are
original bounded layout art; see [MAP_FOUNDATION.md](MAP_FOUNDATION.md) and
[asset provenance](../assets/ATTRIBUTION.md). No external package could be verified
in the bounded access pass, so none was imported. Cost remains 0 UZS.

The translated LocalArea directly reuses the Stage 3C composition and its three real
agents, private memory, LOS sensors, delayed selective relay, decisions, coordination,
exploration and shared collision motor. Ten static sites and a separate 90×90 m
station navmesh (244 polygons) bound their coverage. Navigation uses world coordinates
with the region's local transform compensating for the parent translation. The human
can walk outside it. No large-map perception, omniscient objective state or new AI
strategy is added. Existing F3 diagnostics remain off/default and editor-debug-only.

The human uses the shared character instance plus the existing M1 input/camera/
interactor and lever; the authoring tool rebinds exported node references explicitly
and preserves shared-instance ownership. Only the new human camera's far plane grows
to 1400 m for distant terrain; motor equations, rig, controls and old fixtures retain
their configuration. Summit/station spaces and editor markers do not implement rescue,
spawn balancing or loot. No dummy objectives or victory triggers exist.

Saved static content: 750 nodes, 214 mesh instances, 200 static bodies, 12,914 visual
triangles, 66 pines, four shells, one unshadowed directional light; three existing AI
add their small runtime trees. Counts are budgets, not target-laptop measurements.
Headless tests cover finite real walks, sampled ground/clearance, 192 map-specific
camera poses and 1,200 witnessed AI ticks; old regression fixtures remain unchanged.
The acceptance runner retains the exact reproduced Jolt fixed-job-pool warning as
an engine limitation (including old scenes), rejects errors/unknown warnings, checks
completion reports and does not alter physics to hide it. Software OpenGL fallback
images gave only a layout sanity check; Forward Plus/D3D12 and Windows performance
remain unverified. Next: common human/AI visual model and locomotion, then station
gameplay on the tested map, each under a subsequent scoped task.

## Visual vertical slice V1 (current F5)

`scenes/visual/visual_vertical_slice.tscn` inherits the unchanged full map and adds one
32×32 m static art composition around the storehouse/entry. Old map, character, camera,
interaction, AI, tests and nav resources remain byte-preserved. Only project startup
points at the new scene; renderer/engine/Jolt/D3D12/input settings are unchanged.
Existing shell surfaces get actual original 1K PBR textures; roof/conduit/vent/paint/
debris/weeds are bounded original details. Two verified-license CC0 GLBs retain their
2K materials; an attributed CC-BY humanoid derivative retains rig/walk while removing
the branded image and using original workwear colors. Full notices/manifest are in
[ASSET_LICENSES.md](ASSET_LICENSES.md). No paid service/purchase; cost remains 0 UZS.

`StationArt` applies a presentation-only component identically to one human/three
AI. Hidden original body/facing meshes remain valid focus/reference nodes; the same
CharacterBody3D/capsule/motor/controller still owns physics. WorkerPresentation reads
actual velocity for Idle/Walk, with original breathing Idle and imported walk clip;
it receives no hidden role/mission information and sends no commands. Four bounded
animation updates replace no perception/memory/exploration/coordination system.

Five art colliders require a separate 267-polygon 90×90 m station navmesh. All ten
sites remain reachable; old navigation is retained as fallback. Visual floors add no
collision steps. Overcast sky, 65 m directional shadows and one unshadowed warm fill
are scene resources; no volumetric effects, global per-frame scan or population growth.
Art subtree: 124 nodes, 106 mesh instances, ~20,377 triangles including foliage,
201 small MultiMesh clumps plus six larger clumps, one fill light; four rigs additional.
Budgets are content counts, not Intel-iGPU performance evidence.

[VISUAL_VERTICAL_SLICE_V1.md](VISUAL_VERTICAL_SLICE_V1.md) records source rights,
commands, real rendered before/after evidence and quality limits. The virtual display
could render only after automatic software-OpenGL fallback (Vulkan surface unavailable),
so Forward Plus/D3D12, visual comfort and laptop FPS/RAM remain unverified. Headless
new-scene checks exercise real bones/velocity/walking/collision/camera/navigation;
all old gameplay/map tests and scenario harness remain unchanged and are rerun.

## Stage 4 signal objective subset (current F5)

`scenes/stage4/signal_loop.tscn` inherits the preserved visual benchmark and adds one
service module, a real cabinet control and a marked pickup yard. The task explicitly
requests one prototype component; the final battery-plus-radio station requirement
and independent mountain route remain authoritative and unchanged in the handoff and
game design. This is not completion of full handoff Stage 4's survival systems.

`SignalObjective` is a value-only state/owner/injected-clock object, with no Nodes,
input, AI registry, roles or inventory framework. SEARCH/CARRYING represent the one
component; completed activation installs it, sends one call and enters WAITING.
At arrival, the local player's yard membership gives one SUCCESS, otherwise READY
allows another call with installation retained. Success has a six-second banner;
no transport/spectator/full-match meta is fabricated. Prototype timings remain tuning.

Two narrow WorkTarget subclasses reuse its physical reach/LOS, single-worker lock,
retained work/cancel and actual lever progress. Ownership changes only on completed
pickup; installation/sent-call state changes only on completed legitimate work.
The composition switches the unchanged CharacterInteractor among three authored
reachable targets before local input, advances the clock, samples the yard and
refreshes one minimal local feedback panel at 10 Hz. No movement/camera/input-module
rewrite, global target scan or event bus. R reloads the whole local prototype, not
an in-world action affecting a persistent match. E/controls reuse existing input.

All three real AI retain exploration, range/cone/LOS sensing, private memory, delayed
selective reports and limited coordination unchanged. They may see the player at the
cabinet and investigate the old witnessed point. No component/call state or unsensed
human transform enters decisions. Autonomous item handling, sabotage and combat are
not added. The new-scene test demonstrates an actual objective-area sighting and
frozen last-seen investigation without changing strategy or sensing rules.

A separate Stage 4-only 90×90 m local navmesh retains 267 polygons and all ten authored
sites; the visual benchmark's own resources are unchanged. Original small supporting
meshes reuse existing materials and have recorded provenance. The entire old visual
asset tree, prior scenes/navigation, motor/camera/interactions, AI, tests/harness,
handoff and game design are byte-preserved. Project settings change startup only.

See [STAGE4_SIGNAL_PROTOTYPE.md](STAGE4_SIGNAL_PROTOTYPE.md) for scope/controls, actual
walking/cancel/arrival/reset tests and limitations. Local owner IDs are not network
authentication; authority/session validation belongs to a later multiplayer task.
No combat/death, loot, full inventory, other route, score or full-game result system
is implied. Windows physical-input/visual/performance acceptance remains pending;
software-OpenGL fallback screenshots are documentation, not Forward Plus/iGPU proof.

## Stage 4 objective audit (2026-11-03)

[STAGE4_OBJECTIVE_AUDIT.md](STAGE4_OBJECTIVE_AUDIT.md) confirms the implementation is
a partial prototype: one service module, WAITING → READY on empty arrival, terminal
SUCCESS after yard eligibility. Final handoff extraction grants an individual win,
not necessarily whole-match completion; the prototype folds its local extraction and
result into SUCCESS without production actor removal/spectating or match lifecycle.
No replay defect was reproduced; 73 focused checks passed. Only an additional audit
regression test/docs are added, with no gameplay/asset/setting changes. Final battery
plus radio and other extraction requirements remain unimplemented, not waived.
