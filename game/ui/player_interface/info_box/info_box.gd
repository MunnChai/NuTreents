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
	"tall_tree": "TALL TREE"
}

var tile_name_dictionary = {
	TerrainMap.TILE_TYPE.DIRT: "DIRT",
	TerrainMap.TILE_TYPE.GRASS: "GRASS",
	TerrainMap.TILE_TYPE.CITY: "CITY",
	TerrainMap.TILE_TYPE.WATER: "WATER",
}

var desc_dictionary = {
	"default_tree": "We have all seen a default tree sometime in our lives.",
	"mother_tree": "The source of all trees. Protect it with your life.",
	"gun_tree": "A sandbox tree. Fought in the Great War. Shoots at anything that moves.",
	"explorer_tree": "A bubbly maple. Reaches far to adjacent lands.",
	"tech_tree": "For all your technology needs.",
	"water_tree": "Dredges up them aquifers for your forest's convenience.",
	"tall_tree": "Reaches above the clouds for more of that sweet, sweet sunlight.",
	TerrainMap.TILE_TYPE.DIRT: "Good old dirt. Nothing special.",
	TerrainMap.TILE_TYPE.GRASS: "Fertile grasslands, ripe for trees.",
	TerrainMap.TILE_TYPE.CITY: "Hard, cold asphalt. You'll have to remove it to plant.",
	TerrainMap.TILE_TYPE.WATER: "Hydrates your nearby trees. Don't fall in, though.",
}

func _ready():
	instance = self
	rich_text.text = ""

static func get_instance() -> InfoBox:
	return instance

func show_content_for(pos: Vector2i, id: String, tile_type: int, previously_factory: bool = false) -> void:
	var world_pos = Global.terrain_map.map_to_local(pos)
	var fog_pos = Global.fog_map.local_to_map(world_pos)

	var tile_data = Global.fog_map.get_cell_tile_data(fog_pos)
	if (tile_data != null):
		rich_text.text = ""
		return
	
	if (name_dictionary.has(id)):
		var content = "[i]" + name_dictionary[id] + "[/i]";
		content += "\n\n"
		content += desc_dictionary[id]
		rich_text.text = content
		
		rich_text.text += "\n"
		
		var tree: Twee = TreeManager.get_twee(pos)
		rich_text.text +="\n"
		rich_text.text += "HP: " + str(tree.hp)
		rich_text.text += "\nNET WATER: " + str(tree.gain.y - tree.maint) + "/s"
		rich_text.text += "\nNET NUTRIENTS: " + str(tree.gain.x) + "/s"
		rich_text.text += "\nNET SUN: " + str(tree.gain.z) + "/s"
		
		rich_text.text += "\n"
		
		if (TreeManager.get_twee(pos).is_dehydrated):
			rich_text.text += "\n[color=ab5012]DEHYDRATED[/color]"
		if (previously_factory):
			rich_text.text += "\n[color=6cb3b4]INDUSTRIAL[/color]"
	else:
		if (tile_name_dictionary.has(tile_type)):
			var content = "[i]" + tile_name_dictionary[tile_type] + "[/i]";
			content += "\n\n"
			content += desc_dictionary[tile_type]
			rich_text.text = content
		
			rich_text.text += "\n"
		
			if (previously_factory):
				rich_text.text += "\n[color=6cb3b4]INDUSTRIAL[/color]"
