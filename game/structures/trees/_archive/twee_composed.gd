class_name TweeComposed
extends Node2D

# Munn: I'm using this for an easier way to save tree data
@export var type: Global.TreeType

## Elementary stats resource for this tree
@export var tree_stat: TreeStatResource 
## List of sprite sheet variations for this tree, 
## defaults to a randomly chosen sheet at ready time
@export var sheets: Array[Texture2D]

@export_category("Animation")
@export var h_frames: int = 9
@export var v_frames: int = 2
@export var small_animation_name: String = "small"
@export var large_animation_name: String = "large"

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var sprite_2d: Sprite2D = %Sprite2D

# Components
@onready var tooltip_identifier_component: TooltipIdentifierComponent = $TooltipIdentifierComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var obstruction_component: ObstructionComponent = $ObstructionComponent
@onready var nutreent_production_component: NutreentProductionComponent = $NutreentProductionComponent
@onready var water_production_component: WaterProductionComponent = $WaterProductionComponent
@onready var grid_range_component: GridRangeComponent = $GridRangeComponent
@onready var grid_position_component: GridPositionComponent = $GridPositionComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var popup_emitter_component: PopupEmitterComponent = $PopupEmitterComponent

## State variables
var died: bool
var forest: int # forest id
var marked_for_removal: bool

var is_large := false
var is_growing := false

## Stats
var time_to_grow: float

## Seconds spent alive...
## TODO: This might introduce bugs..? Possibly use TIMERS instead
var life_time_seconds := 0.0

# Water stuff...
const BASE_WATER_RANGE = 1
const WATER_DAMAGE_DELAY = 3.0
var water_damage_time := 0.0

const DEHYDRATION_DAMAGE = 2

var occupied_positions: Array[Vector2i]

func _ready():
	set_stats_from_resource(tree_stat)
	
	sprite_2d.hframes = h_frames
	sprite_2d.vframes = v_frames
	sprite_2d.position.y = -16
	# Equally likely... 
	sprite_2d.texture = sheets.pick_random()
	sprite_2d.material = sprite_2d.material.duplicate()
	
	animation_player.connect("animation_finished", _on_animation_player_animation_finished)
	play_grow_small_animation()
	
	(sprite_2d.get_material() as ShaderMaterial).set_shader_parameter("outline_width", 1)
	
	_connect_component_signals()

func _connect_component_signals():
	hurtbox_component.hit_taken.connect(health_component.subtract_health)
	
	health_component.health_subtracted.connect(take_damage)
	health_component.health_subtracted.connect(popup_emitter_component.popup_number)
	health_component.died.connect(_on_death)



func _process(delta: float) -> void:
	if (is_dehydrated):
		return
	
	life_time_seconds += delta
	
	if life_time_seconds > time_to_grow:
		if not is_large:
			upgrade_tree()



## OVERRIDE
func remove() -> void:
	if marked_for_removal:
		return
	marked_for_removal = true
	
	for pos: Vector2i in grid_position_component.get_occupied_positions():
		TreeManager.remove_tree(pos)


#region Shaders

#const FLASH_DECAY_RATE = 50.0
const SHAKE_DECAY_RATE = 15.0
const FLASH_DURATION = 0.1 # In seconds
var flash_time = 0.0
var flash_amount = 0.0
var shake_amount = 0.0
var is_dehydrated = false

## Handle animating shader parameters relating to damage
func _update_shader(delta: float) -> void:
	if died: ## Death handles its own stuff.
		return
	
	if flash_time > 0:
		flash_amount = 1.0
		flash_time -= delta
		flash_time = max(flash_time, 0.0)
	else:
		flash_amount = 0.0
	
	
	if (!sprite_2d || !sprite_2d.get_material()):
		return
	shake_amount = move_toward(shake_amount, 0.0, delta * SHAKE_DECAY_RATE)
	(sprite_2d.get_material() as ShaderMaterial).set_shader_parameter("flash_amount", flash_amount)
	(sprite_2d.get_material() as ShaderMaterial).set_shader_parameter("shake_amount", shake_amount)
	(sprite_2d.get_material() as ShaderMaterial).set_shader_parameter("alpha", modulate.a)
	(sprite_2d.get_material() as ShaderMaterial).set_shader_parameter("pos", grid_position_component.get_pos())
	(sprite_2d.get_material() as ShaderMaterial).set_shader_parameter("tint_amount", 1.0 if is_dehydrated else 0.0)

	# UV OFFSET FOR TRUNK DIFFERS BY LOCATION ON SHEET (Short and tall)
	# IF MORE SPRITES ARE ADDED BELOW THE SHEET, BEWARE, MUST TWEAK VALUES!
	(sprite_2d.get_material() as ShaderMaterial).set_shader_parameter("uv_y_offset", get_uv_y_offset())

func get_uv_y_offset() -> float:
	if is_large:
		return 0.1
	else:
		return 0.62

#endregion


#region Animation

## NOTHING to SMALL
func play_grow_small_animation():
	animation_player.play("grow_small")

## SMALL to LARGE
func play_grow_large_animation():
	animation_player.play("grow_large")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if (anim_name == "grow_small"):
		animation_player.play(small_animation_name)
	if (anim_name == "grow_large"):
		play_large_tree_animation()
		is_growing = false
	if (anim_name == "die"):
		animation_player.play("stump")

func play_large_tree_animation():
	animation_player.play(large_animation_name)

func play_small_tree_animation():
	animation_player.play(small_animation_name)

#endregion


#region Getters and Setters

func get_id():
	return tooltip_identifier_component.id

func set_stats_from_resource(tree_stat: TreeStatResource):
	tooltip_identifier_component.set_id(tree_stat.id)
	health_component.set_max_health(tree_stat.hp)
	water_production_component.set_water_production(tree_stat.gain.y - tree_stat.maint)
	nutreent_production_component.set_nutreent_production(tree_stat.gain.x)
	time_to_grow = tree_stat.time_to_grow

func set_upgraded_stats_from_resource(tree_stat: TreeStatResource):
	tooltip_identifier_component.set_id(tree_stat.id)
	health_component.set_max_health(tree_stat.hp_2)
	water_production_component.set_water_production(tree_stat.gain_2.y - tree_stat.maint_2)
	nutreent_production_component.set_nutreent_production(tree_stat.gain_2.x)
	time_to_grow = tree_stat.time_to_grow_2

func get_nutrient_gain() -> float:
	return nutreent_production_component.get_nutreent_production()

func get_water_gain() -> float:
	if is_water_adjacent():
		water_production_component.set_water_production(max(0, water_production_component.get_water_production()))
	
	return water_production_component.get_water_production()

## Gets the four directly adjacent tiles next to this twee
## Override this if reachable tiles are different
func get_reachable_offsets() -> Array[Vector2i]:
	return grid_range_component.get_tiles_in_range()

func get_occupied_positions() -> Array:
	return grid_position_component.get_occupied_positions()



func apply_data_resource(tree_resource: Resource):
	
	life_time_seconds = tree_resource.life_time_seconds
	is_large = tree_resource.is_large
	
	sprite_2d.texture = sheets[tree_resource.sheet_id]
	
	if (is_large):
		play_large_tree_animation()
		set_upgraded_stats_from_resource(tree_stat)
	else:
		play_small_tree_animation()
		set_stats_from_resource(tree_stat)
	
	health_component.current_health = tree_resource.hp

#endregion


#region StateModifiers

func upgrade_tree() -> void:
	is_large = true
	animation_player.play("grow_large")
	is_growing = true
	set_upgraded_stats_from_resource(tree_stat)

# Returns true if dead
func take_damage(damage: int) -> bool:
	if (died):
		return true
	
	#play sound effect
	SfxManager.play_sound_effect("tree_damage")
	
	flash_time = FLASH_DURATION
	shake_amount = 30.0
	
	return false

const GREEN_TREE_DIE = preload("res://structures/trees/scenes/death/green_tree_death_vfx.tscn")

func _on_death():
	if TreeManager.get_tree_map().has(grid_position_component.get_pos()):
		TreeManager.remove_tree(grid_position_component.get_pos())

func die():
	died = true
	
	SfxManager.play_sound_effect("tree_remove")
	
	flash_amount = 1.0
	
	if !(!sprite_2d || !sprite_2d.get_material()):
		(sprite_2d.get_material() as ShaderMaterial).set_shader_parameter("flash_amount", flash_amount)
	
	await get_tree().create_timer(FLASH_DURATION).timeout
	
	if is_large and !is_growing: # Temp fix: Prevent small trees from spawning big tree die vfx
		var death_vfx = GREEN_TREE_DIE.instantiate()
		get_parent().add_child(death_vfx)
		death_vfx.global_position = global_position
	
	queue_free()

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
