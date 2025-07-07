class_name TreeAcquireAnimationComponent
extends Node2D

@onready var card: Sprite2D = %Card
@onready var tree_icon: Sprite2D = %TreeIcon

@export var petrified_component: PetrifiedTreeComponent

func _ready() -> void:
	_get_components()
	_get_tree_icon()

func _get_components() -> void:
	if not petrified_component:
		petrified_component = Components.get_component(get_parent(), PetrifiedTreeComponent)

func _get_tree_icon() -> void:
	if petrified_component:
		tree_icon.texture = TreeRegistry.get_twee_stat(petrified_component.tree_type).tree_icon

func set_tree_icon(tree_type: Global.TreeType) -> void:
	tree_icon.texture = TreeRegistry.get_twee_stat(petrified_component.tree_type).tree_icon

## Animation constants
const EMERGE_DURATION: float = 0.75
const FLOAT_DURATION: float = 2.0

const Y_OFFSET: float = 70
const FLOAT_MAGNITUDE: float = 10

func play_acquire_animation() -> void:
	# Init tweens
	var tween: Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	
	# Init card
	card.visible = true
	card.scale = Vector2(0, 0)
	var init_pos = global_position
	
	# Emerge
	tween.set_parallel(true)
	tween.tween_property(card, "scale", Vector2(1, 1), EMERGE_DURATION)
	tween.tween_property(card, "global_position", init_pos + Vector2(0, -Y_OFFSET), EMERGE_DURATION)
	
	# Float
	tween.set_parallel(false)
	tween.tween_property(card, "global_position", Vector2(0, FLOAT_MAGNITUDE), FLOAT_DURATION / 4).as_relative()
	tween.tween_property(card, "global_position", Vector2(0, -FLOAT_MAGNITUDE), FLOAT_DURATION / 4).as_relative()
	tween.tween_property(card, "global_position", Vector2(0, FLOAT_MAGNITUDE), FLOAT_DURATION / 4).as_relative()
	tween.tween_property(card, "global_position", Vector2(0, -FLOAT_MAGNITUDE), FLOAT_DURATION / 4).as_relative()
	
	# Disappear
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel(true)
	tween.tween_property(card, "scale", Vector2(0, 0), EMERGE_DURATION)
	tween.tween_property(card, "global_position", init_pos, EMERGE_DURATION) # Ideally this tweens towards the tree menu
	tween.finished.connect(add_tree_card_to_menu.bind(petrified_component.tree_type))
	tween.finished.connect(queue_free)

func add_tree_card_to_menu(type: Global.TreeType) -> void:
	TreeMenu.instance.add_tree_card(type)
