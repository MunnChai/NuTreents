class_name LightningGenerator
extends Node2D

## GENERATES LIGHTNING

## Hook up to signal detecting weather change...
func _on_weather_changed(new_weather: WeatherManager.WeatherType) -> void:
	if new_weather == WeatherManager.WeatherType.STORM:
		$Timer.start(get_random_wait_delay()) # Storm starts, start timer loop...
	else:
		$Timer.stop() # Halt! No more storm.

## Strike near any structure on the map
const LIGHTNING = preload("res://events/weather/lightning/lightning.tscn")
func summon_lightning() -> void:
	if not Global.structure_map:
		return
	
	var occupied_tiles := Global.structure_map.tile_scene_map.keys()
	
	var base_pos: Vector2i = occupied_tiles.pick_random()
	var offset := Vector2i(randi_range(-2, 2), randi_range(-2, 2))
	
	var pos = base_pos + offset
	
	summon_lightning_at(pos)

## Summon lightning at position!
func summon_lightning_at(pos: Vector2i) -> void:
	if not Global.structure_map:
		return
	
	## Create a new lightning, put it there
	var new_lightning = LIGHTNING.instantiate()
	new_lightning.global_position = Global.structure_map.map_to_local(pos)
	Global.structure_map.add_child(new_lightning)
	
	## Is there something?
	var entity = MapUtility.get_entity_at(pos)
	if entity:
		## Juice
		PopupManager.create_popup("HIT!", new_lightning.global_position, Color("ffab41"), Color.BLACK)
		
		## Ignite
		var flammable: FlammableComponent = Components.get_component(entity, FlammableComponent, "", true)
		if flammable:
			flammable.ignite()
		
		## Deal damage
		var health: HealthComponent = Components.get_component(entity, HealthComponent, "", true)
		if health:
			health.subtract_health(5)

## Gets a random wait from 1 to 20 second
func get_random_wait_delay() -> int:
	return randi_range(1, 20)

## When the timer is done, we want to have a chance of summoning lightning IF it's still a storm
func _on_timer_timeout() -> void:
	if WeatherManager.instance.current_weather != WeatherManager.WeatherType.STORM:
		return
	
	## RNG
	var num := randi_range(0, 100)
	if num > 50:
		summon_lightning()
	
	$Timer.start(get_random_wait_delay())
