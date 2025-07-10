extends RichTextLabel

func _ready() -> void:
	DebugConsole.register("fps", func(args: PackedStringArray):
		visible = !visible
		, "Gives mother tree lots of health")

func _process(delta: float) -> void:
	if visible:
		text = "FPS: " + str(Engine.get_frames_per_second()) + "\nNumTrees: " + str(TreeManager.get_tree_map().size())
