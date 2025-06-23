class_name TweeAnimationComponent
extends Node2D

const GREEN_TREE_DIE = preload("res://structures/trees/scenes/death/green_tree_death_vfx.tscn")

## List of sprite sheet variations for this tree, 
## defaults to a randomly chosen sheet at ready time
@export var sheets: Array[Texture2D]

@export var h_frames: int = 9
@export var v_frames: int = 2
@export var small_animation_name: String = "small"
@export var large_animation_name: String = "large"

@export var large_uv_offset: float = 0.1
@export var small_uv_offset: float = 0.62

@export_group("Components")
@export var animation_player: AnimationPlayer
@export var sprite_2d: Sprite2D

var actor: Node2D

signal death_finished

func _ready() -> void:
	actor = get_parent()
	_get_components()
	
	sprite_2d.hframes = h_frames
	sprite_2d.vframes = v_frames
	sprite_2d.position.y = -16
	sprite_2d.texture = sheets.pick_random()
	sprite_2d.material = sprite_2d.material.duplicate()
	
	if animation_player:
		animation_player.connect("animation_finished", _on_animation_player_animation_finished)
		play_grow_small_animation()
	
	(sprite_2d.get_material() as ShaderMaterial).set_shader_parameter("outline_width", 1)

func _get_components() -> void:
	if not animation_player:
		animation_player = Components.get_component(actor, AnimationPlayer)
	if not sprite_2d:
		sprite_2d = Components.get_component(actor, Sprite2D)

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
	if (anim_name == "die"):
		animation_player.play("stump")
	
	if (anim_name == "shoot"):
		play_large_tree_animation()

func play_large_tree_animation():
	animation_player.play(large_animation_name)

func play_small_tree_animation():
	animation_player.play(small_animation_name)

func play_damage_animation() -> void:
	flash_time = FLASH_DURATION
	shake_amount = 30.0

func play_death_animation() -> void:
	flash_time = FLASH_DURATION
	
	if !(!sprite_2d || !sprite_2d.get_material()):
		(sprite_2d.get_material() as ShaderMaterial).set_shader_parameter("flash_amount", flash_amount)
	
	await get_tree().create_timer(FLASH_DURATION).timeout
	
	if animation_player.current_animation == large_animation_name: # Temp fix: Prevent small trees from spawning big tree die vfx
		var death_vfx = GREEN_TREE_DIE.instantiate()
		get_parent().get_parent().add_child(death_vfx) # Munn; So scuffed lol
		death_vfx.global_position = global_position
	
	death_finished.emit()

func play_custom_animation(animation_name: String) -> void:
	animation_player.play(animation_name)



func apply_data_resource(tree_resource: Resource) -> void:
	if tree_resource.is_large:
		play_large_tree_animation()
	else:
		play_small_tree_animation()
	
	sprite_2d.texture = sheets[tree_resource.sheet_id]


#region Shader Stuff

const SHAKE_DECAY_RATE = 15.0
const FLASH_DURATION = 0.1 # In seconds
var flash_time = 0.0
var flash_amount = 0.0
var shake_amount = 0.0

func _process(delta: float) -> void:
	_update_shader(delta)

## Handle animating shader parameters relating to damage
func _update_shader(delta: float) -> void:
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
	(sprite_2d.get_material() as ShaderMaterial).set_shader_parameter("modulate", actor.modulate)
	var grid_position_component: GridPositionComponent = Components.get_component(actor, GridPositionComponent)
	(sprite_2d.get_material() as ShaderMaterial).set_shader_parameter("pos", grid_position_component.get_pos())
	var twee_behaviour_component: TweeBehaviourComponent = Components.get_component(actor, TweeBehaviourComponent)
	(sprite_2d.get_material() as ShaderMaterial).set_shader_parameter("tint_amount", 1.0 if twee_behaviour_component.is_dehydrated else 0.0)

	# UV OFFSET FOR TRUNK DIFFERS BY LOCATION ON SHEET (Short and tall)
	# IF MORE SPRITES ARE ADDED BELOW THE SHEET, BEWARE, MUST TWEAK VALUES!
	(sprite_2d.get_material() as ShaderMaterial).set_shader_parameter("uv_y_offset", get_uv_y_offset())

func get_uv_y_offset() -> float:
	if not animation_player:
		return 0.0
	
	if animation_player.current_animation == "shoot":
		return 1.0
	if animation_player.current_animation == large_animation_name:
		return large_uv_offset
	else:
		return small_uv_offset

#endregion

func get_current_animation() -> String:
	return animation_player.current_animation
