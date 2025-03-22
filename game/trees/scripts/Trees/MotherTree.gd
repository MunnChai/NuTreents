extends Twee
class_name MotherTree

func _ready():
	get_stats_from_resource(tree_stat)
	id = "mother_tree"

# Override Twee "growing" functionality
func _process(delta: float) -> void:
	pass

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass

func initialize(p: Vector2i, f: int):
	died = false
	attackable = true
	forest = f
	init_pos(p)


func die():
	died = true
	
	#TreeManager.remove_tree(pos)
	# TODO: Game Over

## update local storage and use water for maintainence
## returns the right amount of res to system
func update(delta: float) -> Vector3:
	var prev = storage # record old storage number
	
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
	var g = Vector3(gain.x, storage - prev, gain.z)
	return g

func update_maint():
	# TODO
	return

## Gets the four directly adjacent tiles next to this twee
## Override this if reachable tiles are different
func get_reachable_offsets() -> Array[Vector2i]:
	return [Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.LEFT]
