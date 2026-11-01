# FALSE WORLD — architecture

Status: planned implementation boundaries; no runtime systems implemented.
[FALSE_WORLD_HANDOFF.md v1.0](FALSE_WORLD_HANDOFF.md) controls approved gameplay;
[GAME_DESIGN.md](GAME_DESIGN.md) reconciles it. Technical choices below are proposals
unless required by that handoff. The current task authorizes documentation only.

## Existing project and preservation

The root `project.godot` declares `4.7`, `Forward Plus`, Jolt 3D physics, a Windows
D3D12 preference, `New Game Project`, and a .NET assembly name. It has no main scene.
Retain all these settings; future gameplay uses GDScript. Do not recreate the project,
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
- `scenes/`, `scripts/`, `assets/`, `tests/`: empty `.gitkeep` reservations.

No extra `GAME_LOGIC.md`, services, addons, dependencies, assets, or scaffolding are
needed for this reconciliation. Add feature directories only with authorized code.

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
