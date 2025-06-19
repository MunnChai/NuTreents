class_name MotherTweeComposed
extends TweeComposed

func _ready():
	set_stats_from_resource(tree_stat)
	
	(sprite_2d.get_material() as ShaderMaterial).set_shader_parameter("outline_width", 1)
	
	_connect_component_signals()

# Override Twee "growing" functionality
func _process(delta: float) -> void:
	pass

func _on_death():
	die()

func die():
	died = true
	Global.game_state = Global.GameState.GAME_OVER
	SceneLoader.transition_to_game_over()

func take_damage(damage: int) -> bool:
	CameraShake.instance.add_trauma(0.1)
	return super.take_damage(damage)

## Mother tree is always a medium
func get_arrow_cursor_height() -> String:
	return "medium"
