class_name ShopDetailPanel
extends PanelContainer

@onready var title: RichTextLabel = %Title
@onready var texture: TextureRect = %Texture
@onready var description: RichTextLabel = %Description

func set_details(shop_card: ShopCard):
	title.text = shop_card.tree_stat.name
	texture.texture.atlas = shop_card.tree_stat.tree_icon
	description.text = shop_card.tree_stat.description
