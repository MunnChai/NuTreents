extends Structure
class_name Twee

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
var hp: int
var max_water: int
var gain: Vector3
var maint: int
var time_to_grow: float

var life_time_seconds := 0.0

const TIME_TO_GROW = 5.0

var is_large := false

func _ready():
	get_stats_from_resource(tree_stat)
	
	# Equally likely...
	sprite.texture = sheets.pick_random()
	sprite.hframes = 9
	sprite.vframes = 2
	
	animation_player.connect("animation_finished", _on_animation_player_animation_finished)
	play_grow_small_animation()

func _process(delta: float) -> void:
	life_time_seconds += delta
	
	print(animation_player.current_animation)
	
	if life_time_seconds > TIME_TO_GROW:
		if not is_large:
			is_large = true
			play_grow_large_animation()
			#tree_data.update()

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
		animation_player.play("large")
	if (anim_name == "die"):
		animation_player.play("stump")

func get_id():
	return id

func get_stats_from_resource(tree_stat: TreeStatResource):
	hp = tree_stat.hp
	max_water = tree_stat.max_water
	gain = tree_stat.gain
	maint = tree_stat.maint
	time_to_grow = tree_stat.time_to_grow

func get_upgrades_stats_from_resource(tree_stat: TreeStatResource):
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


func die():
	died = true
	#TreeManager.tree_die(pos)
	
## update local storage and use water for maintainence
## returns the right amount of res to system
func update() -> Vector3:
	var prev = storage # record old storage number
	
	# add new water to storage, storage equals at most max_water
	storage = min(storage + gain.y, max_water)
	
	# take maint from storage
	if (storage >= maint):
		storage -= maint
	else:
		var f: Forest = TreeManager.get_forest(forest)
		if (!f.get_water(maint - storage)):
			# if game doesn't have enough water either
			hp -= 2
		else:
			# game has enough water
			storage = 0
	if (hp <= 0):
		die()
	var g = Vector3(gain.x, storage - prev, gain.z)
	return g

func update_maint():
	# TODO
	return

## Gets the four directly adjacent tiles next to this twee
## Override this if reachable tiles are different
func get_reachable_offsets() -> Array[Vector2i]:
	return [Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.LEFT]
