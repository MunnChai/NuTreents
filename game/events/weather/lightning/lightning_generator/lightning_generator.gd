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
	#elif new_weather == WeatherManagerGlobal.WeatherType.CLEAR:
		#if EnemyManager.instance:
			#for enemy in EnemyManager.instance.get_enemies():
				#if not enemy:
					#continue
				#var grid_pos: GridPositionComponent = Components.get_component(enemy, GridPositionComponent, "", false)
				#if grid_pos:
					#summon_lightning_at(grid_pos.get_pos())
					#$Timer.start(0.15)
					#await $Timer.timeout

const LIGHTNING = preload("res://events/weather/lightning/lightning.tscn")
func summon_lightning() -> void:
	if not Global.structure_map:
		return
	
	var offset := Vector2i(randi_range(-3, 3), randi_range(-3, 3))
	var pos := Global.ORIGIN + offset
	
	summon_lightning_at(pos)

func summon_lightning_at(pos: Vector2i) -> void:
	if not Global.structure_map:
		return
	
	var new_lightning = LIGHTNING.instantiate()
	new_lightning.global_position = Global.structure_map.map_to_local(pos)
	Global.structure_map.add_child(new_lightning)
	
	var entity = MapUtility.get_entity_at(pos)
	if entity:
		PopupManager.create_popup("HIT!", new_lightning.global_position, Color("ffab41"), Color.BLACK)
		
		var flammable: FlammableComponent = Components.get_component(entity, FlammableComponent, "", true)
		if flammable:
			flammable.ignite()
		
		var health: HealthComponent = Components.get_component(entity, HealthComponent, "", true)
		if health:
			health.subtract_health(5)

func _process(delta: float) -> void:
	pass
