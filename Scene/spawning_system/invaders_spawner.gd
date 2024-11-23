extends Node3D

class_name InvaderWaveSpawner

## TO DO:
# Create container to and change clean up enemies to avoid 
# overboard

# Wave configuration
@export var spawn_offset: float = 0 # Offset from origin where wave starts
@export var final_distance: float = 0  # Distance to move towards
@export var enemy_spacing: float = 2.0
@export var formation_spacing: float = 1.0
@export var loop_movement: bool = true
@export var side_movement_speed: float = 2.0 
@export var spawn_container: Node3D

@export_subgroup("Timed movement")
@export var is_time_movement: bool = false
@export var timer_movement: Timer
@export var time_movement: float = 2
@export var stop_movement_timer: Timer
@export var stop_movement: float = 2

# Wave Data Resources
@export var waves: Array[WaveData]

# Wave tracking
var current_wave: int = 0
var enemies_alive: int = 0
var wave_in_progress: bool = false
var current_position: Vector3
var initial_x_positions: Dictionary = {}
var movement_time: float = 0.0
var moving_forward: bool = true

# Signals
signal wave_completed
signal all_waves_completed
signal enemy_destroyed(enemy_type: String)
signal wave_reached_position

var can_move: bool = false
var boss_wave: bool = false

func _ready():
	start_next_wave()
	
	if is_time_movement:
		timer_movement.connect("timeout", movement_timeout)
		timer_movement.start(time_movement)
		
		stop_movement_timer.connect("timeout", stop_movement_timeout)
	else:
		can_move = true

func movement_timeout(): 
	can_move = true
	stop_movement_timer.start(stop_movement)

func stop_movement_timeout(): 
	can_move = false
	timer_movement.start(time_movement)

func _process(delta):
	if wave_in_progress:
		var wave_data = waves[current_wave-1].to_wave_data()
		if can_move:
			match wave_data.movement_pattern:
				WaveData.MovementPattern.STRAIGHT:
					move_straight(delta, wave_data)
				WaveData.MovementPattern.CIRCLE:
					move_in_circle(delta, wave_data)
				WaveData.MovementPattern.V_FORMATION:
					move_in_v_formation(delta, wave_data)
				WaveData.MovementPattern.RANDOM_SIDE:
					move_randomly_side(delta, wave_data)

func start_next_wave():
	if current_wave >= waves.size():
		all_waves_completed.emit()
		return
	
	var wave_data = waves[current_wave].to_wave_data()
	enemies_alive = get_total_enemies(wave_data)
	wave_in_progress = true
	
	# Set initial position with spawn offset
	current_position = Vector3(0, 0, spawn_offset)
	movement_time = 0.0
	
	spawn_wave_enemies(wave_data)
	current_wave += 1

func get_total_enemies(wave_data: Dictionary) -> int:
	var total = 0
	for enemy_type in wave_data.enemy_types:
		total += enemy_type.count
	return total
	
func spawn_wave_enemies(wave_data: Dictionary):
	var total_enemies = get_total_enemies(wave_data)
	var cols = ceil(sqrt(total_enemies)) * formation_spacing
	var rows = ceil(total_enemies as float / cols) * formation_spacing
	
	# Calculate starting position for centered formation
	var start_x = -(wave_data.formation_width / 2)
	var start_z = 0.0
	
	# Track current position in formation
	var current_row = 0
	var current_col = 0
	
	# Spawn each type of enemy
	for enemy_type_data in wave_data.enemy_types:
		var enemy_scene = enemy_type_data.scene
		var enemy_count = enemy_type_data.count
		for i in enemy_count:
			var enemy = enemy_scene.instantiate()
			enemy.add_to_group("current_wave_enemies")
			
			# Calculate spawn position
			var x = start_x + (current_col * enemy_spacing)
			var z = start_z + (current_row * enemy_spacing)
			
			# Store relative position and initial X position
			enemy.set_meta("relative_x", x)
			enemy.set_meta("relative_z", z)
			initial_x_positions[enemy.get_instance_id()] = x
			
			# Set initial position at spawn offset
			enemy.position = Vector3(x, 0, spawn_offset + z)
			
			# Store enemy type for scoring/effects
			enemy.set_meta("enemy_type", enemy_scene.resource_path.get_file().split(".")[0])
			
			# Connect enemy's destroyed signal
			enemy.connect("destroyed", _on_enemy_destroyed.bind(enemy))
			enemy.connect("tree_exiting", _on_enemy_tree_exiting.bind(enemy))
			spawn_container.add_child(enemy)
			
			# Move to next position in formation
			current_col += 1
			if current_col >= cols:
				current_col = 0
				current_row += 1

func move_straight(delta, wave_data: Dictionary):
	
	var halfway: float = final_distance * 0.5
	var right_direction: float = 0
	var left_direction: float = 0
	if halfway != 0:
		right_direction = -halfway
		left_direction = halfway
		
	if loop_movement:
		if moving_forward:
			current_position.z = move_toward(
				current_position.z,
				right_direction,
				wave_data.approach_speed * delta
			)
			if abs(current_position.z - right_direction) < 0.1:
				moving_forward = false
				wave_reached_position.emit()
		else:
			current_position.z = move_toward(
				current_position.z,
				left_direction,
				wave_data.approach_speed * delta
			)
			if abs(current_position.z - left_direction) < 0.1:
				moving_forward = true
	else:
		current_position.z = move_toward(
			current_position.z,
			final_distance,
			wave_data.approach_speed * delta
		)
		if abs(current_position.z - final_distance) < 0.1:
			wave_reached_position.emit()
			for enemy in spawn_container.get_children():
				enemy.queue_free()
	
	# Update all enemy positions
	for enemy in spawn_container.get_children():
		var new_pos = enemy.position
		new_pos.z = current_position.z + enemy.get_meta("relative_z")
		new_pos.x = enemy.get_meta("relative_x")
		enemy.position = new_pos
		
func move_in_circle(delta, wave_data):
	movement_time += delta * wave_data.approach_speed
	var radius = wave_data.movement_data["radius"]
	
	if not loop_movement and movement_time >= TAU:
		wave_reached_position.emit()
		for enemy in spawn_container.get_children():
			enemy.queue_free()
		return
	
	# Reset movement_time if looping to prevent floating-point issues
	if loop_movement and movement_time >= TAU:
		movement_time = 0.0
		wave_reached_position.emit()
	
	# Update all enemy positions
	for enemy in spawn_container.get_children():
		var relative_x = enemy.get_meta("relative_x")
		var relative_z = enemy.get_meta("relative_z")
		var x = radius * cos(movement_time) + relative_x
		var z = radius * sin(movement_time) + relative_z + final_distance
		enemy.position = Vector3(x, 0, z)

func move_in_v_formation(delta, wave_data):
	movement_time += delta * wave_data.approach_speed
	var wing_angle = deg_to_rad(wave_data.movement_data["wing_angle"])
	var wing_length = wave_data.movement_data["wing_length"]
	
	if not loop_movement:
		current_position.z = move_toward(
			current_position.z,
			final_distance,
			wave_data.approach_speed * delta
		)
		
		if abs(current_position.z - final_distance) < 0.1:
			wave_reached_position.emit()
			for enemy in spawn_container.get_children():
				enemy.queue_free()
			return
	
	# Reset movement_time if looping to prevent floating-point issues
	if loop_movement and movement_time >= TAU:
		movement_time = 0.0
		wave_reached_position.emit()
	
	# Update all enemy positions
	for enemy in spawn_container.get_children():
		var relative_x = enemy.get_meta("relative_x")
		var relative_z = enemy.get_meta("relative_z")
		var x = relative_x + wing_length * cos(movement_time + relative_z * wing_angle)
		var z = final_distance + relative_z * sin(movement_time + relative_x * wing_angle)
		enemy.position = Vector3(x, 0, z)

func move_randomly_side(delta, wave_data):
	movement_time += delta
	var x_bounds = wave_data.movement_data["x_bounds"]
	var cycles = wave_data.movement_data["cycles"]
	var pause_duration = wave_data.movement_data["pause_duration"]
	
	if not loop_movement and movement_time >= cycles * TAU + pause_duration:
		wave_reached_position.emit()
		for enemy in spawn_container.get_children():
			enemy.queue_free()
		return
	
	# Reset movement_time if looping to prevent floating-point issues
	if loop_movement and movement_time >= cycles * TAU + pause_duration:
		movement_time = 0.0
		wave_reached_position.emit()
	
	# Update all enemy positions
	for enemy in spawn_container.get_children():
		var relative_x = enemy.get_meta("relative_x")
		var relative_z = enemy.get_meta("relative_z")
		var x = relative_x + sin(movement_time * side_movement_speed) * (x_bounds[1] - x_bounds[0]) / 2.0
		var z = final_distance + relative_z
		enemy.position = Vector3(x, 0, z)
# Cleanup functions
func _on_enemy_destroyed(enemy: Node3D):
	enemies_alive -= 1
	var enemy_type = enemy.get_meta("enemy_type")
	enemy_destroyed.emit(enemy_type)
	
	if enemies_alive <= 0:
		wave_in_progress = false
		# Clear any remaining enemies
		for remaining_enemy in spawn_container.get_children():
			remaining_enemy.queue_free()
		wave_completed.emit()
		start_next_wave()

func _on_enemy_tree_exiting(enemy: Node3D):
	# Clean up stored positions when enemy is freed
	initial_x_positions.erase(enemy.get_instance_id())
