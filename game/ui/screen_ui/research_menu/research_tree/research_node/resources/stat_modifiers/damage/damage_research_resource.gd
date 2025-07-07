class_name DamageResearchResource
extends ResearchNodeResource

@export var damage_increase: int = 1

func apply_research(node: Node2D) -> void:
	super.apply_research(node)
	
	var hitbox_component: HitboxComponent = Components.get_component(node, HitboxComponent)
	if hitbox_component:
		hitbox_component.increase_damage(damage_increase)
	
	var projectile_spawner_component: ProjectileSpawnerComponent = Components.get_component(node, ProjectileSpawnerComponent)
	if projectile_spawner_component:
		projectile_spawner_component.increase_damage(damage_increase)
