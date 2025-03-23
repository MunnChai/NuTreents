extends Label

var y_velocity := 0.0
var x_velocity := 0.0
var gravity := 200.0

func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	y_velocity = rng.randf_range(-50, -100)
	x_velocity = rng.randf_range(-20, 20)

func _process(delta: float) -> void:
	$Label.text = text
	$Label2.text = text
	$Label3.text = text
	$Label4.text = text
	$Label5.text = text
	
	position.x += x_velocity * delta
	position.y += y_velocity * delta
	y_velocity += gravity * delta
