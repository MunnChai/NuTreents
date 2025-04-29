class_name GunTree
extends Twee

const TREE_BULLET = preload("res://structures/trees/projectiles/tree_bullet.tscn")
const BULLET_SPEED = 200

const ATTACK_FREQUENCY = 1

var damage: int = 6
var attack_range: int = 5
var attack_cooldown: float = 0

var current_target_enemy: Enemy

func _ready():
	super._ready()
	
	id = "gun_tree"
	
	sprite.hframes = 9
	sprite.vframes = 3
	sprite.position.y = -16

func _process(delta: float) -> void:
	life_time_seconds += delta
	
	if life_time_seconds > time_to_grow:
		if not is_large:
			upgrade_tree()
	
	# Check for enemies in range
	if (!current_target_enemy || current_target_enemy.is_dead):
		check_attack_range()
	
	# If none were found, don't shoot
	if (!current_target_enemy):
		attack_cooldown = 0
		return
	
	attack_cooldown -= delta
	if (attack_cooldown <= 0):
		attack_cooldown = ATTACK_FREQUENCY
		attack_nearest_enemy()

func check_attack_range():
	for enemy: Enemy in get_tree().get_nodes_in_group("enemies"):
			if (enemy.is_dead):
				continue
			
			var dist_to_enemy = get_taxicab_distance(get_pos(), enemy.map_position)
			
			if (dist_to_enemy <= attack_range):
				current_target_enemy = enemy
				break

func attack_nearest_enemy():
	attack_enemy(current_target_enemy)

func attack_enemy(enemy: Enemy):
	if (enemy.is_dead):
		return
	
	if is_large:
		animation_player.play("shoot")
		current_target_enemy = enemy

func spawn_bullet():
	if (!current_target_enemy || current_target_enemy.is_dead):
		return
	var bullet = TREE_BULLET.instantiate()
	bullet.enemy = current_target_enemy
	bullet.damage = damage
	add_child(bullet)
	bullet.global_position = global_position + Vector2(0, -32)
	
	#call sound effect
	SfxManager.play_sound_effect("gun_tree_projectile")

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

func get_uv_y_offset() -> float:
	if is_large:
		if animation_player.current_animation.get_basename() == "shoot":
			return 1.0
		else:
			return 0.45
	else:
		return 0.75
