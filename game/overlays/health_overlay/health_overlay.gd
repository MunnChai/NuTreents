class_name HealthOverlay
extends Overlay

const HEALTH_HIGHLIGHT = preload("res://overlays/health_overlay/health_highlight.tscn")
var highlights: Dictionary[Vector2i, Sprite2D]

const HEALTHY_COLOR: Color = Color.GREEN_YELLOW
const UNHEALTHY_COLOR: Color = Color.DARK_RED

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
			var new_highlight = HEALTH_HIGHLIGHT.instantiate()
			var true_pos = Global.structure_map.map_to_local(pos)
			new_highlight.global_position = true_pos
			
			add_child(new_highlight)
			highlights[pos] = new_highlight
	
	
	# Update highlights according to forest
	for pos: Vector2i in highlights:
		var tree: Twee = TreeManager.tree_map[pos]
		var highlight = highlights[pos]
		
		var tree_max_hp: float = tree.tree_stat.hp
		if (tree.is_large):
			tree_max_hp = tree.tree_stat.hp_2
		
		var hp_percent = tree.hp / tree_max_hp
		
		var color = lerp(UNHEALTHY_COLOR, HEALTHY_COLOR, hp_percent)
		
		highlight.modulate = color
		highlight.modulate.a = 0.75
