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
	
	var scenes := DataUtil.load_all_scenes_in_folder(tree_unlock_path)
	
	for set_piece_packed: PackedScene in scenes:
		var set_piece: SetPiece = set_piece_packed.instantiate()
		
		var biome_set_pieces: Array = tree_unlock_set_pieces[set_piece.biome]
		biome_set_pieces.append(set_piece_packed)

func _generate_tech_set_piece_dict() -> void:
	for biome: TerrainMap.Biome in TerrainMap.Biome.values():
		tech_point_set_pieces[biome] = []
	
	var tech_unlock_path := "res://world/proc_gen/set_pieces/tech_set_pieces/" # Hardcoded path... bad?
	
	var scenes := DataUtil.load_all_scenes_in_folder(tech_unlock_path)
	
	for set_piece_packed: PackedScene in scenes:
		var set_piece: SetPiece = set_piece_packed.instantiate()
				
		var biome_set_pieces: Array = tech_point_set_pieces[set_piece.biome]
		biome_set_pieces.append(set_piece_packed)

## Returns an array of tree unlock set pieces of the given biome. 
## If no biome is given, returns an array of all tree unlock set pieces.
func get_tree_unlock_set_pieces(biome: TerrainMap.Biome = -999) -> Array:
	if biome == -999:
		var all_set_pieces = []
		for array: Array in tree_unlock_set_pieces.values():
			var instantiated_array = []
			for packed_scene in array:
				instantiated_array.append(packed_scene.instantiate())
			all_set_pieces.append_array(instantiated_array)
		return all_set_pieces
	
	var array = tree_unlock_set_pieces[biome]
	var instantiated_array = []
	for packed_scene in array:
		instantiated_array.append(packed_scene.instantiate())
	
	return instantiated_array

func get_tech_point_set_pieces(biome: TerrainMap.Biome = -999) -> Array:
	if biome == -999:
		var all_set_pieces = []
		for array: Array in tech_point_set_pieces.values():
			var instantiated_array = []
			for packed_scene in array:
				instantiated_array.append(packed_scene.instantiate())
			all_set_pieces.append_array(instantiated_array)
		return all_set_pieces
	
	var array = tech_point_set_pieces[biome]
	var instantiated_array = []
	for packed_scene in array:
		instantiated_array.append(packed_scene.instantiate())
	
	return instantiated_array
