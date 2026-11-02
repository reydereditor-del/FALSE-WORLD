# Map foundation asset provenance

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
