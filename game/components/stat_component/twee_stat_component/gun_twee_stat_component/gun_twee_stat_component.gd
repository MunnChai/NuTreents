class_name GunTweeStatComponent
extends TweeStatComponent

@export var projectile_spawner_component: ProjectileSpawnerComponent
@export var action_timer: Timer
@export var attack_range_component: GridRangeComponent

func _ready() -> void:
	actor = get_parent()
	
	_get_components()
	set_stats_from_resource()

func _get_components() -> void:
	super._get_components()
	
	if not projectile_spawner_component:
		projectile_spawner_component = Components.get_component(actor, ProjectileSpawnerComponent)
	if not action_timer:
		action_timer = Components.get_component(actor, Timer, "ActionTimer")
	if not attack_range_component:
		attack_range_component = Components.get_component(actor, GridRangeComponent, "AttackRangeComponent")

func set_stats_from_resource(resource: StatResource = stat_resource) -> void:
	super.set_stats_from_resource(resource)
	
	projectile_spawner_component.set_damage(resource.attack_damage)
	action_timer.wait_time = resource.attack_cooldown
	attack_range_component.range = resource.attack_range

func set_upgraded_stats_from_resource(resource: StatResource = stat_resource) -> void:
	super.set_upgraded_stats_from_resource(resource)
	
	projectile_spawner_component.set_damage(resource.attack_damage_2)
	action_timer.wait_time = resource.attack_cooldown_2
	attack_range_component.range = resource.attack_range_2
	print("Set Range to: ", attack_range_component.range)
