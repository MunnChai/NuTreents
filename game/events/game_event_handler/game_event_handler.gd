extends Node

## This global singleton listens for game events (like an entity taking damage)
## and triggers appropriate responses (like UI notifications).
## This decouples the core components from specific game rules.

# A dictionary to track notification cooldowns for each entity instance.
var _notification_cooldowns := {}
const DAMAGE_POPUP_COOLDOWN: float = 3.0 # Seconds

func _ready() -> void:
	# We need to know when a tree is placed to connect to its health component's signal.
	TreeManager.tree_placed.connect(_on_tree_placed)

## When a tree is placed, connect its HealthComponent's "damaged" signal to our handler.
func _on_tree_placed(tree: Node2D) -> void:
	if Components.has_component(tree, HealthComponent):
		var health_comp: HealthComponent = Components.get_component(tree, HealthComponent)
		# Connect the new 'damaged' signal to our handler function.
		health_comp.damaged.connect(_on_entity_damaged)

## This function runs whenever ANY HealthComponent emits the "damaged" signal.
func _on_entity_damaged(amount: float, source: Node, owner: Node2D) -> void:
	# --- Game Rule Logic ---
	# This is where we check the specific conditions for showing a notification.

	# 1. Is the damage from a valid enemy?
	if not is_instance_valid(source) or not Components.has_component(source, EnemyStatComponent):
		return # If not, we don't care.

	# 2. Is the entity that took damage a tree?
	if not Components.has_component(owner, TweeStatComponent):
		return # If not, we don't care.

	# 3. Is it the Mother Tree?
	# --- BUG FIX ---
	# Added an explicit type hint to prevent the "inferred as Variant" error.
	var stat_comp: TweeStatComponent = Components.get_component(owner, TweeStatComponent)
	if stat_comp.type == Global.TreeType.MOTHER_TREE:
		return # We don't show notifications for the Mother Tree.

	# 4. Is the notification for this specific tree on cooldown?
	var owner_id = owner.get_instance_id()
	if _notification_cooldowns.has(owner_id):
		return # If it's on cooldown, do nothing.

	# All checks passed! Show the notification and start the cooldown.
	if is_instance_valid(PopupManager):
		PopupManager.create_popup("Tree Under Attack!", owner.global_position, Color.CRIMSON)
	
	_notification_cooldowns[owner_id] = true
	get_tree().create_timer(DAMAGE_POPUP_COOLDOWN).timeout.connect(
		func():
			_notification_cooldowns.erase(owner_id)
	)
