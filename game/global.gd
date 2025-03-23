extends Node

const MAP_SIZE: Vector2i = Vector2i(1, 1) * 40
const ORIGIN: Vector2i = MAP_SIZE / 2

var structure_map: BuildingMap
var terrain_map: TerrainMap
var fog_map: FogMap
var clock: Clock
var tech_menu: TechMenu

enum GameState {
	PLAYING = 0,
	VICTORY = PLAYING + 1,
	MAIN_MENU = VICTORY + 1,
	GAME_OVER = MAIN_MENU + 1,
}

var game_state

func _ready() -> void:
	game_state = GameState.MAIN_MENU


func update_globals():
	structure_map = get_tree().get_first_node_in_group("structure_map")
	terrain_map = get_tree().get_first_node_in_group("terrain_map")
	fog_map = get_tree().get_first_node_in_group("fog_map")
	clock = get_tree().get_first_node_in_group("clock")
	tech_menu = get_tree().get_first_node_in_group("tech_menu")
