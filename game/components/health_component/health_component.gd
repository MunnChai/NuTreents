class_name HealthComponent
extends Node2D

@export var max_health: float
var current_health: float
var is_dead: bool = false

# Cooldown to prevent spamming damage notifications for the same entity.
var _can_show_damage_popup: bool = true
const DAMAGE_POPUP_COOLDOWN: float = 3.0

signal died()
signal health_added(amount: float)
signal health_subtracted(amount: float)

func _ready() -> void:
	current_health = max_health

func increase_max_health(amount: float, increase_current_health: bool = true) -> void:
	max_health += amount
	if increase_current_health:
		current_health += amount

func set_max_health(health: float) -> void:
	max_health = health
	set_current_health(health)

func get_max_health() -> float:
	return max_health

func set_current_health(health: float) -> void:
	current_health = health
	if current_health <= 0:
		current_health = 0
		is_dead = true
		died.emit()
	else:
		is_dead = false

func get_current_health() -> float:
	return current_health

func add_health(amount: float) -> float:
	current_health += amount
	health_added.emit(amount)
	
	if current_health > max_health:
		current_health = max_health
	
	if current_health > 0:
		is_dead = false
	
	return current_health

func subtract_health(amount: float, source: Node = null) -> float:
	current_health -= amount
	health_subtracted.emit(amount)
	
	# --- Notification Logic ---
	var owner = get_parent()
	# Check if the damage source is a valid enemy.
	var is_damage_from_enemy = is_instance_valid(source) and Components.has_component(source, EnemyStatComponent)

	if is_damage_from_enemy:
		# Check if the owner is a non-Mother Tree.
		if Components.has_component(owner, TweeStatComponent):
			var stat_comp = Components.get_component(owner, TweeStatComponent)
			if stat_comp.type != Global.TreeType.MOTHER_TREE:
				# If it is, and the cooldown has passed, show a popup.
				if _can_show_damage_popup:
					_show_damage_notification(owner)
	
	if current_health <= 0:
		current_health = 0
		is_dead = true
		died.emit()
	
	return current_health

## Shows the damage popup and starts the cooldown timer.
func _show_damage_notification(tree_node: Node2D) -> void:
	_can_show_damage_popup = false
	if is_instance_valid(PopupManager):
		PopupManager.create_popup("Tree Under Attack!", tree_node.global_position, Color.CRIMSON)
	
	# Start a timer to re-enable popups for this tree after the cooldown.
	get_tree().create_timer(DAMAGE_POPUP_COOLDOWN).timeout.connect(
		func():
			_can_show_damage_popup = true
	)
