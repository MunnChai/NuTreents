class_name TechTree
extends Twee

const FACTORY_REMAINS = preload("res://structures/city/factory/factory_remains.tscn")

var tech_slot: int = -1

# i have no idea how tech tree works

func _ready():
	get_stats_from_resource(tree_stat)
	
	
	sprite.hframes = 9
	sprite.vframes = 3
	sprite.position.y = -16
	# Equally likely... 
	sprite.texture = sheets.pick_random()
	sprite.material = sprite.material.duplicate()
	
	animation_player.connect("animation_finished", _on_animation_player_animation_finished)
	play_grow_small_animation()
	
	is_adjacent_to_water = is_water_adjacent()
	if (is_adjacent_to_water):
		maint = 0
	
	id = "tech_tree"

func get_uv_y_offset() -> float:
	if is_large:
		return 0.1
	else:
		return 0.75

func play_large_tree_animation():
	animation_player.play("pump")

func die():
	died = true
	
	#play sound effect
	SfxManager.play_sound_effect("tree_remove")

	#TreeManager.remove_tree(pos)
	flash_amount = 1.0
	(sprite.get_material() as ShaderMaterial).set_shader_parameter("flash_amount", flash_amount)
	
	await get_tree().create_timer(FLASH_DURATION).timeout
	
	if is_large and !is_growing: # Temp fix: Prevent small trees from spawning big tree die vfx
		var death_vfx = GREEN_TREE_DIE.instantiate()
		get_parent().add_child(death_vfx)
		death_vfx.global_position = global_position
		#queue_free()
		
		# Remove self from TechMenu
		Global.tech_menu.current_tech.erase(tech_slot)
	
	# Instantiate factory remains again
	var factory_remains = FACTORY_REMAINS.instantiate()
	Global.structure_map.add_structure(get_pos(), factory_remains)
	factory_remains.tech_slot = tech_slot
	
	queue_free()

func upgrade_tree() -> void:
	is_large = true
	animation_player.play("grow_large")
	is_growing = true
	get_upgraded_stats_from_resource(tree_stat)
	
	# Do stuff related to TechMenu
	Global.tech_menu.current_tech.append(tech_slot)
