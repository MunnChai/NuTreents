extends Node2D

@onready var animation_player: AnimationPlayer = %AnimationPlayer

var tree_data: Twee

var life_time_seconds := 0.0

const TIME_TO_GROW = 30.0

var is_large := false
var is_dead := false

func _ready() -> void:
	tree_data = DefaultTree.new(2, global_position, 0)
	animation_player.play("grow_small")

func _process(delta: float) -> void:
	life_time_seconds += delta
	
	if life_time_seconds > TIME_TO_GROW:
		if not is_large:
			is_large = true
			animation_player.play("grow_large")
			#tree_data.update()
	
	#if life_time_seconds > 5.0:
		#if not is_dead:
			#is_dead = true
			#animation_player.play("die")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if (anim_name == "grow_small"):
		animation_player.play("small")
	if (anim_name == "grow_large"):
		animation_player.play("large")
	if (anim_name == "die"):
		animation_player.play("stump")

func get_id():
	return tree_data.get_id()
