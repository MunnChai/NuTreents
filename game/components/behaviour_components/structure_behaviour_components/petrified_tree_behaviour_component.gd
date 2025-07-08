class_name PetrifiedTreeBehaviourComponent
extends StructureBehaviourComponent

func _process(delta: float) -> void:
	if sprite_2d.material is ShaderMaterial:
		sprite_2d.material.set_shader_parameter("alpha", get_parent().modulate.a)

func apply_data_resource(save_resource: Resource):
	super.apply_data_resource(save_resource)
	
	var petrified_component = Components.get_component(actor, PetrifiedTreeComponent)
	petrified_component.set_tree_type(save_resource.tree_type)
	
	var tree_acquire_animation_component: TreeAcquireAnimationComponent = Components.get_component(actor, TreeAcquireAnimationComponent)
	tree_acquire_animation_component.set_tree_icon(save_resource.tree_type)
