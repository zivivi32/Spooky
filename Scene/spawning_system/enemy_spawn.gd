extends Path3D
@export_subgroup("Spawn properties")
@export var easy_enemies: Array[PackedScene] # Easy enemies for early waves
@export var medium_enemies: Array[PackedScene] # Medium enemies for mid-game waves
@export var hard_enemies: Array[PackedScene] # Hard enemies for later waves
@export var boss_enemies: Array[PackedScene] # Boss enemies for special waves
@export var spawn_pos: PathFollow3D
@export var min_number: int = 3
@export var max_number: int = 10
@export var spawn_timer: Timer
@export var difficulty_manager: Difficulty_Manager

# Track enemies in the current wave
var current_wave_enemies: Array = []
var is_in_wave: bool = false
var wave_number: int = 1
var spawning_boss: bool = false

func _ready() -> void:
	# Start spawning when the game starts
	spawn_timer.connect("timeout", spawning)
	start_new_wave()

	# Connect to the difficulty manager signal
	difficulty_manager.connect("stop_spawning_enemies", stop_spawn)

# Start a new wave of enemies
func start_new_wave() -> void:
	if !is_in_wave:
		current_wave_enemies.clear() # Clear the previous wave enemies
		spawning_boss = is_boss_wave() # Check if the new wave is a boss wave

		if spawning_boss:
			spawn_timer.start(0.1)  # Boss spawns immediately
		else:
			spawn_timer.start(difficulty_manager.get_spawn_time())

		print("New wave started: Wave ", wave_number)
		is_in_wave = true

# Stop spawning when wave is over
func stop_spawn() -> void: 
	print_debug("Wave done!")
	spawn_timer.stop()
	is_in_wave = false

# Spawn enemies during the wave
func spawning() -> void:
	if spawning_boss:
		# If it's a boss wave, spawn only one boss and stop further spawning
		spawn_boss()
		spawn_timer.stop()
	else:
		# For regular waves, mix enemy types based on the current wave
		var enemy_scene: PackedScene = pick_enemy_type()

		var spawn = enemy_scene.instantiate()
		get_parent().add_child(spawn)
		spawn_pos.progress_ratio = randf_range(0, 1)
		spawn.global_position = spawn_pos.global_position

		# Add the spawned enemy to the current wave enemies array
		current_wave_enemies.append(spawn)
		spawn.connect("enemy_death", _on_enemy_died)

		# Restart the spawn timer based on difficulty curve
		spawn_timer.start(difficulty_manager.get_spawn_time())

# Determine if this is a boss wave (every 10th wave)
func is_boss_wave() -> bool:
	return wave_number % 5 == 0

# Spawn a boss enemy (only one per boss wave)
func spawn_boss() -> void:
	var boss_scene: PackedScene = boss_enemies.pick_random()
	var boss = boss_scene.instantiate()
	get_parent().add_child(boss)
	spawn_pos.progress_ratio = randf_range(0, 1)
	boss.global_position = spawn_pos.global_position

	# Track the boss as the only enemy in this wave
	current_wave_enemies.append(boss)
	boss.connect("enemy_death", _on_enemy_died)

# Pick an enemy type based on the wave number with mixed probabilities
func pick_enemy_type() -> PackedScene:
	var random_choice = randi() % 100  # Generate a random number from 0 to 99

	if wave_number <= 1 and !easy_enemies.is_empty():
		# Early waves: Mostly easy enemies
		return easy_enemies.pick_random()
	elif wave_number <= 2 and !medium_enemies.is_empty():
		# Mid waves: Higher chance for medium enemies, but still some easy
		if random_choice < 70:  # 70% chance for easy enemies
			return easy_enemies.pick_random()
		else:
			return medium_enemies.pick_random()  # 30% chance for medium enemies
	elif wave_number <= 3 and !hard_enemies.is_empty():
		# Later waves: A mix of easy, medium, and hard
		if random_choice < 50:
			return easy_enemies.pick_random()  # 50% chance for easy
		elif random_choice < 80:
			return medium_enemies.pick_random()  # 30% chance for medium
		else:
			return hard_enemies.pick_random()  # 20% chance for hard
	else:
		## Post wave 10 (excluding boss waves): More medium and hard enemies
		if random_choice < 30:
			return easy_enemies.pick_random()  # 30% chance for easy
		elif random_choice < 70:
			return medium_enemies.pick_random()  # 40% chance for medium
		else:
			return hard_enemies.pick_random()  # 30% chance for hard


## NEED another call back for Boss to end the Wave!
# Callback when an enemy dies
func _on_enemy_died(enemy) -> void:
	current_wave_enemies.erase(enemy) # Remove enemy from the list
	if ! is_in_wave:
		if current_wave_enemies.size() == 0:
			print("All enemies defeated, starting next wave.")
			wave_number += 1
			start_new_wave() # Start a new wave if all enemies are defeated
