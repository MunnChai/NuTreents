class_name WaterTree
extends Twee

const BASE_WATER_RANGE = 1

var is_adjacent_to_water: bool = false
var water_bonus: int = 3

func _ready():
	super._ready()
	
	# Calculate adjacency on start of runtime, instead of each frame
	is_adjacent_to_water = is_water_adjacent()

## update local storage and use water for maintainence
## returns the right amount of res to system
func update(delta: float) -> Vector3:
	var prev = storage # record old storage number
	
	var true_gain = get_water_gain()
	
	# add new water to storage, storage equals at most max_water
	storage = min(storage + gain.y, max_water)
	
	# take maint from storage
	if (storage >= maint):
		storage -= maint
	else:
		var f: Forest = TreeManager.get_forest(forest)
		if (!f.get_water(maint - storage)):
			# if game doesn't have enough water either
			hp -= 2 * delta
		else:
			# game has enough water
			storage = 0
	if (hp <= 0):
		die()
	var g = Vector3(gain.x, storage - prev, gain.z)
	return g



func get_water_gain():
	if (!is_adjacent_to_water):
		return tree_stat.gain.y
	else:
		return tree_stat.gain.y + water_bonus

func is_water_adjacent() -> bool:
	for x in range(-BASE_WATER_RANGE, BASE_WATER_RANGE + 1):
		for y in range(-BASE_WATER_RANGE, BASE_WATER_RANGE + 1):
			var coord: Vector2i = pos + Vector2i(x, y)
			
			var tile_type: int = Global.terrain_map.get_tile_biome(coord)
			
			if (tile_type == Global.terrain_map.TILE_TYPE.WATER):
				return true
	
	return false
