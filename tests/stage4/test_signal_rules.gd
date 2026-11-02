extends SceneTree

var checks := 0
var failures := 0


func expect(value: bool, label: String) -> void:
	checks += 1
	if value:
		print("PASS: ", label)
	else:
		failures += 1
		push_error("FAIL: " + label)


func _initialize() -> void:
	var rules := SignalObjective.new()
	expect(rules.phase == SignalObjective.Phase.SEARCH and rules.carrier_id == 0 and not rules.installed, "one world module, no carrier or installed part initially")
	rules.advance_time(100.0, true)
	expect(rules.phase == SignalObjective.Phase.SEARCH and rules.successes == 0, "walking into the yard alone never wins")
	expect(not rules.send_call(11) and not rules.can_activate(11), "no activation without component")
	expect(not rules.collect(0) and not rules.collect(-1), "invalid owners cannot acquire the component")
	expect(rules.collect(11), "one legitimate pickup transitions to carrying")
	expect(rules.phase == SignalObjective.Phase.CARRYING and rules.carrier_id == 11, "component ownership is explicit")
	expect(not rules.collect(11) and not rules.collect(22), "duplicate and concurrent pickups cannot duplicate component")
	expect(not rules.installed and rules.can_activate(11), "carried component is not consumed before completed work")
	expect(not rules.can_activate(22) and not rules.send_call(22), "another actor cannot install a carried component")
	expect(rules.carrier_id == 11 and not rules.installed, "rejected activation preserves the one owned module")
	expect(rules.send_call(11), "completed legitimate work installs and sends call")
	expect(rules.phase == SignalObjective.Phase.WAITING and rules.installed and rules.carrier_id == 0, "installation transfers module once, without inventory duplication")
	expect(rules.calls_sent == 1 and rules.successes == 0 and rules.remaining == 5.0, "sending is not extraction: waiting starts first")
	expect(not rules.send_call(11) and not rules.send_call(22) and rules.calls_sent == 1, "pending call cannot be resent or have wait reset")
	rules.advance_time(-1, true)
	rules.advance_time(NAN, true)
	rules.advance_time(INF, true)
	expect(rules.remaining == 5.0 and rules.successes == 0, "invalid clock deltas do not advance simulation")
	rules.advance_time(2, false)
	expect(rules.phase == SignalObjective.Phase.WAITING and rules.remaining == 3, "caller departure does not cancel a sent call")
	rules.advance_time(3, false)
	expect(rules.phase == SignalObjective.Phase.READY and rules.missed_arrivals == 1 and rules.successes == 0, "empty arrival rescues nobody and permits a new call")
	expect(rules.installed and rules.carrier_id == 0 and not rules.collect(11), "installed module survives empty arrival; no second pickup")
	expect(rules.can_activate(22) and rules.send_call(22), "shared rules permit another worker to reuse the installed component")
	expect(rules.calls_sent == 2 and rules.remaining == 5, "repeat call starts its own bounded wait")
	rules.advance_time(4.9, true)
	expect(rules.successes == 0 and rules.phase == SignalObjective.Phase.WAITING, "being in zone before arrival does not finish early")
	rules.advance_time(0.2, true)
	expect(rules.phase == SignalObjective.Phase.SUCCESS and rules.successes == 1, "arrival with player in zone produces one local prototype success")
	expect(rules.banner_remaining == 6, "success has an explicit temporary banner lifetime")
	rules.advance_time(100, true)
	expect(rules.banner_remaining == 0 and rules.successes == 1, "banner expires without duplicate success or undoing the result")
	expect(not rules.send_call(11) and not rules.collect(11), "completed run does not re-award success or create items")
	expect(rules.installed and rules.carrier_id == 0, "component conservation after success")
	var fresh := SignalObjective.new()
	expect(fresh.phase == SignalObjective.Phase.SEARCH and fresh.calls_sent == 0 and fresh.successes == 0, "new run starts clean without previous result state")
	print("Signal rules: %d checks, %d failures; complete=true" % [checks, failures])
	quit(0 if failures == 0 else 1)
