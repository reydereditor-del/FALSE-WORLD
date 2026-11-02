# FALSE WORLD — game design

Status: approved gameplay specification, not implemented gameplay.
[FALSE_WORLD_HANDOFF.md v1.0](FALSE_WORLD_HANDOFF.md) is authoritative and overrides
older proposals. This document reconciles its rules in English; technical choices
and balance remain provisional unless explicitly fixed below. The reconciliation
increment implemented no gameplay. The later M1 local traversal/interaction slice is
documented in [M1_PROTOTYPE.md](M1_PROTOTYPE.md). Stage 3A adds only local navigation,
perception, memory and a delayed fact interface; see [STAGE3A_PROTOTYPE.md](STAGE3A_PROTOTYPE.md).
Stage 3A.1 adds only authored exploration and varied local travel/observation pauses;
see [STAGE3A1_PROTOTYPE.md](STAGE3A1_PROTOTYPE.md). Stage 3B.1 adds bounded
observation/last-seen investigation decisions; see [STAGE3B1_PROTOTYPE.md](STAGE3B1_PROTOTYPE.md).
Stage 3C adds only limited local assessment of delayed reports and bounded area
responses; see [STAGE3C_PROTOTYPE.md](STAGE3C_PROTOTYPE.md). Dialogue/deception and
the full gameplay below remain planned.

## Concept, participants, and identity (handoff §§1–3)

FALSE WORLD is a third-person 3D multiplayer social-deception survival /
psychological thriller. Activate either rescue point and survive until help arrives.
Four humans and a match-varying 22–25 human-like AI start on one map. This is the
approved full-game population target, not a measured hardware capability or the
first prototype size. Exact AI count and tiers are hidden from humans. All human-like
AI form one hidden team trying to stop human escape. Separate enemy mobs threaten
both sides.

Solo escape is possible on either route, including for the last living human.
No action, load, or button requires two humans. Cooperation helps divide searching,
carrying, watching, and defense; solo play has no special speed penalty or automatic
extra enemies. Trust and incomplete information create difficulty, not long recipes.

Each human and AI receives a unique per-match military-style ID from the same
format and pool; F11/K72 are examples, exact format pending. No chosen nicknames or
separate role pools. Models, animations, chat, combat/inventory interfaces, death
banners, corpses, loot, and disconnect messages must not automatically reveal role.
Human and AI share physical abilities, HP, healing, loot, weapons, ammunition, and
interaction rules. Perfect indistinguishability is not promised; external calls,
code words, and dialogue limitations remain possible tells.

## Outcomes and deadline (handoff §4)

The collective goal is to save as many humans as possible. Victory is individual:
only a human who actually escapes wins. One escape does not end play for survivors.

| Event | Result |
| --- | --- |
| Some humans escape | Those humans win; remaining humans continue |
| All humans have escaped or died | End the match |
| All humans die and none escaped | Full AI victory |
| Some escape, others die or time out | Preserve escape wins; AI stopped the others |
| All AI die | No automatic human victory; extraction is still required |
| Visible global deadline expires | Unescaped humans lose; previous wins remain |

There is no overtime. Extraction completed at the exact same simulation time as
the deadline is processed first. Emit the terminal match result once. Reconnect
cannot extend the deadline. Match duration is provisional; 45 minutes is not approved.

## Independent rescue routes (handoff §5)

Both routes remain open in the same match, with multiple approaches where feasible.
A player can switch routes when one becomes dangerous.

- Mountain: climb to the summit, manually activate the emergency beacon, survive
  the wait, and be in its extraction area when help arrives. Reaching the summit
  alone is insufficient. Station parts are unnecessary. Exposure makes defense hard.
- Signal station: find one battery and one radio module, install in either order,
  send the signal, wait, and extract in its area. Multiple copies of each part exist;
  copy counts are provisional. One person can carry both. Installed parts cannot
  be removed. Sabotage requires repair of the existing device, not replacement
  parts. Later calls do not consume the parts again. No long recipe or code hunt.

Devices can be sabotaged and restored until the call finishes sending. A successful
call cannot be canceled by sabotage; leaving or the caller dying does not cancel
its wait. At arrival, all living humans inside automatically escape without an
extra button. Nearby AI do not block extraction and cannot escape; presentation
must not expose their role to living participants. An empty area rescues nobody;
another call can be made. Later groups can reuse the same route through a new call.
Escaped humans leave their items as accessible loot at the exit, keeping critical
items in the match. Transport, animation, AI appearance during extraction, and
repeat-call cycle details are unresolved technical/visual choices.

## Interaction, repair, sabotage, and critical items (handoff §6)

Each separate repair/installation action has one active worker at a time. More
characters do not accelerate it; they can search or defend. Cancel immediately to
fight or flee; damage interrupts. Completed progress persists and another character
can resume. An installing item is consumed/attached only on completion; interruption
must neither lose nor duplicate it.

AI may misdirect, split groups, delay, carry real items, ambush, and sabotage.
Sabotage requires physical proximity and time, is repairable, and cannot instantly
wipe all completed work. Progress changes, resume points, and cooldowns remain
provisional; endless toggling must not make forward progress mechanically impossible.

Critical items cannot be destroyed or discarded out of bounds. Both roles may drop
them only at designated reachable loot locations. AI must not hoard every copy for
the entire match. Guarding is allowed, but permanently disabling both routes through
mechanics is not. This does not guarantee human success against combat and time.

## Information and proximity text chat (handoff §7)

Explain both simple rescue sequences at match start. Landmarks/signposts guide
players to mountain and station; exact part coordinates are not automatically shown.
Missing parts and extraction countdown are checked beside the device. Calls give a
local audible or visible cue, never an automatic map-wide mission notification.
Distant players depend on observations or conversation. The global match timer is
visible to everyone; there is no live global death/extraction roster.

Text is delivered to humans and AI within range at send time. New arrivals do not
receive old conversations. Recipients retain bounded received history; moving away
stops delivery of new distant messages. Initially walls do not block chat, distance
does. The game does not pause; closing chat permits immediate movement/defense.
Typing input behavior remains a UI-test choice. Human and AI share appearance,
message-length, and rate limits. No global chat, private messages, voice, or AI
badges. Radius/history/flood limits are provisional; 5 metres is not approved.

## Combat, HP, and healing (handoff §8)

PvP and PvAI are approved. Initial weapons are fists, simple melee weapons, a pistol,
and one rifle type. Melee is relatively common; firearms and ammunition are very
scarce. Unarmed defense is possible but dangerous against weapons. Ammunition is
finite and reloading takes time; interrupted incomplete reloads add no ammunition.
All roles take damage through shared combat rules, including AI–AI friendly fire.
HP zero means permanent death; no revive or respawn. Initially no grenades, armor,
complex combos, or stamina system. Chase/escape balance needs testing.

Automatic regeneration is approved, replacing older no-regen/medkit-only proposals.
After a short delay from the last hit, living characters slowly heal up to maximum.
New damage interrupts regen and restarts the delay; HP zero never regenerates.
The provisional initial rate is maximum HP / 120 seconds of active regeneration,
not a fixed two-minute heal after every injury. With an illustrative maximum of
100 HP, healing from 50 takes 60 active seconds plus the delay; 100 maximum HP is
not approved. Rare medkits heal self or a nearby character much faster, take time,
are interrupted by damage/cancel, and are consumed only on completion. The same
rules apply to AI. No food or extra regeneration resource.

## Hidden final human-damage penalty (handoff §9)

Explain the penalty rule beforehand, but reveal deductions only at match end.
There is no persistent ranked/Elo system. A human initiating damage against another
human has relevant damage counted toward a final score deduction. The victim gets
a temporary self-defense window against that attacker; returned damage in that
window is exempt. Further attacker damage refreshes it. Later revenge is not
automatically defense, and the pairwise window does not excuse attacking a third
person. Small accidental contacts have a forgiveness threshold; repeated small
hits accumulate. No extra kill penalty is stacked on damage deductions. Damage to
AI/mobs carries no such penalty and killing them earns no separate kill bonus.

No live deduction, score change, role-revealing sound, or message can identify a
human. Deductions reduce final score without canceling an escape victory. Initially
only direct damage is attributed; lies, mob luring, and indirect blame are not
inferred. Formula, base result scores, threshold, and window durations are
provisional. Test provocation and small-hit/window abuse; this cannot perfectly
infer intent. The old final-hit-only kill penalty is superseded.

## Inventory, loot, and death (handoff §10)

Weapon capacity is one large plus one small weapon, with no reserve weapons hidden
in general inventory to evade it. Exact weapon slot classification is pending.
Other items use bounded shared capacity that permits one human to carry both
mission parts. Exchange through permitted ground drops, with no trade window.
The server grants an item once; concurrent pickup must not duplicate it.

Death drops all items. Loot remains accessible through match end even if the corpse
model is removed, without role labels. Ordinary loot does not respawn. AI must
actually find and use their weapons, ammunition, and medkits. A critical item lost
to clipping or boundaries returns as the same item to a nearby safe point, without
a duplicate. AI cannot teleport items in ordinary play.

## Spectators (handoff §11)

Dead and escaped humans spectate living character cameras, mixing human and AI
subjects; no free flight or human-only filter. Show normal views and local chat
received by the watched character, without hidden role, inventory, or AI internals.
Spectators cannot send chat, pings, or other in-game signals to living characters.
At match end reveal human identities and individual results, never AI tiers.
External Discord/Telegram information sharing cannot be completely prevented.

## Human-like AI (handoff §12)

Basic agents are the majority, Intermediate agents add contextual deception, memory,
and cooperation, and rare Advanced agents add multistep planning/deception. Basic
agents loot, move, converse simply, defend, and plan simply. Exact tier distribution
is provisional and never visible. Advanced does not mean invulnerable or omniscient.

Agents adapt among observation, truthful help to gain trust, misdirection, sabotage,
delay, retreat, and combat. Seeing a human or hearing “you are AI” does not force an
attack. Saving someone from a mob does not prove humanity. Agents may abandon tasks
to survive or take calculated risks to prevent escape; do not automatically swarm
one target without considering travel time and available information.

AI know their teammates. A visually identified human-like ID outside that team can
be recognized as human. Human current position, HP, inventory, intent, and mission
state are not automatically supplied. Separate server truth from AI knowledge:
perception or a justified report is required. Record observer, subject if known,
event, position, time, confidence, and source. Last seen is not live GPS.

Flow: agent → local memory → delayed/limited Director report → freshness check →
relevant agents receive assignments/information. Internal coordination is separate
from player-visible proximity chat. The Director does not drive agents frame by
frame. No teleporting, infinite ammunition, live tracking through walls, perfect
automatic aim, collision bypass, or invisible inventory. Repath or abandon blocked
tasks. Dialogue initially uses local contextual templates/intents through a modular
adapter. Codex/Antigravity are development assistants, not runtime brains. Dialogue
cannot create mechanics or masquerade as system messages. Human-level free dialogue
or a laptop LLM for 22–25 agents is not promised; future model/API integration needs
separate assessment and authorization, with no automatic paid service.

## Enemy mobs (handoff §13)

Initially one type in small numbers in designated zones; model/type/count pending.
Mobs are separate from the hidden AI team and are not its strategic allies. They
sense and damage humans and AI by the same rules without knowing hidden roles.
One should be relatively easy to evade or kill but dangerous to ignore. They
approach normally with sound/movement warning, never surprise-spawn behind someone
for guaranteed death. Interaction sounds may attract nearby mobs, without a
mandatory wave per action; workers can stop and defend. AI react only after sensing
them. Lost/distant targets trigger giving up and returning to the home zone, not
endless map-wide pursuit. Luring is possible; retargeting uses ordinary perception/
threat rules. Initially killed mobs do not respawn during the match.

## Map, spawning, disconnects (handoff §§14–15)

The full first gameplay map target is 1×1 km with abandoned/unfinished buildings,
forest, roads, mountain, and station. Layout/building count/verticality are pending;
this is not the first coding task. Choose balanced random starts from authored valid
points. Humans are usually spread out, with two sometimes near each other; AI mix
across zones. No wall-interior, immediate mob attack, inescapable instant-kill, or
spawn directly on a mission part/device. Do not systematically place Advanced AI
beside every human start. No automatic AI replacements to restore the starting count
and no new humans joining as living participants after start.

Disconnected human characters remain in-world with items and can take damage;
no AI takeover. Within a bounded reconnect window they return to the same character,
or spectate if it died. On expiry the character dies and leaves all loot. Rejoining
one's reserved character is the exception to no late join; it never extends the
match deadline. Host loss initially ends the match with no host migration; technical
termination must not be falsely reported as a normal gameplay win. Exact presentation,
reconnect time, hosting, and internet connection method are pending. Disconnect
notifications/markers cannot expose role. Free permanent public hosting is not promised.

Modular geometry, instancing, LOD, and visibility culling may help performance.
Distant-agent optimization must preserve travel time, information, and item state.

## Delivery stages and acceptance (handoff §§18–19)

This sequence replaces the earlier M0–M5 roadmap. M1 implements only the local
stage-2 slice; later implementation requires a subsequent scoped task. Stage numbers
below refer to handoff §19.

| Stage | Scope | Required evidence when implemented |
| --- | --- | --- |
| 1 — Audit/reconciliation | Existing docs, rules, skills, configuration inventory | Consistency/preservation checks and a reviewed docs-only commit |
| 2 — Small 3D slice | Third-person controller, camera, interaction, primitive geometry | Recorded movement, ground/obstacle collision, camera and interaction tests; no script errors |
| 3 — Deception proof | 1 human + 3 AI, perception/memory/Director, shared abilities, local chat | Seeded report/freshness/knowledge-limit tests and observed dialogue/decision behavior |
| 4 — Small playable | 6–8 AI, one complete rescue route, combat/regen, inventory, one mob type, spectator, final penalty | Functional solo rescue and interruption/loot/privacy/score checks for implemented route |
| 5 — Four-human networking | Authoritative state, reconnect, role privacy | Real four-human sessions plus invalid-request, disconnect and replication tests |
| 6 — Full scope expansion | Both routes, 1×1 km, 22–25 AI incrementally | Independent solo routes, repeat rescue and target-laptop performance measurements |
| 7 — Stabilization | Balance, stability, credits/licenses, distribution decisions | Recorded abuse/regression/playtests and license audit |

The handoff's 16 required scenarios remain mandatory future acceptance criteria:
solo rescue via each route; useful cooperation without a two-person gate; repeat
calls; caller death/disconnect/empty area; AI coexistence without extraction denial
or UI role leak; completed-call sabotage immunity and bounded reset; critical-item
recovery after carrier death/escape/map loss; transactional pickup/install/heal/ammo;
regen never revives and damage resets delay equally for AI; self-defense/small-hit/
third-party score privacy; spectator/disconnect/log/chat privacy; last-seen AI
without live GPS; equal mob danger/warnings/leash/return; deadline ties and single
finalization; host loss/reconnect/permanent death/full loot; laptop FPS/RAM/navigation/
AI-update measurements. The reconciliation ran none of those runtime scenarios.
M1 tests cover only the local movement/camera/interaction subset; see PROGRESS.md
for actual outcomes.

## Provisional details, constraints, and exclusions (handoff §§2,17)

Maximum HP, damage, melee reach, hit zones/headshots, aim reaction, medkit quantity/
duration, regen delay/rate tuning, weapon classification/ammo types/general capacity,
all match/action/repair/sabotage/call/wait/repeat timings, score formulas/defense/
forgiveness, chat radius/history/rate/input/UI, part-copy/loot counts, spawn distances/
probabilities, tier ratios/report delay/expiry/dispatch/planner weights/dialogue scope,
mob count/model/perception/leash/damage, reconnect/hosting/technical-result display,
map layout/traversal jump/slope/collision, extraction visuals, assets, and performance
benchmarks remain prototype decisions. Use configurable provisional values in later
authorized work. Do not repeatedly reopen approved core rules; return changes to
the game's goals or new major mechanics to the user.

Use Godot 4.x/GDScript and Git/GitHub; target Windows, Intel i5, 16 GB RAM and
integrated graphics. Budget goal is 0 UZS, absolute ceiling 100,000 UZS; spending
requires explicit permission. This task adds no paid service. Only free assets with
verified intended/commercial-use licenses and recorded attribution are allowed.
No voice, login/accounts, persistent ranked/Elo, store, crafting, hunger/thirst,
unrequested progression, procedural worlds, matchmaking, or additional victory
routes. No new large systems beyond the handoff. FPS/RAM, human-like dialogue,
full-map population performance, and online hosting are not guaranteed.
