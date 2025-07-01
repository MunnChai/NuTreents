class_name IsometricCursorVisual
extends Marker2D

## ISOMETRIC CURSOR VISUAL
## The visual component to the IsometricCursor
## This includes:
## - The arrow
## - The modulation
## - Sending request to update transparencies
## - Structure outlines

# Structures where the arrow should "bob" up and down on them,
# if they happen to be in range...
const BOBBING_BUILDING_IDS = ["city_building", "factory", "factory_remains", "petrified_tree"]

const YELLOW := Color("ca910081")
const BLUE := Color("3fd7ff81")
const RED := Color("ff578681")

@export var cursor: IsometricCursor

@onready var large_modulation_highlight: LargeModulationHighlight = %LargeModulationHighlight
@onready var wooden_arrow: CursorWoodenArrow = %WoodenArrow

var previous_position: Vector2i
var is_process_enabled: bool = true

func _ready() -> void:
	cursor.just_moved.connect(_on_just_moved)

func _process(delta: float) -> void:
	if not is_process_enabled:
		return
	
	global_position = Global.terrain_map.map_to_local(cursor.iso_position)
	
	_update_arrow_position()
	_update_arrow_height(cursor.iso_position)
	_update_structure_outline(cursor.iso_position)
	_update_visuals(delta)

func _on_just_moved(old_pos: Vector2i, new_pos: Vector2i) -> void:
	update_adjacent_tile_transparencies()

# Updates the building map to make buildings in front of the currently hovered tile transparent
func update_adjacent_tile_transparencies() -> void:
	var building_map: BuildingMap = Global.structure_map
	building_map.update_transparencies_around(cursor.iso_position)

#region ARROW POSITION & HEIGHT

func _update_arrow_position() -> void:
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

## SET THE ARROW HEIGHT BASED ON WHAT IS ON THIS TILE...
func _update_arrow_height(iso_position: Vector2i) -> void:
	var structure_map = Global.structure_map
	var building_node = structure_map.get_building_node(iso_position)
	
	if building_node == null:
		_set_arrow_height(CursorWoodenArrow.ArrowHeight.LOW)
	else:
		var visual_arrow_component: VisualArrowComponent = Components.get_component(building_node, VisualArrowComponent)
		if visual_arrow_component:
			_set_arrow_height(visual_arrow_component.get_arrow_cursor_height(), visual_arrow_component.get_custom_height())
		else:
			_set_arrow_height(CursorWoodenArrow.ArrowHeight.LOW)

#endregion

#region ENABLE/DISABLE

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

#endregion

#region VISUAL BASED ON HOVER STATE

## Change visual details based on what is highlighted...
func _update_visuals(delta: float) -> void:
	var terrain_map = Global.terrain_map
	var structure_map = Global.structure_map
	var iso_position = cursor.iso_position
	
	## CLEAN UP UPON MOVEMENT
	
	
	## OK, SO WE MOVED
	large_modulation_highlight.highlight_tile_at(iso_position)
	
	var flag := cursor.get_hover_flag()
	
	## GENERAL HOVER CRITERIA
	match flag:
		IsometricCursor.HoverFlag.VOID:
			disable()
		IsometricCursor.HoverFlag.TOO_FAR_AWAY:
			enable()
			_set_highlight_modulate(RED)
			_set_arrow_visible(false)
			_set_arrow_bobbing(false)
		IsometricCursor.HoverFlag.OCCUPIED:
			## CHECK: What is OCCUPIED?
			# We are highlighting an existing tree
			if TreeManager.is_twee(iso_position):
				enable()
				_set_highlight_modulate(YELLOW)
				_set_arrow_visible(true)
				_set_arrow_bobbing(false)
			else:
				# We are highlighting something that can be bobbed
				var building_node = structure_map.get_building_node(iso_position)
				if Components.has_component(building_node, TooltipIdentifierComponent):
					enable()
					var id = Components.get_component(building_node, TooltipIdentifierComponent)
					if id.get_id() in BOBBING_BUILDING_IDS:
						var destructable: DestructableComponent = Components.get_component(building_node, DestructableComponent)
						if destructable: ## Huh, we need destructable verification
							if TreeManager.enough_n(destructable.get_cost()):
								_set_highlight_modulate(YELLOW)
								_set_arrow_visible(true)
								_set_arrow_bobbing(true)
							else:
								_set_highlight_modulate(YELLOW)
								_set_arrow_visible(true)
								_set_arrow_bobbing(false)
						else:
							_set_highlight_modulate(YELLOW)
							_set_arrow_visible(true)
							_set_arrow_bobbing(true)
					else:
						_set_highlight_modulate(YELLOW)
						_set_arrow_visible(true)
						_set_arrow_bobbing(false)
				else:
					disable()
		IsometricCursor.HoverFlag.NOT_FERTILE:
			if terrain_map.is_concrete(iso_position):
				enable()
				_set_highlight_modulate(YELLOW)
				_set_arrow_visible(true)
				_set_arrow_bobbing(true)
				match terrain_map.get_tile_biome(iso_position):
					TerrainMap.TileType.CITY:
						if not TreeManager.enough_n(structure_map.COST_TO_REMOVE_CITY_TILE):
							_set_arrow_bobbing(false)
					TerrainMap.TileType.ROAD:
						if not TreeManager.enough_n(structure_map.COST_TO_REMOVE_ROAD_TILE):
							_set_arrow_bobbing(false)
			else:
				enable()
				_set_highlight_modulate(RED)
				_set_arrow_visible(false)
				_set_arrow_bobbing(false)
		IsometricCursor.HoverFlag.OK_FOR_PLANTING:
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
		_:
			pass ## How did we get here?

func _can_plant() -> bool:
	var type := TreeMenu.instance.get_currently_selected_tree_type()
	var tree_stat: TreeStatResource = TreeRegistry.get_twee_stat(type)
	
	if tree_stat == null:
		return false
	
	## TILE VALIDATION
	var structure_map := Global.structure_map
	var p := cursor.iso_position
	match type:
		Global.TreeType.TECH_TREE: ## Tech Trees must be planted on Factory Remains
			if not structure_map.tile_scene_map.has(p):
				return false
			elif not Components.has_component(structure_map.tile_scene_map[p], FactoryRemainsBehaviourComponent):
				return false
		_: ## All other trees cannot be planted on Factory Remains
			if structure_map.tile_scene_map.has(p) and Components.has_component(structure_map.tile_scene_map[p], FactoryRemainsBehaviourComponent):
				return false
	
	## COST VALIDATION
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

#endregion

#region STRUCTURE OUTLINE

## SHOW/HIDE STRUCTURE OUTLINE AT POSITION
func _update_structure_outline(iso_position: Vector2i) -> void:
	## REMOVE PREVIOUS
	if previous_position != iso_position:
		_hide_structure_outline(previous_position)
	previous_position = iso_position
	
	var structure_map = Global.structure_map
	var building_node = structure_map.get_building_node(iso_position)
	
	if building_node:
		_show_structure_outline(iso_position)

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

#endregion
