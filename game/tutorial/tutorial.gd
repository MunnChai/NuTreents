extends Node

var clock: Clock

# Parent _ready() is called after all children _ready()s have been called, 
# so entire scene will be done when this is called
func _ready():
	Global.update_globals()
	
	TreeManager.call_deferred("start_game")
	Global.game_state = Global.GameState.PLAYING
	
	# Find the clock and pause time
	clock = find_child("Clock", true) 
	clock.is_paused = true
	Global.terrain_map.add_decor()
	#var petrified_tree = StructureRegistry.get_new_structure(Global.StructureType.PETRIFIED_TREE)
	#Global.structure_map.add_structure(Vector2i(-6, -6), petrified_tree)
	#
	#var petrified_component: PetrifiedTreeComponent = Components.get_component(petrified_tree, PetrifiedTreeComponent)
	#petrified_component.set_tree_type(Global.TreeType.SPIKY_TREE)
