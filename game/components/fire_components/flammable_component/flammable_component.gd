class_name FlammableComponent
extends Node2D

## FIRE-ABILITY OF AN OBJECT
## - Can this object be set on fire?
## - What properties would the fire have?

## TODO: Figure some better way to load this in...
const FIRE = preload("res://events/fire/fire.tscn")

@export_category("Behaviour")
@export var is_flammable := true
@export var can_fire_go_out := true ## Will the fire ever go out?
@export var ignite_on_ready := false

@export_category("Burn")
@export var burn_time := 10.0 ## How long does this burn for? In seconds.
@export var fire_tick_duration := 1.0

@export_category("Visual")
@export var fire_pivot: Marker2D ## Choose a spot to put the fire node!

signal ignited(fire: Fire)
signal burned_out
signal extinguished
signal fire_tick

var fire: Fire
var extinguished_counter: int = 0

func _ready() -> void:
	if ignite_on_ready:
		call_deferred("ignite")

var tick_countdown := 0.0
func _process(delta: float) -> void:
	if is_on_fire():
		while tick_countdown <= 0:
			tick_countdown += fire_tick_duration 
			fire_tick.emit()
		tick_countdown -= delta

## Useful information
func is_on_fire() -> bool:
	return fire != null

## Why would you want to get that?
func get_fire() -> Fire:
	return fire

## Put out fire without destroying thing in process
func extinguish() -> void:
	if is_on_fire():
		fire.extinguish()

## Set this object ON FIRE!
func ignite() -> void:
	if not is_flammable: ## How do you ignite something that was never meant to be?
		return
	if is_on_fire(): ## No double fires
		return
	
	## Spawn fire entity on top of this thing, with burn configuration details...
	var new_fire: Fire = FIRE.instantiate()
	add_child(new_fire)
	if fire_pivot: ## Move fire to requested location
		new_fire.global_position = fire_pivot.global_position
	else: ## Fire is ok where it is
		new_fire.global_position = global_position
	fire = new_fire
	
	## Configuration...
	fire.will_go_out = can_fire_go_out
	fire.start_lifetime(burn_time)
	
	## Keep up to date with the fire
	fire.burned_out.connect(_on_fire_burned_out)
	fire.extinguished.connect(_on_fire_extinguished)
	
	tick_countdown = fire_tick_duration
	ignited.emit(fire) ## Let the fire department know

func _on_fire_burned_out() -> void:
	burned_out.emit()

func _on_fire_extinguished() -> void:
	extinguished.emit()
	extinguished_counter += 1 ## Tally!
