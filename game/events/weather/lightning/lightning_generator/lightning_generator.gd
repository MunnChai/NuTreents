class_name LightningGenerator
extends Node2D

## GENERATES LIGHTNING

func _ready() -> void:
	pass

func _on_weather_changed(new_weather: WeatherManagerGlobal.WeatherType) -> void:
	if new_weather == WeatherManagerGlobal.WeatherType.STORM:
		for i in range(3):
			summon_lightning()
			$Timer.start(0.5)
			await $Timer.timeout

const LIGHTNING = preload("res://events/weather/lightning/lightning.tscn")
func summon_lightning() -> void:
	if not Global.structure_map:
		return
	
	var offset := Vector2i(randi_range(-3, 3), randi_range(-3, 3))
	var pos := Global.ORIGIN + offset
	
	var new_lightning = LIGHTNING.instantiate()
	Global.structure_map.add_child(new_lightning)
	new_lightning.position = Global.structure_map.map_to_local(pos)
	
	var entity = MapUtility.get_entity_at(pos)
	if entity:
		var flammable: FlammableComponent = Components.get_component(entity, FlammableComponent, "", true)
		if flammable:
			flammable.ignite()

func _process(delta: float) -> void:
	pass
