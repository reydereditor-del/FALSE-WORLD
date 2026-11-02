# Stage 4 objective-loop audit

Audited 2026-11-03 (Asia/Tashkent), published Stage 4 commit
`f07bdc4207107e9b452be229d82bea0c3a9ced46`, against handoff §§4–6 and the prior
explicitly authorized one-component prototype scope. No gameplay changes are made.

| Question | Finding |
| --- | --- |
| Battery AND radio required? | **No.** Current build uses one service module. This was an explicit prototype simplification, not implementation of final handoff §5.2's two separate components. Final compliance is incomplete. |
| Repeated activation possible? | **Yes after an empty arrival.** SEARCH rejects calls; CARRYING accepts its owner; WAITING rejects calls; READY permits another timed call with installed module; SUCCESS rejects calls permanently for that run. |
| Countdown leads to extraction? | **A real spatial check in the prototype.** After five seconds, player must be inside the 10×10 m yard centered at (220,140). Remaining at the cabinet near (230,124.56) is outside. There is no vehicle, actor removal, spectator transition or full production extraction system. |
| Extraction distinct from winning? | In the handoff, a human's own extraction grants their individual win; other humans can continue, so it is distinct from ending the whole match. Here one SUCCESS phase combines the local prototype extraction/result. Separate multiplayer outcomes/match finalization are not implemented. |
| Completed objective replayed incorrectly? | No reproduced bug: pending calls cannot reset; terminal SUCCESS cannot replay after banner expiry or returning to cabinet. An empty completed call can legitimately be repeated. R explicitly reloads an entirely new prototype run. |
| Approved rules preserved? | Implemented subset preserves completed-call persistence on departure, retained installation, empty-arrival retry, automatic yard eligibility, no AI blocking and one terminal result. It does **not** fully implement the handoff: two station parts, mountain route, multi-human outcomes, death/disconnect/sabotage, loot/spectating and other final systems remain absent. |

## Explanation of reported behavior

100% finishes sending the signal, not extraction. The player must then leave the
cabinet and enter the separate outlined yard before the countdown reaches zero.
If they remain beside the cabinet, arrival is empty, no success is awarded, and
READY rearms the device. Holding E again starts another call. Holding E continuously
can also start another timed activation after READY; there is no fresh-keypress
requirement in the handoff. Repeating an empty call is allowed by §5.3, not a replay
of successful extraction. Do not disable legitimate repeat calls to hide this case.

The six-second banner disappearing does not reset SUCCESS. There is no separate
late-arrival pickup window: arrival samples player position once, and a missed pickup
requires another call. This is consistent with the current documented prototype.

## Focused evidence

Godot `4.7.2.stable.official.ed1daf0bf`, from repository root with the existing writable
XDG directories. Each run had an external 130-second timeout and finite 8,500-frame
ceiling, retained logs, expected completion count, nonzero failure exit and error scan:

```sh
GODOT=/workspace/.tools/godot/4.7.2/Godot_v4.7.2-stable_linux.x86_64
$GODOT --headless --path . --fixed-fps 60 --quit-after 8500 --script res://tests/stage4/test_signal_rules.gd
$GODOT --headless --path . --fixed-fps 60 --quit-after 8500 --script res://tests/stage4/test_signal_integration.gd
$GODOT --headless --path . --fixed-fps 60 --quit-after 8500 --script res://tests/stage4/test_signal_replay_audit.gd
```

Results: **27 rules + 36 actual-scene integration + 10 new replay-audit checks = 73
passed, zero failures**, no script/engine errors. New replay test uses actual pickup/
activation targets, body range/LOS and injected clock/fixture poses to isolate boundaries:
120 repeated activation attempts during WAITING cannot reset it; an empty arrival
rearms; a repeat call can succeed in the yard; 120 attempts and timer advances after
SUCCESS cannot replay it, including after the banner expires. The unchanged existing
integration additionally covers the complete physical walk, interruptions, AI memory
and AI presence, R reset and retry. Logs: `/tmp/stage4-audit-{rules,integration,replay}.log`.

Broader visual/AI regression suites were not rerun for this audit-only change. Previous
passes are historical evidence. No new Windows rendering, manual-input, performance
or export check is claimed. Production source, assets, settings and handoff are unchanged.

## Exact Windows manual checks

```powershell
cd C:\Projects\FALSE-WORLD
git fetch origin
git switch audit/stage4-objective-loop
$Godot = 'C:\Godot\Godot_v4.7.2-stable_win64_console.exe'
& $Godot --headless --path . --editor --import
& $Godot --path . res://scenes/stage4/signal_loop.tscn
```

Adjust the Godot executable path; preserve local edits before switching.

1. Collect the service module on the storehouse workbench near (194.3,118.1).
2. Approach the cabinet from (228.8,125.8). Hold E until 100%; release. During the
   countdown, press/hold E again: it must not reset the pending countdown.
3. Deliberately remain at the cabinet. After five seconds expect **Empty arrival**,
   no extraction success. Hold E for a new four-second call; no new component is needed.
4. Immediately walk around the sign via (220,132), then into the outlined yard
   centered at (220,140), before countdown expiry. Expect **PROTOTYPE EXTRACTION COMPLETE**.
5. Wait for its six-second banner to disappear, return to cabinet, hold E for longer
   than four seconds: no new call, countdown or success should occur.
6. Press R: a new run starts with one fresh module. Entering the yard without a sent
   call must not win. Record commit, exact feedback and debugger output if behavior differs.

Next action is manual confirmation of those states. Implementing both final station
parts or a full extraction/match lifecycle requires a separately scoped implementation
request; this audit does not silently expand the earlier prototype scope.
