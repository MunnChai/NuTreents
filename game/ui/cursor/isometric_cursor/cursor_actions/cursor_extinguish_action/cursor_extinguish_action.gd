class_name CursorExtinguishAction
extends CursorAction

## Water bucket from GOD

@export var square_size := 3
@export var ignite_instead := false

## PUT OUT FIRE in a square
func execute_primary_action(cursor: IsometricCursor) -> void:
	var iso_position := cursor.iso_position
	for x: int in range(iso_position.x - square_size / 2.0, iso_position.x + square_size / 2.0):
		for y: int in range(iso_position.y - square_size / 2.0, iso_position.y + square_size / 2.0):
			var coord := Vector2i(x, y)
			var entity = MapUtility.get_entity_at(coord)
			if entity != null:
				if Components.has_component(entity, FlammableComponent, "", true):
					var flammable := Components.get_component(entity, FlammableComponent, "", true) as FlammableComponent
					flammable.extinguish() if not ignite_instead else flammable.ignite()
