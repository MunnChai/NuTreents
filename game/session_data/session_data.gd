extends Node

const SECTION_NAME := "session_data"
const SAVE_PATH := "user://session_data"
const SAVE_NAME := "session_"

# SAVED DATA:
# seed: int
# structure_map: Dictionary[Vector2i, Node2D]
# current_day: int
# current_time: float
# enemies...?

var session_data: Dictionary = {}

func save_session_data(save_num: int = 1):
	var config = ConfigFile.new()
	
	# Save rng seed
	config.set_value(SECTION_NAME, "seed", Global.get_seed())
	
	# Save structure map as PackedScenes... kinda scuffed, saves a lot more data than we need to
	var structure_map: Dictionary
	for pos in Global.structure_map.tile_scene_map:
		var node = Global.structure_map.tile_scene_map[pos]
		
		var scene = PackedScene.new()
		var scene_root = node
		_set_owner(scene_root, scene_root)
		scene.pack(scene_root)
		
		structure_map[pos] = scene
	
	config.set_value(SECTION_NAME, "structure_map", structure_map)
	
	# TODO: Save time of day + current day
	
	
	# TODO: Save enemies
	
	create_save_directory()
	
	var err = config.save(SAVE_PATH + "/" + SAVE_NAME + str(save_num) + ".cfg")
	
	if err != OK:
		print("WARNING: Failed to save session data!")
	else:
		print("Successfully saved session data!")

func load_session_data(save_num: int = 1) -> Dictionary:
	var session_data: Dictionary = {}
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH + "/" + SAVE_NAME + str(save_num) + ".cfg")
	if err != OK:
		print("WARNING: Failed to load session data!")
		return {}
	else:
		print("Successfully loaded session data!")
	
	# Get rng seed
	var session_seed: int = config.get_value(SECTION_NAME, "seed")
	session_data["seed"] = session_seed
	#print("Seed: ", session_seed)
	
	# Get structure map
	var structure_map: Dictionary = config.get_value(SECTION_NAME, "structure_map")
	session_data["structure_map"] = structure_map
	#for key in structure_map.keys():
		#print(key, ": ", structure_map[key])
	
	return session_data

func clear_session_data(save_num: int = 1):
	pass

# Creates a directory in the User directory if it does not already exist
func create_save_directory() -> void:
	if !DirAccess.dir_exists_absolute(SAVE_PATH):
		DirAccess.make_dir_absolute(SAVE_PATH)




func _set_owner(node, root):
	if node != root:
		node.owner = root
	for child in node.get_children():
		_set_owner(child, root)
