class_name IsometricCursor
extends Marker2D

## ISOMETRIC CURSOR
## The data representation/operations for the cursor in world space...

enum CursorState {
	SELECT = 0,
	PLANT = SELECT + 1,
	DESTROY = PLANT + 1,
	EXTINGUISH = DESTROY + 1,
}

signal just_moved(old_pos: Vector2i, new_pos: Vector2i)
signal selected_entity_changed(old_entity: Node2D, new_entity: Node2D)

@export var default_state: CursorState
@export var cursor_state_dict: Dictionary[CursorState, CursorAction]

var is_enabled := true
var iso_position: Vector2i
var attempted_already := false

static var instance: IsometricCursor
var current_state: CursorState
var currently_selected_entity: Node2D:
	set(new_entity):
		var old_entity = currently_selected_entity
		currently_selected_entity = new_entity
		selected_entity_changed.emit(old_entity, new_entity)

func _ready() -> void:
	instance = self
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

func can_interact() -> bool:
	return is_enabled

#region MOVEMENT
func move_to(local_world_pos: Vector2) -> void:
	set_iso_position(Global.terrain_map.local_to_map(local_world_pos))

func set_iso_position(new_iso_pos: Vector2i) -> void:
	var old_pos = iso_position
	iso_position = new_iso_pos
	if old_pos != new_iso_pos:
		just_moved.emit(old_pos, new_iso_pos)
#endregion

#region HOVER FLAG

# --- REFACTORED ---
# Added new, more descriptive flags for destructible objects and concrete.
enum HoverFlag {
	VOID,
	TOO_FAR_AWAY,
	OBSCURED,
	OCCUPIED, # For non-destructible obstructions like friendly trees
	NOT_FERTILE,
	OK_FOR_PLANTING,
	DESTRUCTIBLE, # For destructible buildings/entities
	CONCRETE,     # For destructible city/road tiles
}

## Supplies one of the above HoverFlags based on the context.
func get_hover_flag(p: Vector2i = iso_position) -> HoverFlag:
	var terrain_map := Global.terrain_map
	
	if terrain_map.is_void(p): return HoverFlag.VOID
	if Global.fog_map.is_tile_foggy(p): return HoverFlag.OBSCURED
	if not TreeManager.is_reachable(p, true): return HoverFlag.TOO_FAR_AWAY
	
	var entity = MapUtility.get_entity_at(p)
	if entity:
		# --- REFACTORED LOGIC ---
		# If the entity is destructible, return the specific DESTRUCTIBLE flag.
		if Components.has_component(entity, DestructableComponent):
			return HoverFlag.DESTRUCTIBLE
		# Otherwise, if it's just a normal obstruction, return OCCUPIED.
		var obstruction_comp: ObstructionComponent = Components.get_component(entity, ObstructionComponent)
		if obstruction_comp and obstruction_comp.is_obstructing:
			return HoverFlag.OCCUPIED
	
	# If there's no entity, check the tile itself.
	if terrain_map.is_concrete(p):
		return HoverFlag.CONCRETE
	if not terrain_map.is_fertile(p):
		return HoverFlag.NOT_FERTILE
	
	return HoverFlag.OK_FOR_PLANTING
#endregion

#region ACTIONS
func return_to_default_state() -> void:
	if current_state == default_state: return
	var current_action = cursor_state_dict[current_state]
	current_action.exit(self)
	var default_action = cursor_state_dict[default_state]
	default_action.enter(self)
	current_state = default_state

func enter_state(state: CursorState) -> void:
	if current_state == state: return
	if current_state in cursor_state_dict:
		cursor_state_dict[current_state].exit(self)
	if state in cursor_state_dict:
		cursor_state_dict[state].enter(self)
	current_state = state

func try_do_primary_action() -> void:
	if attempted_already: return
	attempted_already = true
	cursor_state_dict[current_state].execute_primary_action(self)

func try_do_secondary_action() -> void:
	cursor_state_dict[current_state].execute_secondary_action(self)

func do_water_bucket_from_god() -> void:
	$CursorExtinguishAction.execute(self)

func get_current_state() -> CursorState:
	return current_state
#endregion

#region ENTITY SELECTION
func set_selected_entity(new_entity: Node2D) -> void:
	currently_selected_entity = new_entity

func get_selected_entity() -> Node2D:
	return currently_selected_entity
#endregion
