class_name AlmanacTreeCard
extends AlmanacCardBase

var type: Global.TreeType
var tree_stat: TreeStatResource

@onready var title: RichTextLabel = %Title
@onready var icon: TextureRect = %Icon


func _ready():
	init_tree_card()

func init_tree_card():
	tree_stat = TreeRegistry.get_twee_stat(type)
	title.text = tree_stat.name
	icon.texture = icon.texture.duplicate()
	icon.texture.atlas = tree_stat.tree_icon

func get_title() -> String:
	return tree_stat.name

func get_icon() -> Texture2D:
	return tree_stat.tree_icon

func get_details() -> String:
	var content: String = AlmanacInfo.get_tree_details(type)
	if type == Global.TreeType.MOTHER_TREE:
		content += "HP: " + var_to_str(tree_stat.hp) + "\n"
		content += "Max water storage: " + var_to_str(tree_stat.max_water) + "\n"
		content += "Gains: +" + var_to_str(tree_stat.gain.x) + " N/s" + "  "
		content += "+" + var_to_str(tree_stat.gain.y) + " W/s" + "\n"
		return content
	
	content += "Primary Stats\n"
	content += "HP: " + var_to_str(tree_stat.hp) + "\n"
	content += "Max water storage: " + var_to_str(tree_stat.max_water) + "\n"
	content += "Gains: +" + var_to_str(tree_stat.gain.x) + " N/s" + "  "
	content += "+" + var_to_str(tree_stat.gain.y) + " W/s" + "\n"
	content += "Maintenence: -" + var_to_str(tree_stat.maint) + "W/s" + "\n"
	content += "Time to grow: " + var_to_str(tree_stat.time_to_grow) + "s" + "\n"
	content += "Cost to purchase: " + var_to_str(tree_stat.cost_to_purchase) + "N" + "\n"
	
	if tree_stat.attack_damage > 0:
		content += "Damage: " + var_to_str(tree_stat.attack_damage) + "\n"
		content += "Attack range: " + var_to_str(tree_stat.attack_range) + "\n"
		content += "Cooldown time:" + var_to_str(tree_stat.attack_cooldown) + "s\n"
	
	content += "\n"
	content += "Secondary Stats\n"
	content += "HP: " + var_to_str(tree_stat.hp_2) + "\n"
	content += "Max water storage: " + var_to_str(tree_stat.max_water_2) + "\n"
	content += "Gains: +" + var_to_str(tree_stat.gain_2.x) + " N/s" + "  "
	content += "+" + var_to_str(tree_stat.gain_2.y) + " W/s" + "\n"
	content += "Maintenence: -" + var_to_str(tree_stat.maint_2) + "W/s" + "\n"
	content += "Time to grow: " + var_to_str(tree_stat.time_to_grow_2) + "s" + "\n"
	content += "Cost to purchase: " + var_to_str(tree_stat.cost_to_purchase_2) + "N" + "\n"
	
	if tree_stat.attack_damage_2 > 0:
		content += "Damage: " + var_to_str(tree_stat.attack_damage_2) + "\n"
		content += "Attack range: " + var_to_str(tree_stat.attack_range_2) + "\n"
		content += "Cooldown time:" + var_to_str(tree_stat.attack_cooldown_2) + "s\n"
	return content
