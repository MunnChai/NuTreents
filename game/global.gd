extends Node

const NUM_SAVES: int = 5

const MAP_SIZE: Vector2i = Vector2i(1, 1) * 40
const ORIGIN: Vector2i = Vector2(0, 0)



## ACCESS REFERENCES

var structure_map: BuildingMap
var terrain_map: TerrainMap
var fog_map: FogMap
var clock: Clock
var tech_menu: TechMenu
var overlay_manager: OverlayManager
var camera: Camera2D
#var screen_ui: ScreenUI

## STRUCTURE IDS

enum StructureType {
	CITY_BUILDING = 0,
	FACTORY = CITY_BUILDING + 1,
	FACTORY_REMAINS = FACTORY + 1,
	DECOR = FACTORY_REMAINS + 1,
	OMINOUS_TORCH = DECOR + 1,
	PETRIFIED_TREE = OMINOUS_TORCH + 1,
}

## TREE IDS

enum TreeType {
	MOTHER_TREE = 0,
	DEFAULT_TREE = MOTHER_TREE + 1,
	GUN_TREE = DEFAULT_TREE + 1,
	WATER_TREE = GUN_TREE + 1,
	TECH_TREE = WATER_TREE + 1,
	EXPLORER_TREE = TECH_TREE + 1,
	TALL_TREE = EXPLORER_TREE + 1,
	SLOWING_TREE = TALL_TREE + 1,
	MORTAR_TREE = SLOWING_TREE + 1,
	SPIKY_TREE = MORTAR_TREE + 1,
	ICY_TREE = SPIKY_TREE + 1,
	SPRINKLER_TREE = ICY_TREE + 1,
	FIRE_TREE = SPRINKLER_TREE + 1,
}

## ENEMY IDS 

enum EnemyType {
	SPEEDLE = 0,
	SILK_SPITTER = SPEEDLE + 1,
	TANK_SPEEDLE = SILK_SPITTER + 1,
	SPEED_SPEEDLE = TANK_SPEEDLE + 1,
	BOMB_BUG = SPEED_SPEEDLE + 1
}

## GAME STATE

enum GameState {
	PLAYING = 0,
	VICTORY = PLAYING + 1,
	MAIN_MENU = VICTORY + 1,
	GAME_OVER = MAIN_MENU + 1,
}

enum WorldSize {
	SMALL = 1,
	MEDIUM = 2,
	LARGE = 3,
}

var game_state

# Session Metadata
var world_name: String
var session_id: int
var session_seed: int
var session_data: Dictionary
var current_world_size: WorldSize = WorldSize.SMALL

# Pausing info
var previous_time_scale: float
var is_paused := false

func _ready() -> void:
	game_state = GameState.MAIN_MENU
	
	NutreentsDiscordRPC.instance.start()
	
	# For randomness upon first opening the game
	set_seed(int(Time.get_unix_time_from_system()))
	
	## Register some useful commands...
	await get_tree().process_frame # Wait for setup
	
	DebugConsole.register("lang", func (args: PackedStringArray):
		if args.size() != 1:
			Logger.log("Usage: lang [language-code]")
		else:
			TranslationServer.set_locale(args[0])
		)

func update_globals():
	structure_map = get_tree().get_first_node_in_group("structure_map")
	terrain_map = get_tree().get_first_node_in_group("terrain_map")
	fog_map = get_tree().get_first_node_in_group("fog_map")
	clock = get_tree().get_first_node_in_group("clock")
	tech_menu = get_tree().get_first_node_in_group("tech_menu")
	overlay_manager = get_tree().get_first_node_in_group("overlay_manager")
	camera = get_tree().get_first_node_in_group("camera")


#region Metadata

func new_seed() -> int:
	# Set seed as a semi random number (time since unix epoch or whatever)
	var new_seed = int(Time.get_unix_time_from_system())
	seed(new_seed)
	
	# Generate another semi random number, that feels more random
	new_seed = randi()
	seed(new_seed)
	session_seed = new_seed
	return new_seed

# Sets the seed for all rand calls, eg. randi(), Array.piok_random(), Array.shuffle(), etc.
func set_seed(seed: int) -> void:
	session_seed = seed
	seed(session_seed) 

func get_seed() -> int:
	return session_seed

func set_world_name(name: String) -> void:
	world_name = name

func get_world_name() -> String:
	return world_name

func set_session_id(id: int) -> void:
	session_id = id

func get_session_id() -> int:
	return session_id

func set_metadata(metadata: Dictionary):
	if not metadata.has_all(["world_name", "session_id", "seed", "world_size"]):
		printerr("WARNING: Attempted to set Global metadata without proper keys!")
		return
	
	world_name = metadata["world_name"]
	session_id = metadata["session_id"]
	session_seed = metadata["seed"]
	current_world_size = metadata["world_size"]

func get_metadata() -> Dictionary:
	var metadata = {
		"world_name": world_name,
		"session_id": session_id,
		"seed": session_seed,
		"world_size": current_world_size,
	}
	
	return metadata

#endregion


#region Pausing

func pause_game(hide_tooltip := true) -> void:
	if is_paused:
		return
	
	is_paused = true
	get_tree().paused = true 
	
	if FloatingTooltip.instance:
		FloatingTooltip.instance.force_hidden = hide_tooltip
	
	previous_time_scale = Engine.time_scale
	Engine.time_scale = 1.0

func unpause_game(show_tooltip := true) -> void:
	if not is_paused:
		return
	
	is_paused = false
	Engine.time_scale = previous_time_scale
	
	if FloatingTooltip.instance:
		FloatingTooltip.instance.force_hidden = !show_tooltip
	
	get_tree().paused = false

#endregion
