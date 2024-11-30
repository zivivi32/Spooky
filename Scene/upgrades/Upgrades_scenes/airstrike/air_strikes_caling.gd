extends Node3D

@export var no_air_strike: int = 1
@export_range(0, 15) var num_bullet: int = 5
@export var air_strike_bullet_scene: PackedScene
@export var nav_region: NavigationRegion3D  # Reference to the NavigationRegion3D

func _ready() -> void:
	
	await get_tree().create_timer(0.1).timeout
	nav_region = get_tree().get_first_node_in_group("navigation_region")
	
	call_deferred("call_air_strike")
	
func spawning_position(position_radius) -> Vector3:
	var valid_spawn_position = false
	var spawn_position: Vector3

	while not valid_spawn_position:
		# Generate a random point within the spawn radius
		var random_offset = Vector3(
			randf_range(-position_radius, position_radius),  # X offset
			0,                                        # Y remains the same, no vertical change
			randf_range(-position_radius, position_radius)   # Z offset
		)
		
		# Calculate tentative spawn position relative to the current position
		var tentative_position = global_position + random_offset

		# Use NavigationServer3D to get the closest point on the navigation mesh
		spawn_position = NavigationServer3D.map_get_closest_point(nav_region.get_navigation_map(), tentative_position)
		
		# Check if the spawn_position is valid (on the navigation mesh)
		if spawn_position != Vector3.ZERO:
			valid_spawn_position = true  # Exit the loop when a valid position is found

	return spawn_position 

func call_air_strike():
	for i in range(0, no_air_strike):
		air_strike()
		await get_tree().create_timer(1.5).timeout

func air_strike(): 
	for i in range(0, num_bullet): 
		var air_bullet = air_strike_bullet_scene.instantiate()
		get_tree().root.add_child(air_bullet)
		air_bullet.global_position = spawning_position(10)
