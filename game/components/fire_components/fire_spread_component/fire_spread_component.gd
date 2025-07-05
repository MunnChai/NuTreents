class_name FireSpreadComponent
extends Node2D

## HANDLES SPREADING FIRES
## NOTE: Runs its own independent clock from fire tick!

@export var flammable_component: FlammableComponent ## To check if we are on fire!
@export var grid_position_component: GridPositionComponent ## Where are we?
@export var grid_range_component: GridRangeComponent ## This is expressly for how far the fire can spread!

@export var spread_tick_duration: float = 1.0 ## In seconds
@export var chance: float = 0.5 ## Probability of spread

func _ready() -> void:
	flammable_component.ignited.connect(_on_ignition)
	$Timer.timeout.connect(_spread_tick)
	
	if grid_position_component == null:
		grid_position_component = Components.get_component(get_owner(), GridPositionComponent, "", true)
	if grid_range_component == null:
		grid_range_component = Components.get_component(get_owner(), GridRangeComponent, "", true)

## Start the tick timer!
func _on_ignition(fire: Fire) -> void:
	$Timer.start(spread_tick_duration)

## Update tick
func _spread_tick() -> void:
	if not flammable_component.is_on_fire(): ## Fire disappeared in the meantime :(
		return
	## Try to spread
	try_spread()
	$Timer.start(spread_tick_duration)

## Computational arson
func try_spread() -> void:
	var range_options := grid_range_component.get_tiles_in_range()
	
	var lit_something := false
	while not lit_something: ## Loop until we light something or we are out of options
		if range_options.is_empty():
			break
		
		## "Random pop"
		var random_tile: Vector2i = range_options.pick_random()
		range_options.erase(random_tile)
		
		var world_coord := random_tile + grid_position_component.get_pos()
		
		var entity = MapUtility.get_entity_at(world_coord)
		if entity:
			lit_something = try_ignite_entity(entity)

## Go through checks for setting entity on fire
func try_ignite_entity(entity: Node2D) -> bool:
	if Components.has_component(entity, FlammableComponent, "", true):
		var flammable: FlammableComponent = Components.get_component(entity, FlammableComponent, "", true)
		if flammable != self:
			if randf() < chance:
				flammable.ignite()
			return true
	return false
