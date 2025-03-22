class_name WaterTree
extends Twee


 
func _ready():
	super._ready()
	
	sprite.hframes = 9
	sprite.vframes = 3
	sprite.position.y = -16
	
	# Calculate adjacency on start of runtime, instead of each frame
	

## update local storage and use water for maintainence
## returns the right amount of res to system
func update(delta: float) -> Vector3:
	var prev = storage # record old storage number
	
	# add new water to storage, storage equals at most max_water
	storage = min(storage + gain.y, max_water)
	
	var g = Vector3(gain.x, storage - prev, gain.z)
	return g


func play_large_tree_animation():
	animation_player.play("pump")


func get_upgraded_stats_from_resource(tree_stat: TreeStatResource):
	super.get_upgraded_stats_from_resource(tree_stat)
	
	gain.y = tree_stat.gain_2.y + water_bonus
