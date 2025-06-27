## Credit to u/twinpixelriot and u/ironmaiden947 for this effect 
## https://www.reddit.com/r/godot/comments/nimkqg/how_to_break_a_2d_sprite_in_a_cool_and_easy_way/

class_name SpriteShatterComponent
extends Node2D

## The node to shatter
@export var actor: Sprite2D

## Number of break points.
@export_range(0, 200) var num_break_points: int = 5

## Prevents slim triangles being created at the sprite edges.
@export var edge_threshold: float = 2.0 

## Minimum impulse of the shards upon breaking.
@export var rand_x_force: float = 20.0 

## Maximum impulse of the shards upon breaking.
@export var rand_y_force: float = 40.0

## How long the shards live.
@export var lifetime: float = 1.0

## Whether to display the triangles, for debug purposes.
@export var display_triangles: bool = false

const SHATTER_PIECE = preload("./shatter_piece.tscn")

var triangles = []
var shatter_pieces = []

signal shatter_finished

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_button_2"):
		create_shatter_pieces()
		shatter()

func create_shatter_pieces() -> void:
	var _rect = actor.get_rect()
	
	# Reset pieces
	triangles = []
	shatter_pieces = []
	
	var points = []
	#add outer frame points
	points.append(_rect.position)
	points.append(_rect.position + Vector2(_rect.size.x, 0))
	points.append(_rect.position + Vector2(0, _rect.size.y))
	points.append(_rect.end)
	
	#add random break points
	for i in num_break_points:
		var p = _rect.position + Vector2(randi_range(0, _rect.size.x), randi_range(0, _rect.size.y))
		#move outer points onto rectangle edges
		if p.x < _rect.position.x + edge_threshold:
			p.x = _rect.position.x
		elif p.x > _rect.end.x - edge_threshold:
			p.x = _rect.end.x
		if p.y < _rect.position.y + edge_threshold:
			p.y = _rect.position.y
		elif p.y > _rect.end.y - edge_threshold:
			p.y = _rect.end.y
		points.append(p)
	
	#calculate triangles
	var delaunay = Geometry2D.triangulate_delaunay(points)
	for i in range(0, delaunay.size(), 3):
		triangles.append([points[delaunay[i + 2]], points[delaunay[i + 1]], points[delaunay[i]]])
	
	#create RigidBody2D shards
	var texture = actor.texture
	for t in triangles:
		var center = Vector2((t[0].x + t[1].x + t[2].x)/3.0,(t[0].y + t[1].y + t[2].y)/3.0)
		
		var shatter_piece = SHATTER_PIECE.instantiate()
		add_child(shatter_piece)
		
		shatter_piece.position = center
		shatter_piece.hide()
		shatter_pieces.append(shatter_piece)
		
		#setup polygons
		shatter_piece.polygon_2d.texture = texture
		shatter_piece.polygon_2d.polygon = t
		shatter_piece.polygon_2d.position = -center
		shatter_piece.polygon_2d.texture_offset = texture.get_size() / 2 
		
		if actor.material:
			shatter_piece.polygon_2d.material = actor.material
	
	queue_redraw()

const NUM_SHAKE_FRAMES: int = 9
const SHAKE_DURATION: float = 0.4
const X_SHAKE_MAGNITUDE: int = 1
const Y_SHAKE_MAGNITUDE: int = 1

const FLASH_DURATION: float = 0.1
func shatter() -> void:
	actor.modulate.a = 1.0
	
	# Randomly shake for SHAKE_DURATION seconds
	var init_position: Vector2 = actor.position
	for i in NUM_SHAKE_FRAMES:
		var rand_x = randi_range(-X_SHAKE_MAGNITUDE, X_SHAKE_MAGNITUDE)
		var rand_y = randi_range(-Y_SHAKE_MAGNITUDE, Y_SHAKE_MAGNITUDE)
		actor.position = init_position + Vector2(rand_x, rand_y)
		
		await get_tree().create_timer(SHAKE_DURATION / NUM_SHAKE_FRAMES).timeout
	
	# Reset to initial position
	actor.position = init_position
	
	# Flash sprite for FLASH_DURATION seconds
	if actor.material is ShaderMaterial:
		actor.material.set_shader_parameter("is_flashing", true)
		
		await get_tree().create_timer(FLASH_DURATION).timeout
		
		actor.material.set_shader_parameter("is_flashing", false)
	
	# Hide sprite
	actor.modulate.a = 0.0
	
	# Show shattered pieces
	for shatter_piece in shatter_pieces:
		shatter_piece.show()
		var rand_x: float = randf_range(-rand_x_force, rand_x_force)
		var rand_y: float = randf_range(-rand_y_force, 0) # Give it a "bounce" upwards
		
		shatter_piece.velocity = Vector2(rand_x, rand_y)
		shatter_piece.lifetime = lifetime
	
	shatter_finished.emit()

func set_sprite_to_copy(sprite: Sprite2D) -> void:
	actor = sprite

func _draw() -> void:
	if display_triangles:
		for i in triangles:
			draw_line(i[0], i[1], Color.WHITE, 1)
			draw_line(i[1], i[2], Color.WHITE, 1)
			draw_line(i[2], i[0], Color.WHITE, 1)
