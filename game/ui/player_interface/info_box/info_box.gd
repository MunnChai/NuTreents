class_name InfoBox
extends Control

static var instance: InfoBox

@onready var rich_text: RichTextLabel = %RichText

var name_dictionary = {
	"default_tree": "DEFAULT TREE",
	"mother_tree": "MOTHER TREE",
	"gun_tree": "GUN TREE",
	"explorer_tree": "EXPLORER TREE",
	"tech_tree": "TECH TREE",
	"water_tree": "WATER TREE",
	"tall_tree": "TALL TREE",
	"slowing_tree": "SLOWING TREE",
	"mortar_tree": "MORTAR TREE",
	"spiky_tree": "SPIKY TREE",
	"icy_tree": "ICY TREE",
	"fire_tree": "FIRE TREE",
	"sprinkler_tree": "SPRINKLER TREE",
	
	
	"city_building": "CITY STRUCTURE",
	"factory": "FACTORY",
	"factory_remains": "FACTORY REMAINS",
	"petrified_tree": "PETRIFIED TREE",
	
	"speedle": "SPEEDLE",
	"silk_spitter": "SILK SPITTER",
	"speed_speedle": "SPEEDY SPEEDLE",
	"tank_speedle": "TANKY SPEEDLE",
	"bomb_bug": "BOMB BUG",
	
	"ominous_torch": "OMINOUS TORCH",
}

var tile_name_dictionary = {
	TerrainMap.TileType.DIRT: "DIRT",
	TerrainMap.TileType.GRASS: "GRASS",
	TerrainMap.TileType.CITY: "CITY",
	TerrainMap.TileType.WATER: "WATER",
	TerrainMap.TileType.ROAD: "ROAD",
	TerrainMap.TileType.SAND: "SAND",
	TerrainMap.TileType.SNOW: "SNOW",
	TerrainMap.TileType.ICE: "ICE"
}

# --- FIX: Added newlines to long descriptions for better formatting ---
var desc_dictionary = {
	"default_tree": "We have all seen a default tree\nsometime in our lives.",
	"mother_tree": "The source of all trees.\n[color=ffdda9]Protect it with your life.[/color]",
	"gun_tree": "A sandbox tree.\nFought in the Great War.\n[color=ffdda9]Shoots at anything that moves.[/color]",
	"explorer_tree": "A bubbly maple.\n[color=ffdda9]Reaches far to adjacent lands.[/color]",
	"tech_tree": "For all your technology needs.",
	"water_tree": "Dredges up them aquifers,\nfor your forest's convenience.",
	"tall_tree": "[color=ffdda9]Sharp and sturdy.[/color]\nIt'll take more than a few bugs\nto chop this one.",
	"slowing_tree": "A close relative to the gun tree. \nSomehow survived growing up\nin the Arctic.",
	"mortar_tree": "It was enlisted for the Great War, \nbut was too scared to go near\nthe frontline.",
	"spiky_tree": "A prickly tree with sharp branches. \n[color=ffdda9]Hurts anything that touches it.[/color]",
	"icy_tree": "Cold and sharp. [color=ffdda9]Its branches\nfreeze anything that touches it.[/color]",
	"fire_tree": "[color=ffdda9]It shoots fiery hot seeds\nat enemies.[/color]",
	"sprinkler_tree": "[color=ffdda9]Protects nearby trees from\nblazing fires.[/color]",
	
	"city_building": "The last signs of human civilization.\n[color=ffdda9]You'll have to remove it to plant.[/color]",
	"factory": "Despite its abandoned state, the\nmachinery in this factory is still\nfunctional. [color=6be1e3]It might be worth looting.[/color]",
	"factory_remains": "What if you planted a\nTech Tree here?",
	"petrified_tree": "A tree made of stone.\n[color=ffdda9]Could you save it somehow?[/color]",
	
	"speedle": "A mutant arthropod dead-set on\ndestroying any and all trees\nin its path.",
	"silk_spitter": "A mutant caterpillar that spits\nsilken bullets at any trees\nin its line of sight.",
	"speed_speedle": "The name is redundant.",
	"tank_speedle": "Life in the wilderness has gifted\nthis speedle with the power of armour.",
	"bomb_bug": "An unholy abomination of an ant,\na beetle, and a propane tanker.",
	
	"ominous_torch": "What the hell is that thing?",
	
	TerrainMap.TileType.DIRT: "Good old dirt. Nothing special.",
	TerrainMap.TileType.GRASS: "Fertile grasslands, ripe for trees.",
	TerrainMap.TileType.CITY: "Cold, hard asphalt.\n[color=ffdda9]You'll have to remove it to plant.[/color]",
	TerrainMap.TileType.WATER: "[color=ffdda9]Hydrates your nearby trees.[/color]\nDon't fall in, though.",
	TerrainMap.TileType.ROAD: "Well-worn tar.\n[color=ffdda9]You'll have to remove it to plant.[/color]",
	TerrainMap.TileType.SAND: "Coarse and rough and irritating\nand it gets everywhere.",
	TerrainMap.TileType.SNOW: "A soft blanket of snow.",
	TerrainMap.TileType.ICE: "Frozen. [color=ffdda9]No place for roots.[/color]"
}

func _ready():
	instance = self
	rich_text.text = ""

static func get_instance() -> InfoBox:
	return instance

func hide_content():
	rich_text.text = ""

func show_content_for_tree(tree_stat: TreeStatResource):
	var content = "[i]" + tree_stat.name.to_upper() + "[/i]"
	content += "\n\n"
	content += desc_dictionary[tree_stat.id]
	rich_text.text = content
	
	rich_text.text += "\n"

	rich_text.text +="\n"
	rich_text.text += "HP: " + str(tree_stat.hp)
	rich_text.text += "\nNET WATER: " + str(tree_stat.gain.y - tree_stat.maint) + "/s"
	rich_text.text += "\nNET NUTRIENTS: " + str(tree_stat.gain.x) + "/s"
	#rich_text.text += "\nNET SUN: " + str(tree_stat.gain.z) + "/s"
	
	rich_text.text += "\n"



func show_content_for(pos: Vector2i, id: String, tile_type: int, previously_factory: bool = false) -> void:
	var world_pos = Global.terrain_map.map_to_local(pos)
	var fog_pos = Global.fog_map.local_to_map(world_pos)

	if (Global.fog_map.is_tile_foggy(fog_pos)):
		rich_text.text = ""
		return
	
	if (name_dictionary.has(id)):
		var content = "[i]" + name_dictionary[id] + "[/i]";
		content += "\n"
		content += "[color=d9863e]" + desc_dictionary[id]
		rich_text.text = content
		
		rich_text.text += "\n"
		
		var enemy = EnemyManager.instance.get_enemy_at(pos)
		var structure: Node2D = null
		if (Global.structure_map.tile_scene_map.has(pos)):
			structure = Global.structure_map.tile_scene_map[pos]
		
		var tree_stat_component: TweeStatComponent = Components.get_component(structure, TweeStatComponent)
		if tree_stat_component:
			## HP
			rich_text.text +="\n"
			rich_text.text += tr(&"INFO_HP").format({ "value": str(Components.get_component(structure, HealthComponent).get_current_health())})
			
			## WATER
			var water: float = Components.get_component(structure, WaterProductionComponent).get_water_production()
			if water != 0:
				rich_text.text +="\n"
				if water > 0:
					rich_text.text += tr(&"INFO_WATER_GAIN").format({ "value": str(water) })
				elif water < 0:
					rich_text.text += tr(&"INFO_WATER_LOSS").format({ "value": str(water) })
			
			var nutreents: float = Components.get_component(structure, NutreentProductionComponent).get_nutreent_production()
			if nutreents != 0:
				rich_text.text +="\n"
				rich_text.text += tr(&"INFO_NUTREENTS").format({ "value": str(nutreents)})
			
			var hitbox = Components.get_component(structure, HitboxComponent)
			if hitbox:
				var damage: float = hitbox.damage
				if damage != 0:
					rich_text.text +="\n"
					rich_text.text += tr(&"INFO_CONTACT_DAMAGE").format({ "value": str(damage)})
			
			var projectile_spawner = Components.get_component(structure, ProjectileSpawnerComponent)
			if projectile_spawner:
				var damage: float = projectile_spawner.damage
				if damage != 0:
					rich_text.text +="\n"
					rich_text.text += tr(&"INFO_RANGED_DAMAGE").format({ "value": str(damage)})
			
			rich_text.text += "\n"
			
			## TODO:
			# Dehydrated
			# Water boost
			# Mortar tree armed
			# Damage of spiky tree
			
			#if (TreeManager.get_twee(pos).is_dehydrated):
				#rich_text.text += "\n[color=ab5012]DEHYDRATED[/color]"
			#if (previously_factory):
				#rich_text.text += "\n[color=6cb3b4]INDUSTRIAL[/color]"
		var destructable_component: DestructableComponent = Components.get_component(structure, DestructableComponent)
		if destructable_component and not tree_stat_component:
			rich_text.text +="\n"
			rich_text.text += tr(&"INFO_NUTREENTS_TO_VERB").format({ "cost": str(int(destructable_component.get_cost())), "verb": "DESTROY"})
		elif (enemy != null):
			rich_text.text +="\n"
			
			var health_component: HealthComponent = Components.get_component(enemy, HealthComponent)
			rich_text.text += tr(&"INFO_HP").format({ "value": str(health_component.current_health)})
			rich_text.text +="\n"
			
			var stat_component: EnemyStatComponent = Components.get_component(enemy, EnemyStatComponent)

			rich_text.text += tr(&"INFO_DAMAGE").format({ "value": str(stat_component.stat_resource.attack_damage)})
			rich_text.text +="\n"
			
			rich_text.text += tr(&"INFO_RANGE").format({ "value": str(stat_component.stat_resource.attack_range)})
			rich_text.text +="\n"
	else:
		if (tile_name_dictionary.has(tile_type)):
			var content = "[i]" + tile_name_dictionary[tile_type] + "[/i]";
			content += "\n"
			content += "[color=d9863e]" + desc_dictionary[tile_type]
			rich_text.text = content
		
			rich_text.text += "\n"
		
			if (previously_factory):
				rich_text.text += "\n[color=6cb3b4]INDUSTRIAL[/color]"
			
			var structure_map = Global.structure_map
			if (tile_type == TerrainMap.TileType.ROAD):
				rich_text.text += "\n"
				var cost := str(int(structure_map.COST_TO_REMOVE_ROAD_TILE))
				rich_text.text += tr(&"INFO_NUTREENTS_TO_VERB").format({ "cost": cost, "verb": "DESTROY"})
			elif (tile_type == TerrainMap.TileType.CITY):
				rich_text.text += "\n"
				var cost := str(int(structure_map.COST_TO_REMOVE_CITY_TILE))
				rich_text.text += tr(&"INFO_NUTREENTS_TO_VERB").format({ "cost": cost, "verb": "DESTROY"})

func _process(delta: float) -> void:
	if not rich_text.text.is_empty():
		FloatingTooltip.instance.show_content(rich_text.text)
	else:
		FloatingTooltip.instance.hide_content()
