class_name IsometricCursorVisual
extends Marker2D

## ISOMETRIC CURSOR VISUAL
## The visual component to the IsometricCursor
## This includes:
## - The arrow
## - The modulation
## - Sending request to update transparencies
## - Structure outlines

const LARGE_MODULATION_HIGHLIGHT = preload("modulation_highlight/large_modulation_highlight.tscn")

const YELLOW := Color("ca910081")
const BLUE := Color("3fd7ff81")
const RED := Color("ff578681")

@export var cursor: IsometricCursor
@export var cursor_state_dict: Dictionary[IsometricCursor.CursorState, VisualCursorState]

@onready var large_modulation_highlight: LargeModulationHighlight = %LargeModulationHighlight
@onready var wooden_arrow: CursorWoodenArrow = %WoodenArrow
@onready var extra_highlights: Node = $ExtraHighlights
@onready var hologram: Sprite2D = $Hologram

var is_process_enabled: bool = true
# Set default to out of bounds to allow for "enter" to be called
var current_state: IsometricCursor.CursorState = -1

func _ready() -> void:
	cursor.just_moved.connect(_on_just_moved)
	
	DebugConsole.register("toggle_iso_cursor", func(args: PackedStringArray):
		visible = !visible
		, "Toggles isometric cursor visibility (the highlight and wooden arrow)")

func _process(delta: float) -> void:
	if not is_process_enabled:
		return
	
	global_position = Global.terrain_map.map_to_local(cursor.iso_position)
	
	# Get current state and update visual state to match
	var new_state: IsometricCursor.CursorState = cursor.current_state
	if current_state != new_state:
		enter_state(new_state)

func _on_just_moved(old_pos: Vector2i, new_pos: Vector2i) -> void:
	update_adjacent_tile_transparencies(old_pos, new_pos)
	
	var visual_state: VisualCursorState = cursor_state_dict[current_state]
	visual_state.update(cursor, self)

# Updates the building map to make buildings in front of the currently hovered tile transparent
func update_adjacent_tile_transparencies(old_pos: Vector2i, new_pos: Vector2i) -> void:
	var building_map: BuildingMap = Global.structure_map
	building_map.update_transparencies_around(old_pos, new_pos)

#region STATE MACHINE

func enter_state(new_state: IsometricCursor.CursorState) -> void:
	if current_state == new_state:
		return
	
	# Exit old action
	if current_state in IsometricCursor.CursorState.values():
		var current_visual_state: VisualCursorState = cursor_state_dict[current_state]
		current_visual_state.exit(cursor, self)
	
	# Enter new action
	var new_visual_state: VisualCursorState = cursor_state_dict[new_state]
	new_visual_state.enter(cursor, self)
	
	# Set current state
	current_state = new_state

#endregion

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

#region EXTRA MODULATIONS POOL

## A pool of the current individual tile modulation highlights
var large_highlight_pool: Array[Node2D] = []
var next_available := 0 ## The next index of a tile that is not currently used
func reset_highlight_pool():
	for highlight: Node2D in large_highlight_pool:
		highlight.hide()
	next_available = 0

## Get the next available unused modulation tile
## If none remain, instantiate a new one!
func get_large_highlight() -> LargeModulationHighlight:
	var get_index = next_available
	next_available += 1
	
	if large_highlight_pool.size() <= get_index:
		## Don't have another one...
		## Create one!
		var new_highlight = LARGE_MODULATION_HIGHLIGHT.instantiate()
		extra_highlights.add_child(new_highlight)
		large_highlight_pool.append(new_highlight)
	
	var highlight = large_highlight_pool[get_index]
	highlight.show()
	return highlight

#endregion

#region HOLOGRAM

func set_hologram_texture(texture: Texture2D) -> void:
	hologram.texture = texture

func set_hologram_offset(offset: Vector2) -> void:
	hologram.offset = offset

func set_hologram_visible(value: bool) -> void:
	hologram.visible = value

func set_hologram_modulate(color: Color, custom_alpha: float = -1) -> void:
	hologram.modulate = color
	if custom_alpha >= 0:
		hologram.modulate.a = custom_alpha

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
