extends SpotLight3D

@export var cycle_duration_x: float = 20.0
@export var cycle_duration_z: float = 20.0
@export var movement_magnitude_x: float = 1.0
@export var movement_magnitude_z: float = 1.0
@export var time_offset_x: float = 0.0
@export var time_offset_z: float = 0.0
@export var movement_curve_x: Curve = null
@export var movement_curve_z: Curve = null

var initial_position: Vector3
var time_elapsed: float = 0.0

func _ready():
	initial_position = position

func _process(delta):
	time_elapsed += delta  # Increment the custom timer with delta
	update_motion()


func update_motion():
	# Use fmod for floating-point modulus operation
	var time_x = fmod(time_elapsed, cycle_duration_x) / cycle_duration_x
	var time_z = fmod(time_elapsed, cycle_duration_z) / cycle_duration_z

	# Evaluate curves and apply magnitude and offsets
	var new_x = movement_curve_x.sample(time_x + time_offset_x) * movement_magnitude_x
	var new_z = movement_curve_z.sample(time_z + time_offset_z) * movement_magnitude_z

	# Set the position with new X and Z values, keeping Y unchanged
	position = initial_position + Vector3(new_x, 0, new_z)
