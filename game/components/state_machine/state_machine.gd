class_name StateMachine
extends Node

@export var initial_state: State
var states: Array[State]
var current_state: State

func _ready() -> void:
	initialize_states()


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func initialize_states():
	var children = get_children()
	for node in children:
		if node is State:
			states.append(node)
	
	transition_to(initial_state.name)


func transition_to(state_name: String):
	if current_state:
		current_state.exit()
	
	var new_state = get_state_by_name(state_name)
	current_state = new_state
	
	if new_state:
		new_state.enter()


func get_state_by_name(state_name: String) -> State:
	for state: State in states:
		if state.name == state_name:
			return state
	
	return null
