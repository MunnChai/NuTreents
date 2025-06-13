class_name TechTweeComposed
extends TweeComposed

var tech_slot: int

#region Overrides

func die():
	died = true
	
	SfxManager.play_sound_effect("tree_remove")
	
	flash_amount = 1.0
	
	if !(!sprite_2d || !sprite_2d.get_material()):
		(sprite_2d.get_material() as ShaderMaterial).set_shader_parameter("flash_amount", flash_amount)
	
	await get_tree().create_timer(FLASH_DURATION).timeout
	
	if is_large and !is_growing: # Temp fix: Prevent small trees from spawning big tree die vfx
		var death_vfx = GREEN_TREE_DIE.instantiate()
		get_parent().add_child(death_vfx)
		death_vfx.global_position = global_position
		
		# Remove self from TechMenu
		Global.tech_menu.current_tech.erase(tech_slot)
	
	# Instantiate factory remains again
	var factory_remains = StructureRegistry.get_new_structure(Global.StructureType.FACTORY_REMAINS)
	Global.structure_map.add_structure(grid_position_component.get_pos(), factory_remains)
	factory_remains.tech_slot = tech_slot
	
	queue_free()

func get_uv_y_offset() -> float:
	if is_large:
		return 0.1
	else:
		return 0.75

func upgrade_tree() -> void:
	super.upgrade_tree()
	
	# Do stuff related to TechMenu
	Global.tech_menu.current_tech.append(tech_slot)

func apply_data_resource(tree_resource: Resource):
	super.apply_data_resource(tree_resource)
	
	tech_slot = tree_resource.tech_slot
	if is_large:
		Global.tech_menu.current_tech.append(tech_slot)

#endregion
