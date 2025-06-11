class_name InfoBoxDetector
extends Node

## Detect what's at this position in this world, 
## then throw it over to the InfoBox for handling...
func detect(pos: Vector2i) -> void:
	var terrain_map = Global.terrain_map
	var building_map = Global.structure_map
	var tile_type: TerrainMap.TileType = terrain_map.get_tile_biome(pos)
	var building_node: Node2D = building_map.get_building_node(pos)
	var enemies: Array = EnemyManager.instance.get_enemies()
	
	# Munn: shouldn't actually be too performance heavy, since we should have like < 50 enemies at a time
	var is_hovering_enemy: bool = false
	var hovered_enemy: Enemy
	for enemy: Enemy in enemies:
		if (!enemy):
			continue
		if (enemy.map_position == pos):
			hovered_enemy = enemy
			is_hovering_enemy = true
			break
	
	if (is_hovering_enemy):
		InfoBox.get_instance().show_content_for(pos, hovered_enemy.id, tile_type)
	elif building_node != null:
		InfoBox.get_instance().show_content_for(pos, building_node.get_id(), tile_type)
	else:
		InfoBox.get_instance().show_content_for(pos, "no_building", tile_type)
