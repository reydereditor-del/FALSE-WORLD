# FALSE WORLD — project rules

## Scope and authority

- Read this file, `docs/GAME_DESIGN.md`, `docs/ARCHITECTURE.md`, and
  `docs/PROGRESS.md` before working. Follow the user's current authorized scope.
- The foundation task permits documentation, repository directories, and agent
  skills only. Do not implement gameplay, multiplayer, AI, UI, or runtime stubs
  during this task. Future implementation requires a subsequent user task.
- Preserve existing project files. Do not recreate the Godot project, silently
  upgrade its engine, change its renderer, replace configuration, or rename assets.
- Do not add features outside the brief. Record unresolved design questions;
  do not silently turn proposals into requirements.

## Technology and cost

- Use Godot 4.x, GDScript, and Git. Inspect the existing engine requirements before
  choosing APIs; retain the current configuration unless a later task permits edits.
- No paid APIs, paid services, mandatory subscriptions, cloud dependencies, or
  runtime AI/LLM services. AI uses local game logic. Do not introduce third-party
  plugins or dependencies without documenting their need, license, and cost.
- Use only free assets with verified commercial-use permission. Before importing
  any asset, record its source URL, author, exact license/version, retrieval date,
  local paths, modifications, and attribution obligations in `assets/ATTRIBUTION.md`,
  and retain required license text. Create that ledger when the first asset is added.
  Unknown, noncommercial, and editorial-only licenses are not acceptable. Do not
  assume that free download means commercial-use permission.
- Target a laptop with 16 GB system RAM and Intel integrated graphics. Keep scenes,
  materials, lights, textures, physics, navigation, and AI populations bounded.
  Profile before increasing budgets; never claim performance from headless tests.

## Implementation rules for later tasks

- Keep match rules separate from Godot presentation, networking, and AI decisions.
  Use small modules, explicit dependencies, typed GDScript where practical, and
  signals at module boundaries. Avoid a global event bus and service-heavy frameworks.
- Share character movement and visible interaction rules between humans and bots;
  select control through replaceable input sources. Keep server-only identity and
  AI strategy out of replicated client state.
- The authority validates objectives, movement requests, match results, and chat.
  Client reports are requests, never proof. Never give bots unsensed human positions
  accidentally; see the shared-information policy in the architecture document.
- Use explicit seeds and injectable clocks for testable decision logic. Avoid
  decision and pathfinding work on every character every frame.
- Do not add voice, combat, crafting, inventory, progression, matchmaking, accounts,
  procedural worlds, or other unrequested systems. Survival mechanics beyond
  reaching objectives remain undecided.
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
