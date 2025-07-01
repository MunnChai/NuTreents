extends Node

## A dictionary of arrays containing tree unlock setpieces, with biomes as the key.
## Full type: Dictionary[TerrainMap.Biome, Array[SetPiece]]
var tree_unlock_set_pieces: Dictionary[TerrainMap.Biome, Array]

## A dictionary of arrays containing tech point setpieces, with biomes as the key.
## Full type: Dictionary[TerrainMap.Biome, Array[SetPiece]]
var tech_point_set_pieces: Dictionary[TerrainMap.Biome, Array]

func _ready() -> void:
	_generate_tree_set_piece_dict()
	_generate_tech_set_piece_dict()
	#print("Trees: ", tree_unlock_set_pieces)
	#print("Tech: ", tech_point_set_pieces)

func _generate_tree_set_piece_dict() -> void:
	for biome: TerrainMap.Biome in TerrainMap.Biome.values():
		tree_unlock_set_pieces[biome] = []
	
	var tree_unlock_path := "res://world/proc_gen/set_pieces/tree_set_pieces/" # Hardcoded path... bad?
	var dir: DirAccess = DirAccess.open(tree_unlock_path)
	if dir:
		# Initialize stream
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			# Do stuff with file...
			if not dir.current_is_dir():
				var full_path: String = tree_unlock_path + file_name
				var set_piece_packed = load(full_path)
				var set_piece: SetPiece = set_piece_packed.instantiate()
				
				var biome_set_pieces: Array = tree_unlock_set_pieces[set_piece.biome]
				biome_set_pieces.append(set_piece)
			
			# Get next
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path: ", tree_unlock_path)

func _generate_tech_set_piece_dict() -> void:
	for biome: TerrainMap.Biome in TerrainMap.Biome.values():
		tech_point_set_pieces[biome] = []
	
	var tech_unlock_path := "res://world/proc_gen/set_pieces/tech_set_pieces/" # Hardcoded path... bad?
	var dir: DirAccess = DirAccess.open(tech_unlock_path)
	if dir:
		# Initialize stream
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			# Do stuff with file...
			if not dir.current_is_dir():
				var full_path: String = tech_unlock_path + file_name
				var set_piece_packed = load(full_path)
				var set_piece: SetPiece = set_piece_packed.instantiate()
				
				var biome_set_pieces: Array = tech_point_set_pieces[set_piece.biome]
				biome_set_pieces.append(set_piece)
			
			# Get next
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path: ", tech_unlock_path)

## Returns an array of tree unlock set pieces of the given biome. 
## If no biome is given, returns an array of all tree unlock set pieces.
func get_tree_unlock_set_pieces(biome: TerrainMap.Biome = -999) -> Array:
	if biome == -999:
		var all_set_pieces = []
		for array: Array in tree_unlock_set_pieces.values():
			all_set_pieces.append_array(array)
		return all_set_pieces
	
	return tree_unlock_set_pieces[biome].duplicate()

func get_tech_point_set_pieces(biome: TerrainMap.Biome = -999) -> Array:
	if biome == -999:
		var all_set_pieces = []
		for array: Array in tech_point_set_pieces.values():
			all_set_pieces.append_array(array)
		return all_set_pieces
	
	return tech_point_set_pieces[biome].duplicate()
