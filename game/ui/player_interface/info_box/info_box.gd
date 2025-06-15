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
	
	"city_building": "CITY STRUCTURE",
	"factory": "FACTORY",
	"factory_remains": "FACTORY REMAINS",
	
	"speedle": "SPEEDLE",
	"silk_spitter": "SILK SPITTER"
}

var tile_name_dictionary = {
	TerrainMap.TileType.DIRT: "DIRT",
	TerrainMap.TileType.GRASS: "GRASS",
	TerrainMap.TileType.CITY: "CITY",
	TerrainMap.TileType.WATER: "WATER",
	TerrainMap.TileType.ROAD: "ROAD",
}

var desc_dictionary = {
	"default_tree": "We have all seen a default tree\nsometime in our lives.",
	"mother_tree": "The source of all trees.\nProtect it with your life.",
	"gun_tree": "A sandbox tree.\nFought in the Great War.\nShoots at anything that moves.",
	"explorer_tree": "A bubbly maple.\nReaches far to adjacent lands.",
	"tech_tree": "For all your technology needs.",
	"water_tree": "Dredges up them aquifers,\nfor your forest's convenience.",
	"tall_tree": "Sharp and sturdy.\nIt'll take more than a few bugs to chop this one.",
	
	"city_building": "The last signs of human civilization in the vicinity. You'll have to remove it to plant.",
	"factory": "Despite its abandoned state, the machinery in this factory is still functional. It might be worth looting.",
	"factory_remains": "What if you planted a Tech Tree here?",
	
	"speedle": "A mutant arthropod dead-set on destroying any and all trees in its path.",
	"silk_spitter": "A mutant caterpillar that spits silken bullets at any trees in its line of sight.",
	
	TerrainMap.TileType.DIRT: "Good old dirt. Nothing special.",
	TerrainMap.TileType.GRASS: "Fertile grasslands, ripe for trees.",
	TerrainMap.TileType.CITY: "Cold, hard asphalt.\nYou'll have to remove it to plant.",
	TerrainMap.TileType.WATER: "Hydrates your nearby trees.\nDon't fall in, though.",
	TerrainMap.TileType.ROAD: "Well-worn tar.\nYou'll have to remove it to plant.",
}

func _ready():
	instance = self
	rich_text.text = ""

static func get_instance() -> InfoBox:
	return instance

func hide_content():
	rich_text.text = ""

func show_content_for_tree(tree_stat: TreeStatResource):
	if (!name_dictionary.has(tree_stat.id)):
		rich_text.text = ""
		return
	
	var content = "[i]" + name_dictionary[tree_stat.id] + "[/i]";
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
		
		if (structure is Twee):
			rich_text.text +="\n"
			rich_text.text += "HP: " + str(structure.hp)
			rich_text.text += "\nNET WATER: " + str(structure.gain.y - structure.maint) + "/s"
			rich_text.text += "\nNET NUTRIENTS: " + str(structure.gain.x) + "/s"
			#rich_text.text += "\nNET SUN: " + str(structure.gain.z) + "/s"
			
			rich_text.text += "\n"
			
			if (TreeManager.get_twee(pos).is_dehydrated):
				rich_text.text += "\n[color=ab5012]DEHYDRATED[/color]"
			if (previously_factory):
				rich_text.text += "\n[color=6cb3b4]INDUSTRIAL[/color]"
		elif (structure is CityBuilding || structure is Factory):
			rich_text.text +="\n"
			rich_text.text += "Nutrients needed to destroy: " + str(structure.cost_to_remove)
		elif (enemy != null):
			rich_text.text +="\n"
			#rich_text.text += "HP: " + str(enemy.current_health)
			#rich_text.text += "\nDAMAGE: " + str(enemy.attack_damage)
			#rich_text.text += "\nRANGE: " + str(enemy.attack_range)
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
				rich_text.text += "Nutrients needed to destroy: " + str(structure_map.COST_TO_REMOVE_ROAD_TILE)
			elif (tile_type == TerrainMap.TileType.CITY):
				rich_text.text += "\n"
				rich_text.text += "Nutrients needed to destroy: " + str(structure_map.COST_TO_REMOVE_CITY_TILE)

func _process(delta: float) -> void:
	if not rich_text.text.is_empty():
		FloatingTooltip.instance.show_content(rich_text.text)
	else:
		FloatingTooltip.instance.hide_content()
