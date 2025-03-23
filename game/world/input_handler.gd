class_name InputHandler
extends Node

func _unhandled_input(event: InputEvent) -> void:
	print(event)
	if (Global.game_state != Global.GameState.PLAYING):
		return
	
	if (TreeManager.is_mother_dead()):
		# if mother died
		return
	if (Input.is_action_pressed("lmb")):
		var map_coords: Vector2i = Global.structure_map.local_to_map(Global.structure_map.get_mouse_coords())
		
		TreeManager.add_tree(TreeManager.selected_tree_species, map_coords) 
	
	if (Input.is_action_just_pressed("rmb")):
		var map_coords: Vector2i = Global.structure_map.local_to_map(Global.structure_map.get_mouse_coords())
		
		TreeManager.handle_right_click(map_coords)
