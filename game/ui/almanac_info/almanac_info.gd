extends Node

# trees and enemies that have been explored
var trees: Array[Global.TreeType]
var enemies: Array[Global.EnemyType]

var name_dictionary = {
	"city_building": "CITY STRUCTURE",
	"factory": "FACTORY",
	"factory_remains": "FACTORY REMAINS",
	"petrified_tree": "PETRIFIED TREE",
	
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

var tree_name_dict = {
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
	"sprinkler_tree": "SPRINKLER TREE"
}

var tree_type_dict = {
	"default_tree": Global.TreeType.DEFAULT_TREE,
	"mother_tree": Global.TreeType.MOTHER_TREE,
	"gun_tree": Global.TreeType.GUN_TREE,
	"explorer_tree": Global.TreeType.EXPLORER_TREE,
	"tech_tree": Global.TreeType.TECH_TREE,
	"water_tree": Global.TreeType.WATER_TREE,
	"tall_tree": Global.TreeType.TALL_TREE,
	"slowing_tree": Global.TreeType.SLOWING_TREE,
	"mortar_tree": Global.TreeType.MORTAR_TREE,
	"spiky_tree": Global.TreeType.SPIKY_TREE,
	"icy_tree": Global.TreeType.ICY_TREE,
	"fire_tree": Global.TreeType.FIRE_TREE,
	"sprinkler_tree": Global.TreeType.SPRINKLER_TREE
}

# TODO: fill out all
var tree_short_desc= {
	"default_tree": "Produces nutreents.",
	"mother_tree": "",
	"gun_tree": "Fires at baddies.",
	"explorer_tree": "Has +1 square placement range.",
	"tech_tree": "???",
	"water_tree": "Produces water.",
	"tall_tree": "Very Tall.",
	"slowing_tree": "Slows the baddies.",
	"mortar_tree": "Shoots baddies from afar.",
	"spiky_tree": "Do not touch!",
	"icy_tree": "Icy branches freeze enemies upon contact.",
	"fire_tree": "Lights bugs on fire.",
	"sprinkler_tree": "Douses nearby fires."
}

var enemy_name_dict = {
	"speedle": "SPEEDLE",
	"silk_spitter": "SILK SPITTER",
	"speed_speedle": "SPEEDY SPEEDLE",
	"tank_speedle": "TANKY SPEEDLE",
	"bomb_bug": "BOMB BUG"
}

var enemy_type_dict = {
	"speedle": Global.EnemyType.SPEEDLE,
	"silk_spitter": Global.EnemyType.SILK_SPITTER,
	"speed_speedle": Global.EnemyType.SPEED_SPEEDLE,
	"tank_speedle": Global.EnemyType.TANK_SPEEDLE,
	"bomb_bug":  Global.EnemyType.BOMB_BUG
	}

var enemy_short_desc = {
	"speedle": "A speedy spider beetle...",
	"silk_spitter": "A silky spider.",
	"speed_speedle": "A speedy spider beetle...\nbut faster.",
	"tank_speedle": "A speedy spider beetle...\nbut tankier.",
	"bomb_bug": "An unholy abomination of an ant, a beetle, and a propane tank."
}

# long desc for everything
var desc_dictionary = {
	"default_tree": "We have all seen a default tree\nsometime in our lives.",
	"mother_tree": "The source of all trees.\nProtect it with your life.",
	"gun_tree": "A sandbox tree.\nFought in the Great War.\nShoots at anything that moves.",
	"explorer_tree": "A bubbly maple.\nReaches far to adjacent lands.",
	"tech_tree": "For all your technology needs.",
	"water_tree": "Dredges up them aquifers,\nfor your forest's convenience.",
	"tall_tree": "Sharp and sturdy.\nIt'll take more than a few bugs to chop this one.",
	"slowing_tree": "A close relative to the gun tree. \nSomehow survived growing up in the Arctic.",
	"mortar_tree": "It was enlisted for the Great War, \nbut was too scared to go near the frontline.",
	"spiky_tree": "A prickly tree with sharp branches. \nHurts anything that touches it.",
	"icy_tree": "Cold and sharp. Its branches\nfreeze anything that touches it.",
	"fire_tree": "It shoots fiery hot seeds at enemies.",
	"sprinkler_tree": "Protects nearby trees from blazing fires.",
	
	"city_building": "The last signs of human civilization in the vicinity. You'll have to remove it to plant.",
	"factory": "Despite its abandoned state, the machinery in this factory is still functional. It might be worth looting.",
	"factory_remains": "What if you planted a Tech Tree here?",
	"petrified_tree": "A tree made of stone.\nCould you save it somehow?",
	
	"speedle": "A mutant arthropod dead-set on destroying any and all trees in its path.",
	"silk_spitter": "A mutant caterpillar that spits silken bullets at any trees in its line of sight.",
	"speed_speedle": "The name is redundant.",
	"tank_speedle": "Life in the wilderness has gifted this speedle with the power of armour.",
	"bomb_bug": "An unholy abomination of an ant, a beetle, and a propane tanker.",
	
	"ominous_torch": "What the hell is that thing?",
	
	TerrainMap.TileType.DIRT: "Good old dirt. Nothing special.",
	TerrainMap.TileType.GRASS: "Fertile grasslands, ripe for trees.",
	TerrainMap.TileType.CITY: "Cold, hard asphalt.\nYou'll have to remove it to plant.",
	TerrainMap.TileType.WATER: "Hydrates your nearby trees.\nDon't fall in, though.",
	TerrainMap.TileType.ROAD: "Well-worn tar.\nYou'll have to remove it to plant.",
	TerrainMap.TileType.SAND: "Coarse and rough and irritating\nand it gets everywhere.",
	TerrainMap.TileType.SNOW: "A soft blanket of snow.",
	TerrainMap.TileType.ICE: "Frozen. No place for roots."
}

func _ready():
	add_tree(Global.TreeType.MOTHER_TREE)
	add_tree(Global.TreeType.DEFAULT_TREE)
	add_tree(Global.TreeType.WATER_TREE)
	add_tree(Global.TreeType.GUN_TREE)
	

# add explored tree
func add_tree(tree_type: Global.TreeType):
	if not trees.has(tree_type):
		trees.push_back(tree_type)

# add explored enemy
func add_enemy(enemy_type: Global.EnemyType):
	if not enemies.has(enemy_type):
		enemies.push_back(enemy_type)

func get_trees() -> Array[Global.TreeType]:
	return trees

func get_enemies() -> Array[Global.EnemyType]:
	return enemies

func get_tree_details(type: Global.TreeType) -> String:
	var tree_stat: TreeStatResource = TreeRegistry.get_twee_stat(type)
	var id: String = tree_stat.id
	var content: String = desc_dictionary[id]
	content += "\n\n"
	return content

func get_enemy_details(type: Global.EnemyType) -> String:
	var enemy_stat: EnemyStatResource = EnemyRegistry.get_enemy_stat(type)
	var id: String = enemy_stat.id
	var content: String = desc_dictionary[id]
	content += "\n\n"
	return content

func get_tree_type(id: String) -> Global.TreeType:
	return tree_type_dict[id]

func get_enemy_type(id: String) -> Global.EnemyType:
	return enemy_type_dict[id]

# returns true if given id is of a tree type
func is_tree(id: String) -> bool:
	return tree_name_dict.has(id)
