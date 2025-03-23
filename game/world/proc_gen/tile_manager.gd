class_name TileManager
extends Node2D

@onready var highlight: Sprite2D = $Highlight
@onready var cursor: AnimatedSprite2D = $Cursor
@onready var terrain_map: TerrainMap = $GroundLayer
@onready var building_map: BuildingMap = $BuildingLayer

func _process(_delta: float) -> void:
	
	if (TreeManager.is_mother_dead()):
		# if mother is dead
		return
	#update_highlight()
	#
	#update_adjacent_tile_transparencies()
