class_name Cursor
extends Marker2D

static var instance: Cursor

signal just_moved(old_pos: Vector2i, new_pos: Vector2i)

var is_enabled := false
var iso_position: Vector2i

## BUGS
## - When in UI, kind scuffed.
## - Correct height on billboard/short city buildings... 

func _ready() -> void:
	instance = self # Assuming only one cursor!
	set_iso_position(Global.ORIGIN)
	just_moved.connect(on_just_moved)
	disable()

func can_interact() -> bool:
	return is_enabled

func enable() -> void:
	if is_enabled:
		return
	is_enabled = true
	show()
	global_position = Global.terrain_map.map_to_local(iso_position)
	wooden_arrow.set_cursor_position(global_position)
	_set_arrow_visible(true)

func disable() -> void:
	if not is_enabled:
		return
	is_enabled = false
	hide()
	_set_arrow_visible(false)

static func get_instance() -> Cursor:
	return instance

func move_to(mouse_pos: Vector2) -> void:
	set_iso_position(Global.terrain_map.local_to_map(mouse_pos))

func move_by(offset: Vector2i) -> void:
	#if offset.y < 0:
		#set_iso_position(iso_position + Vector2i.UP + Vector2i.LEFT)
	#elif offset.y > 0:
		#set_iso_position(iso_position + Vector2i.DOWN + Vector2i.RIGHT)
	
	if (iso_position.y % 2 == 0) != (iso_position.x % 2 == 0):
		if offset.y > 0:
			set_iso_position(iso_position + Vector2i.DOWN)
		elif offset.y < 0:
			set_iso_position(iso_position + Vector2i.LEFT)
	else:
		if offset.y > 0:
			set_iso_position(iso_position + Vector2i.RIGHT)
		elif offset.y < 0:
			set_iso_position(iso_position + Vector2i.UP)
	
	if (iso_position.y % 2 == 0) != (iso_position.x % 2 == 0):
		if offset.x > 0:
			set_iso_position(iso_position + Vector2i.RIGHT)
		elif offset.x < 0:
			set_iso_position(iso_position + Vector2i.DOWN)
	else:
		if offset.x > 0:
			set_iso_position(iso_position + Vector2i.UP)
		elif offset.x < 0:
			set_iso_position(iso_position + Vector2i.LEFT)

func move_by_smooth(amount: Vector2) -> void:
	var new_pos = Global.terrain_map.map_to_local(iso_position) + amount.normalized()
	move_to(new_pos)

func set_iso_position(new_iso_pos: Vector2i) -> void:
	var old_pos = iso_position
	iso_position = new_iso_pos
	if old_pos != new_iso_pos:
		just_moved.emit(old_pos, new_iso_pos)

func on_just_moved(old_pos: Vector2i, new_pos: Vector2i) -> void:
	update_adjacent_tile_transparencies()
	
	$InfoBoxDetector.detect(iso_position)

## Update position and change state based on what's at the position
func _process(delta: float) -> void:
	global_position = Global.terrain_map.map_to_local(iso_position)
	wooden_arrow.set_cursor_position(global_position)
	
	_update_visuals()

#region VISUALS

# Structures where the arrow should "bob" up and down on them,
# if they happen to be in range...
const BOBBING_BUILDING_IDS = ["city_building", "factory", "factory_remains"]

const YELLOW := Color("ca910081")
const BLUE := Color("3fd7ff81")
const RED := Color("ff578681")

@onready var highlight: Sprite2D = %ModulationHighlight
@onready var wooden_arrow: CursorWoodenArrow = %WoodenArrow

## Change visual details based on what is highlighted...
func _update_visuals() -> void:
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
	if TreeManager.is_occupied(iso_position):
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
		return

func _can_plant() -> bool:
	var current_twee: Twee = TreeManager.get_new_tree_of_currently_selected_type()
	if current_twee == null:
		return false
	return TreeManager.enough_n(current_twee.tree_stat.cost_to_purchase)

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
	building_map.update_transparencies_around(iso_position)

#endregion
