class_name VisualCursor
extends Marker2D

## HANDLES ONLY VISUAL CURSOR STUFF

@export var cursor: Cursor

func _ready() -> void:
	cursor.just_moved.connect(_on_just_moved)

func _process(delta: float) -> void:
	global_position = Global.terrain_map.map_to_local(cursor.iso_position)
	wooden_arrow.set_cursor_position(global_position)
	_update_visuals()

func _on_just_moved(old_pos: Vector2i, new_pos: Vector2i) -> void:
	update_adjacent_tile_transparencies()

# Structures where the arrow should "bob" up and down on them,
# if they happen to be in range...
const BOBBING_BUILDING_IDS = ["city_building", "factory", "factory_remains"]

const YELLOW := Color("ca910081")
const BLUE := Color("3fd7ff81")
const RED := Color("ff578681")

@onready var highlight: Sprite2D = %ModulationHighlight
@onready var wooden_arrow: CursorWoodenArrow = %WoodenArrow

var is_enabled := false

func enable() -> void:
	if is_enabled:
		return
	is_enabled = true
	show()
	global_position = Global.terrain_map.map_to_local(cursor.iso_position)
	wooden_arrow.set_cursor_position(global_position)
	_set_arrow_visible(true)

func disable() -> void:
	if not is_enabled:
		return
	is_enabled = false
	hide()
	_set_arrow_visible(false)

## Change visual details based on what is highlighted...
func _update_visuals() -> void:
	var iso_position = cursor.iso_position
	
	var terrain_map = Global.terrain_map
	var structure_map = Global.structure_map
	var building_node = structure_map.get_building_node(iso_position)
	
	# SET THE ARROW HEIGHT BASED ON WHAT IS ON THIS TILE...
	if building_node == null:
		_set_arrow_height("low")
	else:
		_set_arrow_height((building_node as Structure).get_arrow_cursor_height())
	
	# SET THE ARROW BOBBING BASED ON WHAT IS ON THIS TILE...
	if building_node == null:
		_set_arrow_bobbing(true)
	else:
		if (building_node as Structure).get_id() in BOBBING_BUILDING_IDS:
			_set_arrow_bobbing(true)
		else:
			_set_arrow_bobbing(false)

	# Don't highlight outside the map or on non-solid tiles...
	if not terrain_map.is_solid(iso_position):
		# Don't highlight void
		if terrain_map.is_void(iso_position):
			disable()
		else: # Show red on water
			enable()
			_set_highlight_modulate(RED)
			_set_arrow_visible(false)
		return
	
	# We are highlighting an existing tree
	if TreeManager.is_twee(iso_position):
		enable()
		_set_highlight_modulate(YELLOW)
		_set_arrow_visible(true)
		return
	
	# We are too far away from any trees...
	if not TreeManager.is_reachable(iso_position):
		enable()
		_set_highlight_modulate(RED)
		_set_arrow_visible(false)
		return
	
	# OK. Now we are in range...
	
	# Fertile ground!
	if terrain_map.is_fertile(iso_position):
		enable()
		if _can_plant():
			_set_highlight_modulate(BLUE)
			_set_arrow_bobbing(true)
		else:
			_set_highlight_modulate(YELLOW)
			_set_arrow_bobbing(false)
		_set_arrow_visible(true)
		return
	
	# We are highlighting concrete...
	if terrain_map.is_concrete(iso_position):
		enable()
		_set_highlight_modulate(YELLOW)
		_set_arrow_visible(true)
		_set_arrow_bobbing(true)
		if (building_node as Structure) != null:
			if building_node is CityBuilding:
				if not TreeManager.enough_n((building_node as CityBuilding).cost_to_remove):
					_set_arrow_bobbing(false)
			elif building_node is Factory:
				if not TreeManager.enough_n((building_node as Factory).cost_to_remove):
					_set_arrow_bobbing(false)
		else:
			if terrain_map.get_tile_biome(iso_position) == TerrainMap.TileType.CITY:
				if not TreeManager.enough_n(structure_map.COST_TO_REMOVE_CITY_TILE):
					_set_arrow_bobbing(false)
			if terrain_map.get_tile_biome(iso_position) == TerrainMap.TileType.ROAD:
				if not TreeManager.enough_n(structure_map.COST_TO_REMOVE_ROAD_TILE):
					_set_arrow_bobbing(false)
		return

func _can_plant() -> bool:
	var tree_stat: TreeStatResource = TreeRegistry.get_twee_stat(TreeMenu.instance.get_currently_selected_tree_type())
	if tree_stat == null:
		return false
	return TreeManager.enough_n(tree_stat.cost_to_purchase)

func _set_highlight_modulate(color: Color) -> void:
	highlight.modulate = color

func _set_arrow_visible(value: bool) -> void:
	if value:
		wooden_arrow.enable()
	else:
		wooden_arrow.disable()

func _set_arrow_height(value: String) -> void:
	wooden_arrow.set_height(value)

func _set_arrow_bobbing(value: bool) -> void:
	if value and not wooden_arrow.is_playing():
		wooden_arrow.play()
	elif not value and wooden_arrow.is_playing():
		wooden_arrow.stop()

# Updates the building map to make buildings in front of the currently hovered tile transparent
func update_adjacent_tile_transparencies() -> void:
	var building_map: BuildingMap = Global.structure_map
	building_map.update_transparencies_around(cursor.iso_position)
