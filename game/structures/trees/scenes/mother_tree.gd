extends Twee
class_name MotherTree

func _ready():
	get_stats_from_resource(tree_stat)
	id = "mother_tree"

# Override Twee "growing" functionality
func _process(delta: float) -> void:
	if is_outline_active:
		show_outline(delta)
	else:
		hide_outline(delta)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass

func initialize(p: Vector2i, f: int):
	died = false
	attackable = true
	forest = f
	#init_pos(p)

func take_damage(damage: int) -> bool:
	CameraShake.instance.add_trauma(0.1)
	return super.take_damage(damage)

## Gets the four directly adjacent tiles next to this twee
## Override this if reachable tiles are different
func get_reachable_offsets() -> Array[Vector2i]:
	return [Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.LEFT]

## Mother tree is always a medium
func get_arrow_cursor_height() -> String:
	return "medium"
