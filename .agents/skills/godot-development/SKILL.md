---
name: godot-development
description: Safely develop FALSE WORLD in the existing Godot 4.x project using modular GDScript within the authorized milestone.
---

# Godot development

1. Read root `AGENTS.md` and the three project docs. Inspect Git status and the
   existing `project.godot`. State the current authorized scope and milestone.
2. For foundation-only work, edit documentation and folder markers only. Do not
   create runtime scripts, scenes, configuration changes, UI, or autoload stubs.
3. Before later implementation, verify the intended editor version against the
   project feature declaration. Use APIs available in that version; report engine
   mismatch rather than upgrading or rewriting configuration automatically.
4. Make the smallest complete increment. Use typed GDScript, small scene components,
   explicit dependencies, and focused signals. Separate match rules from camera,
   transport, and scene paths. Share character mechanics across input sources.
5. Preserve existing files and settings unless the current task authorizes a
   necessary change. Document renderer, dependency, transport, and cost decisions
   before adopting them. Use no paid services or unverifiable asset licenses.
6. Keep the 16 GB / Intel integrated graphics target visible: simple graybox,
   bounded physics and draw work, modest assets, no speculative visual effects.
   Rendering recommendations are proposals until measured on target hardware.
7. Apply `game-testing` to the changed behavior. Run engine/import checks only with
   a suitable version and inspect any resulting file changes. A headless import
   is not a third-person camera, multiplayer, or performance test.
8. Update `docs/PROGRESS.md` with files changed, actual checks, unresolved issues,
   and one exact next implementation step. Review and commit only intended changes.

Do not add dependencies merely to scaffold a future feature. Do not label a stub
or disconnected control as implemented. Read this skill manually in either Codex
or Antigravity if automatic skill discovery is unavailable.
