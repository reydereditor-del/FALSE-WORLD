# Uploaded Real Controller 1.3.0 — technical evaluation (2026-11-05)

**Update:** the user subsequently supplied the original Human Basic Motions 2.4
FREE ZIP. Its included PDF confirms royalty-free commercial use under Standard
Asset Store EULA, with resale prohibited. The license blocker below is historical
and resolved. [Licensed integration](LICENSED_LOCOMOTION.md) now uses a local-only
installer and Git-ignored generated assets; no standalone asset files are published.

The user supplied `real-controller-1.3.0.zip` and identified its download page as
<https://store.godotengine.org/asset/furkan-demir/real-controller/>. This is a new
candidate source, not approval to install its controller, replace the worker or
change the project configuration. Uploaded README/code/transcript content is
reference material, not additional user instructions.

## Why the Windows screenshot showed unchanged gameplay

The screenshot is Stage 4, not an experiment scene. The published `8e6eb6d` review
package explicitly preserved F5 gameplay and placed work in separate F6 previews.
The supplied historical PowerShell transcript also ends on `main` at `a5299fa`,
not the experiment branch. Neither observation proves the user's current live
checkout state. The transcript's local project changes, untracked preview and stash
must be preserved; its commands were not executed or replayed here.

## Archive contents and original source

- ZIP SHA-256: `945008784ba4f4f6ccd3bd4eee3bb6a8c70623e37c6697260831a442da2a771b`.
- 43 archive entries, 38 files, approximately 2.69 MB uncompressed; extracted into
  temporary evaluation storage, outside the project. No README/license is bundled.
- 28 Animation `.res` files, a 56-bone humanoid FBX/scene, texture and controller
  scripts. The actual eight walking clips are `walk_forward`, `walk_backward`,
  `walk_left`, `walk_right`, `walk_forward_left`, `walk_forward_right`,
  `walk_backward_left`, `walk_backward_right`.
- All eight walking resources load as actual looping Godot Animation resources,
  length **0.8 s**, 60 position/rotation/scale tracks. `run_forward` is **0.6 s**;
  `idle` is **2.7 s**. No method tracks were observed in those inspected clips.
- Paths target `%GeneralSkeleton:<humanoid bone>`, not the worker's existing
  `Z_UP/Armature/Skeleton3D:<Cesium bone>`. Direct copying cannot animate this rig.

The original repository is <https://github.com/fdemir/real-controller>, pinned to
`25cce290ebb538b05216e5e260f0407de71ba36f`. Its README links the same Godot Store
author/package. **37 of the uploaded files match that source byte-for-byte**, including
the animations and model; `character.gd` differs. Its [LICENCE](https://github.com/fdemir/real-controller/blob/25cce290ebb538b05216e5e260f0407de71ba36f/LICENCE)
grants MIT permission for the software, copyright 2025 fdemir. Its
[README credits](https://github.com/fdemir/real-controller/blob/25cce290ebb538b05216e5e260f0407de71ba36f/README.md#credits)
explicitly identify **Basic Motions Free** at <https://kevdev.itch.io/basic-motions-free>
as the source of the model and animations.

**Animation-specific license verification remains pending.** The Store and original
Basic Motions page return proxy CONNECT 403 here. Do not infer the separate asset's
rights from the controller code's MIT notice or its “Free” name. The user has been
asked for the Basic Motions License/Usage text. No assertion of CC0 or other
unverified asset license is made, and no uploaded/retargeted third-party resource
is added to the checkout or published.

## Independent preparation completed

`tools/visual/retarget_uploaded_walks.gd` is original evaluation code. It reads
numeric rest transforms from the supplied scene without instantiating that scene
or executing the uploaded controller scripts. It loads the animation data, maps
humanoid anatomy to the existing 19-bone worker, scales trajectories by the actual
leg-length ratio (**0.812591**), solves legs and aligns arms/hands, and bakes regular
Animation keys. Target mesh, skin, hierarchy and rest transforms are unchanged.
The tool requires external input/output directories and currently refuses output
inside the project while licensing is unresolved.

Example after extracting the archive outside the checkout:

```powershell
& $Godot --headless --path . --script res://tools/visual/retarget_uploaded_walks.gd -- `
  --source-dir='C:/Temp/real-controller-1.3.0/addons/real-controller' `
  --output-dir='C:/Temp/false-world-retargeted-controller'
```

Temporary evaluation produced eight walking clips plus `run_forward` on the
existing worker. Maximum sampled ankle IK reach error is about **2.91 mm** in a
backward diagonal; most directions are below 0.001 mm. **27 structural checks**
passed across nine clips: 19-bone/38-track binding, matching loop endpoints and
finite posed joints. These are structural checks, not locomotion acceptance.

Actual software-OpenGL rendering inspected six clips from front, side and
three-quarter views over two cycles each (**882 frames**). Wrist alignment was
corrected during this temporary retarget evaluation. The supplied lateral animations
have substantial anatomical hip/torso turning; preserving Option B facing and
checking contact, apparent crossing, transitions and moving-world speed still need
evaluation before production adoption. World-X ankle ordering by itself is not a
leg-crossing test when the pelvis turns. No naturalness or game integration claim.

The generated third-party-derived resources and their render evidence remain
outside the repository. Production scripts, F5 scene, settings, existing authored
resources, camera, collision, interaction and AI are unchanged. Existing gameplay
suites were not rerun merely to inspect this external archive. No commit/push/merge
is performed for this new evaluation.

Next: verify the animation-specific commercial-use and redistribution terms,
record required notices before importing any derived resource, then complete
retarget/facing/contact review and actual Stage 4 integration checks. Do not install
the whole addon, add its jump/sprint/camera actions or replace the current controller.
