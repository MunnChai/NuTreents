class_name Clock extends Node

const MINUTES_PER_DAY: float = 3.0
const TOTAL_DAY_SECONDS: int = int(MINUTES_PER_DAY * 60)
const HALF_DAY_SECONDS: int = TOTAL_DAY_SECONDS / 2

var is_day: bool = true

var _current_day_seconds: int = 0  # Tracks the current second in the day [0, TOTAL_DAY_SECONDS - 1]
var _delta_seconds: float = 0
var _tot_sec_elapsed: float = 0 # For func get_current_sec()
var _curr_day: int = 1

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var label: Label = $Label

func _ready() -> void:
	animation_player.play("RESET")
	# Engine.time_scale = 20

func _process(delta: float) -> void:
	_process_time(delta)
	_update_animation_player()
	_update_label()

# Returns time in seconds since start of game
func get_current_sec() -> float:
	return _tot_sec_elapsed

# Returns time in seconds since start of most recent day
func get_curr_day_sec() -> float:
	return _current_day_seconds

# Returns the current day (starts at day 1)
func get_curr_day() -> int:
	return _curr_day

# Increments time variables
func _process_time(delta: float) -> void:
	_tot_sec_elapsed += delta
	_delta_seconds += delta
	
	if _delta_seconds >= 1.0:
		_current_day_seconds += int(_delta_seconds)
		_delta_seconds -= int(_delta_seconds)
		
		# Wrap around at end of day
		if _current_day_seconds >= TOTAL_DAY_SECONDS:
			_curr_day += _current_day_seconds / TOTAL_DAY_SECONDS
			_current_day_seconds %= TOTAL_DAY_SECONDS
		
		_current_day_seconds %= TOTAL_DAY_SECONDS
		debug1()

# Plays animation player on day/night transitions
func _update_animation_player() -> void:
	if _current_day_seconds == HALF_DAY_SECONDS:
		is_day = false # day->night
		animation_player.play("day_to_night")
	elif _current_day_seconds == TOTAL_DAY_SECONDS - 1:
		is_day = true # night->day
		animation_player.play_backwards("day_to_night")

func _update_label():
	label.text = "Day " + str(_curr_day)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if !is_day:
		animation_player.play("night_twinkle")

func debug1() -> void:
	var minutes: int = _current_day_seconds / 60
	var seconds: int = _current_day_seconds % 60
	print(str(minutes) + ":" + str(seconds))
