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
@export var cursor_state_dict: Dictionary[IsometricCursor.CursorState, VisualCursorState]

@onready var large_modulation_highlight: LargeModulationHighlight = %LargeModulationHighlight
@onready var wooden_arrow: CursorWoodenArrow = %WoodenArrow

var is_process_enabled: bool = true

func _ready() -> void:
	cursor.just_moved.connect(_on_just_moved)

func _process(delta: float) -> void:
	if not is_process_enabled:
		return
	
	global_position = Global.terrain_map.map_to_local(cursor.iso_position)
	
	# Get current state and update visual state to match
	var current_state: IsometricCursor.CursorState = cursor.current_state
	var visual_state: VisualCursorState = cursor_state_dict[current_state]
	visual_state.update(cursor, self)

func _on_just_moved(old_pos: Vector2i, new_pos: Vector2i) -> void:
	update_adjacent_tile_transparencies()

# Updates the building map to make buildings in front of the currently hovered tile transparent
func update_adjacent_tile_transparencies() -> void:
	var building_map: BuildingMap = Global.structure_map
	building_map.update_transparencies_around(cursor.iso_position)

#region MODULATE HIGHLIGHT

func highlight_tile_at(iso_position: Vector2i) -> void:
	large_modulation_highlight.highlight_tile_at(iso_position)

func set_highlight_modulate(color: Color) -> void:
	large_modulation_highlight.set_color(color)

func set_highlight_visible(value: bool) -> void:
	if value:
		large_modulation_highlight.enable()
	else:
		large_modulation_highlight.disable()

#endregion

#region ARROW POSITION & HEIGHT

func set_arrow_position(new_position: Vector2) -> void:
	wooden_arrow.set_cursor_position(new_position)

func set_arrow_height(value: CursorWoodenArrow.ArrowHeight, custom_height: float = 0.0) -> void:
	wooden_arrow.set_height(value, custom_height)

func set_arrow_visible(value: bool) -> void:
	if value:
		wooden_arrow.enable()
	else:
		wooden_arrow.disable()

func set_arrow_bobbing(value: bool) -> void:
	if value and not wooden_arrow.is_playing():
		wooden_arrow.play()
	elif not value and wooden_arrow.is_playing():
		wooden_arrow.stop()

#endregion

#region ENABLE/DISABLE

func enable() -> void:
	show()
	global_position = Global.terrain_map.map_to_local(cursor.iso_position)
	set_arrow_position(global_position)
	set_arrow_visible(true)

func disable() -> void:
	hide()
	set_arrow_visible(false)

#endregion
