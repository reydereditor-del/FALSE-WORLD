# Map foundation asset provenance

## User-licensed Basic Motions on the existing worker (2026-11-05)

- Original animation author: **Kevin Iglesias**, Human Basic Motions **2.4 FREE**,
  <https://kevdev.itch.io/basic-motions-free>. User supplied the Godot/Unreal ZIP,
  SHA-256 `063d5e1822f85549d14035ef342b1feae45bac37962499a8b478c7eb997200cd`.
  Its included author PDF specifies Standard Asset Store EULA, royalty-free
  commercial use allowed and resale prohibited. It is not CC0/MIT content.
- Normalized Godot donor: **Furkan Demir**, Real Controller **1.3.0**,
  <https://store.godotengine.org/asset/furkan-demir/real-controller/>;
  <https://github.com/fdemir/real-controller> pinned to
  `25cce290ebb538b05216e5e260f0407de71ba36f`. Supplied donor archive SHA-256
  `945008784ba4f4f6ccd3bd4eee3bb6a8c70623e37c6697260831a442da2a771b`.
  Donor software MIT notice retained separately; not a replacement animation license.
- Files: local, Git-ignored `assets/visual/licensed_locomotion/{walk,run}_*.tres`
  (eight directions each), `manifest.json`, original author PDF and notices.
  The installer reads only animation data and numeric rest definitions; it does
  not install the donor character, controller, texture, jump/sprint or camera.
- Modifications: original project retarget code maps 56 source bones to the existing
  19 worker joints, solves limb poses, scales trajectories, aligns hands and closes
  loops. Existing worker mesh, skeleton/rests and original workwear remain unchanged
  under their existing Cesium Man CC-BY-4.0 records below.
- Author credit and original PDF/EULA notice are retained with generated local data;
  keep the applicable notices for any permitted game distribution. Raw/retargeted
  animations are excluded from the public Git repository. No asset resale, new
  service, subscription, paid tool or cost (0 UZS).

[Setup, source terms and verification](../docs/LICENSED_LOCOMOTION.md).

## Directional speed comparison (2026-11-05)

Original preview-only marked-floor shader, meter labels, three-profile composition
and blending/measurement code are in `tools/visual/*walk*experiment*` and
`tools/visual/experimental_walk_*.gd`. Evidence in `docs/evidence/directional_speed/`
is actual Godot rendering of the existing attributed worker and unchanged local
clips, with an explicit unaccepted-blend caption. The floor is original review
geometry, not map work; screenshots/video are not game assets. No third-party asset,
animation set, license, paid service or cost is introduced. Existing worker
CC-BY-4.0 credit obligations remain unchanged. See
[the experiment record](../docs/DIRECTIONAL_SPEED_EXPERIMENT.md).

## Locally authored directional walks (2026-11-04)

Original pose/trajectory authoring by FALSE WORLD project contributors in this
Codex-assisted task: `tools/visual/author_directional_walks.gd` reproducibly bakes
`assets/visual/animations/{backward_walk,strafe_left,strafe_right}.tres` onto the
existing worker skeleton. The source forward walk was inspected as a timing/style
reference; no animation channel was copied, time-reversed or rotated into a strafe.
These are local authoring outputs, not downloaded Quaternius/KayKit/Mixamo assets.
No third-party tool/plugin, service or paid asset is added. Cost: 0 UZS.

The unchanged worker skin/skeleton and its existing forward walk remain the
attributed Cesium Man derivative, CC-BY-4.0; retain its existing source, license
and modification notices with distributions. This authoring does not remove those
obligations or introduce a new blanket repository license.

`scenes/preview/directional_walks.tscn` and its script use original checker-floor
geometry for isolated review, not new map content. Evidence in
`docs/evidence/directional_local/` contains actual Godot renders of that existing
attributed character and the local clips, plus test results; it is documentation,
excluded from Godot imports. No screenshot is used as a game texture or model.

Recorded 2026-11-02 (Asia/Tashkent). No third-party art is imported in this task.

## Original project work

- Author: FALSE WORLD project contributors, created in this Codex-assisted task.
- Source: this repository's `tools/build_map_foundation.gd` and
  `scripts/world/map_layout.gd`; generated `scenes/world/map_foundation.tscn`.
- Content: terrain mesh, road ribbons, roofless building shells, pine geometry,
  simple independent colliders, water tower, radio mast/cabinet, signs and materials.
- Creation date: 2026-11-02. No external source URL or third-party license applies
  to this original work; this record does not introduce a new repository license.
- Modifications: initial authoring, collision/road/sign-placement corrections.
- Attribution obligations: no third-party art obligations introduced. Existing Godot
  engine licensing is unchanged. Characters/camera/lever reuse the existing project.
- No downloaded texture, model, font file, addon, importer, rig or animation is used.
  Label3D uses Godot's existing default font; no font resource was copied into the repo.

## Bounded external-source review

No Google/general web-search tool is exposed in this task. Direct original-page
requests through the provided HTTPS proxy all returned HTTP 403, before page or
license content could be inspected:

| Candidate | Original page attempted | Intended comparison | Outcome |
| --- | --- | --- | --- |
| Kenney Nature Kit | https://kenney.nl/assets/nature-kit | Coherent simple environment geometry; format, scale, license and pack size | Unavailable; no page/license/download verified |
| Quaternius Ultimate Nature | https://quaternius.com/packs/ultimatenature.html | Forest silhouettes/style; mesh cost, collisions and supported formats | Unavailable; no page/license/download verified |
| Poly Haven models | https://polyhaven.com/models | More detailed environment pieces; texture/geometry cost and reuse rights | Unavailable; no page/license/download verified |

These are candidate-review intentions, not claims about unseen content, exact licenses,
quality, format, cost or download size. No candidate was selected or downloaded and
no third-party license text is applicable to retain. Original bounded geometry was
selected because no candidate's rights or files could be verified within the focused
pass. It is layout art, not finished environment art or an internet-wide best selection.
A later asset task must verify original download pages, exact licenses and obligations
and add the ledger and retained license text **before** importing any third-party art.

## Visual vertical slice V1 (subsequent task)

Recorded before import on 2026-11-02. Model-specific verified assets:
Microsoft/sbtron's Lantern and Microsoft's Boom Box, CC0-1.0, downloaded from
KhronosGroup/glTF-Sample-Assets pinned commit
`8f492390ddc7a2ae221a1369ef560589cf8c70fb`, each `Models/NAME/glTF-Binary/NAME.glb`.
Files: `assets/visual/models/{Lantern,BoomBox}.glb`; static decorative props, scale
and placement only, no fabricated device functionality. Original author/license/
source records, changes and secure hashes are in
[docs/ASSET_LICENSES.md](../docs/ASSET_LICENSES.md); full notices in `assets/licenses/`.
CC0 requires no attribution, retained voluntarily. No paid service or asset purchase.
Original PBR maps and architecture/detail meshes are project work, recorded there.
Character candidates remain temporary until their rights/style/import are evaluated.

Selected character derivative, recorded before export/import: `worker.glb` derives
from Cesium Man by Cesium (2017), CC-BY-4.0, same pinned Khronos source. Full original
branded image/materials are discarded; new original workwear vertex colors replace
them. Geometry/skeleton/source walk are retained. Source URL/hash, modifications,
attribution obligations and original notices: [ASSET_LICENSES.md](../docs/ASSET_LICENSES.md).
The original temporary GLB is not included in the repository. No trademark rights
or endorsement are claimed; no Cesium logo texture is shipped.

## Stage 4 signal prototype (original supporting pieces)

Created 2026-11-02 by FALSE WORLD project contributors in this Codex-assisted task:
`scenes/stage4/signal_loop.tscn` adds an original small service-module/latch mesh,
signal control panel/lever and yard markings/sign text. It reuses existing original
steel material and creates no new downloaded art, texture, font or third-party
license obligation. Existing visual-slice licensed assets remain unchanged with
credits above and in `docs/ASSET_LICENSES.md`. No asset purchase or paid service.
