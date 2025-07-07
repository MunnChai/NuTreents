class_name Fire
extends Node2D

## TODO/BUG: The particles on this thing (I think it's particles...)
## ...or something with the fire system currently LAGS REALLY BAD 
## the more there are. Make it more performant and also more
## visually stunning.

## A FIRE!

signal burned_out ## Ended on its own accord
signal extinguished ## Was put out by an external force

@export var will_go_out := true ## Disable this for an infinite flame
var lifetime_countdown := 0.0 ## Time until the cold
var is_extinguished := false ## The end of days is here

var audio: AudioStreamPlayer2D

func _ready() -> void:
	audio = SoundManager.start_player(&"fire_burn", global_position)

func _exit_tree() -> void:
	if audio:
		audio.stop()
		audio.queue_free()

## Manual extinguishing, prevent destruction!
func extinguish() -> void:
	if is_extinguished:
		return
	is_extinguished = true
	extinguished.emit()
	burn_away()

func _process(delta: float) -> void:
	_update_lifetime(delta)

#region LIFETIME

func start_lifetime(time: float) -> void:
	lifetime_countdown = time

func add_lifetime(time: float) -> void:
	lifetime_countdown += time

func _update_lifetime(delta: float) -> void:
	if is_extinguished:
		return
	if not will_go_out:
		return
	
	lifetime_countdown -= delta
	if lifetime_countdown <= 0.0:
		burned_out.emit()
		burn_away()

#endregion

#region VISUAL

func burn_away() -> void:
	## TODO: Do like an animation or fade away or something
	queue_free()

func set_intensity(value: int) -> void:
	## TODO: Amount of particles based on intensity, which can grow or decrease over time
	## Depending on weather conditions and properties of host
	pass

#endregion
