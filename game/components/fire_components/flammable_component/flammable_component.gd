class_name FlammableComponent
extends Node2D

## A COMPONENT THAT REPRESENTS AN OBJECT WHICH CAN BE SET ON FIRE
## Tracks fire "state" on this object

@export var is_flammable := true
@export var can_fire_go_out := true ## Will the fire ever go out?
@export var burn_time := 10.0 ## How long does this burn for? In seconds.

signal ignited(fire: Fire)
signal burned_out
signal extinguished

var fire: Fire
var extinguished_counter: int = 0

const FIRE = preload("res://status_events/fires/fire.tscn") # Figure some better way to load this in...

func is_on_fire() -> bool:
	return fire != null

## Set this object ON FIRE!
func ignite() -> void:
	if not is_flammable: ## How do you ignite something that was never meant to be?
		return
	if is_on_fire(): ## No double fires
		return
	
	## Spawn fire entity on top of this thing, with burn configuration details...
	var new_fire: Fire = FIRE.instantiate()
	add_child(new_fire)
	new_fire.global_position = global_position
	fire = new_fire
	
	## Configuration...
	fire.will_go_out = can_fire_go_out
	fire.start_lifetime(burn_time)
	
	fire.burned_out.connect(_on_fire_burned_out)
	fire.extinguished.connect(_on_fire_extinguished)
	
	ignited.emit(fire) ## Let the fire department know

func _on_fire_burned_out() -> void:
	burned_out.emit()

func _on_fire_extinguished() -> void:
	extinguished.emit()

## Why would you want to get that?
func get_fire() -> Fire:
	return fire

func extinguish() -> void:
	fire.extinguish()
