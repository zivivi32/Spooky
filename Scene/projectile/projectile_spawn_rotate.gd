extends Node3D

@export var min_rotate: float = 0
@export var max_rotate: float = 45

func _ready() -> void:
	# Rotate the node on the Z axis by a random angle between 0 and 360 degrees
	randomize()  # Ensure the randomness is different each time the scene runs
	var random_angle = randf_range(min_rotate, max_rotate)  # Random angle in degrees
	# Convert degrees to radians (as Godot uses radians for rotation)
	var random_angle_radians = deg_to_rad(random_angle)
	# Set the rotation on the Z axis
	rotate_z(random_angle_radians)
