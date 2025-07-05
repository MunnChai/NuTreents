class_name AlmanacEnemyCard
extends AlmanacCardBase

var type: Global.EnemyType
var enemy_stat: EnemyStatResource

@onready var title: RichTextLabel = %Title
@onready var icon: TextureRect = %Icon

func _ready():
	init_enemy_card()

func init_enemy_card():
	enemy_stat = EnemyRegistry.get_enemy_stat(type)
	title.text = enemy_stat.name
	icon.texture = icon.texture.duplicate()
	icon.texture.atlas = enemy_stat.enemy_icon

func get_title() -> String:
	return enemy_stat.name

func get_icon() -> Texture2D:
	return enemy_stat.enemy_icon

func get_details() -> String:
	var content: String = AlmanacInfo.get_enemy_details(type)
	
	content += "HP: " + var_to_str(enemy_stat.hp) + "\n"
	content += "Attack cooldown: " + var_to_str(enemy_stat.action_cooldown) + "s\n"
	content += "Damage: " + var_to_str(enemy_stat.attack_damage) + "\n"
	content += "Range: " + var_to_str(enemy_stat.attack_range) + "\n"
	return content
