class_name LocalMemory
extends RefCounted
## Only value snapshots, never live character references. Tick time is injectable.

var capacity: int = 8
var freshness_ticks: int = 300
var _facts: Dictionary = {}
const FIELDS := ["observer", "subject", "event", "position", "tick", "confidence", "source"]


func remember(fact: Dictionary, now: int) -> bool:
	if fact.size() != FIELDS.size():
		return false
	for field in FIELDS:
		if not fact.has(field):
			return false
	if typeof(fact.tick) != TYPE_INT or typeof(fact.position) != TYPE_VECTOR3:
		return false
	if not fact.position.is_finite() or not fact.observer is StringName or not fact.subject is StringName:
		return false
	if fact.observer == &"" or fact.subject == &"" or fact.event != &"seen":
		return false
	if fact.source not in [&"vision", &"team_report"] or fact.confidence != 1.0:
		return false
	if now < fact.tick or now - fact.tick >= freshness_ticks:
		return false
	expire(now)
	if _facts.has(fact.subject):
		var old: Dictionary = _facts[fact.subject]
		if old.tick > fact.tick or (old.tick == fact.tick and old.source == &"vision"):
			return false
	elif _facts.size() >= capacity:
		# Deterministic insertion-order tie break among equally old entries.
		var oldest: StringName = _facts.keys()[0]
		for subject in _facts:
			if _facts[subject].tick < _facts[oldest].tick:
				oldest = subject
		_facts.erase(oldest)
	_facts[fact.subject] = fact.duplicate(true)
	return true


func expire(now: int) -> void:
	for subject in _facts.keys():
		if now < _facts[subject].tick or now - _facts[subject].tick >= freshness_ticks:
			_facts.erase(subject)


func snapshot(now: int) -> Dictionary:
	expire(now)
	return _facts.duplicate(true)


func contains_observation(fact: Dictionary) -> bool:
	# Provenance validation must not expire or mutate memory using an incoming tick.
	return _facts.get(fact.get("subject", &""), {}) == fact


func inspect(now: int) -> Dictionary:
	# Nonmutating diagnostic view: reading cannot expire, refresh or alter AI memory.
	var result: Dictionary = {}
	for subject in _facts:
		var fact: Dictionary = _facts[subject]
		if fact.tick <= now and now - fact.tick < freshness_ticks:
			result[subject] = fact.duplicate(true)
	return result
