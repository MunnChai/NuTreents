class_name DehydrationEvent
extends RefCounted

## Dehydration Event
## - Tracks elapsed time
## - Applies more and more significant penalities as time goes on

var forest: Forest
var time_elapsed := 0.0

const SMALL_TREE_DAMAGE_TIME := 30.0
const LARGE_TREE_DAMAGE_TIME := 60.0

func _init(_forest: Forest, _time_elapsed: float = 0.0) -> void:
	forest = _forest
	time_elapsed = _time_elapsed

func change_forest(_forest: Forest) -> void:
	forest = _forest

func update(delta: float) -> void:
	time_elapsed += delta
	
	for tree: Node2D in forest.tree_set:
		var twee_component: TweeBehaviourComponent = Components.get_component(tree, TweeBehaviourComponent, "", false)
		var dehydration_component: DehydrationComponent = Components.get_component(tree, DehydrationComponent, "", false)
		
		dehydration_component.is_dehydrated = true
		
		## TODO: Distance
		## TODO: Small trees, most recently planted/longest time remaining in growth
		
		if time_elapsed > SMALL_TREE_DAMAGE_TIME:
			if not twee_component.is_large:
				dehydration_component.is_taking_damage = true
		
		if time_elapsed > LARGE_TREE_DAMAGE_TIME:
			dehydration_component.is_taking_damage = true

func end_event() -> void:
	for tree: Node2D in forest.tree_set:
		var dehydration_component: DehydrationComponent = Components.get_component(tree, DehydrationComponent, "", false)
		
		dehydration_component.is_dehydrated = false
		dehydration_component.is_taking_damage = false

func get_elapsed_time() -> float:
	return time_elapsed
