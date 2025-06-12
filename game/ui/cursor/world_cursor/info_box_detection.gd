class_name InfoBoxDetector
extends Node

## Detect what's at this position in this world, 
## then throw it over to the InfoBox for handling...
func detect(pos: Vector2i) -> void:
	var tile_type: TerrainMap.TileType = Global.terrain_map.get_tile_biome(pos)
	
	var entity: Node = MapUtility.get_entity_at(pos)
	var id_component: TooltipIdentifierComponent = null
	
	if Components.has_component(entity, TooltipIdentifierComponent):
		id_component = Components.get_component(entity, TooltipIdentifierComponent)
	
	if id_component != null:
		InfoBox.get_instance().show_content_for(pos, id_component.get_id(), tile_type)
	else:
		InfoBox.get_instance().show_content_for(pos, "no_building", tile_type)
