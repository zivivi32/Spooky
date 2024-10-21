extends Node3D

@export var time: float = 0
@export var amplitude: float = 5
@export var frequency: float = 1

func _process(delta):
	
	rotate_y(2 * delta) # Rotation
	position.y += (cos(time * amplitude) * frequency) * delta # Sine movement
	
	time += delta
