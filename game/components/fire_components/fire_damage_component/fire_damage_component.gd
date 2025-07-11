class_name FireDamageComponent
extends Node2D

## DEALS DAMAGE EVERY FIRE TICK

signal damage_tick

@export var flammable_component: FlammableComponent
@export var health_component: HealthComponent
@export var damage_amount: float = 3.0

func _ready() -> void:
	if not is_instance_valid(flammable_component):
		printerr("FireDamageComponent Error: FlammableComponent is not assigned.")
		return
		
	flammable_component.fire_tick.connect(_on_tick)
	
	if health_component == null:
		health_component = Components.get_component(get_owner(), HealthComponent, "", true)

func _on_tick() -> void:
	if not is_instance_valid(health_component):
		return

	var owner = get_parent()
	var final_damage = damage_amount

	# --- FEATURE IMPLEMENTATION ---
	# Check if the owner is a tree with special vulnerabilities.
	if Components.has_component(owner, TweeStatComponent):
		var stat_comp: TweeStatComponent = Components.get_component(owner, TweeStatComponent)
		
		# Apply extra damage if the tree is an Icy or Slowing tree.
		if stat_comp.type == Global.TreeType.ICY_TREE or stat_comp.type == Global.TreeType.SLOWING_TREE:
			# Apply a 50% damage vulnerability
			final_damage *= 1.5 

	# --- BUG FIX ---
	# The subtract_health function in the active HealthComponent script expects
	# only one argument. The second argument has been removed to fix the crash.
	health_component.subtract_health(final_damage)
	damage_tick.emit()

func increase_damage(amount: float) -> void:
	damage_amount += amount
	
	# NO HEALING
	if damage_amount < 0:
		damage_amount = 0
