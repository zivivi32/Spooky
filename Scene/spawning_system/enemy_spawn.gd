extends Path3D
@export_subgroup("Spawn properties")
@export var easy_wave: int = 1
@export var easy_enemies: Array[PackedScene] # Easy enemies for early waves
@export var medium_wave: int = 2
@export var medium_enemies: Array[PackedScene] # Medium enemies for mid-game waves
@export var hard_wave: int = 3
@export var hard_enemies: Array[PackedScene] # Hard enemies for later waves
@export var boss_wave: int = 5
@export var boss_enemies: Array[PackedScene] # Boss enemies for special waves
@export var spawn_pos: PathFollow3D
@export var min_number: int = 3
@export var max_number: int = 10
@export var spawn_timer: Timer
@export var difficulty_manager: Difficulty_Manager

@export_subgroup("Wave UI")
@export var wave_label: Label
@export var score_label: Label

# Track enemies in the current wave
var current_wave_enemies: Array = []
var is_in_wave: bool = false
var wave_number: int : 
	set(wave_num): 
		wave_number = wave_num
		if ! spawning_boss:
			wave_label.text = "WAVE: " + str(wave_number)
		else: 
			wave_label.text = "BOSS WAVE"
	get():
		return wave_number

var score: int: 
	set(new_score): 
		score = new_score
		score_label.text = "Score: " + str(score)
	get():
		return score

var spawning_boss: bool = false


signal wave_started
signal boss_spawn

func _ready() -> void:
	wave_number = 1
	score = 0
	# Start spawning when the game starts
	Events.shop_done.connect(start_next_wave)
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
			boss_spawn.emit()
		else: 
			wave_started.emit()

		if spawning_boss:
			spawn_timer.start(0.1)  # Boss spawns immediately
		else:
			spawn_timer.start(difficulty_manager.get_spawn_time())
		is_in_wave = true

# Stop spawning when wave is over
func stop_spawn() -> void: 
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
	return wave_number % boss_wave == 0

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

	if wave_number <= easy_wave and !easy_enemies.is_empty():
		# Early waves: Mostly easy enemies
		return easy_enemies.pick_random()
	elif wave_number <= medium_wave and !medium_enemies.is_empty():
		# Mid waves: Higher chance for medium enemies, but still some easy
		if random_choice < 70:  # 70% chance for easy enemies
			return easy_enemies.pick_random()
		else:
			return medium_enemies.pick_random()  # 30% chance for medium enemies
	elif wave_number <= hard_wave and !hard_enemies.is_empty():
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

# Callback when an enemy dies
func _on_enemy_died(enemy) -> void:
	score += enemy.enemy_score	
	current_wave_enemies.erase(enemy) # Remove enemy from the list
	if spawning_boss:
		await get_tree().create_timer(3).timeout
		print_debug("Emit End Game")
		Events.end_game.emit()
		
	if ! is_in_wave:
		if current_wave_enemies.size() == 0:
			### EMIT SHOW SHOP SIGNAL HERE!
			await get_tree().create_timer(3).timeout
			Events.wave_done.emit()



func start_next_wave():
	wave_number += 1
	start_new_wave() # Start a new wave if all enemies are defeated
