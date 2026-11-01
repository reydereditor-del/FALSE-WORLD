# FALSE WORLD — architecture

Status: proposed implementation boundaries, not implemented systems.

## Existing project and preservation

The existing Godot project is at repository root. The initial `project.godot`
declares feature strings `4.7` and `Forward Plus`, Jolt 3D physics, a Windows D3D12
driver preference, and the application name `New Game Project`. No main scene is
configured. Preserve these settings in this task, including the existing .NET
assembly-name entry; future gameplay uses GDScript, not C#.

The inspected environment provides Godot `4.6.3.stable.official.7d41c59c4`, which
is older than the declared 4.7 project feature. No engine import, editor launch,
or runtime validation was performed. Establish the intended 4.x editor version
before implementation; do not infer compatibility from the presence of a binary.

## Repository layout

```text
AGENTS.md                         shared project rules
project.godot                     existing project; preserved
.agents/skills/
  godot-development/SKILL.md       Godot workflow and boundaries
  game-ai/SKILL.md                 local coordinated-AI workflow
  game-testing/SKILL.md            evidence-based validation workflow
docs/
  GAME_DESIGN.md                   concept, open rules, milestone acceptance
  ARCHITECTURE.md                  boundaries, budgets, decision rationale
  PROGRESS.md                      completed work, checks, exact next step
scenes/.gitkeep                   future composed scenes
scripts/.gitkeep                  future GDScript modules
assets/.gitkeep                   future licensed/original content
tests/.gitkeep                    future behavior tests and scenarios
```

Only `.gitkeep` markers reserve runtime folders; they are not features. Existing
root files are retained. Add feature subdirectories only when actual code exists.
Do not add framework scaffolds, addons, test dependencies, or configuration here.

## Planned ownership and dependency direction

| Boundary | Owns | Depends on |
| --- | --- | --- |
| Match rules | Match phase, participants, spawn assignment, objective progress, terminal result | Explicit state and requests; no rendering or RPC calls |
| Character | Shared movement, collision, visible actions | Local input or an injected bot/remote command source |
| World/objectives | Authored map, spawn markers, summit zone, signal interaction | Match request interface and character identity |
| AI coordination | Shared observations, strategy, task assignments | Perception inputs, navigation queries, validated action requests |
| Session transport | Peer lifecycle, input routing, snapshots, text delivery | Match/character interfaces; never direct scene presentation rules |
| Presentation | Camera, character appearance, later functional chat UI | Public replicated state and local control; no match authority |

Keep domain decisions in small GDScript classes (plain data/RefCounted where
appropriate), with Node adapters for scene lifecycle, physics, and transport.
Use explicit references and focused signals instead of making every module an
autoload. A small match composition root can wire dependencies when required.
Do not implement empty services to satisfy this diagram. Scenes compose modules;
rule code must not reach into UI paths or depend on a network connection to test.

## Multiplayer boundary, for M3 onward

Use Godot's built-in multiplayer facilities and ENet for an initial local/LAN
host-authoritative prototype. The host also plays as one of four humans and runs
match rules, bots, and shared AI state. Clients submit bounded requests; the host
validates authority, ownership, movement constraints, objective proximity, and
match state before accepting them. One authority resolves terminal outcomes once.

Replicate only needed public actor state and objective/match outcomes. A peer ID
is a connection identifier, not a trusted actor or chat sender identity supplied
by a client. Server-side bot roles, coordinator state, and private observations
stay off remote clients. A host can inspect its process: resistance to a cheating
host is not promised by this low-cost architecture.

Text chat uses bounded message size and rate, host-associated senders, safe literal
text rendering, and agreed channel rules. Bot chat or natural-language generation
is not assumed. Define limits and disconnect behavior at M3. Late join, reconnect,
host migration, internet relay, and matchmaking are outside the prototype scope;
record host-loss handling when implementing sessions.

## AI coordination, for M4 onward

Use deterministic local state machines and simple scored task selection, not LLM
calls, training pipelines, or a general-purpose behavior framework. Share a bounded
host-only blackboard of observed actor ID, location, timestamp, confidence, and
objective evidence. Age and expire observations; never silently refresh a last-seen
position from unsensed world state. All bots can consult the same strategic state.

The coordinator assigns tasks such as approaching an observed route or regrouping.
Each bot owns execution and navigation, while using the shared character command
interface. Perception/decisions run on staggered fixed intervals (start experiments
at 2–5 Hz); movement remains on the physics tick. Bound path requests and retries,
reuse navigation data, cap retained facts, and reduce distant-agent decision rates.
Inject seed and time into rule decisions. Repeatable logic tests do not imply
bit-for-bit determinism of physics or networking.

## Hardware budgets and rendering proposal

These are initial measurement targets, not achieved results or guarantees. Intel
iGPU model, OS, driver, RAM sharing, scene content, and host load must be recorded.

| Measure | Initial target / method |
| --- | --- |
| Rendering baseline | Evaluate Godot Compatibility renderer at 1280×720 in a later authorized task; retain current renderer for this step |
| Frame time | Aim for 30 FPS or better, p95 frame time at most 33.3 ms in a representative 10-minute host session after warmup |
| Memory | Aim for at most 2 GB game-process resident memory for one host/client process; measure editor and other processes separately on the 16 GB laptop |
| Population | Four humans plus measured tiers of 8/16/24 bots; choose supported count from timings rather than promising an arbitrary crowd size |
| Content | Compact graybox; simple materials, modest meshes, baked/static lighting where feasible, few shadowed lights; start textures at 1K or less when assets arrive |
| Work scheduling | Stagger perception and pathfinding; capture CPU physics/AI and GPU timings separately before tuning |

Compatibility is proposed because advanced Forward Plus effects are unnecessary
for the prototype and may consume integrated-GPU budget. It is not selected or
validated here. Avoid volumetrics, screen-space effects, high-resolution textures,
and large dynamic-light counts by default. Do not change existing project settings
until an implementation task permits it and checks can compare the result.

## Cost and architecture decisions

| Decision | Rationale and consequence |
| --- | --- |
| Existing Godot 4.x project + GDScript | Reuse the user's stack, avoid rebuild/configuration drift, native extensions, and additional language tooling |
| Built-in transport and player host | No required hosting bills, paid APIs, or service dependency; host CPU load and host trust are tradeoffs; internet NAT traversal is not solved |
| Local rule-based AI | No per-request cost or service latency; human-like behavior needs design and playtesting rather than generated dialogue |
| Small modules and explicit interfaces | Enables rule tests without full rendering/multiplayer; avoids a heavyweight ECS or generic service framework |
| Primitive graybox first | No asset download cost or licensing uncertainty; visual fidelity is deferred, while shared human/bot appearance remains a requirement |
| Verify licenses before importing | Commercial distribution needs actual permission and attribution records; no third-party assets are added in this task |
| Portable Markdown rules and skills | Same readable workflow for Codex and Antigravity without tool-specific runtime dependencies; discovery must be checked per tool |
| Standard-library docs checks now | No new test framework or paid CI; choose a free runtime test approach only when meaningful tests require it |

## Validation boundaries

Documentation checks can establish file completeness and preservation, not that
Godot imports, a network session works, bots coordinate, or target hardware performs
adequately. Future milestones require rule tests, engine checks with the intended
version, manual third-person scenarios, real four-human sessions, and target-laptop
profiling. Record commands, engine version, setup, results, and untested cases in
`PROGRESS.md` after every increment.
