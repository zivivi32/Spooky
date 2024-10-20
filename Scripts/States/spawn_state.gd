extends LimboState

@export_subgroup("State Properties")
@export var followtarget: FollowTarget3D

@export_subgroup("Minion spawner")
@export var can_spawn_minion: bool = false
@export var spawn_radius: float = 3
@export var minions: Array[PackedScene]
@export var min_spawn: int = 3
@export var max_spawn: int = 5
@export var spawn_position: Vector3


func spawn_minions() -> void:
	var num_spawn : int = randi_range(min_spawn, max_spawn)
	
	for i in range(num_spawn):
		var spawn = minions.pick_random().instantiate()
		# Generate a random point within the spawn radius
		var random_offset = Vector3(
			randf_range(-spawn_radius, spawn_radius),  # X offset
			0,                                        # Y remains the same, no vertical change
			randf_range(-spawn_radius, spawn_radius)   # Z offset
		)
		# Calculate spawn position relative to the current enemy's position
		spawn_position = agent.global_position + random_offset
		spawn.is_spawned = true
		# Defer adding the minion to the scene
		get_parent().add_child(spawn)
		# Set the calculated spawn position
		spawn.global_position = spawn_position

func _enter() -> void:
	followtarget.ClearTarget()
	followtarget.Speed = 0
	spawn_minions()
	agent.playback.travel("Cheer")
	
