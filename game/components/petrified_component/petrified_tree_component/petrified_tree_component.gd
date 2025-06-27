class_name PetrifiedTreeComponent
extends PetrifiedComponent

@export var tree_type: Global.TreeType
@export var grid_position_component: GridPositionComponent
@export var destructable_component: DestructableComponent

@onready var depetrify_particles: GPUParticles2D = $"../DepetrifyParticles"

func _get_components() -> void:
	super._get_components()
	
	if not grid_position_component:
		grid_position_component = Components.get_component(actor, GridPositionComponent)
	if not destructable_component: 
		destructable_component = Components.get_component(actor, DestructableComponent)

func _connect_signals() -> void:
	destructable_component.cost_to_destroy = TreeRegistry.get_twee_stat(tree_type).cost_to_purchase
	
	destructable_component.destroyed.connect(depetrify)

func set_tree_type(type: Global.TreeType) -> void:
	tree_type = type
	_set_sprite_textures()

func _set_sprite_textures() -> void:
	var tree_texture: TreeStatResource = TreeRegistry.get_twee_stat(tree_type)
	
	petrified_sprite_2d.texture = tree_texture.tree_icon
	
	sprite_shatter_component.set_sprite_to_copy(petrified_sprite_2d)
	sprite_shatter_component.create_shatter_pieces()

func depetrify() -> void:
	# Play sprite shattering effect
	super.depetrify()
	
	# Wait for animation to finish
	await sprite_shatter_component.shatter_finished
	
	# Begin reparenting sprite_shatter_component to new tree
	sprite_shatter_component.get_parent().remove_child(sprite_shatter_component)
	get_parent().remove_child(depetrify_particles)
	
	# Remove self from map
	Global.structure_map.remove_structure(grid_position_component.get_pos())
	
	# Add new tree to map
	var new_twee: Node2D = TreeRegistry.get_new_twee(tree_type)
	TreeManager.place_tree(new_twee, grid_position_component.get_pos())
	
	# Complete reparenting
	new_twee.add_child(sprite_shatter_component)
	new_twee.add_child(depetrify_particles)
	depetrify_particles.emitting = true
	
	# Force grow tree
	var twee_behaviour_component: TweeBehaviourComponent = Components.get_component(new_twee, TweeBehaviourComponent)
	twee_behaviour_component.upgrade_tree()
	
	# Override growing animation
	var twee_animation_component: TweeAnimationComponent = Components.get_component(new_twee, TweeAnimationComponent)
	twee_animation_component.play_large_tree_animation()
	
	
