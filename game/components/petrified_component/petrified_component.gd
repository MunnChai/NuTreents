class_name PetrifiedComponent
extends Node2D

var actor: Node2D
var depetrified: bool = false

func _ready() -> void:
	actor = get_owner()
	
	_get_components()
	_connect_signals()

func _get_components() -> void:
	pass

func _connect_signals() -> void:
	pass

func depetrify() -> void:
	if depetrified:
		return
	
	depetrified = true
