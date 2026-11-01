---
name: game-ai
description: Design and validate lightweight local coordinated deception AI for FALSE WORLD without cloud AI or hidden information leaks.
---

# Game AI

1. Read `AGENTS.md`, the design's unresolved decisions, the architecture's AI
   boundary, and current progress. During the foundation task, document only.
2. Before an authorized AI increment, define the observable inputs, allowed shared
   knowledge, action outputs, decision cadence, seed, and measurable scenario.
   Resolve the permitted interference rule before implementing it.
3. Use local state machines and small scored decisions. No LLM APIs, paid tools,
   online inference, training stack, or large AI framework is required.
4. Keep a host-only bounded shared blackboard. Record source, timestamp, confidence,
   and last-seen position. Expire stale observations. Strategy may be shared by all
   bots; unsensed human state and hidden intentions must not become facts.
5. Separate perception, shared task assignment, per-bot decision, and movement.
   Feed commands into the same movement constraints humans use. Do not expose bot
   roles or blackboard fields in client snapshots, visible names, or chat metadata.
6. Start with a small seeded scenario. Stagger low-frequency decisions, bound
   navigation requests/retries and memory, and profile population tiers before
   increasing them. Avoid per-frame all-pairs perception and repeated path rebuilds.
7. Validate observation sharing, fact expiration, coordinated assignments, blocked
   navigation recovery, and information privacy. Inject seed/time for logic tests;
   do not claim deterministic physics. Use `game-testing` for evidence reporting.
8. Record actual results and remaining deception/playtest limitations in
   `docs/PROGRESS.md`. A bot reaching a point is not proof that humans mistake it
   for a player. Four-human deception evaluation remains a separate manual check.

Never expand this skill into bot chat generation, combat, or new objectives without
an explicit task. The initial AI count is a profiling question, not a fixed promise.
