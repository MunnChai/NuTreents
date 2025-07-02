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
