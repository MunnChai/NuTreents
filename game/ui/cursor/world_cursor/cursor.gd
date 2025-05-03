class_name Cursor
extends Marker2D

static var instance: Cursor

signal just_moved(old_pos: Vector2i, new_pos: Vector2i)
signal enabled
signal disabled

var is_enabled := true
var iso_position: Vector2i

var attempted_already := false

## BUGS
## - When in UI, kind scuffed.
## - Correct height on billboard/short city buildings... 

func _ready() -> void:
	instance = self # Assuming only one cursor!
	set_iso_position(Global.ORIGIN)
	just_moved.connect(on_just_moved)

func _process(delta: float) -> void:
	$InfoBoxDetector.detect(iso_position)

## Perform LEFT MOUSE BUTTON action
func do_primary_action() -> void:
	if attempted_already:
		return 
	
	attempted_already = true
	
	var p: Vector2i = iso_position
	
	var terrain_map := Global.terrain_map
	var structure_map := Global.structure_map
	
	var type: Global.TreeType = TreeMenu.instance.get_currently_selected_tree_type() 
	var tree_stat = TreeRegistry.get_twee_stat(type)
	
	if terrain_map.is_void(p):
		return
	
	if TreeManager.is_twee(p):
		SfxManager.play_sound_effect("ui_fail")
		PopupManager.create_popup("Occupied!", structure_map.map_to_local(p), Color("ffb561"))
		return
	
	if not TreeManager.is_reachable(p):
		SfxManager.play_sound_effect("ui_fail")
		PopupManager.create_popup("Too far away!", structure_map.map_to_local(p))
		return
	
	if not terrain_map.is_fertile(p):
		SfxManager.play_sound_effect("ui_fail")
		PopupManager.create_popup("Ground not fertile!", structure_map.map_to_local(p))
		return
	 
	if !TreeManager.enough_n(tree_stat.cost_to_purchase):
		SfxManager.play_sound_effect("ui_fail")
		PopupManager.create_popup("Not enough nutreents!", structure_map.map_to_local(p))
		return

	if type == Global.TreeType.TECH_TREE:
		var can_place = true
		
		if !structure_map.tile_scene_map.has(p):
			can_place = false
		else:
			var structure: Structure = structure_map.tile_scene_map[p]
			if (not structure is FactoryRemains):
				can_place = false
		
		if !can_place:
			SfxManager.play_sound_effect("ui_fail")
			PopupManager.create_popup("Requires factory remains!", structure_map.map_to_local(p), Color("6be1e3"))
			return
	
	var tech_slot: int
	# SPECIAL CASE FOR PLANTING TECH TREES ON FACTORY REMAINS:
	if structure_map.tile_scene_map.has(p):
		var structure: Structure = structure_map.tile_scene_map[p]
		if structure is FactoryRemains:
			if type == Global.TreeType.TECH_TREE:
				tech_slot = structure.tech_slot
				structure_map.remove_structure(p)
			else:
				SfxManager.play_sound_effect("ui_fail")
				PopupManager.create_popup("Only Tech Trees grow on factory remains!", structure_map.map_to_local(p), Color("6be1e3"))
				return
	
	var tree: Twee = TreeRegistry.get_new_twee(type)
	
	if tree is TechTree:
		tree.tech_slot = tech_slot
	
	TreeManager.consume_n(tree.tree_stat.cost_to_purchase)
	SfxManager.play_sound_effect("tree_plant")
	TreeManager.place_tree(tree, p)

const FACTORY_REMAINS = preload("res://structures/city/factory/factory_remains.tscn")

## Perform RIGHT MOUSE BUTTON action
func do_secondary_action() -> void:
	var map_pos: Vector2i = iso_position
	
	var terrain_map := Global.terrain_map
	var structure_map := Global.structure_map
	
	if not TreeManager.is_reachable(map_pos, true):
		SfxManager.play_sound_effect("ui_fail")
		PopupManager.create_popup("Too far away!", structure_map.map_to_local(map_pos))
		return
	
	# Get any building on the tile
	if (structure_map.does_obstructive_structure_exist(map_pos)):
		var structure: Structure = structure_map.tile_scene_map[map_pos]
		
		# If building is tree, remove tree and return (unless it's the mother tree)
		if (structure is Twee):
			if (structure is MotherTree):
				PopupManager.create_popup("Cannot remove mother tree!", structure_map.map_to_local(map_pos))
				SfxManager.play_sound_effect("ui_fail")
				return
			
			TreeManager.remove_tree(map_pos)
			PopupManager.create_popup("Tree removed!", structure_map.map_to_local(map_pos))
		
		# If building is city_building, remove city_building (if you have enough nutrients)
		if (structure is CityBuilding):
			if TreeManager.enough_n(structure.cost_to_remove):
				SfxManager.play_sound_effect("concrete_break")
				TreeManager.consume_n(structure.cost_to_remove)
				structure_map.remove_structure(map_pos)
				PopupManager.create_popup("Building destroyed!", structure_map.map_to_local(map_pos))
			else:
				SfxManager.play_sound_effect("ui_fail")
				PopupManager.create_popup("Not enough nutrients!", structure_map.map_to_local(map_pos))
		
		# If building is factory, remove factory, instantiate factory remains
		if (structure is Factory):
			if TreeManager.enough_n(structure.cost_to_remove):
				TreeManager.consume_n(structure.cost_to_remove)
				
				var tech_slot = structure.tech_slot
				structure_map.remove_structure(map_pos)
				
				terrain_map.set_cell_type(map_pos, terrain_map.TileType.DIRT)
				
				SfxManager.play_sound_effect("concrete_break")
				PopupManager.create_popup("Factory destroyed!", structure_map.map_to_local(map_pos))
				
				# TODO: INSTANTIATE FACTORY REMAINS
				var factory_remains = FACTORY_REMAINS.instantiate()
				factory_remains.tech_slot = tech_slot
				structure_map.add_structure(map_pos, factory_remains)
			else:
				SfxManager.play_sound_effect("ui_fail")
				PopupManager.create_popup("Not enough nutrients!", structure_map.map_to_local(map_pos))
		
		if (structure is FactoryRemains):
			SfxManager.play_sound_effect("ui_fail")
			PopupManager.create_popup("Cannot destroy factory remains!", structure_map.map_to_local(map_pos))
		
		# Return after removing building
		return
	
	# IF THERE ARE NO STRUCTURES (except decor) ON THE TILE
	
	# If tile is city_tile/road_tile, replace tile with dirt tile if you have enough nutrients
	
	var tile_data = terrain_map.get_cell_tile_data(map_pos)
	if (tile_data):
		var tile_type = tile_data.get_custom_data("biome")
		
		if (tile_type == terrain_map.TileType.CITY):
			if TreeManager.enough_n(structure_map.COST_TO_REMOVE_CITY_TILE):
				TreeManager.consume_n(structure_map.COST_TO_REMOVE_CITY_TILE)
				terrain_map.set_cell_type(map_pos, terrain_map.TileType.DIRT)
				
				# Check if decor exists on this spot
				if (structure_map.tile_scene_map.has(map_pos) && !structure_map.does_obstructive_structure_exist(map_pos)):
					structure_map.remove_structure(map_pos)
				
				SfxManager.play_sound_effect("concrete_break")
				PopupManager.create_popup("Concrete removed!", structure_map.map_to_local(map_pos))
			else:
				SfxManager.play_sound_effect("ui_fail")
				PopupManager.create_popup("Not enough nutrients!", structure_map.map_to_local(map_pos))
		
		if (tile_type == terrain_map.TileType.ROAD):
			if TreeManager.enough_n(structure_map.COST_TO_REMOVE_ROAD_TILE):
				
				TreeManager.consume_n(structure_map.COST_TO_REMOVE_ROAD_TILE)
				terrain_map.set_cell_type(map_pos, terrain_map.TileType.DIRT)
				
				# Check if decor exists on this spot
				if (structure_map.tile_scene_map.has(map_pos) && !structure_map.does_obstructive_structure_exist(map_pos)):
					structure_map.remove_structure(map_pos)
				
				SfxManager.play_sound_effect("concrete_break")
				PopupManager.create_popup("Road destroyed!", structure_map.map_to_local(map_pos))
			else:
				SfxManager.play_sound_effect("ui_fail")
				PopupManager.create_popup("Not enough nutrients!", structure_map.map_to_local(map_pos))

## Moves the cursor to the given LOCAL WORLD COORDINATE
func move_to(local_world_pos: Vector2) -> void:
	set_iso_position(Global.terrain_map.local_to_map(local_world_pos))

## Sets the ISOMETRIC WORLD POSITION of the cursor
func set_iso_position(new_iso_pos: Vector2i) -> void:
	var old_pos = iso_position
	iso_position = new_iso_pos
	if old_pos != new_iso_pos:
		just_moved.emit(old_pos, new_iso_pos)

## Returns true if the cursor may be used to interact...
func can_interact() -> bool:
	return is_enabled

func on_just_moved(old_pos: Vector2i, new_pos: Vector2i) -> void:
	#$InfoBoxDetector.detect(iso_position)
	attempted_already = false
