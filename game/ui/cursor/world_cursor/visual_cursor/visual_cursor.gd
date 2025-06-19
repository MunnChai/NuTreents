class_name VisualCursor
extends Marker2D

## HANDLES ONLY VISUAL CURSOR STUFF

@export var cursor: Cursor

var previous_position: Vector2i

var is_process_enabled: bool = true

func _ready() -> void:
	cursor.just_moved.connect(_on_just_moved)

func _process(delta: float) -> void:
	if not is_process_enabled:
		return
	
	global_position = Global.terrain_map.map_to_local(cursor.iso_position)
	
	var building: Node2D = Global.structure_map.get_building_node(cursor.iso_position)
	
	## BUILDING:
	if building != null and Components.has_component(building, GridPositionComponent):
		var position_component: GridPositionComponent = Components.get_component(building, GridPositionComponent)
		var positions := position_component.get_occupied_positions()
		var average_pos := Vector2.ZERO
		var sum := 0
		for pos: Vector2i in positions:
			var smooth_pos := Global.structure_map.map_to_local(pos)
			average_pos += smooth_pos
			sum += 1
		average_pos /= sum
		wooden_arrow.set_cursor_position(average_pos)
	## TILE:
	else:
		wooden_arrow.set_cursor_position(global_position)

	_update_visuals(delta)

func _on_just_moved(old_pos: Vector2i, new_pos: Vector2i) -> void:
	update_adjacent_tile_transparencies()

# Structures where the arrow should "bob" up and down on them,
# if they happen to be in range...
const BOBBING_BUILDING_IDS = ["city_building", "factory", "factory_remains"]

const YELLOW := Color("ca910081")
const BLUE := Color("3fd7ff81")
const RED := Color("ff578681")

@onready var large_modulation_highlight: LargeModulationHighlight = %LargeModulationHighlight
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
func _update_visuals(delta: float) -> void:
	var iso_position = cursor.iso_position
	
	if previous_position != iso_position:
		_hide_structure_outline(previous_position)
	
	previous_position = iso_position
	
	large_modulation_highlight.highlight_tile_at(iso_position)
	
	var terrain_map = Global.terrain_map
	var structure_map = Global.structure_map
	var building_node = structure_map.get_building_node(iso_position)
	
	#Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	
	# SET THE ARROW HEIGHT BASED ON WHAT IS ON THIS TILE...
	if building_node == null:
		_set_arrow_height(CursorWoodenArrow.ArrowHeight.LOW)
	else:
		var visual_arrow_component: VisualArrowComponent = Components.get_component(building_node, VisualArrowComponent)
		if visual_arrow_component:
			_set_arrow_height(visual_arrow_component.get_arrow_cursor_height(), visual_arrow_component.get_custom_height())
		_show_structure_outline(iso_position)
	
	# SET THE ARROW BOBBING BASED ON WHAT IS ON THIS TILE...
	if building_node == null || not structure_map.does_obstructive_structure_exist(iso_position):
		_set_arrow_bobbing(true)
	else:
		if Components.has_component(building_node, TooltipIdentifierComponent):
			var id = Components.get_component(building_node, TooltipIdentifierComponent)
			if id in BOBBING_BUILDING_IDS:
				_set_arrow_bobbing(true)
			else:
				_set_arrow_bobbing(false)
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
	
	# Obstruction
	if structure_map.does_obstructive_structure_exist(iso_position):
		enable()
		_set_highlight_modulate(RED)
		_set_arrow_visible(false)
		return
	
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

func _can_plant() -> bool:
	var tree_stat: TreeStatResource = TreeRegistry.get_twee_stat(TreeMenu.instance.get_currently_selected_tree_type())
	if tree_stat == null:
		return false
	return TreeManager.enough_n(tree_stat.cost_to_purchase)

func _set_highlight_modulate(color: Color) -> void:
	large_modulation_highlight.set_color(color)

func _set_arrow_visible(value: bool) -> void:
	if value:
		wooden_arrow.enable()
	else:
		wooden_arrow.disable()

func _set_arrow_height(value: CursorWoodenArrow.ArrowHeight, custom_height: float = 0.0) -> void:
	wooden_arrow.set_height(value, custom_height)

func _set_arrow_bobbing(value: bool) -> void:
	if value and not wooden_arrow.is_playing():
		wooden_arrow.play()
	elif not value and wooden_arrow.is_playing():
		wooden_arrow.stop()

# Updates the building map to make buildings in front of the currently hovered tile transparent
func update_adjacent_tile_transparencies() -> void:
	var building_map: BuildingMap = Global.structure_map
	building_map.update_transparencies_around(cursor.iso_position)

func _show_structure_outline(iso_position: Vector2i):
	var entity: Node2D = MapUtility.get_entity_at(iso_position)
	if entity and Components.has_component(entity, OutlineComponent):
		var outline_component = Components.get_component(entity, OutlineComponent)
		outline_component.show_outline()
		return

func _hide_structure_outline(iso_position: Vector2i):
	var entity: Node2D = MapUtility.get_entity_at(iso_position)
	if entity and Components.has_component(entity, OutlineComponent):
		var outline_component = Components.get_component(entity, OutlineComponent)
		outline_component.hide_outline()
		return
