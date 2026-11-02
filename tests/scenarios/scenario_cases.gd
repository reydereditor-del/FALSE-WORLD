extends RefCounted

const IDS := ["visible", "wall", "lost_moving", "delayed_report", "independent_reports", "expires_travel", "blocked", "repeated"]
const S := ObservationDecisions.State


func run(id: String, f, audit_probe: bool) -> void:
	match id:
		"visible": await visible(f)
		"wall": await wall(f)
		"lost_moving": await lost_moving(f, audit_probe)
		"delayed_report": await delayed_report(f)
		"independent_reports": await independent_reports(f)
		"expires_travel": await expires_travel(f)
		"blocked": await blocked(f)
		"repeated": await repeated(f)


func seen(f) -> bool:
	return await f.until(func(): return not f.ledger.is_empty(), 60)


func visible(f) -> void:
	var c: ObservationController = f.controllers[0]
	f.expect(f.clear_ray(0), "visible fixture has a clear physical ray")
	f.expect(await seen(f), "visible human emits an actual observation within four sensing phases")
	f.expect(c.decisions.state == S.OBSERVE and c.decisions.evidence.source == &"vision",
		"clear direct perception triggers Observe with legitimate local evidence")
	var position: Vector3 = c.decisions.evidence.get("position", Vector3.INF)
	f.expect(position.distance_to(f.human.position) < 0.001, "direct evidence matches witnessed position")
	await f.step(120)
	f.expect(c.decisions.state in [S.EXPLORE, S.RESUME], "continued visible sight ends its bounded observation without pursuit")


func wall(f) -> void:
	f.move_human(Vector3(0, 0.1, -2))
	await f.step(3)
	f.expect(not f.clear_ray(0), "in-range forward human is physically occluded by the central solid box")
	await f.step(120)
	f.expect(f.ledger.is_empty(), "solid wall produces no observations")
	f.expect(f.controllers[0].memory.inspect(f.now).is_empty(), "occluded human cannot enter private memory")
	f.expect(f.controllers[0].decisions.state == S.EXPLORE, "without legitimate evidence exploration continues")


func lost_moving(f, audit_probe: bool) -> void:
	var c: ObservationController = f.controllers[0]
	f.expect(await seen(f), "record actual sight before LOS loss")
	var fact: Dictionary = c.decisions.evidence.duplicate(true)
	f.move_human(Vector3(0, 0.1, -2))
	await f.step(3)
	f.expect(not f.clear_ray(0), "first hidden location has a blocked ray")
	f.move_human(Vector3(-1, 0.1, -2))
	await f.step(3)
	f.expect(not f.clear_ray(0), "second hidden location remains occluded")
	if audit_probe:
		# Negative control: deliberate fixture-only corruption must fail the ledger audit.
		var forged := fact.duplicate(true)
		forged.tick = f.now
		forged.position = f.human.position
		c.memory.remember(forged, f.now)
		await f.step()
		return
	c.set_physics_process(true)
	f.expect(await f.until(func(): return c.decisions.state == S.INVESTIGATE, 150), "LOS loss starts an old-location visit")
	f.expect(c.decisions.evidence.position == fact.position and c.decisions.evidence.tick == fact.tick,
		"hidden movement cannot refresh original evidence timestamp or point")
	f.expect(c.navigator.target_position.distance_to(fact.position) < 0.2, "physical navigation targets old sight, not unseen current position")
	f.expect(await f.until(func(): return c.decisions.state == S.RESUME, 180), "actual remembered-location travel terminates")
	f.expect(c.motor.position.distance_to(fact.position) < 0.9, "motor physically reaches the remembered point")


func delayed_report(f) -> void:
	f.plan_enabled = [false, true, false]
	f.place_agent(1, Vector3(7, 0.1, 5), 0.0)
	f.expect(await seen(f), "report originates in a real sensor event")
	var original: Dictionary = f.ledger.values()[0]
	f.sample_enabled[0] = false
	f.move_human(Vector3(0, 0.1, -2))
	var recipient: ObservationController = f.controllers[1]
	await f.step(int(original.tick) + 30 - f.now - 1)
	f.expect(recipient.memory.inspect(f.now).is_empty(), "no report before minimum latency")
	await f.step()
	var received: Dictionary = recipient.memory.inspect(f.now).get(&"F11", {})
	f.expect(not received.is_empty() and received.tick == original.tick and received.position == original.position
		and received.source == &"team_report", "delivery retains original time, point and indirect source")
	f.expect(await f.until(func(): return recipient.decisions.state == S.OBSERVE, 30), "recipient independently evaluates delivered report")
	f.expect(f.controllers[2].memory.inspect(f.now).is_empty(), "unaddressed third agent gets no global knowledge")


func independent_reports(f) -> void:
	f.two_recipients()
	f.plan_enabled = [false, true, true]
	f.place_agent(1, Vector3(7, 0.1, 5), 0.0)
	f.place_agent(2, Vector3(7, 0.1, -3), 0.0)
	f.expect(await seen(f), "one real observation supplies both controlled one-recipient channels")
	f.sample_enabled[0] = false
	f.move_human(Vector3(0, 0.1, -2))
	var b: ObservationController = f.controllers[1]
	var d: ObservationController = f.controllers[2]
	f.expect(await f.until(func(): return b.decisions.state == S.OBSERVE and d.decisions.state == S.OBSERVE, 90),
		"both recipients respond independently after genuine delayed delivery")
	f.expect(f.ledger.size() == 1 and b.memory != d.memory, "one observation, independent private memories")
	f.expect(b.decisions.evidence == d.decisions.evidence, "both received the same original legitimate report")
	f.expect(b.decisions.investigation_destination != d.decisions.investigation_destination
		and b.decisions._until != d.decisions._until, "seeded approaches and response timing differ")
	var copy := b.memory.inspect(f.now)
	copy[&"F11"].position = Vector3(90, 0, 90)
	f.expect(d.memory.inspect(f.now)[&"F11"].position != copy[&"F11"].position, "one recipient's view cannot mutate the other")


func expires_travel(f) -> void:
	var c: ObservationController = f.controllers[0]
	# Deliberately short test-only configuration, not a production tuning change.
	c.memory.freshness_ticks = 100
	c.decisions.freshness_ticks = 100
	f.record("configuration", {"freshness_ticks": 100})
	f.expect(await seen(f), "expiry scenario starts with actual sight")
	var original: Dictionary = c.decisions.evidence.duplicate(true)
	f.move_human(Vector3(0, 0.1, -2))
	c.set_physics_process(true)
	f.expect(await f.until(func(): return c.decisions.state == S.INVESTIGATE, 120), "agent begins real travel before expiry")
	f.expect(await f.until(func(): return c.decisions.state == S.RESUME, 90), "original expiry interrupts travel")
	f.expect(f.now - int(original.tick) >= 100 and c.motor.position.distance_to(original.position) > 0.9,
		"evidence expires before arrival without inventing a replacement target")
	f.expect(c.memory.inspect(f.now).is_empty(), "expired actionable memory is absent")


func blocked(f) -> void:
	var c: ObservationController = f.controllers[0]
	f.place_agent(0, Vector3(0, 0.1, 5), PI)
	f.move_human(Vector3(0, 0.1, 12))
	c.stall_timeout_ticks = 30
	f.record("configuration", {"stall_timeout_ticks": 30})
	f.expect(await seen(f), "blocked case uses a reachable genuinely seen destination")
	f.blocker(Vector3(0, 1.5, 8), Vector3(6, 3, 0.5))
	f.move_human(Vector3(40, 0.1, 40))
	c.set_physics_process(true)
	var before := c.abandoned_paths
	f.expect(await f.until(func(): return c.decisions.state == S.RESUME, 300), "blocked physical travel terminates unattended")
	f.expect(c.abandoned_paths > before and c.repath_attempts <= 2, "finite native-route retries lead to abandonment")
	f.expect(c.motor.position.z < 7.5, "agent never crosses the solid fixture blocker")


func repeated(f) -> void:
	# Stationary body isolates suppression; actual rays/decisions keep running.
	f.record("configuration", {"motion": "disabled; repeated sight/perception still uses real physics rays"})
	f.expect(await seen(f), "repeated case starts from genuine direct sight")
	f.move_human(Vector3(0, 0.1, -2))
	await f.step(105)
	f.expect(f.controllers[0].decisions.state == S.INVESTIGATE, "initial LOS loss starts one legitimate investigation")
	for cycle in range(8):
		f.move_human(Vector3(3, 0.1, 1))
		await f.step(150)
		f.move_human(Vector3(0, 0.1, -2))
		await f.step(150)
	var c: ObservationController = f.controllers[0]
	var investigations := 0
	for event in f.semantics:
		if event[0] == "state" and event[3] == "Investigate":
			investigations += 1
	f.expect(f.ledger.size() >= 70, "many actual sightings and LOS breaks exercised across cooldown windows")
	f.expect(c.decisions.transitions == 4 and investigations == 1 and c.decisions.state == S.EXPLORE,
		"same-location resightings never restart the initial finite investigation")
