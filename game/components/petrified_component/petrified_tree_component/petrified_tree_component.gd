class_name PetrifiedTreeComponent
extends PetrifiedComponent

@export var tree_type: Global.TreeType
@export var grid_position_component: GridPositionComponent
@export var destructable_component: DestructableComponent
@export var tree_acquire_animation: TreeAcquireAnimationComponent

@onready var depetrify_particles: GPUParticles2D = $"../DepetrifyParticles"

func _get_components() -> void:
	super._get_components()
	
	if not grid_position_component:
		grid_position_component = Components.get_component(actor, GridPositionComponent)
	if not destructable_component: 
		destructable_component = Components.get_component(actor, DestructableComponent)
	if not tree_acquire_animation:
		tree_acquire_animation = Components.get_component(actor, TreeAcquireAnimationComponent)

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
	if depetrified:
		return
	
	# Play sprite shattering effect
	super.depetrify()
	
	# Wait for animation to finish
	await sprite_shatter_component.shatter_finished
	
	# Begin reparenting sprite_shatter_component to new tree
	sprite_shatter_component.get_parent().remove_child(sprite_shatter_component)
	depetrify_particles.get_parent().remove_child(depetrify_particles)
	tree_acquire_animation.get_parent().remove_child(tree_acquire_animation)
	
	# Remove self from map
	Global.structure_map.remove_structure(grid_position_component.get_pos())
	
	# Add new tree to map
	var new_twee: Node2D = TreeRegistry.get_new_twee(tree_type)
	TreeManager.place_tree(new_twee, grid_position_component.get_pos())
	
	# Complete reparenting
	new_twee.add_child(sprite_shatter_component)
	new_twee.add_child(depetrify_particles)
	Global.fog_map.add_child(tree_acquire_animation)
	tree_acquire_animation.global_position = new_twee.global_position
	depetrify_particles.emitting = true
	
	# Force grow tree and override animation
	var twee_behaviour_component: TweeBehaviourComponent = Components.get_component(new_twee, TweeBehaviourComponent)
	twee_behaviour_component.upgrade_tree()
	var twee_animation_component: TweeAnimationComponent = Components.get_component(new_twee, TweeAnimationComponent)
	twee_animation_component.play_large_tree_animation()
	
	# Play tree acquisition animation
	tree_acquire_animation.play_acquire_animation()
