extends Node

const SECTION_NAME := "session_data"

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
	
	# Save structure map
	config.set_value(SECTION_NAME, "structure_map", Global.structure_map.tile_scene_map)
	
	# TODO: Save time of day + current day
	
	
	# TODO: Save enemies
	
	
	var err = config.save("user://session_data/session_1.cfg")
	
	if err != OK:
		print("WARNING: Failed to save session data!")

func load_session_data(save_num: int = 1) -> Dictionary:
	var session_data: Dictionary = {}
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err != OK:
		print("WARNING: Failed to load session data!")
		return {}
	
	# Get rng seed
	var session_seed: int = config.get_value(SECTION_NAME, "seed")
	session_data["seed"] = session_seed
	print("Seed: ", session_seed)
	
	# Get structure map
	var structure_map: Dictionary[Vector2i, Node2D] = config.get_value(SECTION_NAME, "structure_map")
	session_data["structure_map"] = structure_map
	for key in structure_map.keys():
		print(key, ": ", structure_map[key])
	
	return session_data

func clear_session_data(save_num: int = 1):
	pass
