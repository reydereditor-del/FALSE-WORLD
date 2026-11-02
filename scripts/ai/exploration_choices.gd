class_name ExplorationChoices
extends RefCounted
## Static places + private visit history only. No actor registry or perception inputs.

var sites: Array[Dictionary] = []
var minimum_wait_ticks: int = 45
var maximum_wait_ticks: int = 180
var _rng := RandomNumberGenerator.new()
var _visits: Dictionary = {}
var _recent: Array[int] = []
var _blocked_until: Dictionary = {}
var _last_area: StringName = &""


func initialize(seed_value: int) -> void:
	_rng.seed = seed_value
	_visits.clear()
	_recent.clear()
	_blocked_until.clear()
	_last_area = &""


func initial_pause() -> int:
	return _rng.randi_range(15, 90)


func choose(position: Vector3, now: int) -> int:
	var best: int = -1
	var best_score: float = -INF
	# Bounded authored catalog; seeded variation breaks identical ranking/route loops.
	for index in range(mini(sites.size(), 16)):
		if index in _recent or now < _blocked_until.get(index, 0):
			continue
		var site := sites[index]
		var distance := position.distance_to(site.position)
		if distance < 1.0:
			continue
		var novelty := 4.0 / (1.0 + float(_visits.get(index, 0)))
		var area_bonus := 0.8 if site.area != _last_area else 0.0
		var nearby_bonus := 1.5 / (1.0 + distance / 20.0)
		var score := novelty + area_bonus + nearby_bonus + _rng.randf_range(0.0, 1.2)
		if score > best_score:
			best_score = score
			best = index
	return best


func arrived(index: int) -> int:
	_visits[index] = _visits.get(index, 0) + 1
	_last_area = sites[index].area
	_recent.append(index)
	if _recent.size() > mini(2, maxi(0, sites.size() - 1)):
		_recent.pop_front()
	var wait := _rng.randi_range(minimum_wait_ticks, maximum_wait_ticks)
	match sites[index].kind:
		&"transit": return floori(float(wait) / 3.0)
		&"observe": return wait + minimum_wait_ticks
		_: return wait


func reject(index: int, now: int) -> void:
	_blocked_until[index] = now + 900
