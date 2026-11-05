# Licensed directional locomotion — 2026-11-05

The uploaded **Human Basic Motions FREE.zip** is the correct Godot/Unreal package;
the Unity `.unitypackage` is unnecessary. Its included **Human Basic Motions 2.4
FREE.pdf** explicitly states **Standard Asset Store EULA**, royalty-free commercial
use allowed, and resale not allowed. The earlier asset-license blocker is resolved.
See [the retained usage notice](../assets/licenses/HumanBasicMotions-usage-notice.md).

This work integrates the uploaded motions into the actual Stage 4 composition,
after a local licensed-data installation. It does not activate the previously failed
locally authored blend experiment. That older experiment and its evidence remain
preserved and unaccepted. This change packages the installer/runtime integration
for `feat/authentic-directional-locomotion`; the earlier published review commit
`8e6eb6d` contains the old previews only.

## Local assets and publication boundary

Kevin Iglesias supplies the animation asset. The uploaded Real Controller package
contains its Godot-normalized Animation resources and humanoid rest definitions;
Furkan Demir's original repository is pinned to
`25cce290ebb538b05216e5e260f0407de71ba36f`. Its software MIT notice is retained
separately and does not replace the underlying animation EULA.

`tools/visual/install_licensed_walks.gd` checks both user-supplied archive hashes,
reads only sixteen walk/run animations and numeric rest definitions, and invokes
the original retarget tool. It never installs the addon/controller scripts, its
model, texture, input actions, camera, jump or sprint functionality.

The original and generated animation files are not published in Git. Generated
resources are placed in **`assets/visual/licensed_locomotion/`**, which is explicitly
Git-ignored. The installer retains the author's original PDF and donor MIT notice
there. Raw source data used during generation stays in the ignored `.godot` cache.
The public code alone preserves the original baseline until the user installs
their licensed files; it must not be described as containing these asset files.

## Simple Windows CMD route (2026-11-06)

**Publication note:** the animation integration was pushed as `63f3abb`. The new
Windows file-picker helper below is not yet pushed: this cloud session's GitHub
token is invalid. The supplied chat helper ZIP includes both Windows scripts and
works against the already-published integration, without needing the helper itself
on GitHub. Extract it and run `review_licensed_locomotion.cmd`; this clones into a
new folder, invokes its adjacent PowerShell script with an explicit project root,
then opens the three file pickers described below. Keep the two scripts together.

Codex web edits and publishes the cloud checkout, not files on the user's laptop.
`git pull origin main` updates main only; this integration is on the feature branch.
The previous clean-tree PowerShell block correctly stops on local edits, but does
not resolve them for the user. For a simple review, clone a separate directory and
keep the existing `C:\Projects\FALSE-WORLD` and every stash untouched.

After helper publication, the following single command works in **CMD or
PowerShell**, since it explicitly invokes CMD. Close the existing game/editor.
It stops if any command fails; if the
destination already exists, clone refuses to overwrite it and the installer does
not run. No automatic stash, reset, clean, main merge or settings replacement.

```text
cmd /c "cd /d C:\Projects && git clone --branch feat/authentic-directional-locomotion --single-branch https://github.com/reydereditor-del/FALSE-WORLD.git FALSE-WORLD-animation-review && cd FALSE-WORLD-animation-review && powershell -NoProfile -STA -ExecutionPolicy Bypass -File tools\windows\install_licensed_locomotion.ps1"
```

The local helper opens three file pickers: select the installed Godot **4.7.2**
`.exe`, `real-controller-1.3.0.zip`, and `Human Basic Motions FREE.zip`. Unity is not
needed. The helper verifies the engine version, waits for headless import and the
existing hash-verified animation installer, checks all sixteen outputs and opens
the editor for **`C:\Projects\FALSE-WORLD-animation-review\project.godot`**.
Press **F5 in that editor**. The old project's editor continues to show its old
files. The PowerShell execution-policy flag affects only this helper process;
no machine-wide setting is changed. Git and the existing engine/archives must
already be present; there is no download, purchase, administrator requirement or
external service inside the helper.

The Windows wrapper is reviewed statically in this Linux cloud environment;
PowerShell/Windows Forms execution and the user's laptop remain unverified. The
underlying Godot installer retains its earlier passing reproducibility checks.
Do not report that the user's Windows files or uploaded `Projects.zip` were opened:
the archive exceeds the available transfer tool's 32 MiB limit.

## Windows installation and F5 (existing checkout, advanced)

Close Godot and update the feature branch from PowerShell first. This block stops
if any tracked or untracked local work exists; it never stashes, resets, cleans,
discards files or switches to main. Keep any existing stashes intact.

```powershell
& {
    Set-Location -LiteralPath 'C:\Projects\FALSE-WORLD' -ErrorAction Stop
    $LocalChanges = @(git status --porcelain)
    if ($LASTEXITCODE -ne 0) { throw 'Cannot read Git status.' }
    if ($LocalChanges.Count -gt 0) {
        $LocalChanges | ForEach-Object { Write-Host $_ }
        throw 'Local changes found. Stop here and preserve them before switching.'
    }
    git fetch origin
    if ($LASTEXITCODE -ne 0) { throw 'Fetch failed.' }
    git switch feat/authentic-directional-locomotion
    if ($LASTEXITCODE -ne 0) { throw 'Branch switch failed.' }
    git pull --ff-only origin feat/authentic-directional-locomotion
    if ($LASTEXITCODE -ne 0) { throw 'Fast-forward update failed.' }
    git log -1 --oneline
}
```

If local changes prevent updating, leave that checkout alone. As an alternative,
clone the feature branch into a new, unused folder to review it separately:

```powershell
& {
    $ReviewPath = 'C:\Projects\FALSE-WORLD-locomotion-review'
    if (Test-Path -LiteralPath $ReviewPath) { throw 'Review folder already exists; preserve it.' }
    git clone --branch feat/authentic-directional-locomotion --single-branch `
        https://github.com/reydereditor-del/FALSE-WORLD.git $ReviewPath
    if ($LASTEXITCODE -ne 0) { throw 'Clone failed.' }
}
```

For that alternative, use the new review folder as the project root in the next
commands, then open its `project.godot`. It does not affect the original checkout.

After obtaining this code update, close any running game, change to the repository
root and use the real paths to the two ZIPs already downloaded. No further purchase,
account, Python, Blender, Unity package or new service is required.

```powershell
Set-Location -LiteralPath 'C:\Projects\FALSE-WORLD' -ErrorAction Stop
$Godot = 'C:\Godot\Godot_v4.7.2-stable_win64_console.exe'
$ControllerZip = 'C:\your-download-folder\real-controller-1.3.0.zip'
$MotionsZip = 'C:\your-download-folder\Human Basic Motions FREE.zip'

& $Godot --headless --path . --editor --import
if ($LASTEXITCODE -ne 0) { throw 'Project import failed.' }
& $Godot --headless --path . --script res://tools/visual/install_licensed_walks.gd -- `
  "--controller-zip=$ControllerZip" "--motions-zip=$MotionsZip"
if ($LASTEXITCODE -ne 0) { throw 'Animation installation failed; inspect the output.' }
& $Godot --editor --path .
```

Replace the three executable/archive paths above; they are examples, not claims
about the user's filesystem. Archive names may include browser download suffixes;
the installer checks contents by SHA-256 rather than relying on their filenames.
An existing destination without the tool's manifest is preserved rather than
overwritten. Rerunning regenerates the documented sixteen output clips.

Open `project.godot` in Godot 4.7.2 and press **F5**. This now uses the existing
`scenes/stage4/signal_loop.tscn`, not a separate preview. If the editor/game was
already running during installation, restart the game so it reloads the new library.
The existing F6 preview scenes remain available as historical experiments.

## Runtime change

- Original worker mesh, vertex colors, 19-bone skeleton, rest transforms and capsule
  are retained. Offline anatomical mapping/leg solving generates keyed animations;
  no runtime IK or replacement character/controller is added.
- Camera-facing human controls opt into **4 m/s forward**, **1.6 m/s backward**
  and **1.6 m/s lateral** motion. The normalized facing-frame elliptical envelope
  limits forward diagonals to **2.101 m/s**, backward diagonals to **1.6 m/s**;
  no independent-axis diagonal boost. Gravity, collision and actual camera logic
  are unchanged. The composition's late Option B enablement is respected each tick,
  with asset availability cached once at startup.
- `WorkerPresentation` uses the actual local physical velocity to select native
  eight-direction clips. Walks play at the retargeted 2 m/s source pace, scaled by
  actual leg-length ratio **0.812591**; runs use the source 4 m/s pace similarly
  scaled. Speed above 2.6 m/s uses the appropriate run clip, including transient
  lateral motion during fast camera-facing turns. No forced high-speed walk.
- Changes retain normalized gait phase and use the existing **0.18 s** crossfade.
  Stops return to the original resting-arm/breathing Idle. Bounded animated pelvis
  offsets do not drive physical motion or accumulate root translation.
- AI keeps its existing movement-facing input, speed and original Walk/Idle
  presentation. The shared presentation library can load the resources, but new
  directional playback is gated by the explicit facing intent used by Option B.
  No AI decision, perception, memory, navigation or objective logic changes.

## Verification and rendered evidence

[Actual Stage 4 locomotion video](evidence/licensed_stage4/actual-stage4-locomotion.mp4)
shows forward, backward, both strafes, forward/backward diagonals, stopping and a
camera-facing turn, driven through real Input actions. A closer review camera makes
footwork legible; the game geometry/physics/AI/objectives still run. A clear existing
ground patch was selected to avoid sign/collider occlusion, without map editing.
[Ordinary game-camera screenshot](evidence/licensed_stage4/game-camera.png) verifies
the unchanged camera and actual player spawn as well. These are automated captures,
not a human Windows playtest.

- Godot **4.7.2.stable.official.ed1daf0bf**. Full existing acceptance **369/0** plus
  **16/16 AI scenario runs**; fresh nested completion/success reports verified.
- Updated real-input Option B **36/0**; new installed-asset suite **34/0** (sixteen
  loop/binding checks, actual directional speeds/stepping/stops, unchanged AI
  configuration); character/camera **7/0**; Stage 4 replay **10/0**.
  **456 ordinary checks passed**, plus the scenario runs.
- Six actual-body contact diagnostics passed a 0.05 m/s mean sampled-ankle drift
  gate: approximately **0.008–0.011 m/s** walking and **0.039 m/s** forward running.
  This samples near-ground ankle motion, not perfect skinned-sole locking across
  every phase/terrain or subjective naturalness.
- An asset-free public-file export imported and passed the original-baseline
  **36/0 Option B checks**. The new installed-asset suite explicitly errors if its
  input assets are missing; it does not falsely pass a zero-animation workflow.
- Installer rerun reproduced all **16 Animation files byte-for-byte** and retained
  license documents. All licensed files are Git-ignored. No supplied controller
  script was executed or copied into the runtime.
- Actual Stage 4 renders: **480 close-up frames / 16 seconds**, plus **90 frames**
  through the normal game camera. Rendering used automatic software OpenGL/Mesa
  llvmpipe after the known Vulkan surface failure. No renderer/project upgrade,
  Windows/D3D12 validation, target-laptop FPS or exported-game claim.

Saved summaries, contact metrics, motion trace and contact sheet are in
`docs/evidence/licensed_stage4/`. Tests retain baseline checks when assets are
absent and intentionally replace only the documented missing-clip expectation
when the licensed installation is available. An initial late-composition setting
issue was corrected before the passing real-input checks. A first capture obscured
diagonal walking behind a station sign; final footage uses a clear existing area.

For repeatable diagnostics after installation:

```sh
godot --headless --path . --fixed-fps 60 --script res://tests/visual/test_licensed_locomotion.gd
godot --headless --path . --fixed-fps 60 --script res://tools/visual/measure_licensed_contacts.gd
```

The second command writes `user://licensed_contact_metrics.json`, or accepts
`-- --output=ABSOLUTE_FILE_PATH`. It checks six sampled contact windows and does
not substitute for rendered review.

## Remaining manual checks

On Windows: confirm F5 uses the installed clips; W/S/A/D and all four diagonals
step with the body following camera yaw; stop, reverse and orbit the mouse while
moving. Inspect foot/ankle/arm transitions and wall contact. Verify existing camera
clearance, E pickup/cancel/resume, cabinet call, marked-yard success, empty retry
and R restart. Check all three AI still move normally. Asset packaging for a game
export and further distribution review remain separate, untested work.
