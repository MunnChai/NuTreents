class_name TweeBehaviourComponent
extends Node2D

signal grew_up

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
@export var sound_loop_component: SoundLoopComponent

var actor: Node2D

## State variables
var forest: int # forest id
var marked_for_removal: bool

var is_large := false

var is_dehydrated := false
const BASE_WATER_RANGE = 1
const WATER_DAMAGE_DELAY = 3.0
var water_damage_time := 0.0

const DEHYDRATION_DAMAGE = 2

func _ready():
	actor = get_parent()
	
	_get_components()
	
	# Randomize water damage time
	water_damage_time += RandomNumberGenerator.new().randf_range(WATER_DAMAGE_DELAY, WATER_DAMAGE_DELAY * 2)
	
	call_deferred("_set_stats")
	call_deferred("_connect_component_signals")

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
	# --- REFACTORED ---
	# The hurtbox now calls a local function, which then calls the HealthComponent
	# with the correct damage source information.
	hurtbox_component.hit_taken.connect(_on_hit_taken)
	
	# The other components now connect to the new 'damaged' signal.
	# We use .unbind() to discard the extra arguments they don't need.
	health_component.damaged.connect(damage_sound_emitter_component.play_sound_effect.unbind(1).unbind(1))
	health_component.damaged.connect(popup_emitter_component.popup_number.unbind(1).unbind(1))
	health_component.damaged.connect(tree_animation_component.play_damage_animation.unbind(1).unbind(1))
	health_component.died.connect(die)
	
	if grow_timer:
		grow_timer.timeout.connect(upgrade_tree)
		grow_timer.one_shot = true
		
		await get_tree().process_frame
		
		grow_timer.start()

# --- NEW FUNCTION ---
# This function intercepts the hit, finds the damage source, and passes it along.
func _on_hit_taken(damage: float, hitbox: HitboxComponent) -> void:
	var source = null
	if is_instance_valid(hitbox):
		source = hitbox.get_owner()
	health_component.subtract_health(damage, source)

func _set_stats() -> void:
	if is_large:
		tree_stat_component.set_upgraded_stats_from_resource()
	else:
		tree_stat_component.set_stats_from_resource()

#endregion

func _process(delta: float) -> void:
	if is_dehydrated:
		grow_timer.paused = true
		
		while (water_damage_time > WATER_DAMAGE_DELAY):
			# Dehydration damage has no source, so we pass null.
			health_component.subtract_health(DEHYDRATION_DAMAGE, null)
			water_damage_time -= RandomNumberGenerator.new().randf_range(WATER_DAMAGE_DELAY, WATER_DAMAGE_DELAY * 2)
		water_damage_time += delta
	else:
		grow_timer.paused = false

#region StateModifiers

func upgrade_tree() -> void:
	if is_large:
		return
	
	is_large = true
	grew_up.emit()
	
	tree_animation_component.play_grow_large_animation()
	tree_stat_component.set_upgraded_stats_from_resource()
	
	if sound_loop_component:
		sound_loop_component.start()

func die():
	# Do extra death stuff here... maybe tree death counter...
	remove()

## Frees self, and calls TreeManager.remove_tree() to remove self from tree_map, structure_map, forests, etc.
func remove() -> void:
	death_sound_emitter_component.play_sound_effect()
	tree_animation_component.play_death_animation()
	
	await tree_animation_component.death_finished
	
	TreeManager.remove_tree(grid_position_component.get_pos())
	actor.queue_free()

#endregion

# Applies a save resource to this tree
func apply_data_resource(tree_resource: Resource):
	
	if tree_resource.life_time_seconds > 0:
		grow_timer.wait_time = tree_resource.life_time_seconds
	is_large = tree_resource.is_large
	
	_set_stats()
	if is_large:
		upgrade_tree()
	
	health_component.set_current_health(tree_resource.hp)
	
	tree_animation_component.apply_data_resource(tree_resource)
	
	## LOAD FIRE DATA
	if tree_resource.is_on_fire:
		var flammable: FlammableComponent = Components.get_component(actor, FlammableComponent, "", true)
		if flammable:
			flammable.ignite()
			flammable.get_fire().start_lifetime(tree_resource.remaining_fire_lifetime)

# For forests...
func set_forest(f: int):
	forest = f
