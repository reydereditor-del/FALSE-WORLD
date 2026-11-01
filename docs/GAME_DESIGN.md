# FALSE WORLD — game design

Status: planning baseline. No gameplay is implemented by this foundation change.

## Core concept

FALSE WORLD is a third-person 3D social-deception survival game. Four human
players spawn at different locations in a world populated by numerous
AI-controlled characters. Bots use the same visual language and apparent actions
as humans. Humans must judge whom to trust while trying to complete objectives.
All AI agents share strategic information and coordinate to prevent human success.
Communication is text chat only; voice is excluded.

Humans have alternative victory routes: reaching a mountain summit or activating
a signal device. Either route must be independently achievable in the prototype;
neither may be a disguised prerequisite for the other.

## Intended play loop

1. Spawn four humans at distinct, traversable locations.
2. Observe nearby characters, navigate, and communicate through text.
3. Choose a route, interpret behavior, and decide whether to cooperate.
4. Encounter coordinated bot interference while approaching the chosen objective.
5. Resolve the match through a validated human objective completion or the
   agreed human-failure condition.

This is a design target, not a description of working features. The form of bot
interference must be settled before implementing it; combat or damage is not implied.

## Prototype limits and open decisions

Use one compact authored graybox map containing four spawn points, a traversable
summit route, and a separate signal-device location. Use original primitive
geometry until commercially usable assets are verified. Keep both routes simple
so the prototype tests deception and coordination rather than content volume.

The following are unresolved and must be settled before their dependent milestone:

| Decision | Required by | Working proposal to evaluate |
| --- | --- | --- |
| Does one human's completion win for all humans? | M2 | Shared human victory on either route; not yet approved |
| What ends a match in human failure? | M2 | A configurable deadline; duration and rule need agreement |
| How is the signal activated? | M2 | One validated interaction, without inventory prerequisites |
| How can bots delay humans without combat? | M4 | Route interception and misleading movement; avoid permanent physical deadlock |
| Can humans and bots physically block each other? | M4 | Evaluate collisions and escape paths before enabling blocking |
| Which chat channel and visibility rules apply? | M3/M4 | One match-wide human text channel; bot participation remains undecided |
| How many bots qualify as numerous on target hardware? | M4/M5 | Measure tiers of 8, 16, and 24; final count follows profiling |

Bot coordination uses shared observations, not automatic omniscience. All agents
may share their strategy and sensed facts; hidden human intent and unsensed current
positions are not available. This is a proposed fairness boundary documented in
architecture and subject to playtesting. Do not expose bot-only identifiers through
visible labels or chat metadata. Do not promise perfectly human-like behavior.

## First playable prototype milestones

All milestones below are planned and untested. Only M0 is this task's deliverable.
A later task authorizes implementation. Each milestone depends on the preceding one.

| Milestone | Scope | Acceptance evidence |
| --- | --- | --- |
| M0 — Foundation | Rules, structure, design, architecture, progress, three skills | Docs and structure checked; original files unchanged; dedicated branch committed |
| M1 — Local traversal slice | One isolated graybox scene, one locally controlled third-person character, ground collision, camera | Character moves on ground and against an obstacle; camera follows without persistent clipping; no runtime script errors in a recorded manual run |
| M2 — Local objective rules | Settle win/failure rules; implement separately testable match/objective state, distinct spawn definitions, summit and signal triggers | Either route alone reaches the agreed human-win state; invalid interactions are rejected; terminal result happens once; reset clears objective state |
| M3 — Four humans and text | Local/LAN host-authoritative session, four separate spawns, replicated movement/objectives, minimal functional text chat | Four peers join, observe consistent state, complete each route in separate runs, and exchange bounded text; spoofed completion/sender and a disconnect are handled |
| M4 — Coordinated population | Local deterministic bots, shared observations and strategic assignments, human-like movement, agreed interference | Seeded two-bot scenario demonstrates shared observation and coordination; bots use the same movement limits; no role leak; navigation recovers from a blocked route |
| M5 — First playable validation | Combine four humans, numerous bots, both routes, text chat; tune within measured hardware budgets | Separate four-player playthroughs demonstrate each route, agreed failure, and restart; record deception feedback, synchronization errors, frame times, memory, and actual bot count on target laptop |

M1 is a technical slice, not the complete social-deception game. The first playable
is M5. Do not call simulated peers a four-human playtest. Do not call a four-process
load test representative of one laptop client without separating its overhead.

## Explicit exclusions

No voice, paid services, online matchmaking, accounts, persistence, progression,
combat, crafting, hunger/thirst meters, inventory, procedural generation, or
additional victory routes are part of this prototype brief. A functional debug
view may be added only when needed for an authorized implementation or test, not
as a substitute for an implemented system.
