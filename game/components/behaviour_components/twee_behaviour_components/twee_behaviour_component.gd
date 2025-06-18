class_name TweeBehaviourComponent
extends Node2D

# Components
@export_group("Components")
@export var health_component: HealthComponent
@export var nutreent_production_component: NutreentProductionComponent
@export var water_production_component: WaterProductionComponent
@export var grid_range_component: GridRangeComponent
@export var grid_position_component: GridPositionComponent
@export var hurtbox_component: HurtboxComponent
@export var popup_emitter_component: PopupEmitterComponent
@export var tree_stat_component: TweeStatComponent
@export var tree_animation_component: TweeAnimationComponent
@export var grow_timer: Timer
@export var damage_sound_emitter_component: SoundEmitterComponent
@export var death_sound_emitter_component: SoundEmitterComponent

var actor: Node2D


## State variables
var died: bool
var forest: int # forest id
var marked_for_removal: bool

var is_large := false
var is_growing := false
var is_dehydrated := false

## Stats
var time_to_grow: float

## Seconds spent alive...
## TODO: This might introduce bugs..? Possibly use TIMERS instead
  
# Water stuff...
const BASE_WATER_RANGE = 1
const WATER_DAMAGE_DELAY = 3.0
var water_damage_time := 0.0

const DEHYDRATION_DAMAGE = 2

func _ready():
	actor = get_parent()
	
	
	_get_components()
	_connect_component_signals()

#region Components and Signals

func _get_components() -> void:
	if not health_component:
		health_component = Components.get_component(actor, HealthComponent)
	if not nutreent_production_component:
		nutreent_production_component = Components.get_component(actor, NutreentProductionComponent)
	if not water_production_component:
		water_production_component = Components.get_component(actor, WaterProductionComponent)
	if not grid_range_component:
		grid_range_component = Components.get_component(actor, GridRangeComponent, "GridRangeComponent")
	if not grid_position_component:
		grid_position_component = Components.get_component(actor, GridPositionComponent)
	if not hurtbox_component:
		hurtbox_component = Components.get_component(actor, HurtboxComponent)
	if not popup_emitter_component:
		popup_emitter_component = Components.get_component(actor, PopupEmitterComponent)
	if not tree_stat_component:
		tree_stat_component = Components.get_component(actor, TweeStatComponent)
	if not tree_animation_component:
		tree_animation_component = Components.get_component(actor, TweeAnimationComponent)
	if not grow_timer:
		grow_timer = Components.get_component(actor, Timer, "GrowTimer")
	
	if not damage_sound_emitter_component:
		damage_sound_emitter_component = Components.get_component(actor, SoundEmitterComponent, "DamageSoundEmitterComponent")
	if not death_sound_emitter_component:
		death_sound_emitter_component = Components.get_component(actor, SoundEmitterComponent, "DeathSoundEmitterComponent")

func _connect_component_signals():
	hurtbox_component.hit_taken.connect(health_component.subtract_health)
	
	health_component.health_subtracted.connect(damage_sound_emitter_component.play_sound_effect.unbind(1))
	health_component.health_subtracted.connect(popup_emitter_component.popup_number)
	health_component.health_subtracted.connect(tree_animation_component.play_damage_animation.unbind(1))
	health_component.died.connect(_on_death)
	
	if grow_timer:
		grow_timer.timeout.connect(upgrade_tree)
		grow_timer.one_shot = true
		
		await get_tree().process_frame # Await, stat_component can set grow_timer time
		 
		grow_timer.start()

#endregion

func _process(delta: float) -> void:
	if is_dehydrated:
		grow_timer.paused = true
	else:
		grow_timer.paused = false



## OVERRIDE
func remove() -> void:
	if marked_for_removal:
		return
	marked_for_removal = true
	
	for pos: Vector2i in grid_position_component.get_occupied_positions():
		TreeManager.remove_tree(pos)



#region Getters and Setters

func get_nutrient_gain() -> float:
	return nutreent_production_component.get_nutreent_production()

func get_water_gain() -> float:
	if is_water_adjacent():
		water_production_component.set_water_production(max(0, water_production_component.get_water_production() * 1.5))
	
	return water_production_component.get_water_production()

## Gets the four directly adjacent tiles next to this twee
## Override this if reachable tiles are different
func get_reachable_offsets() -> Array[Vector2i]:
	return grid_range_component.get_tiles_in_range()

func get_occupied_positions() -> Array:
	return grid_position_component.get_occupied_positions()

func apply_data_resource(tree_resource: Resource):
	
	grow_timer.wait_time = tree_resource.life_time_seconds
	is_large = tree_resource.is_large
	
	if is_large:
		tree_stat_component.set_upgraded_stats_from_resource()
	
	health_component.current_health = tree_resource.hp
	
	tree_animation_component.apply_data_resource(tree_resource)

#endregion


#region StateModifiers

func upgrade_tree() -> void:
	if is_large:
		return
	
	is_large = true
	is_growing = true
	tree_animation_component.play_grow_large_animation()
	tree_stat_component.set_upgraded_stats_from_resource()

func _on_death():
	if TreeManager.get_tree_map().has(grid_position_component.get_pos()):
		TreeManager.remove_tree(grid_position_component.get_pos())

func die():
	died = true
	
	death_sound_emitter_component.play_sound_effect()
	
	await tree_animation_component.play_death_animation()
	
	actor.queue_free()

#endregion

func set_forest(f: int):
	forest = f

func is_water_adjacent() -> bool:
	for x in range(-BASE_WATER_RANGE, BASE_WATER_RANGE + 1):
		for y in range(-BASE_WATER_RANGE, BASE_WATER_RANGE + 1):
			var coord: Vector2i = grid_position_component.get_pos() + Vector2i(x, y)
			
			var tile_type: int = Global.terrain_map.get_tile_biome(coord)
			
			if (tile_type == Global.terrain_map.TileType.WATER):
				return true
	
	return false
