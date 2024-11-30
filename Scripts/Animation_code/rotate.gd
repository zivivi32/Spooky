extends Node3D

# Exported variables to customize the rotation axis and speed
@export var rotation_axis: Vector3 = Vector3.UP  # Default to the Y-axis
@export var rotation_speed: float = 1.0  # Rotation speed in degrees per second

func _process(delta: float) -> void:
	# Convert speed to radians and calculate rotation for this frame
	var rotation_amount = rotation_speed * delta
	rotate(rotation_axis.normalized(), deg_to_rad(rotation_amount))
