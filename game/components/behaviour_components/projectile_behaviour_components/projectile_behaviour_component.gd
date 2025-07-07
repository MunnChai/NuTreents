class_name ProjectileBehaviourComponent
extends Node2D

@export var removal_timer: Timer
@export var hitbox_component: HitboxComponent

var actor: Node2D

func _ready() -> void:
	actor = get_owner()
	
	_get_components()
	_connect_signals()
	
	if hitbox_component:
		hitbox_component.monitoring = false
		hitbox_component.monitorable = false
		await get_tree().create_timer(removal_timer.wait_time - 0.1).timeout
		hitbox_component.monitoring = true
		hitbox_component.monitorable = false

func _get_components() -> void:
	if not removal_timer:
		removal_timer = Components.get_component(actor, Timer, "RemovalTimer")
	if not hitbox_component:
		hitbox_component = Components.get_component(actor, HitboxComponent, "", true)

func _connect_signals() -> void:
	# Disable projectile after it hits something
	hitbox_component.hit_entity.connect(hitbox_component.disable.unbind(1))
