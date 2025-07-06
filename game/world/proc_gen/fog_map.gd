class_name FogMap
extends TileMapLayer

enum TransparencyLevel {
	OPAQUE = 1,
	SEMI = OPAQUE + 1,
	TRANSPARENT = SEMI + 1,
	CLEAR = TRANSPARENT + 1,
}

const FOG_SIZE = Global.MAP_SIZE * 4

@onready var solid_atlas_coords := get_solid_atlas_coords()
@onready var semi_transparent_atlas_coords := get_semi_transparent_atlas_coords()
@onready var transparent_atlas_coords := get_transparent_atlas_coords()

func _ready() -> void:
	DebugConsole.register("fog", func(args: PackedStringArray):
		visible = !visible
		, "Toggles the visibility of the fog")

func init() -> void:
	for x in range(Global.ORIGIN.x - FOG_SIZE.x / 2, Global.ORIGIN.x + FOG_SIZE.x / 2): # Munn: Ignore how ugly this is lol
		for y in range(Global.ORIGIN.y - FOG_SIZE.y / 2, Global.ORIGIN.y + FOG_SIZE.y / 2):
			var map_coords: Vector2i = Vector2i(x ,y)
			
			var origin: Vector2i = Vector2i(Global.MAP_SIZE) / 2
			
			var distance_from_origin: float = (map_coords - origin).length()
			var distance_scaled = distance_from_origin / (Global.MAP_SIZE.length())
			
			var atlas_coords: Vector2i = get_random_solid_atlas_coords()
			
			set_cell(map_coords, 0, atlas_coords, 0)

func remove_fog_around(map_coords: Vector2i, fog_revealer_component: FogRevealerComponent):
	var offsets = fog_revealer_component.reveal_range_component.get_tiles_in_range()
	var transparency_level = fog_revealer_component.transparency_level
	for offset in offsets:
		var current_coord: Vector2i = map_coords + offset
		
		set_tile_fog(current_coord, transparency_level)
		
		if fog_revealer_component.update_surrounding:
			update_surrounding_transparencies(current_coord, transparency_level)

func update_surrounding_transparencies(map_coord: Vector2i, transparency_level: TransparencyLevel) -> void:
	# Don't do anything if opaque...
	if transparency_level == TransparencyLevel.OPAQUE or transparency_level == TransparencyLevel.SEMI:
		return
	
	var surrounding = get_surrounding_cells(map_coord)
	for cell in surrounding:
		if get_cell_tile_data(cell) != null:
			if get_tile_transparency(cell) < transparency_level:
				set_tile_fog(cell, transparency_level - 1)
			
			update_surrounding_transparencies(cell, transparency_level - 1)

func set_tile_fog(map_coord: Vector2i, transparency_level: TransparencyLevel) -> void:
	match transparency_level:
		TransparencyLevel.OPAQUE:
			set_cell(map_coord, 0, get_random_solid_atlas_coords(), 0)
		TransparencyLevel.SEMI:
			set_cell(map_coord, 0, get_random_transparent_atlas_coords(), 0)
		TransparencyLevel.TRANSPARENT:
			set_cell(map_coord, 0, get_random_most_transparent_atlas_coords(), 0)
		TransparencyLevel.CLEAR:
			erase_cell(map_coord)

func get_tile_transparency(map_coord: Vector2i) -> TransparencyLevel:
	var transparency: TransparencyLevel
	
	var atlas_coords = get_cell_atlas_coords(map_coord)
	if atlas_coords in transparent_atlas_coords:
		return TransparencyLevel.TRANSPARENT
	elif atlas_coords in semi_transparent_atlas_coords:
		return TransparencyLevel.SEMI
	elif atlas_coords in solid_atlas_coords:
		return TransparencyLevel.OPAQUE
	else:
		return TransparencyLevel.CLEAR

func is_tile_foggy(map_coord) -> bool: 
	if get_cell_tile_data(map_coord) == null:
		return false
	
	var atlas_coords = get_cell_atlas_coords(map_coord)
	if atlas_coords in semi_transparent_atlas_coords or atlas_coords in transparent_atlas_coords:
		return false
	
	return true

func get_solid_atlas_coords() -> Array[Vector2i]:
	var fog_source: TileSetSource = tile_set.get_source(0)
	
	var array: Array[Vector2i] = []
	for i in range(0, 8):
		for j in range(0, 2):
			array.append(Vector2i(i, j * 2))
	
	return array

func get_semi_transparent_atlas_coords() -> Array[Vector2i]:
	var fog_source: TileSetSource = tile_set.get_source(0)
	
	var array: Array[Vector2i] = []
	for i in range(0, 8):
		for j in range(2, 3):
			array.append(Vector2i(i, j * 2))
	
	return array

func get_transparent_atlas_coords() -> Array[Vector2i]:
	var fog_source: TileSetSource = tile_set.get_source(0)
	
	var array: Array[Vector2i] = []
	for i in range(0, 8):
		for j in range(3, 4):
			array.append(Vector2i(i, j * 2))
	
	return array

# Munn: get_random_solid/transparent_atlas_coords both have HARD CODED THINGS, so if you change the fog tilesheet, CHANGE THE HARD CODED PARTS TOO (i have marked them)
func get_random_solid_atlas_coords() -> Vector2i:
	return Vector2i(randi_range(0, 7), randi_range(0, 1) * 2)

func get_random_transparent_atlas_coords() -> Vector2i:
	return Vector2i(randi_range(0, 7), 2 * 2)

func get_random_most_transparent_atlas_coords() -> Vector2i:
	return Vector2i(randi_range(0, 7), 3 * 2)
