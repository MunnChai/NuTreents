@tool
class_name ResearchNode
extends Control

enum ResearchState {
	LOCKED = 0, 
	UNLOCKABLE = LOCKED + 1,
	UNLOCKED = UNLOCKABLE + 1,
}


@export var state: ResearchState = ResearchState.LOCKED:
	set(new_state):
		state = new_state
		match new_state:
			ResearchState.LOCKED:
				modulate = Color("#646464")
				get_node("%Background").texture = locked_icon
			ResearchState.UNLOCKABLE:
				modulate = Color.WHITE
				get_node("%Background").texture = unlockable_icon
			ResearchState.UNLOCKED:
				modulate = Color.WHITE
				get_node("%Background").texture = unlocked_icon

@export var resource: ResearchNodeResource:
	set(new_resource):
		if new_resource != null:
			get_node("%Icon").texture = new_resource.icon
		else:
			get_node("%Icon").texture = null
		resource = new_resource

@export_group("BackgroundTextures")
@export var locked_icon: Texture2D
@export var unlockable_icon: Texture2D
@export var unlocked_icon: Texture2D

@onready var background: NinePatchRect = %Background
@onready var icon: TextureRect = %Icon

func unlock_research_node() -> void:
	# Set Stuff
	pass
