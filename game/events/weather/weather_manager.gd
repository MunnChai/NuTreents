class_name WeatherManager
extends Node2D

## THE WEATHER

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
	WeatherType.RAIN: 5.0,
	WeatherType.STORM: 60.0,
}

@onready var timer: Timer = $Timer

static var instance: WeatherManager

func _ready() -> void:
	instance = self
	weather_changed.connect($LightningGenerator._on_weather_changed)
	switch_to(WeatherType.CLEAR)

## Update the weather
func _process(delta: float) -> void:
	if Global.game_state != Global.GameState.PLAYING:
		return
	
	match current_weather:
		WeatherType.CLEAR:
			update_clear_weather()
		WeatherType.RAIN:
			update_rain_weather()
		WeatherType.STORM:
			update_storm_weather()

## Changing up the weather
func switch_to(weather: WeatherType, duration: float = -1.0) -> void:
	match weather:
		WeatherType.CLEAR:
			pass
		WeatherType.RAIN:
			pass
		WeatherType.STORM:
			pass
	
	if duration < 0.0:
		timer.start(durations.get(weather, 1.0))
	else:
		timer.start(duration)
	current_weather = weather
	
	weather_changed.emit(weather)

## Sunny day
func update_clear_weather() -> void:
	if Rain.instance:
		Rain.instance.stop_particles()

## Light rain
func update_rain_weather() -> void:
	if Rain.instance:
		Rain.instance.start_particles()

## Storm clouds
func update_storm_weather() -> void:
	if Rain.instance:
		Rain.instance.start_particles()

## Weather's over!
func _on_timer_timeout() -> void:
	match current_weather:
		WeatherType.CLEAR:
			## Temporarily doesn't have RAIN because there's
			## no way to distinguish between it and STORM at the moment...
			var next_weathers: Array[WeatherType] = [WeatherType.CLEAR, WeatherType.STORM, WeatherType.STORM]
			switch_to(next_weathers.pick_random())
		WeatherType.RAIN:
			switch_to(WeatherType.CLEAR)
		WeatherType.STORM:
			switch_to(WeatherType.CLEAR)
