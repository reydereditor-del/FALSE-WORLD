# Visual slice asset licenses

Retrieval: 2026-11-02 (Asia/Tashkent). Source repository pinned to
`KhronosGroup/glTF-Sample-Assets` commit `8f492390ddc7a2ae221a1369ef560589cf8c70fb`.
Original model-specific legal records were read before project import. Full license
texts and upstream model notices are retained under `assets/licenses/`.

| Asset / author | Exact source | License | Project file / use / modifications |
| --- | --- | --- | --- |
| Lantern — Microsoft, initial version sbtron (2017) | https://github.com/KhronosGroup/glTF-Sample-Assets/tree/8f492390ddc7a2ae221a1369ef560589cf8c70fb/Models/Lantern | CC0-1.0 | `assets/visual/models/Lantern.glb`; weathered lamp prop; placement/scale only |
| Boom Box — Microsoft (2017) | https://github.com/KhronosGroup/glTF-Sample-Assets/tree/8f492390ddc7a2ae221a1369ef560589cf8c70fb/Models/BoomBox | CC0-1.0 | `assets/visual/models/BoomBox.glb`; static workshop clutter, not a functional rescue radio; placement/scale only |

The model source pages link their `glTF-Binary/NAME.glb` downloads. CC0 permits free
commercial use and redistribution; attribution is voluntary and retained here.
No asset-store purchase/account or paid service is used. Do not infer licenses from
the repository's top-level license: these notices are model-specific.

Original concrete, painted/rusted steel and gravel PBR textures are authored in
`tools/visual/create_pbr_materials.py` and stored in `assets/visual/materials/`.
They are original procedural maps (albedo, tangent-space normal, roughness, plus
steel metallic), not photographs, downloaded scans or generated game screenshots.
No third-party texture license/attribution applies to these original outputs.
NumPy/Pillow/SciPy are optional existing authoring tools, not bundled/runtime packages.
Their licenses are BSD-3-Clause / HPND / BSD-3-Clause respectively; cost 0 UZS.

## Candidates and access limitations

- Poly Haven original site/API and Quaternius original page: unavailable through the
  configured proxy; Poly Haven API CONNECT returned HTTP 403. No files/license from
  these domains are claimed verified. Mixamo would require account/redistribution
  review; no login or animation scraping was attempted.
- Sponza was rejected after reading its model-specific CRYENGINE Limited License;
  it must not be assumed freely usable in Godot from an older CC label.
- Cesium Man has CC-BY-4.0 geometry/animation plus a separate reserved trademark/logo
  notice. Rigged Figure offers CC-BY-4.0 without that branded texture; character
  evaluation/integration status will be recorded after import/animation validation.
- The temporary Soldier model candidate was not imported: its source/animation
  redistribution rights were not sufficiently established for this repository.

Credits here must ship with any distribution containing the attributed assets.
No material in this ledger grants trademarks or endorsement rights.

## Selected humanoid derivative (recorded before export/import)

Cesium Man — Cesium, copyright 2017, **CC-BY-4.0**. Exact acquired original:
https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Assets/8f492390ddc7a2ae221a1369ef560589cf8c70fb/Models/CesiumMan/glTF-Binary/CesiumMan.glb
SHA-256: `b7001eaeea8254bd44773bcd247e78696d94169388fbb2a1800fc69434e777d9`.

The original is temporary authoring input only, not included in the repository.
**Discard its entire original branded image and original materials** before exporting
`assets/visual/models/worker.glb`. Preserve mesh, skeleton and source walk animation;
author original unbranded per-vertex workwear colors/materials. No Cesium logo or
original texture is shipped in the derivative. This avoids claiming any trademark
rights from the asset copyright license. CC-BY attribution, source link, license
text/link and modification notice are retained here and must accompany distribution.
Scale/placement, original Idle pose/breathing and velocity-driven playback are
project presentation work; source supplies one walking clip, not an idle clip.
Integration is not considered complete until real import/skin/animation tests pass.

Rigged Figure was evaluated but rejected as only 370 vertices with no texture UVs;
it is too abstract for this art direction. Cesium Man's 3,273-vertex skinned form is
a lightweight fallback, not a photorealistic final character or a custom animation set.

## Imported and validated files

`assets/visual/manifest.json` records SHA-256 and size for every imported model and
texture, including Godot-extracted embedded prop PNGs. Lantern's acquired GLB SHA-256:
`a79458c4b02d695187a952f23a63b8bf278e7bc3d316a3c2a314f2d6974181f1`.
BoomBox's acquired GLB SHA-256:
`f8b918445ebdd006768232205a62f5182d2208ca57f84c6ccc084943c0bc8f15`.
Those two originals remain unmodified; generated `Lantern_*.png` / `BoomBox_*.png`
are their embedded 2048×2048 material maps extracted by Godot, under the same CC0
model license. Their `.import` files are engine import settings, not new art sources.

Worker source geometry/skeleton/walk imported successfully with **19 bones**.
The derivative has vertex colors and **no embedded images**; the source branded
texture is absent. Godot imports the source clip as `Anim_0`; runtime copies it to
`Presentation/Walk`, adds original `Presentation/Idle`, and uses the same presentation
on human and all three AI. Bone-pose changes, real playback, stopping/starting and
velocity selection are checked in `tests/visual/test_showcase.gd`. The source supplied
one walk clip; Idle is authored project work, not a downloaded second clip. No
Mixamo animation or Quaternius file is included. Motion matching, foot IK, perfect
foot locking and final realistic character art are not claimed.

All new architecture, conduits, partial corrugated roof, vent, drums, debris, weeds,
stencil and supporting colliders are original project geometry/material work in
`tools/visual/build_showcase.gd`. Preview images under `docs/evidence/visual_v1/` are
actual game renders for review only; `.gdignore` excludes them from Godot resources.
No screenshot is used for a wall, sky, texture, model, shader or other game asset.
