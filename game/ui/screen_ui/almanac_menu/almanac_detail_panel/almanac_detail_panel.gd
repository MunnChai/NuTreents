class_name AlmanacDetailPanel
extends PanelContainer

@onready var title: RichTextLabel = %Title
@onready var texture: TextureRect = %Texture
@onready var description: RichTextLabel = %Description

func _ready():
	description.set_fit_content(true)

func set_card(card: AlmanacCardBase):
	if card == null:
		title.text = "Select A Card To View Info"
		texture.texture.atlas = null
		description.text = ""
	else:
		title.text = card.get_title()
		texture.texture.atlas = card.get_icon()
		description.text = card.get_details()

func set_title(content: String):
	title.text = content
