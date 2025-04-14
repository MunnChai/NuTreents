class_name WaterOverlay
extends Overlay

const WATER_HIGHLIGHT = preload("res://overlays/water_overlay/water_highlight.tscn")
var highlights: Dictionary[Vector2i, WaterHighlight]

const HEALTHY_WATER_GAIN = 15
const UNHEALTHY_WATER_GAIN = 0

const HEALTHY_COLOR: Color = Color.SKY_BLUE
const UNHEALTHY_COLOR: Color = Color.INDIAN_RED
const DEHYDRATED_COLOR: Color = Color.DARK_RED

func update_highlights() -> void:
	# PENTUPLE FOR LOOP ON EVERY FRAME? satisfactory
	
	# Remove trees that no longer exist
	var to_erase: Array[Vector2i] = []
	for pos: Vector2i in highlights.keys():
		if (!TreeManager.forest_map.has(pos)):
			to_erase.push_back(pos)
	for pos: Vector2i in to_erase:
		remove_child(highlights[pos])
		highlights.erase(pos)
	
	# Add trees that aren't in highlights
	for pos: Vector2i in TreeManager.forest_map.keys():
		if (!highlights.has(pos)):
			var new_highlight = WATER_HIGHLIGHT.instantiate()
			var true_pos = Global.structure_map.map_to_local(pos)
			new_highlight.global_position = true_pos
			
			add_child(new_highlight)
			highlights[pos] = new_highlight
	
	
	# Update highlights according to forest
	for pos: Vector2i in highlights:
		var tree: Twee = TreeManager.tree_map[pos]
		var forest: Forest = TreeManager.forests[tree.forest]
		
		var highlight: WaterHighlight = highlights[pos]
		
		var gain = clamp(forest.water_gain, UNHEALTHY_WATER_GAIN, HEALTHY_WATER_GAIN) / (HEALTHY_WATER_GAIN - UNHEALTHY_WATER_GAIN)
		
		var color = lerp(UNHEALTHY_COLOR, HEALTHY_COLOR, gain)
		
		if (forest.water_gain < 0):
			color = DEHYDRATED_COLOR
		
		highlight.self_modulate = color
		highlight.self_modulate.a = 0.75
		
		var net_water = tree.get_water_gain() - tree.get_water_maint()
		
		highlight.set_label_number(net_water)
