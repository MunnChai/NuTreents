extends Node

func _ready() -> void:
	NutreentsDiscordRPC.instance = DiscordObject.new()

func _process(delta: float) -> void:
	DiscordRPC.run_callbacks()
