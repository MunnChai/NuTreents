class_name WeatherManager
extends Node2D

## THE WEATHER

const RAIN_WATER_PRODUCTION_MULTIPLIER = 1.5
# This constant is no longer used in the timer logic, but can be kept for other features.
const FIRST_DAY_OF_STORM = 5

enum WeatherType {
	CLEAR,
	RAIN,
	STORM
}

signal weather_changed(new_weather: WeatherType)

## What's the weather?
var current_weather: WeatherType = WeatherType.CLEAR

## How long's the weather?
var durations: Dictionary[WeatherType, float] = {
	WeatherType.CLEAR: 60.0,
	WeatherType.RAIN: 15.0, # Increased duration slightly
	WeatherType.STORM: 60.0,
}

@onready var timer: Timer = $Timer

static var instance: WeatherManager

func is_raining() -> bool:
	return current_weather == WeatherType.RAIN or current_weather == WeatherType.STORM

func _ready() -> void:
	instance = self
	if get_node_or_null("LightningGenerator"):
		weather_changed.connect($LightningGenerator._on_weather_changed)
	switch_to(WeatherType.CLEAR)
	
	DebugConsole.register("weather", func (args: PackedStringArray):
		if args.size() != 1:
			Logger.log("Usage: weather [CLEAR/STORM]")
		else:
			var arg = args[0]
			if arg == "CLEAR":
				switch_to(WeatherType.CLEAR, 60.0)
			elif arg == "STORM":
				switch_to(WeatherType.STORM, 60.0)
		)

## Update the weather
func _process(delta: float) -> void:
	if Global.game_state != Global.GameState.PLAYING:
		return
	
	#match current_weather:
		#WeatherType.CLEAR:
			#update_clear_weather()
		#WeatherType.RAIN:
			#update_rain_weather()
		#WeatherType.STORM:
			#update_storm_weather()

## Changing up the weather
func switch_to(weather: WeatherType, duration: float = -1.0) -> void:
	# Added a debug print to make it easy to see when the weather changes.
	print("Weather changing to: ", WeatherType.keys()[weather])
	
	if duration < 0.0:
		timer.start(durations.get(weather, 1.0))
	else:
		timer.start(duration)
		
	current_weather = weather
	
	# This initial call ensures the visual state changes immediately.
	match current_weather:
		WeatherType.CLEAR:
			update_clear_weather()
		WeatherType.RAIN:
			update_rain_weather()
		WeatherType.STORM:
			update_storm_weather()

	weather_changed.emit(weather)

## Sunny day
func update_clear_weather() -> void:
	if is_instance_valid(Rain.instance):
		Rain.instance.stop_particles()

## Light rain
func update_rain_weather() -> void:
	if is_instance_valid(Rain.instance):
		Rain.instance.start_particles()

## Storm clouds
func update_storm_weather() -> void:
	if is_instance_valid(Rain.instance):
		Rain.instance.start_particles()

## Weather's over!
func _on_timer_timeout() -> void:
	match current_weather:
		WeatherType.CLEAR:
			# --- BUG FIX ---
			# The check for FIRST_DAY_OF_STORM has been removed.
			# Storms can now happen from Day 1, but are less likely than clear weather.
			var next_weathers: Array[WeatherType] = [WeatherType.CLEAR, WeatherType.CLEAR, WeatherType.CLEAR, WeatherType.STORM]
			switch_to(next_weathers.pick_random())
		WeatherType.RAIN:
			switch_to(WeatherType.CLEAR)
		WeatherType.STORM:
			switch_to(WeatherType.CLEAR)
