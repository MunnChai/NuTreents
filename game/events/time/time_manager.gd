class_name TimeManager
extends Node

## Manages the in-game time of day, day count, and broadcasts time-based signals.
## Time is represented as a float from 0.0 (midnight) to 24.0 (next midnight).

signal hour_passed(hour: int)
signal day_passed(day_count: int)

static var instance: TimeManager

var current_time: float = 8.0 # Start the day at 8 AM
var day_count: int = 1
var time_scale: float = 60.0 # How fast time passes. 60 means 1 real minute = 1 game hour.

var _last_hour_checked: int = -1

func _ready() -> void:
	instance = self
	_last_hour_checked = floor(current_time)

func _process(delta: float) -> void:
	if Global.game_state != Global.GameState.PLAYING:
		return
		
	# Advance time
	current_time += delta * time_scale / 3600.0
	
	# Check for hour change
	var current_hour: int = floor(current_time)
	if current_hour != _last_hour_checked:
		_last_hour_checked = current_hour
		hour_passed.emit(current_hour)

	# Check for day change
	if current_time >= 24.0:
		current_time = fmod(current_time, 24.0)
		day_count += 1
		# Hour might roll over from 23 to 0
		_last_hour_checked = 0 
		hour_passed.emit(0)
		day_passed.emit(day_count)

# --- PUBLIC API ---

## Returns the current time as a float between 0.0 and 24.0
func get_current_time() -> float:
	return current_time

## Returns the current day number.
func get_day_count() -> int:
	return day_count

## Returns the time formatted as a string "HH:MM".
func get_formatted_time() -> String:
	var hour: int = floor(current_time)
	var minute: int = floor(fmod(current_time, 1.0) * 60)
	return "%02d:%02d" % [hour, minute]
