class_name EnemyStatComponent
extends StatComponent

@export var tooltip_identifier_component: TooltipIdentifierComponent
@export var health_component: HealthComponent
@export var hitbox_component: HitboxComponent
@export var grid_range_component: GridRangeComponent
@export var action_timer: Timer

func _ready() -> void:
	var actor: Node2D = get_parent()
	
	if not tooltip_identifier_component:
		tooltip_identifier_component = Components.get_component(actor, TooltipIdentifierComponent)
	if not health_component:
		health_component = Components.get_component(actor, HealthComponent)
	if not hitbox_component:
		hitbox_component = Components.get_component(actor, HitboxComponent)
	if not grid_range_component:
		grid_range_component = Components.get_component(actor, GridRangeComponent)
	if not action_timer:
		action_timer = Components.get_component(actor, Timer)

func set_stats_from_resource(resource: StatResource = stat_resource) -> void:
	health_component.set_max_health(resource.hp)
	hitbox_component.damage = resource.attack_damage
	grid_range_component.range = resource.attack_range
	action_timer.wait_time = resource.action_cooldown
