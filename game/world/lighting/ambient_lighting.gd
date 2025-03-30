class_name AmbientLighting extends Node2D

var clock: Clock

const LERP_TO_MORNING_SPEED = 1.0
const LERP_TO_DAY_SPEED = 1.2
const LERP_TO_EVENING_SPEED = 1.0
const LERP_TO_NIGHT_SPEED = 0.5

const PERCENT_EVENING_THRESHOLD = 0.75 ## Percent of half day, occurs AFTER
const PERCENT_MORNING_THRESHOLD = 0.15 ## Percent of half day, occurs BEFORE

@export var day_color = Color(1.0, 1.0, 1.0, 1.0)
@export var night_color = Color("224575", 1.0)
@export var evening_color = Color("ec955d", 1.0)
@export var morning_color = Color("7fc3db", 1.0)

@onready var modulation: CanvasModulate = %Modulation

static var amount_of_night = 0.0

func _ready() -> void:
	clock = get_tree().root.find_child("Clock", true, false)

func _process(delta: float) -> void:
	if clock:
		_update_modulation(delta)
		_update_amount_of_night(delta)

func _update_modulation(delta: float) -> void:
	if clock.get_curr_day_sec() > clock.HALF_DAY_SECONDS:
		modulation.color = modulation.color.lerp(night_color, delta * LERP_TO_NIGHT_SPEED)
	elif clock.get_curr_day_sec() > clock.HALF_DAY_SECONDS * PERCENT_EVENING_THRESHOLD:
		modulation.color = modulation.color.lerp(evening_color, delta * LERP_TO_EVENING_SPEED)
	elif clock.get_curr_day_sec() > clock.HALF_DAY_SECONDS * PERCENT_MORNING_THRESHOLD:
		modulation.color = modulation.color.lerp(day_color, delta * LERP_TO_DAY_SPEED)
	else:
		modulation.color = modulation.color.lerp(morning_color, delta * LERP_TO_MORNING_SPEED)

func _update_amount_of_night(delta: float) -> void:
	if clock.get_curr_day_sec() <= clock.HALF_DAY_SECONDS:
		amount_of_night = lerp(amount_of_night, 0.0, delta * LERP_TO_MORNING_SPEED)
	else:
		amount_of_night = lerp(amount_of_night, 1.0, delta * LERP_TO_NIGHT_SPEED)
