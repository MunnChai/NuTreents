class_name DecorComposed
extends StructureComposed

@onready var atlas_randomizer_component: AtlasRandomizerComponent = $AtlasRandomizerComponent

var tile_type: TerrainMap.TileType

func set_decor_type(type: TerrainMap.TileType):
	tile_type = type
	match type:
		TerrainMap.TileType.GRASS:
			atlas_randomizer_component.set_y_frame(0)
		TerrainMap.TileType.DIRT:
			atlas_randomizer_component.set_y_frame(1)
		TerrainMap.TileType.CITY:
			atlas_randomizer_component.set_y_frame(2)
