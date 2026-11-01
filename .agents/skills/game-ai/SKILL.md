---
name: game-ai
description: Design and validate lightweight local coordinated deception AI for FALSE WORLD without cloud AI or hidden information leaks.
---

# Game AI

1. Read `AGENTS.md`, `docs/FALSE_WORLD_HANDOFF.md` v1.0, design, architecture and
   progress. The handoff overrides earlier gameplay proposals. Documentation alone
   never authorizes code; implement only the current explicitly scoped AI task.
2. Define allowed inputs, observations/reports, commands, seed/time and a measurable
   scenario before implementation. Full target: varying 22–25 hidden human-like AI,
   Basic majority, Intermediate, rare Advanced; ratios are provisional. Begin with
   the handoff's 1 human + 3 AI proof, then 6–8 AI playable before full scale.
3. Use local state machines and small utility/feasibility decisions. Basic handles
   loot/movement/simple dialogue/defense/plans; Intermediate adds contextual deception,
   memory/cooperation; Advanced adds multistep planning without omniscience. Agents
   may observe, help truthfully, misdirect, delay, sabotage, retreat or fight. Seeing
   a human or an accusation is not an automatic attack trigger; helping against a
   mob does not prove humanity. Use existing approved actions, never new mechanics.
4. Separate server truth from AI knowledge. AI know teammate IDs and may classify a
   visually identified human-like non-teammate as human. Current human position, HP,
   inventory, intent and mission state require perception or justified reports.
   Record observer, subject if known, event, position, time, confidence and source.
   Last seen ages/expires; never refresh it into wall-penetrating live GPS.
5. Required flow: perception → local memory → delayed/limited Director report →
   freshness check → relevant agent assignments/information → local planner → shared
   actions. No instant globally shared blackboard, frame-by-frame Director puppeting,
   or unrestricted server-state access. Internal coordination differs from visible
   proximity text. Dispatch considers travel, feasibility and evidence; no automatic
   all-agent swarm. Agents may abandon tasks to survive or accept calculated risk.
6. Human and AI share motor, collision, HP/regen, damage/friendly fire, medkits,
   inventory, interaction, actual weapons/ammo/loot rules. No teleport, infinite
   ammo, perfect aim, invisible inventory, collision bypass or all-copy hoarding.
   Sabotage is local/timed/repairable, cannot cancel sent calls or permanently lock
   both routes. Repath or abandon blocked tasks. Optimization preserves travel time,
   information and item state. Stagger decisions and bound memory/navigation work;
   cadence/report delay/expiry/weights remain provisional and need profiling.
7. Use local contextual dialogue templates/intents behind a modular adapter and
   the same proximity delivery/style/length/rate rules as humans. Dialogue cannot
   create mechanics or fake system messages. No role badges. Codex/Antigravity are
   development tools, not runtime minds. No paid runtime AI; future model/API use
   needs separate evaluation/authorization. Do not promise free human-level dialogue.
8. Keep enemy mob AI separate from the hidden team/Director. One initial type in
   small designated-zone populations, identical human/AI sensing/damage, ordinary
   approach warnings, bounded chase/return, no guaranteed-death surprise spawns or
   mandatory action waves, and initially no respawn. Human-like AI must sense mobs
   before reacting; mob knowledge cannot magically enter team knowledge.
9. Validate report delays, freshness/provenance, visual ID recognition versus
   unsensed state, relevant assignments, travel limits, survival/task abandonment,
   legal shared actions, dialogue bounds, mob independence and role privacy.
   Keep roles/tiers/Director facts out of player snapshots, logs, names, spectator
   views and chat metadata. Inject time/seed for logic tests, not a claim of
   deterministic physics. Use `game-testing`; record actual checks in PROGRESS.md.

Test real four-human deception separately from seeded simulations. A bot reaching
a location does not prove human-like behavior or target-hardware population support.
