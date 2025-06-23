class_name DecorBehaviourComponent
extends StructureBehaviourComponent

@export_group("Components")
@export var atlas_randomizer_component: AtlasRandomizerComponent

var tile_type: TerrainMap.TileType

func _ready() -> void:
	super._ready()
	
	await get_tree().process_frame
	
	var grid_position_component: GridPositionComponent = Components.get_component(actor, GridPositionComponent)
	set_decor_type(Global.terrain_map.get_tile_biome(grid_position_component.get_pos()))

func _get_components() -> void:
	super._get_components()
	
	if not atlas_randomizer_component:
		atlas_randomizer_component = Components.get_component(actor, AtlasRandomizerComponent)

func set_decor_type(type: TerrainMap.TileType):
	tile_type = type
	match type:
		TerrainMap.TileType.GRASS:
			atlas_randomizer_component.set_y_frame(0)
		TerrainMap.TileType.DIRT:
			atlas_randomizer_component.set_y_frame(1)
		TerrainMap.TileType.CITY:
			atlas_randomizer_component.set_y_frame(2)
		TerrainMap.TileType.DESERT:
			atlas_randomizer_component.set_y_frame(0)
