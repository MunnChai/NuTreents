class_name ShopDetailPanel
extends PanelContainer

@onready var title: RichTextLabel = %Title
@onready var texture: TextureRect = %Texture
@onready var description: RichTextLabel = %Description

func set_details(shop_card: ShopCard):
	if shop_card == null:
		title.text = "Select a Tree or Power"
		texture.texture.atlas = null
		description.text = ""
		return
	
	title.text = shop_card.tree_stat.name
	texture.texture.atlas = shop_card.tree_stat.tree_icon
	description.text = shop_card.tree_stat.description
