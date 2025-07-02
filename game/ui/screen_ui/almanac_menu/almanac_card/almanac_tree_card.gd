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
