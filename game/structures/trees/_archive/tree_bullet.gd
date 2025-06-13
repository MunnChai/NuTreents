extends Node2D

const ARC_HEIGHT: float = 32
const BULLET_DURATION: float = 0.5
const SPEED: float = 128
const CONTACT_DIST: float = 16

@onready var sprite_2d = $Sprite2D

var enemy: Enemy
var damage: int

func _ready():
	y_sort_enabled = true
	begin_tween()
	
	var timer = get_tree().create_timer(BULLET_DURATION)
	timer.timeout.connect(end_bullet_life)

func _process(delta: float) -> void:
	if (!enemy):
		return
	
	global_position = lerp(global_position, enemy.global_position, 2 * delta / BULLET_DURATION)
	
	var sprite_distance = (enemy.global_position - sprite_2d.global_position).length()
	
	if (sprite_distance < CONTACT_DIST):
		end_bullet_life()

func begin_tween():
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT) 
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite_2d, "position:y", -ARC_HEIGHT, BULLET_DURATION / 2)
	tween.set_ease(Tween.EASE_IN) 
	tween.tween_property(sprite_2d, "position:y", 0, BULLET_DURATION / 2)

func end_bullet_life() -> void:
	enemy.take_damage(damage)
	queue_free()
