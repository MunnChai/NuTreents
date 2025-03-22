class_name GunTree
extends Twee

const TREE_BULLET = preload("res://trees/scenes/TreeBullet.tscn")
const BULLET_SPEED = 200

const ATTACK_FREQUENCY = 1

var damage: int = 3
var attack_range: int = 5
var attack_cooldown: float = 0

func _ready():
	super._ready()
	
	sprite.hframes = 9
	sprite.vframes = 3
	sprite.position.y = -16

func _process(delta: float) -> void:
	life_time_seconds += delta
	
	if life_time_seconds > time_to_grow:
		if not is_large:
			upgrade_tree()
	
	attack_cooldown -= delta
	if (attack_cooldown <= 0):
		attack_cooldown = ATTACK_FREQUENCY
		attack_nearest_enemy()

func attack_nearest_enemy():
	for enemy: Enemy in get_tree().get_nodes_in_group("enemies"):
		if (enemy.is_dead):
			continue
		
		var dist_to_enemy = get_taxicab_distance(pos, enemy.map_position)
		
		if (dist_to_enemy <= attack_range):
			attack_enemy(enemy)
			return

func attack_enemy(enemy: Enemy):
	if is_large:
		animation_player.play("shoot")
	
	var bullet = TREE_BULLET.instantiate()
	add_child(bullet)
	bullet.global_position = global_position
	
	var distance = (enemy.global_position - global_position).length()
	
	var bullet_tween = get_tree().create_tween()
	bullet_tween.set_ease(Tween.EASE_OUT)
	bullet_tween.set_trans(Tween.TRANS_CUBIC)
	bullet_tween.tween_property(bullet, "global_position", enemy.global_position, distance / BULLET_SPEED)
	
	bullet_tween.finished.connect(
		func():
			deal_damage(enemy)
			bullet.queue_free()
	)

func get_taxicab_distance(pos_i: Vector2i, pos_j: Vector2i) -> int:
	return abs(pos_i.x - pos_j.x) + abs(pos_i.y - pos_j.y)


func deal_damage(enemy: Enemy):
	if (!enemy):
		return
	
	enemy.take_damage(damage)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	super._on_animation_player_animation_finished(anim_name)
	if (anim_name == "shoot"):
		play_large_tree_animation()

func upgrade_tree():
	super.upgrade_tree()
	damage = 6 # TODO: Make a better way set damage values (resource, dictionary, etc.)
