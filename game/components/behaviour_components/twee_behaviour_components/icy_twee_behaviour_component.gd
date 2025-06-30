class_name IcyTweeBehaviourComponent
extends TweeBehaviourComponent

func upgrade_tree() -> void:
	super.upgrade_tree()
	
	var hitbox_component: HitboxComponent = Components.get_component(actor, HitboxComponent)
	var status_inflictor: StatusInflictorComponent = Components.get_component(actor, StatusInflictorComponent)
	hitbox_component.hit_entity.connect(status_inflictor.apply_status_effect)
