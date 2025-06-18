class_name FireSpreadComponent
extends Node2D

## Handles spreading fires

@export var flammable_component: FlammableComponent ## To check if we are on fire!
@export var grid_position_component: GridPositionComponent ## Where are we?
@export var grid_range_component: GridRangeComponent ## This is expressly for how far the fire can spread!

@export var fire_spread_increment: float = 1.0 ## In seconds

func _ready() -> void:
	flammable_component.ignited.connect(_on_ignition)
	$Timer.timeout.connect(_spread_tick)

func _on_ignition(fire: Fire) -> void:
	$Timer.start(fire_spread_increment) # Test value

## Concern for stack overflow?
func _spread_tick() -> void:
	if not flammable_component.is_on_fire(): ## Fire disappeared in the meantime :(
		return
	## Try to spread
	try_spread()
	$Timer.start(fire_spread_increment)

@onready var rng := RandomNumberGenerator.new()

## Computational arson
func try_spread() -> void:
	var range_options := grid_range_component.get_tiles_in_range()
	
	#var random := rng.randi_range(0, 100)
	#if random > 50: # 50% chance to just not do anything
		#return
	
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
			if Components.has_component(entity, FlammableComponent):
				var flammable: FlammableComponent = Components.get_component(entity, FlammableComponent)
				if flammable != self:
					flammable.ignite()
					lit_something = true
