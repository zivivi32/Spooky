extends CharacterBody3D

class_name Ghost_Boss

@export_subgroup("Character properties")
@export var model: Node3D
@export var model_mesh: Node3D
@export var speed: int = 5
@export var chase_speed: int = 5
@export var health: Health_System
@export var navigation_agent: FollowTarget3D
@export var random_target_point : RandomTarget3D
@export var enemy_score: int = 500
@export var bt: BTPlayer

@export_subgroup("FX")
@export var spawn_particles: GPUParticles3D
@export var walking_particles: GPUParticles3D
@export var death_particles: Array[GPUParticles3D]
@export var death_sfx: Array[AudioStream]

@export_subgroup("default attack")
@export var bullet_count: int = 5
@export var default_arc: float = 60
@export var default_bullet: PackedScene
@export var attack_sfx: Array[AudioStream]

@export_subgroup("Weapons")
@export var weapon: Gun_Weapon
@export var melee_bullet: PackedScene
@export var range_bullet: PackedScene
@export var range_attack_sfx: Array[AudioStream]
@export var range_bullet_count: int = 10
@export var range_arc: float = 360

@export_subgroup("Minion spawner")
@export var nav_region: NavigationRegion3D  # Reference to the NavigationRegion3D
@export var can_spawn_minion: bool = false
@export var spawn_radius: float = 3
@export var minions: Array[PackedScene]
@export var min_spawn: int = 3
@export var max_spawn: int = 5
@export var spawn_position: Vector3

@export_subgroup("Invaders Minions")
@export var invaders_spawner_scene: PackedScene
var invader_spawner 
@export var spawner_location: Marker3D
@export var teleport_location: Marker3D

var rotation_direction = 0
var player: Player
var playback 
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Retrieve the blackboard variable to track thresholds
var thresholds_triggered = []
signal enemy_death

func _ready() -> void:
	health.connect("death", death)
	weapon.bullet_count = bullet_count

	nav_region = get_tree().get_first_node_in_group("navigation_region")
	teleport_location = get_tree().get_first_node_in_group("boss_teleport")
	spawner_location = get_tree().get_first_node_in_group("invader_spawn_markers")
################### BOSS FUNCTIONS ##########################

func get_player(): 
	player = get_tree().get_first_node_in_group("player")

func reached_target(): 
	velocity = Vector3.ZERO

func melee_attack(): 
	switch_bullet(melee_bullet)
	weapon.shoot()
	switch_bullet(default_bullet)
	
func range_attack():
	weapon.attack_timer.stop()
	
	switch_bullet(range_bullet)
	weapon.bullet_count = range_bullet_count
	weapon.arc = range_arc
	
	navigation_agent.ClearTarget()
	velocity = Vector3.ZERO
	navigation_agent.Speed = 0
	
	if range_attack_sfx:
		for sfx in range_attack_sfx:
			AudioManager.play_sound(sfx)
	weapon.shoot()
	
func switch_default_bullet():
	weapon.attack_timer.stop()
	
	switch_bullet(default_bullet)
	weapon.bullet_count = bullet_count
	weapon.arc = default_arc
	start_attack()

func stop_attack(): 
	weapon.attack_timer.stop()

func start_attack():
	if weapon.attack_timer.is_stopped():
		weapon.attack_timer.start()

func switch_bullet(new_bullet: PackedScene):
	weapon.bullet_scene = new_bullet
	
func spawn_invaders():
	print_debug("spawn invaders")
	invader_spawner = invaders_spawner_scene.instantiate()
	invader_spawner.boss_wave = true
	get_tree().root.add_child(invader_spawner)
	invader_spawner.all_waves_completed.connect(bt_wave_done)
	invader_spawner.global_position = spawner_location.global_position
	#invader_spawner.current_wave = 0
	invader_spawner.start_next_wave()
	bt.blackboard.set_var(&"quarter_life", false)
	bt.blackboard.set_var(&"wave_spawned", true)

func teleport():
	print_debug("teleport")
	global_position = teleport_location.global_position
	bt.blackboard.set_var(&"is_wave_done", false)
	
func bt_wave_done():
	print_debug("NOT MOVING!")
	bt.blackboard.set_var(&"is_wave_done", true)
	bt.blackboard.set_var(&"wave_spawned", false)
	
func spawn_minions() -> void:
	print_debug("spawn_minions")
	navigation_agent.Speed = 0
	velocity = Vector3.ZERO
	
	var num_spawn: int = randi_range(min_spawn, max_spawn)
	for i in range(num_spawn):
		var spawn = minions.pick_random().instantiate()
		
		var valid_spawn_position = false
		var spawn_position: Vector3
		
		while not valid_spawn_position:
			# Generate a random point within the spawn radius
			var random_offset = Vector3(
				randf_range(-spawn_radius, spawn_radius),  # X offset
				0,                                        # Y remains the same, no vertical change
				randf_range(-spawn_radius, spawn_radius)   # Z offset
			)
			
			# Calculate tentative spawn position relative to the current position
			var tentative_position = global_position + random_offset

			# Use NavigationServer3D to get the closest point on the navigation mesh
			spawn_position = NavigationServer3D.map_get_closest_point(nav_region.get_navigation_map(), tentative_position)
			
			# Check if the spawn_position is valid (on the navigation mesh)
			if spawn_position != Vector3.ZERO:
				valid_spawn_position = true  # Exit the loop when a valid position is found

		# Spawn the minion at the valid position
		spawn.is_spawned = true
		get_parent().add_child(spawn)
		spawn.global_position = spawn_position

	Events.emit_signal("fx_screen_shake", 0.1, 0.2)
	if weapon.attack_timer.is_stopped():
		weapon.attack_timer.start()
		
###############################################################

func _physics_process(_delta: float) -> void:
	if walking_particles:
		var animation_velocity = Vector2(velocity.x,velocity.z)
		walking_particles.emitting = (animation_velocity != Vector2.ZERO)
	if player:
		model.look_at(player.global_position, Vector3.UP, true)
		model.rotation.x = 0
		model.rotation.z = 0
	else: 
		get_player()


func death() -> void:
	print_debug("died")
	enemy_death.emit(self)
	
	if bt: 
		bt.active = false
	
	navigation_agent.ClearTarget()
	navigation_agent.Speed = 0
	velocity = Vector3.ZERO
	
	weapon.attack_timer.stop()
	
	if death_particles:
		
		model_mesh.visible = false
		navigation_agent.ClearTarget()
		health.set_deferred("monitoring", false)
		health.set_deferred("monitorable", false)
		set_collision_layer_value(1, false)
		set_collision_layer_value(4, false)
		velocity = Vector3.ZERO
		
		for vfx in death_particles:
			vfx.emitting = true
			

	if death_sfx:
		for sfx in death_sfx: 
			AudioManager.play_sound(sfx)
			
	await get_tree().create_timer(2).timeout
	queue_free()


func _on_health_system_hurt() -> void:
	check_health_thresholds()

# Function to check health thresholds
func check_health_thresholds():
	
	# Define thresholds
	var thresholds = [0.75, 0.50, 0.25]
	
	# Current health percentage
	var current_health_percentage : float = float(health.health) / float(health.max_health)
	
	print_debug(current_health_percentage)
	
	# Check each threshold
	for threshold in thresholds:
		# If the threshold is crossed and hasn't been triggered yet
		if current_health_percentage <= threshold and not thresholds_triggered.has(threshold):
			# Add the threshold to the triggered list
			thresholds_triggered.append(threshold)
			
			# Set the quarter_life variable to true to trigger the behavior tree logic
			bt.blackboard.set_var(&"quarter_life", true)
			return
