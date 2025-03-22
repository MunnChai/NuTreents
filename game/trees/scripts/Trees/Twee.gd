extends Structure
class_name Twee

const TREE_DAMAGE_SHADER = preload("res://trees/tree_damage.gdshader")

@export var tree_stat: TreeStatResource 
@export var sheets: Array[Texture2D]
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var sprite: Sprite2D = %Sprite2D

# State variables
var died: bool
var attackable: bool
var forest: int # forest id
var storage: int # Current water amount

# Stats
var hp: float
var max_water: int
var gain: Vector3
var maint: int
var time_to_grow: float

var life_time_seconds := 0.0

var is_adjacent_to_water: bool = false
var water_bonus: int = 3
const BASE_WATER_RANGE = 1


#const TIME_TO_GROW = 5.0

var is_large := false
var is_growing := false

func _ready():
	get_stats_from_resource(tree_stat)
	
	
	sprite.hframes = 9
	sprite.vframes = 2
	sprite.position.y = -16
	# Equally likely... 
	sprite.texture = sheets.pick_random()
	sprite.material = sprite.material.duplicate()
	
	animation_player.connect("animation_finished", _on_animation_player_animation_finished)
	play_grow_small_animation()
	
	is_adjacent_to_water = is_water_adjacent()
	gain.y = get_water_gain()

func _process(delta: float) -> void:
	life_time_seconds += delta
	
	#print(animation_player.current_animation)
	
	if life_time_seconds > time_to_grow:
		if not is_large:
			upgrade_tree()
			#tree_data.update()



#const FLASH_DECAY_RATE = 50.0
const SHAKE_DECAY_RATE = 35.0
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
	
	
	if (!sprite || !sprite.get_material()):
		return
	shake_amount = move_toward(shake_amount, 0.0, delta * SHAKE_DECAY_RATE)
	(sprite.get_material() as ShaderMaterial).set_shader_parameter("flash_amount", flash_amount)
	(sprite.get_material() as ShaderMaterial).set_shader_parameter("shake_amount", shake_amount)
	(sprite.get_material() as ShaderMaterial).set_shader_parameter("alpha", modulate.a)
	(sprite.get_material() as ShaderMaterial).set_shader_parameter("pos", pos)
	(sprite.get_material() as ShaderMaterial).set_shader_parameter("dehydrated", is_dehydrated)
	#print(is_dehydrated)

	# UV OFFSET FOR TRUNK DIFFERS BY LOCATION ON SHEET (Short and tall)
	# IF MORE SPRITES ARE ADDED BELOW THE SHEET, BEWARE, MUST TWEAK VALUES!
	if is_large:
		(sprite.get_material() as ShaderMaterial).set_shader_parameter("uv_y_offset", 0.1)
	else:
		(sprite.get_material() as ShaderMaterial).set_shader_parameter("uv_y_offset", 0.62)


## NOTHING to SMALL
func play_grow_small_animation():
	animation_player.play("grow_small")

## SMALL to LARGE
func play_grow_large_animation():
	animation_player.play("grow_large")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if (anim_name == "grow_small"):
		animation_player.play("small")
	if (anim_name == "grow_large"):
		play_large_tree_animation()
		is_growing = false
	if (anim_name == "die"):
		animation_player.play("stump")

func play_large_tree_animation():
	animation_player.play("large")

func get_id():
	return id

func get_stats_from_resource(tree_stat: TreeStatResource):
	hp = tree_stat.hp
	max_water = tree_stat.max_water
	gain = tree_stat.gain
	maint = tree_stat.maint
	time_to_grow = tree_stat.time_to_grow

func get_upgraded_stats_from_resource(tree_stat: TreeStatResource):
	hp = tree_stat.hp_2
	max_water = tree_stat.max_water_2
	gain = tree_stat.gain_2
	maint = tree_stat.maint_2
	time_to_grow = tree_stat.time_to_grow_2

func initialize(p: Vector2i, f: int):
	died = false
	attackable = true
	forest = f
	init_pos(p)

const GREEN_TREE_DIE = preload("res://trees/scenes/death/GreenTreeDie.tscn")

func die():
	died = true
	#TreeManager.remove_tree(pos)
	flash_amount = 1.0
	(sprite.get_material() as ShaderMaterial).set_shader_parameter("flash_amount", flash_amount)
	
	await get_tree().create_timer(FLASH_DURATION).timeout
	
	if is_large and !is_growing: # Temp fix: Prevent small trees from spawning big tree die vfx
		var death_vfx = GREEN_TREE_DIE.instantiate()
		get_parent().add_child(death_vfx)
		death_vfx.global_position = global_position
		#queue_free()
	
	queue_free()
	
	#animation_player.play("die")
	#animation_player.animation_finished.connect(
		#func(animation_name):
			#queue_free()
	#)

const WATER_DAMAGE_DELAY = 3.0
var water_damage_time := 0.0

const DEHYDRATION_DAMAGE = 2

## update local storage and use water for maintainence
## returns the right amount of res to system
func update(delta: float) -> Vector3:
	var prev = storage # record old storage number

	# add new water to storage, storage equals at most max_water
	storage = min(storage + gain.y, max_water)
	
	var g = Vector3(gain.x, storage - prev, gain.z)
	return g

func update_maint():
	# TODO
	return

## Gets the four directly adjacent tiles next to this twee
## Override this if reachable tiles are different
func get_reachable_offsets() -> Array[Vector2i]:
	return [Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.LEFT]

# Returns true if dead
func take_damage(damage: int) -> bool:
	if (died):
		return true
	
	hp -= damage
	print(pos, " taking damage ", damage)
	print(hp)
	if (hp <= 0 and TreeManager.get_tree_map()[pos]):
		TreeManager.remove_tree(pos)
		print("remove mother tree")
		return true
	#else:
		#animation_player.play("hurt")
	
	# VISUAL: SET AMOUNTS FOR FLASH & SHAKE
	flash_time = FLASH_DURATION
	shake_amount = 20.0
	
	return false


func upgrade_tree() -> void:
	is_large = true
	animation_player.play("grow_large")
	is_growing = true
	get_upgraded_stats_from_resource(tree_stat)



func get_water_gain():
	if (!is_adjacent_to_water):
		return tree_stat.gain.y
	else:
		return tree_stat.gain.y * 1.5

func is_water_adjacent() -> bool:
	for x in range(-BASE_WATER_RANGE, BASE_WATER_RANGE + 1):
		for y in range(-BASE_WATER_RANGE, BASE_WATER_RANGE + 1):
			var coord: Vector2i = pos + Vector2i(x, y)
			
			var tile_type: int = Global.terrain_map.get_tile_biome(coord)
			
			if (tile_type == Global.terrain_map.TILE_TYPE.WATER):
				return true
	
	return false
