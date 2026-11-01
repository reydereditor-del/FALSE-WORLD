class_name ObservedFactChannel
extends RefCounted
## Delayed selective relay, not a world-state blackboard or strategy Director.

var delay_ticks: int = 30
var capacity: int = 12
var _memories: Dictionary = {}
var _routes: Dictionary = {}
var _pending: Array[Dictionary] = []


func register(sensor: LocalPerception, recipient: StringName, memory: LocalMemory) -> void:
	_memories[sensor.observer_id] = memory
	_routes[sensor.observer_id] = recipient
	# Only the actual sensor signal enters the queue. Reports are not re-broadcast.
	sensor.observed.connect(_accept_observation.bind(sensor))


func _accept_observation(fact: Dictionary, sensor: LocalPerception) -> void:
	if not fact.has_all(LocalMemory.FIELDS):
		return
	if fact.observer != sensor.observer_id or fact.source != &"vision":
		return
	# Require an identical fact in that sensor's local memory; no arbitrary world lookup.
	if not sensor.memory.contains_observation(fact):
		return
	var recipient: StringName = _routes[fact.observer]
	if recipient == fact.subject or recipient == fact.observer:
		return
	for item in _pending:
		if item.fact.observer == fact.observer and item.fact.subject == fact.subject:
			# Keep the original snapshot and due tick. A newer sighting must not
			# bypass its own delay or indefinitely postpone the pending report.
			return
	if _pending.size() >= capacity:
		return
	_pending.append({"fact": fact.duplicate(true), "recipient": recipient,
		"due": fact.tick + delay_ticks})


func advance(now: int) -> void:
	# One due report per simulation tick. Source observation time never changes.
	for index in range(_pending.size()):
		var item: Dictionary = _pending[index]
		if item.due > now:
			continue
		_pending.remove_at(index)
		if _memories.has(item.recipient):
			var fact: Dictionary = item.fact.duplicate(true)
			fact.source = &"team_report"
			_memories[item.recipient].remember(fact, now)
		return


func pending_count() -> int:
	return _pending.size()
