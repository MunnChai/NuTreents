class_name MortarTweeAnimationComponent
extends TweeAnimationComponent

func play_large_tree_animation() -> void:
	animation_player.play("large")

func play_reload_animation() -> void:
	animation_player.play("reload")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if (anim_name == "grow_small"):
		animation_player.play(small_animation_name)
	if (anim_name == "grow_large"):
		play_reload_animation()
	if (anim_name == "die"):
		animation_player.play("stump")
	if (anim_name == "reload"):
		animation_player.play("loaded")
	
	if (anim_name == "shoot"):
		play_large_tree_animation()

func apply_data_resource(tree_resource: Resource) -> void:
	if tree_resource.is_large:
		play_large_tree_animation()
	else:
		play_small_tree_animation()
	
	sprite_2d.texture = sheets[tree_resource.sheet_id]


#region Shader Stuff



func _process(delta: float) -> void:
	_update_shader(delta)

func get_uv_y_offset() -> float:
	if not animation_player:
		return 0.0
	
	if animation_player.current_animation == "shoot":
		return 0.05
	if animation_player.current_animation == "loaded":
		return 0.25
	if animation_player.current_animation == "reload":
		return 0.45
	if animation_player.current_animation == large_animation_name or animation_player.current_animation == "grow_large":
		return 0.65
	if animation_player.current_animation == small_animation_name or animation_player.current_animation == "grow_small":
		return 0.85
	
	return 0.0

#endregion

func get_current_animation() -> String:
	return animation_player.current_animation
