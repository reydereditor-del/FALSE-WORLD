# Direction-dependent walking speed experiment — 2026-11-05

**Not accepted for production integration.** Slower speeds resolve the cardinal
walking cadence problem, but the experimental forward-diagonal blend still loses
foot contact. Production movement/presentation, all existing gameplay and the three
authored animation resources remain unchanged. No new animation set, asset research
or paid service. The subsequent review request authorizes committing and pushing
this isolated experiment on `feat/authentic-directional-locomotion`; it does not
authorize production integration or merging into main. Earlier no-commit records
describe the experiment before that publication request.

[Watch the 17-second rendered comparison](evidence/directional_speed/speed-comparison-unaccepted.mp4).
All three columns show actual CharacterBody3D movement over a **stationary 1 m
grid**, with world coordinates and measured velocity. The cameras follow the bodies;
the floor does not scroll or reset. [Contact sheet](evidence/directional_speed/contact-sheet.png).

## Measurement and evaluated speeds

`tools/visual/measure_directional_walks.gd` loads the unchanged worker and measures
actual planted ankle displacement between 10% and 50% of each 0.9-second loop:

| Existing authored clip | Measured plant travel / time | Intended speed |
| --- | --- | ---: |
| Backward | 0.293333 m / 0.36 s | 0.814815 m/s |
| Left/right strafe | 0.186667 m / 0.36 s | 0.518519 m/s |

These estimates come from actual posed joints, independently of clip metadata.
Source forward contact was also sampled: its near-ground movement is nonuniform,
with median travel about 1.73 m per normalized cycle. The preview retains the
original forward playback cadence at 4 m/s; it does not pretend that its existing
timing constant represents a physically measured 5 m stride.

| Comparison column | Forward | Backward | Sideways | Cardinal cycles/s, back / side |
| --- | ---: | ---: | ---: | ---: |
| Starting ranges | 4.00 | 1.75 | 2.25 | 2.39 / 4.82 |
| Middle | 4.00 | 1.10 | 0.85 | 1.50 / 1.82 |
| Lower cadence | 4.00 | 0.90 | 0.65 | 1.23 / 1.39 |

Speeds are m/s. The starting-range lateral profile still produces visibly rapid
steps. **1.10 backward / 0.85 sideways** is a promising provisional cardinal
choice: better cadence with immediate directional response. The lower column is
also available for comparison. None is an adopted gameplay setting or a claim of
verified human input feel.

## Transitions and diagonal limit

The finite sequence shows forward → left strafe → forward → backward → backward-right
diagonal → stop → forward-right diagonal → right strafe → camera-relative yaw turn
of 90 degrees → stop. Body yaw retains the existing 3.5 rad/s bound and remains
independent of translation. The preview uses the actual shared motor/collision
scene, with a preview-only subclass for the speed envelope, and three explicitly
separate physics spaces. It does not instantiate or change the gameplay camera,
interaction, objective system or AI.

For a normalized intended facing-space direction `(x,z)`, the preview limits speed
to `1 / sqrt((x / side_speed)^2 + (z / longitudinal_speed)^2)`, with longitudinal
speed 4 forward or the evaluated backward value. It then multiplies the normalized
input by that single scalar. This elliptical directional envelope provides no
extra speed from combining independent axis velocities. In the middle column,
forward diagonals are capped at 1.176 m/s and backward diagonals at 0.951 m/s.
Stops respond immediately; pose transitions blend over a short interval.

The presentation experiment samples only the existing forward and three authored
clips, aligns contact phases (including the opposite initial phase of the right
strafe), and blends local joint poses. It creates no additional animation files.
The preview's cached idle pose is only for reviewing stops, not a production
replacement for the existing breathing idle. Helpers under `tools/visual/experimental_*`
are deliberately preview-only; production scripts do not reference them.

## Exact remaining defect

The cardinal clips can keep their planted ankles stationary against the world.
Backward-diagonal blending has small contact-window drift. **Forward-diagonal
blending is not convincing:** the imported forward clip's contact timing and
nonuniform leg trajectories do not maintain a planted foot when mixed with the
locally authored strafe. Calibrating its contact distance improved the first
candidate, but did not remove the defect. Changing speed alone did not solve it.

Final captured middle-column mean horizontal ankle motion during the authored
expected plant window was approximately:

- Left strafe: **under 0.001 m/s**.
- Backward: **under 0.001 m/s**.
- Backward diagonal: **0.013 m/s**.
- Forward diagonal: **0.295 m/s**, failing the provisional **0.05 m/s** contact gate.

The lower-speed column still failed forward-diagonal contact, approximately
0.286 m/s. This measures joint motion during the authored contact window, not
perfect skinned-sole contact or a general proof that no better blend can exist.
Rendered contact poses and world-grid movement also require review; passing a
joint metric alone would not establish naturalness.

Integrating this candidate would replace the old glide with a new diagonal slip.
It is therefore withheld. The remaining work is phase/contact-compatible forward
diagonal blending and rechecking stops/direction changes before integration. Do not
introduce extra animation sets, runtime foot-IK infrastructure or a controller
rewrite automatically to expand this bounded experiment.

## Checks and evidence

- **35/0** new experiment mechanics checks: all ten stages for all three profiles,
  exact directional caps, separate physics spaces, actual bounded translation,
  Option B facing bounds, 19 finite bones and finite execution budgets.
- **212/0** unchanged focused existing checks: Option B 36, character 7, shared
  visual/AI 25, M1 camera 15, M1 graybox/interaction 31, AI exploration 25, Stage 4
  rules 27, integration 36 and replay audit 10.
- **16/0** authored resource checks. Total **263 mechanics/resource/regression
  checks passed**. No existing test or expected fallback was changed. No new full
  AI scenario-suite run is claimed.
- **Contact diagnostic failed**, exit 1, for all three profiles' forward diagonals;
  [report](evidence/directional_speed/contact-report.json). This failure is distinct
  from the passing mechanics checks and prevents production acceptance.
- Godot 4.7.2 final editor import passed. All three animation SHA-256s still match
  the previous authoring outputs. Git confirms no production scripts, existing
  scenes/settings/model or existing tests changed.
- Final video: **510 traced/rendered frames at 30 fps**, actual motion for 17 seconds
  (the encoder excludes the extra shutdown frame, which has no trace record).
  Software OpenGL/Mesa llvmpipe rendered after the known Vulkan surface failure;
  project renderer settings are unchanged. No Windows, Forward Plus/D3D12, Intel
  iGPU performance or real human control-feel acceptance is claimed.
- The initial comparison's profile physics interference was corrected before final
  evidence. Final traces record the separate spaces and exact intended speeds.

Saved [check summary](evidence/directional_speed/checks.json),
[actual motion/ankle trace](evidence/directional_speed/motion-trace.json),
[mechanics log](evidence/directional_speed/mechanics-checks.log) and
[render log](evidence/directional_speed/render.log). No external assets or costs.

## Reproduce and review on Windows

From the repository root, using your actual Godot 4.7.2 executable:

```powershell
$Godot = 'C:\Godot\Godot_v4.7.2-stable_win64_console.exe'
& $Godot --path . --fixed-fps 30 'res://scenes/preview/moving_walk_experiment.tscn'
```

The comparison automatically runs for 17 seconds and exits. Add
`-- --capture=C:/Temp/false-world-speed` to save frames and the actual motion trace.
The separate original isolated clip preview remains available.

In the Godot editor, open `scenes/preview/moving_walk_experiment.tscn` and press
**F6 (Run Current Scene)**. This comparison is an automatic sequence; it has no
keyboard movement controls. Rerun F6 to replay. **F5 starts unchanged production
gameplay**, not the experiment.

For individual clip inspection, open `scenes/preview/directional_walks.tscn` and
press **F6**. **1/2/3** select backward/left/right; **F1/F2/F3** select front/side/
three-quarter views; **Space** toggles authored pace versus the unaccepted 4 m/s
comparison. The moving experiment's three slower profiles are separate from that
older individual-clip speed toggle.

The comparison MP4 and the authored Animation `.tres` files are included in Git.
No download from chat, `/workspace`, temporary directory, animation pack, Blender,
Python installation or local authoring step is required just to run either scene.
Godot 4.7.2 imports the existing model from the checkout. Python is needed only for
the optional diagnostic command below. The full rendered comparison is also
available at `docs/evidence/directional_speed/speed-comparison-unaccepted.mp4`.

```sh
godot --headless --path . --script res://tools/visual/measure_directional_walks.gd
godot --headless --path . --fixed-fps 60 --script res://tests/visual/test_moving_walk_experiment.gd
python3 tools/visual/analyze_walk_experiment.py --trace PATH/trace.json --output PATH/contact-report.json
```

The last command currently exits **1** because the blend fails its contact gate.
Do not loosen that gate to describe the experiment as accepted.

Remaining manual checks: compare cardinal cadence and responsiveness on Windows,
inspect foot contact through the forward/backward/diagonal changes and stopping,
then correct/retest the forward-diagonal defect. After a future accepted integration,
verify real mouse orbit, all four diagonals, collision/interaction and the Stage 4
module → cabinet → marked-yard flow. F5 currently still starts unchanged gameplay.
