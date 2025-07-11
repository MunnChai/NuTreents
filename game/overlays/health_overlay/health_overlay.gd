class_name HealthOverlay
extends Overlay

const HEALTH_HIGHLIGHT = preload("res://overlays/health_overlay/health_highlight.tscn")
var highlights: Dictionary[Vector2i, HealthHighlight]

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
		var tree: Node2D  = TreeManager.tree_map[pos]
		var highlight: HealthHighlight = highlights[pos]
		
		var health_component: HealthComponent = Components.get_component(tree, HealthComponent)
		
		var tree_max_hp: float = health_component.get_max_health()
		
		var hp_percent = health_component.get_current_health() / tree_max_hp
		
		var color = lerp(UNHEALTHY_COLOR, HEALTHY_COLOR, hp_percent)
		
		highlight.self_modulate = color
		highlight.self_modulate.a = 0.75
		
		highlight.set_label_number(health_component.get_current_health())
