# FALSE WORLD — project rules

## Scope and authority

- Read this file, `docs/FALSE_WORLD_HANDOFF.md`, `docs/GAME_DESIGN.md`,
  `docs/ARCHITECTURE.md`, and `docs/PROGRESS.md` before working, plus relevant skills.
  The finalized handoff v1.0 overrides conflicting earlier gameplay proposals.
  Follow the user's current authorized scope; approved design is not permission
  to implement every system. Documentation-only restrictions apply to reconciliation
  tasks; later explicitly authorized implementation is limited to its stated scope.
- Keep confirmed mechanics separate from provisional balance/technical choices.
  Do not reopen approved rules or silently add major mechanics. Future runtime
  implementation requires a subsequent scoped task; follow the handoff's stages.
- Preserve existing project files. Do not recreate the Godot project, silently
  upgrade its engine, change its renderer, replace configuration, or rename assets.
- Do not add features outside the brief. Record unresolved design questions;
  do not silently turn proposals into requirements.

## Technology and cost

- Use Godot 4.x, GDScript, and Git. Inspect the existing engine requirements before
  choosing APIs; retain the current configuration unless a later task permits edits.
- Budget target is 0 UZS, absolute ceiling 100,000 UZS; no expenditure without
  explicit user permission. Do not add paid APIs/services, subscriptions or cloud
  dependencies. Start AI with local logic and contextual dialogue templates/intents;
  no runtime LLM is required. Future model/API integration needs separate assessment
  and authorization. Document any proposed dependency's need, license, and cost.
- Use only free assets with verified commercial-use permission. Before importing
  any asset, record its source URL, author, exact license/version, retrieval date,
  local paths, modifications, and attribution obligations in `assets/ATTRIBUTION.md`,
  and retain required license text. Create that ledger when the first asset is added.
  Unknown, noncommercial, and editorial-only licenses are not acceptable. Do not
  assume that free download means commercial-use permission.
- Target Windows on an Intel i5 laptop with 16 GB RAM and integrated graphics. Keep scenes,
  materials, lights, textures, physics, navigation, and AI populations bounded.
  Profile before increasing budgets; never claim performance from headless tests.

## Implementation rules for later tasks

- Keep match rules separate from Godot presentation, networking, and AI decisions.
  Use small modules, explicit dependencies, typed GDScript where practical, and
  signals at module boundaries. Avoid a global event bus and service-heavy frameworks.
- Share character movement and visible interaction rules between humans and bots;
  select control through replaceable input sources. Keep server-only identity and
  AI strategy out of replicated client state.
- The authority validates identity, movement, range/damage, loot, objectives, AI,
  chat, reconnect, and results. Client reports are requests, never proof. Separate
  server truth from AI knowledge and audience-filtered replication. AI know teammates
  and may identify visually observed non-teammates; human state requires perception
  or justified reports via local memory and delayed/limited Director dispatch.
  No live role, tier, score, spectator, disconnect, or log leaks to living players.
- Use explicit seeds and injectable clocks for testable decision logic. Avoid
  decision and pathfinding work on every character every frame.
- Combat, slow automatic HP regeneration plus medkits, bounded inventory/full
  loot, proximity text chat, hidden final human-damage penalties, separate enemy
  mobs, role-blind spectators and bounded reconnect are approved design, not yet
  implemented. Individual escape requires a completed rescue call/wait on either
  independent route; reaching the summit alone is insufficient. Preserve permanent
  death, shared human/AI capabilities, critical-item safety, and restricted AI
  knowledge. See the handoff for all approved rules and provisional details.
- Do not add voice, crafting, hunger/thirst, store, persistent ranked/Elo, accounts,
  unrequested progression/matchmaking/procedural worlds, or other new systems.
  The full target is four humans and varying 22–25 AI on 1×1 km; start small per
  handoff §19 and measure performance rather than promising it.
- Do not create UI controls, dummy network responses, or placeholder features that
  appear functional. Empty directory markers are organizational, not runtime code.

## Verification and delivery

- Inspect Git status before editing. Preserve unrelated and uncommitted work;
  never reset, clean, overwrite, or stage it indiscriminately.
- Work on a dedicated branch. Stage only intended files, review the staged diff,
  and commit the authorized changes. Do not push or deploy without authorization.
- Run checks appropriate to the change. For docs, check paths, links, skill
  metadata, scope, whitespace, and preservation of existing files. For runtime
  changes, also run applicable engine checks, behavior tests, and manual scenarios.
- Report the exact checks run, their outcomes, and what remains untested. A file
  existing or a parser succeeding does not establish gameplay correctness.
- Update `docs/PROGRESS.md` in every work increment with completed work, verification,
  limitations, and the exact next implementation step. Record cost and architectural
  decisions with rationale in `docs/ARCHITECTURE.md`.

## Codex and Antigravity

- This plain Markdown file is the shared source of project rules for both tools.
  An agent whose tool does not auto-load it must open it explicitly before editing.
- Skills live at `.agents/skills/<name>/SKILL.md` with portable YAML `name` and
  `description` fields. Read the relevant skill explicitly if discovery is unavailable.
- Do not require proprietary agent APIs, editor-specific workflows, symlinks, or
  duplicate rule files. Tool auto-discovery is not assumed or verified.
- Use `godot-development` for Godot changes, `game-ai` for AI changes, and
  `game-testing` for validation. These skills never expand the authorized task.
