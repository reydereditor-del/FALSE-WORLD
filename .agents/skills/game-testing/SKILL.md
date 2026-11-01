---
name: game-testing
description: Verify FALSE WORLD changes with scoped repository checks, meaningful Godot behavior tests, multiplayer scenarios, and honest performance evidence.
---

# Game testing

1. Read `AGENTS.md`, authoritative `docs/FALSE_WORLD_HANDOFF.md` v1.0, design,
   architecture and progress. Identify authorized scope and handoff §19 stage.
   Inspect Git status; baseline protected files before edits. Approved design is
   not implemented behavior; superseded proposals must not become assertions.
2. For docs-only tasks, verify paths/links, skill frontmatter, empty directory
   markers, whitespace, consistency with the handoff and intended-file scope.
   Confirm handoff and Godot configuration preservation by content comparison.
   Do not add runtime code, assets or test frameworks merely to validate docs.
3. Before runtime checks, record actual Godot version and project requirements.
   An older engine or historical import does not validate today's behavior.
   Report mismatches; do not rewrite settings to pass. Use actual existing test
   entry points and confirm tests executed; never invent a passing test command.
4. In later authorized work, trace coverage to all 16 handoff §18 scenarios. Test
   both solo routes and useful cooperation without two-person gates; repeat calls;
   caller death/disconnect/departure and empty arrival; AI in extraction areas;
   completed-call sabotage immunity, resumable work and bounded reset; critical-item
   recovery after death/escape/map loss; parallel pickup/install/heal/reload without
   duplication; permanent death and equal human/AI regen with delay reset on damage.
5. Cover private direct-human-damage scoring: pairwise self-defense refresh/expiry,
   repeated small-hit accumulation/forgiveness, third parties and provocation,
   no double kill penalty or AI/mob kill bonus, no live role/score feedback and no
   reversal of escape wins. Treat formulas/timings as provisional, not approved constants.
6. Test proximity text at send-time radius, initially through walls, bounded received
   history without replay to arrivals, identical AI/human limits, no global/private
   channel, and non-pausing input. Test role-blind dead/escaped spectator cameras
   across both roles, local chat visibility and no hidden inventory or signals to
   living players. Check role leaks through UI, logs, loot and disconnect messages.
7. Cover AI local memory → delayed/limited Director reports → freshness → relevant
   assignments, stale last-seen versus live truth, observed ID recognition, shared
   actions/resources and blocked-path recovery. Cover mob role-blind danger, warnings,
   retargeting, leash/return and independence. Seed/time injection supports repeatable
   logic checks, not deterministic physics or proof of human-like deception.
8. Test authoritative rejection of spoofed sender/identity, damage/range/movement,
   loot and objective requests. Check deadline/extraction ties (extraction first),
   one terminal result, preserved individual wins and no all-AI-dead auto-win.
   Cover vulnerable disconnected characters, same-actor reconnect or spectating,
   timeout death/full loot without overtime, no late living joins/AI takeover,
   and host-loss technical termination without migration or fabricated gameplay wins.
9. Distinguish automated peers from real four-human sessions. Manual runs are
   necessary for camera/collision, visible identity, extraction visuals, readable
   text and perceived deception. Record commands, engine, counts, outcomes,
   expected failures/skips and unrun scenarios; do not claim absent gameplay works.
10. For performance, measure on Windows/Intel i5/16 GB/integrated graphics and record
    actual CPU/iGPU, driver, resolution/renderer, scene, bot count, role, warmup and
    duration. Measure FPS/frame times, RAM, navigation and AI updates as population
    grows toward 22–25 and the 1×1 km target. Separate editor/multiple-process costs.
    Benchmarks are provisional; headless checks cannot demonstrate GPU performance.
11. Update PROGRESS.md with actual checks, limitations, unresolved technical choices
    and the exact next step. Review staged scope/whitespace and commit on the
    dedicated branch; do not push/merge unless authorized.

Use built-in/standard-library tooling first. A new test dependency needs documented
need, license and cost. Do not claim Codex/Antigravity auto-discovery from plain files.
