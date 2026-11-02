class_name MapLayout
extends RefCounted
## Provisional authored coordinates; no mission state or AI knowledge.

const HALF_SIZE := 500.0
const GRID := 20.0
const SUMMIT := Vector2(-280, -260)
const STATION := Vector3(220, 0, 140)
const PLAYER_START := Vector3(220, 0.1, 154)

static func vertex_height(x: float, z: float) -> float:
	return 64.0 * clampf((230.0 - Vector2(x, z).distance_to(SUMMIT)) / 190.0, 0.0, 1.0)


static func height(x: float, z: float) -> float:
	# Match the actual two terrain triangles in each grid cell, including transitions.
	var x0 := floorf(x / GRID) * GRID
	var z0 := floorf(z / GRID) * GRID
	var u := (x - x0) / GRID
	var v := (z - z0) / GRID
	var a := vertex_height(x0, z0)
	var b := vertex_height(x0 + GRID, z0)
	var c := vertex_height(x0, z0 + GRID)
	var d := vertex_height(x0 + GRID, z0 + GRID)
	if u + v <= 1.0:
		return a + (b - a) * u + (c - a) * v
	return d + (c - d) * (1.0 - u) + (b - d) * (1.0 - v)


static func point(x: float, z: float, lift: float = 0.0) -> Vector3:
	return Vector3(x, height(x, z) + lift, z)


static func routes() -> Dictionary:
	return {
		"StationWest": PackedVector3Array([point(80, 40), point(140, 100), point(140, 140), point(180, 140), point(220, 140)]),
		"StationEast": PackedVector3Array([point(340, 140), point(290, 140), point(250, 140), point(220, 140)]),
		"SummitEast": PackedVector3Array([point(80, 40), point(80, -120), point(-40, -260), point(-240, -260), point(-270, -260)]),
		"SummitSouth": PackedVector3Array([point(-80, 20), point(-80, 70), point(-280, 70), point(-280, -220), point(-280, -250)]),
		"StationLink": PackedVector3Array([point(220, 140), point(220, 40), point(80, 40)]),
		"WorksLink": PackedVector3Array([point(80, 40), point(-80, 40), point(-80, 20)]),
		"SouthLoop": PackedVector3Array([point(-280, 70), point(-300, 300), point(80, 300), point(220, 300), point(340, 300), point(340, 140)]),
		"EastLoop": PackedVector3Array([point(340, 140), point(340, -120), point(80, -120)]),
		"ForestPath": PackedVector3Array([point(265, 190), point(280, 220), point(300, 250), point(340, 300)])
	}


static func starts() -> PackedVector3Array:
	return PackedVector3Array([PLAYER_START, point(60, 60, 0.1), point(-100, 60, 0.1), point(-320, 80, 0.1)])


static func drops() -> PackedVector3Array:
	return PackedVector3Array([point(195, 125), point(245, 115), point(-100, 55), point(-310, -235)])
