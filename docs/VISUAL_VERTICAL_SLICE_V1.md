# Visual vertical slice V1

A separate runnable visual composition of the current map. F5 now starts
`scenes/visual/visual_vertical_slice.tscn`; the unchanged
`scenes/world/map_foundation.tscn` remains the explicit graybox fallback. No map-wide
art replacement, gameplay expansion, AI retuning or engine/renderer migration.

## What changed

The storehouse and entry apron around X [184,216], Z [110,142] cover **32×32 m**.
The showcase begins at (200,0.1,133), facing its existing open south entrance.
Outside this representative patch, the map deliberately remains the earlier layout.
The separate scene inherits all existing world geometry/AI/controls. The existing
storehouse colliders remain; door openings are preserved and new details overlay
its actual wall/roof surfaces. This is a textured/detail pass on the working shell,
not a fully reconstructed scanned building or a finished realistic environment.

- Original **1K albedo, normal and roughness maps** for dirty/cracked concrete,
  rusted painted steel and gravel; steel also has a metallic map. These are
  procedural PBR texture sets, not downloaded photography/photogrammetry. World-scale
  triplanar tiling avoids stretched cube faces. A ground PBR shader blends the apron
  edges into the old terrain; no screenshot planes or image-based scenery.
- Rusted door frames, partial corrugated roof, beams, conduit/straps, vent slats,
  lower foundation details, faded paint/stencil, supported workbench, colliding
  steel drums, scattered original fragments and bounded grass/weeds. Both old 4 m
  doorways and the central entry lane remain open. Most details are original pieces,
  not a downloaded high-detail architecture pack.
- Two real **CC0 GLB props**: Microsoft's BoomBox and Microsoft/sbtron's Lantern,
  acquired from pinned Khronos sources with their original PBR maps. They are static
  art: the radio does not send rescue calls and the lantern has no new interaction.
- Overcast procedural sky, restrained exponential distance fog, neutral cool color
  balance, directional shadows bounded to 65 m and one small unshadowed warm fill.
  No volumetric fog, SSR, SSAO, dynamic crowds or expensive new post-processing.
- One shared **CC-BY-4.0 Cesium Man derivative** for all four actors: unbranded
  original workwear vertex colors, retained skin/rig/walk, original breathing Idle,
  velocity-driven Walk/Idle transitions. Original branded image/materials are stripped
  from the exported file. This is a lightweight stylized humanoid fallback, not
  photorealistic final characters, realistic footsteps or complete locomotion polish.

See [asset licenses](ASSET_LICENSES.md), [attribution](../assets/ATTRIBUTION.md),
[retained licenses](../assets/licenses/) and
[asset checksums](../assets/visual/manifest.json).

## Composition and preservation

`StationArt` is a committed static scene authored by `tools/visual/build_showcase.gd`.
It adds detail only once; there is no per-frame environment scan or generation.
`visual_slice.gd` attaches `WorkerPresentation` to the existing `Visual` node of the
human/three actual AI, hides the two old visible capsule meshes only in this scene,
and leaves their body/capsule/motor/controller and camera focus node intact.
`worker_presentation.gd` reads physical velocity and changes animation playback;
it sends no movement commands, senses nothing and changes no AI knowledge.
The inherited human controls, real M1 lever, developer-only F3 gate, perception,
private memory, exploration, report coordination and scenario harness are unchanged.

Five new simple static bodies (table, three drums, lantern post) require a separate
local navigation bake: `scenes/visual/station_visual_navigation.tres`, **267 polygons**.
Its 90×90 m station bounds and agent settings match the graybox bake. Old scenes,
old navmeshes and tests remain byte-preserved; ten authored AI destinations, including
interiors, remain reachable. Visual-only floor overlays are millimetres above the old
terrain without raised collision steps. Door frames stay outside the clear openings.

Static art subtree inventory: **124 nodes, 106 mesh instances, about 20,377 triangles**
(includes imported props and 201 small foliage instances across two MultiMeshes),
plus six larger wall-side weed clumps and one small fill light. The four skinned
characters are additional. Prop textures are 2K; original material sets are 1K.
Draw calls/frame time/RAM are **not** measured on the target Intel integrated GPU.
The rest of the full map and its three-agent coverage remain bounded as before.

## Run and controls

Windows PowerShell; adjust the actual Godot executable path:

```powershell
Set-Location C:\Projects\FALSE-WORLD
git fetch origin
git switch feat/visual-vertical-slice-v1
$Godot = 'C:\Godot\Godot_v4.7.2-stable_win64_console.exe'
& $Godot --version
& $Godot --headless --path . --editor --import
& $Godot --path . --editor
# F5 starts the showcase; these are explicit scene launches:
& $Godot --path . res://scenes/visual/visual_vertical_slice.tscn
& $Godot --path . res://scenes/world/map_foundation.tscn
& $Godot --path . res://scenes/prototype/stage3c_coordination.tscn
& $Godot --path . res://scenes/prototype/m1_graybox.tscn
```

WASD and mouse use the working camera-relative motor/orbit. Escape releases control,
left click recaptures; focus loss stops movement/work. E still operates only the
old lever at (216,1,158), retaining partial progress when canceled. It lies outside
the art patch. F3 remains off/default and developer editor-debug only. No new inputs,
objective buttons, combat, HP, mobs, inventory, networking or rescue mechanics.

## Automated acceptance

Use Python 3 (standard library only) and verified Godot 4.7.2:

```sh
python3 tools/visual/run_checks.py --godot /path/to/Godot-4.7.2 --output /tmp/visual-checks
```

Cloud binary: `/workspace/.tools/godot/4.7.2/Godot_v4.7.2-stable_linux.x86_64`.
Export writable `XDG_CACHE_HOME=/workspace/.cache`,
`XDG_DATA_HOME=/workspace/.local/share`, `XDG_CONFIG_HOME=/workspace/.config`.
Editor import requires permitted local sockets; use the supported command sandbox
flow without changing project settings.

The runner executes `tools/run_map_checks.py` unchanged: 281 map/gameplay assertions,
including all seven earlier suites, and the real Stage 3D harness at seed 431/repeat 2
(16 cases/98 assertions with matching repeats). It then checks all new GDScript
parsers, the new real-scene integration suite, explicit showcase and graybox starts,
asset SHA-256s, full license presence, worker skin/animation/color data and absence
of branded embedded images. Every subprocess has a timeout; completion text/JSON
is checked as well as exit status. Logs reject engine/script errors and unknown
warnings. The exact previously reproduced Jolt fixed-job-pool warning remains visible
and recorded; no physics or old assertions are changed to hide it.

New-scene integration has **25 checks**, including unchanged capsule/radius/speed,
original input/interactor references, four real 19-bone rigs and both playing clips,
actual breathing and animated leg-pose changes, velocity transitions, imported 1K
PBR paths, instantiated GLB props, all three AI moving for 1,200 ticks, all ten sites
reachable on the rebake, normal-speed physics walks through both doors/around a
corner, drum collision, real lever cancel/progress, 36 camera-clearance/framing poses
and disabled-by-default diagnostics. Test starts change between independent cases;
walks use the real motor without teleporting or increasing speed.

## Rendered evidence and honest visual limits

Matched actual 1280×720 game renders, identical capture camera poses:

| View | Before | After |
| --- | --- | --- |
| Entry | [Graybox](evidence/visual_v1/before-entry.png) | [Textured slice](evidence/visual_v1/after-entry.png) |
| Player view | [Capsule/flat surface](evidence/visual_v1/before-player.png) | [Shared humanoid/PBR](evidence/visual_v1/after-player.png) |
| Interior | [Original shell](evidence/visual_v1/before-interior.png) | [Materials/roof/real radio prop](evidence/visual_v1/after-interior.png) |

`tools/visual/capture_preview.gd` loads and renders the actual scenes, freezes AI
movement only for matched capture, and saves images. These files live under
`docs/evidence/` with `.gdignore` and are never loaded as game assets. The before
capture places the old human at the same entry start for a fair camera comparison.

The cloud's default Forward Plus startup **cannot find VK_KHR_surface**. Godot
then automatically falls back to OpenGL 3 on Mesa llvmpipe/Xorg dummy display. These
fallback renders were actually inspected: surfaces and textures appear, silhouettes,
prop scale/support, common workwear and normal camera view are visible. Initial
white vertex-color characters and overly bright/noisy surfaces were corrected after
inspection. Final fallback images are not a clean Forward Plus/D3D12 pass. Preview
initialization logs contain Vulkan errors and fallback/V-sync warnings, separate
from successful headless runtime checks. No renderer/project downgrade was made.
Actual soft-shadow quality, subtle fog/sky differences, Windows driver behavior,
physical-input camera comfort, target-laptop FPS/frame time/RAM and exports remain
pending. Software rendering is not a GPU performance measurement.

External-source limits: Poly Haven API CONNECT returned HTTP 403; Quaternius site
was also unreachable. No asset/account/paid service was fabricated to fill that gap.
Missing **preferred upgrades**, not missing runtime resources: verified photo-based
1K concrete/gravel/steel sets, a coherent realistic industrial-architecture/foliage
pack and a higher-quality common worker with polished idle/walk. These originals
are a functioning first texture/detail slice, not a claim those preferred packs,
photogrammetry, final realism or an indie/AAA visual-quality target have been met.

Windows visual checklist:

1. Open F5: check the textured entry/storehouse and humanoid appear immediately;
   compare the three before/after pairs and check no missing pink/white materials.
2. Walk through both doors, around the outside corner and near new drums/table/post.
   Orbit close to frames/partial roof; check grounding, skin deformation, clipping,
   camera retraction and character size. Check idle-to-walk and stopping on all actors.
3. View concrete/gravel/steel near and far, weathering scale, repeats and normal-map
   direction. Evaluate neutral overcast/fog, shadows and interior readability on
   Forward Plus/D3D12; tune only after recording evidence.
4. Recheck three AI navigation, F3 on/off and the unchanged E lever/Escape/click/focus.
   Require no script errors or missing-resource warnings; record any Jolt warning.
5. Record commit SHA, Godot version, CPU/iGPU/driver, resolution, FPS/frame time/RAM
   and duration. No target performance claim is valid without that measurement.

## Reproduce optional authoring

Committed assets/scenes run without Blender or Python image libraries. Optional
material authoring uses existing NumPy/Pillow/SciPy (free, authoring-only):

```sh
python3 tools/visual/create_pbr_materials.py
godot --headless --path . --editor --import
godot --headless --path . --script res://tools/visual/build_showcase.gd
godot --headless --path . --script res://tools/visual/bake_navigation.gd
```

Rebuilding static art overwrites only the new visual scenes/material resources.
Refresh `assets/visual/manifest.json` and acceptance evidence after intentional asset
changes. `prepare_worker.py` takes a separately downloaded, hash-verified source GLB
in Blender and discards its entire branded image/materials before exporting the
unbranded rig. No raw branded original is shipped. Rebuilding requires respecting
its CC-BY license and retaining distribution credits.

Next: Windows visual/performance review and measured adjustments within this slice;
then a scoped station gameplay task. Better characters/photographic assets remain
separate quality work if access permits; no new gameplay milestone is claimed here.
