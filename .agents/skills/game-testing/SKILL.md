---
name: game-testing
description: Verify FALSE WORLD changes with scoped repository checks, meaningful Godot behavior tests, multiplayer scenarios, and honest performance evidence.
---

# Game testing

1. Read `AGENTS.md` and `docs/PROGRESS.md`; identify what changed and the milestone
   acceptance criteria. Preserve a baseline of existing files and inspect Git status.
2. For documentation-only changes, verify required paths, local Markdown links,
   skill metadata, directory markers, whitespace, consistency, and preservation of
   original files. Do not add gameplay scripts or a test framework just to test docs.
3. Before runtime checks, record Godot version and project requirements. An older
   binary is not evidence that the configured project is supported. Report blockers;
   do not rewrite project settings to make a test pass.
4. For authorized rule changes, test observable behavior with explicit inputs and
   expected outcomes: each win route independently, rejection of invalid requests,
   one terminal result, and reset. Use deterministic seeds and clocks where relevant.
5. Run applicable headless checks using the actual test entry point present in the
   repo; never invent a passing test command. Use manual runs for camera, collision,
   visual identity, text rendering, and perceived deception.
6. For multiplayer, distinguish automated/simulated peers from four human players.
   Test separate spawns, state agreement, sender ownership, invalid objective calls,
   text bounds/rate, and disconnect behavior. Separate host and client observations.
7. For AI, cover two-agent knowledge sharing, stale facts, assignment coordination,
   legal movement, blocked routes, and private-state leaks before crowd profiling.
8. For performance, record CPU/iGPU, OS, driver, RAM, engine, renderer, resolution,
   scene, bot count, host/client role, warmup, and duration. Capture frame-time
   distribution and process memory; compare against architecture targets. A headless
   run cannot demonstrate GPU performance. Separate four-process load from one client.
9. Record exact commands/scenarios, pass/fail results, limitations, untested items,
   and the next implementation step in `docs/PROGRESS.md`. If blocked, report the
   cause and remaining validation. Never infer gameplay correctness from file checks.

Use built-in or standard-library tooling first. Adopt a free test dependency only
when needed, with license and architecture rationale. Do not claim Codex or
Antigravity auto-discovery works unless it has actually been exercised.
