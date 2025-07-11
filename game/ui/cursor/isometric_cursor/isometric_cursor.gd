class_name IsometricCursor
extends Marker2D

## ISOMETRIC CURSOR
## The data representation/operations for the cursor in world space...
## snapped to the currently highlighted isometric grid position

## TODO
## - BUG: When in UI, kind scuffed.

## Cursor State enum, for ease of switching states in other scripts
enum CursorState {
	SELECT = 0,
	PLANT = SELECT + 1,
	DESTROY = PLANT + 1,
	EXTINGUISH = DESTROY + 1,
}

signal just_moved(old_pos: Vector2i, new_pos: Vector2i)
signal enabled
signal disabled

## DEPRECATED
#@export var primary_action: CursorAction
#@export var secondary_action: CursorAction

@export var default_state: CursorState
@export var cursor_state_dict: Dictionary[CursorState, CursorAction]

var is_enabled := true
var iso_position: Vector2i

var attempted_already := false ## Has the primary action already been attempted this input and tile?

static var instance: IsometricCursor

var current_state: CursorState

var currently_selected_entity: Node2D:
	set(new_entity):
		var old_entity = currently_selected_entity
		currently_selected_entity = new_entity
		selected_entity_changed.emit(old_entity, new_entity)

signal selected_entity_changed(old_entity: Node2D, new_entity: Node2D)

func _ready() -> void:
	instance = self # Assuming only one cursor!
	
	set_iso_position(Global.ORIGIN)
	just_moved.connect(_on_just_moved)
	
	enter_state(default_state)

func _process(delta: float) -> void:
	$InfoBoxDetector.detect(iso_position)
	
	global_position = Global.terrain_map.map_to_local(iso_position)
	
	var current_action: CursorAction = cursor_state_dict[current_state]
	current_action.update(self, delta)

func _on_just_moved(old_pos: Vector2i, new_pos: Vector2i) -> void:
	attempted_already = false

## Returns true if the cursor may be used to interact...
func can_interact() -> bool:
	return is_enabled

#region MOVEMENT

## Moves the cursor to the given LOCAL WORLD COORDINATE
func move_to(local_world_pos: Vector2) -> void:
	set_iso_position(Global.terrain_map.local_to_map(local_world_pos))

## Sets the ISOMETRIC WORLD POSITION of the cursor
func set_iso_position(new_iso_pos: Vector2i) -> void:
	var old_pos = iso_position
	iso_position = new_iso_pos
	if old_pos != new_iso_pos:
		just_moved.emit(old_pos, new_iso_pos)

#endregion

#region HOVER FLAG

enum HoverFlag {
	VOID,
	TOO_FAR_AWAY,
	OBSCURED,
	OCCUPIED,
	NOT_FERTILE,
	OK_FOR_PLANTING,
}

## Supplies one of the above HoverFlags
## based on the context of where the cursor is hovering...
func get_hover_flag(p: Vector2i = iso_position) -> HoverFlag:
	var terrain_map := Global.terrain_map
	var structure_map := Global.structure_map
	var fog_map := Global.fog_map
	
	## Early termination for void tiles
	if terrain_map.is_void(p):
		return HoverFlag.VOID
	
	## Early termination for foggy tiles
	if fog_map.is_tile_foggy(p):
		return HoverFlag.OBSCURED
	
	## Early termination for far away tiles
	if not TreeManager.is_reachable(p, true):
		return HoverFlag.TOO_FAR_AWAY
	
	## OK, there is a possibility of an entity here
	var entity = MapUtility.get_entity_at(p)

	if entity:
		var obstruction_component: ObstructionComponent = Components.get_component(entity, ObstructionComponent)
		if obstruction_component and obstruction_component.is_obstructing:
			return HoverFlag.OCCUPIED
	
	## OK, no entity here
	if not terrain_map.is_fertile(p):
		return HoverFlag.NOT_FERTILE
	
	## Hmm, seems OK, but it might vary based on what we're trying to do
	return HoverFlag.OK_FOR_PLANTING

#endregion

#region ACTIONS

func return_to_default_state() -> void:
	# Do not leave the default state
	if current_state == default_state:
		return
	
	# Exit old action
	var current_action = cursor_state_dict[current_state]
	current_action.exit(self)
	
	# Enter default action
	var default_action = cursor_state_dict[default_state]
	default_action.enter(self)
	
	# Set current state
	current_state = default_state

func enter_state(state: CursorState) -> void:
	# Do not transition to the same state
	if current_state == state:
		return
	
	# Exit old action
	var current_action = cursor_state_dict[current_state]
	current_action.exit(self)
	
	# Enter new action
	var new_action: CursorAction = cursor_state_dict[state]
	new_action.enter(self)
	
	# Set current state
	current_state = state

## PRIMARY ACTION
## Delegate to primary action
func try_do_primary_action() -> void:
	if attempted_already:
		return
	attempted_already = true
	
	var current_action = cursor_state_dict[current_state]
	current_action.execute_primary_action(self)

## SECONDARY ACTION
## Delegate to secondary action
func try_do_secondary_action() -> void:
	var current_action = cursor_state_dict[current_state]
	current_action.execute_secondary_action(self)

func do_water_bucket_from_god() -> void:
	$CursorExtinguishAction.execute(self)

func get_current_state() -> CursorState:
	return current_state

#endregion

# Munn: Having this here feels wrong
#region ENTITY SELECTION

func set_selected_entity(new_entity: Node2D) -> void:
	currently_selected_entity = new_entity

func get_selected_entity() -> Node2D:
	return currently_selected_entity

#endregion
