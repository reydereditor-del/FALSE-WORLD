extends SceneTree
## Isolated headless entry point. Not referenced by gameplay scenes or project startup.

const Fixture := preload("res://tests/scenarios/scenario_fixture.gd")
const Cases := preload("res://tests/scenarios/scenario_cases.gd")
var _started_ms: int = 0
var _done: bool = false
var _output: String = "user://ai-scenarios"
var _rows: Array[Dictionary] = []
var _current: RefCounted


func _initialize() -> void:
	_started_ms = Time.get_ticks_msec()
	call_deferred("run")


func _process(_delta: float) -> bool:
	if not _done and Time.get_ticks_msec() - _started_ms > 120000:
		if _current != null:
			_current.fail("global 120-second wall watchdog expired")
			_rows.append(_current.result())
		_write(false, false, "global wall watchdog")
		_done = true
		quit(1)
	return false


func run() -> void:
	var selected: String = "all"
	var repeat: int = 2
	var seed_value: int = 431
	var audit_probe := false
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--scenario="): selected = argument.get_slice("=", 1)
		elif argument.begins_with("--repeat="): repeat = argument.get_slice("=", 1).to_int()
		elif argument.begins_with("--seed="): seed_value = argument.get_slice("=", 1).to_int()
		elif argument.begins_with("--output="): _output = argument.trim_prefix("--output=")
		elif argument == "--audit-probe": audit_probe = true
		else:
			invalid("Unknown argument: " + argument)
			return
	var version := Engine.get_version_info()
	if version.major != 4 or version.minor != 7 or version.patch != 2 or Engine.physics_ticks_per_second != 60:
		invalid("Requires Godot 4.7.2 and 60 physics ticks/s")
		return
	if repeat < 1 or repeat > 3 or (selected != "all" and selected not in Cases.IDS):
		invalid("Use --scenario=all|" + "|".join(Cases.IDS) + " and --repeat=1..3")
		return
	if audit_probe and selected != "lost_moving":
		invalid("--audit-probe requires --scenario=lost_moving")
		return
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_output)) != OK:
		invalid("Cannot create output directory")
		return
	var ids: Array = Cases.IDS if selected == "all" else [selected]
	var cases = Cases.new()
	var references: Dictionary = {}
	var success := true
	for run_index in range(repeat):
		for id: String in ids:
			var fixture = Fixture.new()
			_current = fixture
			await fixture.setup(self, seed_value)
			await cases.run(id, fixture, audit_probe)
			var row: Dictionary = fixture.result()
			row["scenario"] = id
			row["run"] = run_index + 1
			row["seed"] = seed_value
			var signature := JSON.stringify(_json(row.semantic_trace)).sha256_text()
			row["semantic_sha256"] = signature
			if references.has(id) and references[id] != signature:
				row.failures.append("seeded logical event trace differs from the previous repetition")
			references[id] = signature
			row["passed"] = row.failures.is_empty()
			success = success and row.passed
			_rows.append(row)
			print("%s %s #%d: %d assertions, %d audited frames, %d observations [%s]" % [
				"PASS" if row.passed else "FAIL", id, run_index + 1, row.checks, row.audited_frames,
				row.observations, signature.left(12)])
			if not row.passed:
				print("DIAGNOSTICS: ", JSON.stringify(row.failures))
				print(JSON.stringify(_json(row.trace.slice(maxi(0, row.trace.size() - 12))), "  "))
			await fixture.cleanup()
			_current = null
	if not _write(true, success, ""):
		_done = true
		quit(2)
		return
	_done = true
	print("AI scenarios: %d/%d passed; complete=%s; %s/summary.json" % [
		_rows.filter(func(row): return row.passed).size(), _rows.size(), true, _output])
	quit(0 if success else 1)


func invalid(message: String) -> void:
	_done = true
	printerr(message)
	quit(2)


func _write(complete: bool, success: bool, error: String) -> bool:
	var file := FileAccess.open(_output.path_join("summary.json"), FileAccess.WRITE)
	if file == null:
		printerr("Cannot write scenario summary: ", FileAccess.get_open_error())
		_done = true
		return false
	file.store_string(JSON.stringify(_json({"engine": Engine.get_version_info().string,
		"complete": complete, "success": success, "error": error, "results": _rows}), "  ") + "\n")
	return true


func _json(value: Variant) -> Variant:
	if value is Vector3:
		return [value.x, value.y, value.z]
	if value is Dictionary:
		var result: Dictionary = {}
		for key in value:
			result[String(key)] = _json(value[key])
		return result
	if value is Array:
		return value.map(_json)
	if value is StringName:
		return String(value)
	return value
