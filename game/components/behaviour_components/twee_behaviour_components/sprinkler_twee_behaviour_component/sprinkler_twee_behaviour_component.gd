class_name SprinklerTweeBehaviourComponent
extends TweeBehaviourComponent

@export_group("Components")
@export var action_timer: Timer
@export var sprinkler_component: SprinklerComponent

func _get_components() -> void:
	super._get_components()
	
	if not action_timer:
		action_timer = Components.get_component(actor, Timer, "ActionTimer")
	if not sprinkler_component:
		sprinkler_component = Components.get_component(actor, SprinklerComponent)

func _connect_component_signals() -> void:
	super._connect_component_signals()
	
	action_timer.timeout.connect(perform_action)
	action_timer.one_shot = false
	await get_tree().create_timer(randf_range(0, action_timer.wait_time)).timeout
	action_timer.start()

func perform_action() -> void:
	if not is_large: 
		return
	
	sprinkler_component.douse_surrounding_entities()
