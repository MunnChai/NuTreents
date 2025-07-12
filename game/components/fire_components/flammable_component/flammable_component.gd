class_name FlammableComponent
extends Node2D

const FIRE = preload("res://events/fire/fire.tscn")

@export_category("Behaviour")
@export var is_flammable := true
@export var can_fire_go_out := true
@export var ignite_on_ready := false

@export_category("Burn")
@export var burn_time := 10.0
@export var fire_tick_duration := 1.0

@export_category("Visual")
@export var fire_pivot: Marker2D

signal ignited(fire: Fire)
signal burned_out
signal extinguished
signal fire_tick

var fire: Fire
var tick_countdown := 0.0

func _ready() -> void:
	if ignite_on_ready:
		call_deferred("ignite")

func _process(delta: float) -> void:
	if is_on_fire():
		tick_countdown -= delta
		if tick_countdown <= 0:
			tick_countdown += fire_tick_duration
			fire_tick.emit()

func is_on_fire() -> bool:
	return fire != null

func get_fire() -> Fire:
	return fire

func extinguish() -> void:
	if is_on_fire():
		fire.extinguish()

func ignite() -> void:
	if not is_flammable or is_on_fire(): return
	
	var new_fire: Fire = FIRE.instantiate()
	add_child(new_fire)
	new_fire.global_position = fire_pivot.global_position if fire_pivot else global_position
	fire = new_fire
	
	fire.will_go_out = can_fire_go_out
	fire.start_lifetime(burn_time)
	
	fire.burned_out.connect(_on_fire_burned_out)
	fire.extinguished.connect(_on_fire_extinguished)
	
	tick_countdown = fire_tick_duration
	ignited.emit(fire)

func _on_fire_burned_out() -> void:
	burned_out.emit()

func _on_fire_extinguished() -> void:
	extinguished.emit()
