---
name: godot-development
description: Safely develop FALSE WORLD in the existing Godot 4.x project using modular GDScript within the authorized milestone.
---

# Godot development

1. Read `AGENTS.md`, `docs/FALSE_WORLD_HANDOFF.md`, `docs/GAME_DESIGN.md`,
   `docs/ARCHITECTURE.md`, and `docs/PROGRESS.md` completely before edits. The handoff
   v1.0 controls approved gameplay over older proposals. Inspect Git status and
   existing configuration; state the authorized scope and handoff §19 stage.
2. Documentation reconciliation permits docs/rules/skill edits only. Preserve the
   handoff and Godot configuration; do not create scenes, scripts, UI, networking,
   assets, runtime stubs, or dependencies. Approved mechanics do not authorize code.
3. Before later implementation, verify the actual editor version against the
   project's 4.7 declaration. Report mismatch; do not automatically recreate,
   downgrade, change renderer or rewrite settings. Historical checks are not fresh
   runtime validation. Use GDScript, retaining existing configuration unless authorized.
4. Follow the handoff's small-first sequence: traversal/camera/interaction slice,
   1 human + 3 AI deception proof, 6–8 AI small playable with one complete rescue
   route and survival systems, four-human authoritative networking, incremental
   two-route/full-map/22–25 AI expansion, stabilization. Keep increments scoped.
5. Use small typed modules, explicit dependencies and focused signals. Separate
   match/objective/combat/health/inventory/score rules from Godot presentation,
   transport and AI beliefs. Share human/AI character mechanics via input sources.
   Networking validates requests, resources and ownership; do not trust clients.
6. Preserve approved rules: individual rescue after call/wait, sent-call persistence,
   independent solo routes, bounded sabotage/progress, transactional critical items,
   permanent death/full loot, delayed living-only regen, finite ammo, pairwise hidden
   final damage penalties, proximity chat, role-blind spectators and bounded reconnect.
   Consult the handoff for details; do not replace these with earlier exclusions.
   Keep provisional values configurable; new major mechanics require user agreement.
7. Protect private roles, tiers, score ledger, AI memory and unsensed human state.
   Use audience filtering and restricted perception/report flow. Treat dialogue as
   local templates/intents through an adapter, not runtime Codex/Antigravity or a
   fake system message. Use `game-ai` for authorized AI changes.
8. Target Windows/Intel i5/16 GB RAM/integrated graphics with bounded content and
   measured performance. Full population/map and human-level dialogue are not
   guaranteed. Budget goal 0 UZS, absolute cap 100,000 UZS, no spending without
   permission and no paid service in this task. Verify and record commercial-use
   asset licenses before import; no unnecessary frameworks or cloud dependencies.
9. Apply `game-testing` for actual scoped checks. Suitable-version headless import
   is not proof of camera behavior, gameplay, network safety or GPU performance.
   Update PROGRESS.md with actual results, technical gaps and exact next step.
   Work on a dedicated branch, review/stage only intended files, commit, and do not
   push/merge/deploy without authorization.

Read these portable files explicitly if discovery is unavailable. Do not claim
agent integration, implemented features or passing tests from file existence alone.
