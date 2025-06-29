class_name AoeComponent
extends HitboxComponent

@export var explode_range: float
var grid_range_component: GridRangeComponent
var grid_pos_component: GridPositionComponent

var actor: Node2D
var range: Array[Vector2i]

func _ready() -> void:
	actor = get_parent()
	if not grid_range_component:
		grid_range_component = Components.get_component(actor, GridRangeComponent)
	if not grid_pos_component:
		grid_pos_component = Components.get_component(actor, GridPositionComponent)
	grid_range_component.range = explode_range
	range = grid_range_component.get_tiles_in_range()
	range.erase(Vector2i(0,0))

func explode(pos: Vector2i) -> void:
	for tile in range:
		var adj_pos: Vector2i = pos + tile
		var entity: Node2D = MapUtility.get_entity_at(adj_pos)
		if not entity:
			continue
		var health: HealthComponent = Components.get_component(entity, HealthComponent)
		if not health:
			continue
		health.subtract_health(damage)
