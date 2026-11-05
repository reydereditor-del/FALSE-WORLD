# Directional locomotion sourcing — 2026-11-04

**Historical research record.** The subsequent user instruction stops external
asset research and downloads. [Locally authored walks](LOCAL_DIRECTIONAL_WALKS.md)
now provide three editable clips and an isolated rendered preview. Gameplay
integration remains unaccepted at 4 m/s. The download handoff below is preserved
as history and is no longer the requested next step.

**Blocked; backward/strafe integration is not complete.** This increment performed
source research, actual rig/clip inspection, candidate rendering and regression
validation. It adds no runtime animation, retargeted asset or new fallback.
The existing Option B idle glide remains. No Windows-only Antigravity work was
present or assumed. Branch: `feat/authentic-directional-locomotion`, clean base
`a5299fa`; no commit, push or merge.

## Existing integration boundary

`assets/visual/models/worker.glb` is the existing unbranded Cesium Man derivative,
with 19 joints and exactly one source animation, `Anim_0`. It is CC-BY-4.0, as
recorded in [ASSET_LICENSES.md](ASSET_LICENSES.md). No model replacement is needed.
`scripts/visual/worker_presentation.gd` clones that animation to `Presentation/Walk`
and authors `Presentation/Idle` from rest with corrected arms. It has no
AnimationTree. State changes crossfade for 0.18 seconds; forward playback uses
actual horizontal speed divided by 2.5, clamped to 0.4–1.6.

The presentation reads velocity in `Visual`'s local frame. With facing intent,
positive Z or lateral speed exceeding 15% selects the explicit missing-direction
fallback. `LocalController` supplies camera-relative normalized input and a separate
camera-facing intent. `CharacterMotor` owns movement/collision and limits visual
turning; these are not animation/root-motion responsibilities. AI retains its
existing movement-facing behavior. Do not change those modules to fit an asset.

Anatomical correspondence for evaluating incoming clips (not a tested retarget):

| Anatomical joint | Existing worker bone | KayKit candidate bone |
| --- | --- | --- |
| Pelvis | Skeleton_torso_joint_1 | hips |
| Spine / chest | Skeleton_torso_joint_2 / torso_joint_3 | spine / chest |
| Neck / head | Skeleton_neck_joint_1 / Skeleton_neck_joint_2 | no separate neck / head |
| Left upper/lower arm, hand | Skeleton_arm_joint_L__4_ / Skeleton_arm_joint_L__3_ / Skeleton_arm_joint_L__2_ | upperarm.l / lowerarm.l / wrist.l |
| Right upper/lower arm, hand | Skeleton_arm_joint_R / Skeleton_arm_joint_R__2_ / Skeleton_arm_joint_R__3_ | upperarm.r / lowerarm.r / wrist.r |
| Left thigh, calf, foot, toe | leg_joint_L_1 / leg_joint_L_2 / leg_joint_L_3 / leg_joint_L_5 | upperleg.l / lowerleg.l / foot.l / toes.l |
| Right thigh, calf, foot, toe | leg_joint_R_1 / leg_joint_R_2 / leg_joint_R_3 / leg_joint_R_5 | upperleg.r / lowerleg.r / foot.r / toes.r |

Blender inspection found different rest axes and proportions; name substitution
alone is insufficient. KayKit has 41 joints including IK/control bones, versus
the worker's 19. Preserve target rest transforms, skin, scale and hierarchy;
any future retarget must bake to target bones and verify foot contacts.

## Bounded source search and actual results

No general web-search/browser tool was available. Direct public source/catalog
requests and GitHub discovery were used; no login, scraping of restricted downloads,
paid service, or network-policy bypass was attempted.

| Source | Observed result |
| --- | --- |
| <https://quaternius.com/packs/universalanimationlibrary.html> | Proxy CONNECT 403; page, license and download not readable |
| <https://quaternius.itch.io/universal-animation-library> | Proxy CONNECT 403; not downloaded |
| <https://kaylousberg.com/game-assets> and <https://kaylousberg.itch.io/kaykit-character-animations> | Proxy CONNECT 403 |
| <https://github.com/KayKit-Game-Assets> | Readable official catalog; discovered Adventurers repository |
| <https://github.com/KayKit-Game-Assets/KayKit-Character-Pack-Adventures-1.0> | Original repository cloned into temporary research storage; README, license and actual GLB inspected |
| <https://www.mixamo.com/> | Proxy CONNECT 403; no login or manual flow bypass attempted |
| Google query / GitHub repository search | CONNECT 403 / HTTP 429; no search results treated as license evidence |

The guessed GitHub `KayKit-Character-Animations` URL returned 404; it is not an
acquired source. The authoritative usable source was **KayKit — Character Pack:
Adventurers 1.0**, by **Kay Lousberg**, pinned to
`672074b73ba276876a19e8816ecdc5241817ab47`.
Its [original license](https://github.com/KayKit-Game-Assets/KayKit-Character-Pack-Adventures-1.0/blob/672074b73ba276876a19e8816ecdc5241817ab47/LICENSE.txt)
states CC0 1.0, free personal/educational/commercial use and optional credit.
CC0 permits redistribution, including in a commercial game; no attribution is
required. Voluntary credit would be “KayKit by Kay Lousberg, kaylousberg.com”.

Inspected file:
`addons/kaykit_character_pack_adventures/Characters/gltf/Knight.glb`, SHA-256
`60428e3abc09ba83e595d256e3af8c5c976b46cdae599f0802fc82b4a3445168`.
Actual animation inventory includes `Walking_Backwards`, `Walking_A/B/C` and
`Running_Strafe_Left/Right`. It contains **no walking-strafe clips**.
Blender 4.3.2 CPU Cycles rendered four quarter-cycle poses for each of the three
candidate directions. Inspection showed stylized lateral running with body
rotation, not an established forward-facing walking set for Option B. These
clips are not accepted as completed authentic walking strafes. This does not prove
retargeting them is impossible; compatibility and final-worker quality are unverified.
No KayKit model, texture, clip or screenshot was imported into this repository.

## Remaining blocker and precise download handoff

A verified complete walking set has not been acquired. To unblock the preferred
next candidate, open **Quaternius Universal Animation Library** at
<https://quaternius.com/packs/universalanimationlibrary.html> in a browser with
access. Use only its free tier and normal author-provided download flow. Download
the archive with backward-walk and left/right walking-strafe clips **if included**,
plus the original license/readme. Its license was inaccessible here: do not treat
its name or an external “CC0” claim as verified permission. Supply the archive and
license only if they explicitly permit commercial game use and redistribution.

Place supplied files under `/workspace/shared/false-world-animation-input/` (outside
Godot's resource tree), or attach them for the next task. Prefer the original
Blender source, otherwise FBX/glTF/GLB containing the source armature and animations;
no replacement character is requested. For an export, include the rest/T pose,
all deform-bone rotation keys, 30 fps baked sampling and complete loop endpoints;
use in-place clips without horizontal root displacement, preserve vertical hip
motion, and include units/axis information. Do not strip the armature or rename
bones before retargeting. Preserve the original archive too. Exact available clip
names, formats and license remain subject to inspection; no paid upgrade is implied.

Once input is available: verify source/license, retain notices and add attribution
**before import**, retarget to the existing worker, reject horizontal root motion,
and integrate only into WorkerPresentation. Evaluate normalized diagonals and
phase-aware transitions using actual local velocity, while preserving forward/idle
and motor authority. This is preparation, not implemented blending infrastructure.

## Checks actually run

Godot `4.7.2.stable.official.ed1daf0bf`, writable XDG directories and four-core
affinity in the existing runners:

- `python3 tools/run_stage4_checks.py --godot /workspace/.tools/godot/4.7.2/Godot_v4.7.2-stable_linux.x86_64 --output /tmp/directional-stage4-validation`:
  PASS, fresh complete/success summaries, **369 checks**, **16/16 AI scenario runs**;
  includes imports, asset checks, startup, movement, camera, interaction, AI and
  Stage 4 integration. No tests modified.
- Direct existing scripts with `--headless --max-fps 600 --fixed-fps 60
  --quit-after 8500 --script res://tests/<path>`: `visual/test_option_b.gd`
  **36/0**, `visual/test_character_fixes.gd` **7/0**,
  `stage4/test_signal_replay_audit.gd` **10/0**. Total **422 ordinary checks**.
  Option B covers eight directions at two camera yaws, stopping, rapid changes,
  turning while moving, pitch and AI facing; it still asserts the old glide.
- Original-source renders inspected in isolation. Actual current Stage 4 rendered
  on an isolated Xorg display: Vulkan initialization failed; automatic Mesa llvmpipe
  OpenGL fallback produced a review image. Project renderer settings were not
  changed. The temporary review camera was occluded by existing building geometry;
  that gameplay capture does not validate character footwork. This confirms rendering
  availability, not new animation quality.
- Git preservation/whitespace checks: recorded in PROGRESS.md. No new locomotion
  is implemented or visually validated; no Windows or performance pass claimed.

## Windows acceptance after integration

1. Open the existing project in Godot 4.7.2; F5 starts Stage 4. Test W/S/A/D
   and all four diagonals at constant camera yaw. Each must step in its direction
   with camera-facing body and unchanged normalized speed.
2. Stop/restart, alternate opposite directions and rotate the camera while moving.
   Inspect feet through full cycles: no severe sliding, snaps, twisted knees,
   root drift or doubled translation. Check forward and resting arms remain intact.
3. Walk into a wall and orbit near walls; check collision/camera and the three AI.
4. Collect the module, cancel/resume E at the cabinet, and reach the marked yard
   during the countdown. Check success, empty-arrival retry and R restart.

These are pending acceptance steps, not passing results for new clips.
