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
#var screen_ui: ScreenUI

## STRUCTURE IDS

enum StructureType {
	CITY_BUILDING = 0,
	FACTORY = CITY_BUILDING + 1,
	DECOR = FACTORY + 1
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

# SESSION_DATA
var session_id: int
var session_seed: int
var session_data: Dictionary
var current_world_size: WorldSize = WorldSize.SMALL

func _ready() -> void:
	game_state = GameState.MAIN_MENU
	
	NutreentsDiscordRPC.start()
	
	# For randomness upon first opening the game
	set_seed(int(Time.get_unix_time_from_system()))

func update_globals():
	structure_map = get_tree().get_first_node_in_group("structure_map")
	terrain_map = get_tree().get_first_node_in_group("terrain_map")
	fog_map = get_tree().get_first_node_in_group("fog_map")
	clock = get_tree().get_first_node_in_group("clock")
	tech_menu = get_tree().get_first_node_in_group("tech_menu")
	overlay_manager = get_tree().get_first_node_in_group("overlay_manager")

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
