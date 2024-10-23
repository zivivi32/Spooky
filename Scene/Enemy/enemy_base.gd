extends CharacterBody3D
class_name Enemy

@export_subgroup("Character properties")
@export var model: Node3D
@export var model_mesh: Node3D
@export var speed: int = 5
@export var health: Health_System
@export var animation_tree: AnimationTree
@export var is_spawned: bool = false
@export var navigation_agent: FollowTarget3D

@export_subgroup("VFX")
@export var spawn_particles: GPUParticles3D
@export var walking_particles: GPUParticles3D
@export var death_particles: GPUParticles3D

@export_subgroup("Loot configurations")
@export var nav_region: NavigationRegion3D
@export var has_loot: bool = true
@export var loot: Array[PackedScene]
@export var min_spawn_loot: int = 2
@export var max_spawn_loot: int = 5
@export var spawn_radius_loot: float = 3

@export_subgroup("Minion spawner")
@export var can_spawn_minion: bool = false
@export var spawn_radius: float = 3
@export var minions: Array[PackedScene]
@export var min_spawn: int = 3
@export var max_spawn: int = 5
@export var spawn_position: Vector3

@export_subgroup("State Machine")
@export var hsm: LimboHSM
@export var chase_state: LimboState
@export var attack_state: LimboState
@export var death_state: LimboState


@export_subgroup("SFX")
@export var spawn_sfx: Array[AudioStream]
@export var death_sfx: Array[AudioStream]

var rotation_direction = 0
var player: Player
var playback 
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
signal enemy_death

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	nav_region = get_tree().get_first_node_in_group("navigation_region")
	
	health.connect("death", death)
	set_as_top_level(true)
	
	playback = animation_tree["parameters/playback"]
	initialise_state_machine()

	if is_spawned: 
		health.immune(0.5)

	if spawn_particles:
		spawn_particles.emitting = true
		
	if spawn_sfx:
		for sfx in spawn_sfx:
			AudioManager.play_sound(sfx)


func handle_rotation(delta) -> void : 
	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
		
	model.rotation.y = lerp_angle(model.rotation.y, rotation_direction, delta * 10)

func handle_animation() -> void: 
	var animation_velocity = Vector2(velocity.x,velocity.z)
	animation_tree.set("parameters/Movement/blend_position", animation_velocity)
	
	if walking_particles:
		walking_particles.emitting = (animation_velocity != Vector2.ZERO)
	
func _physics_process(_delta: float) -> void:
	handle_animation()
	#handle_gravity(delta)
	
	if !player:
		if is_instance_valid(player):
			player = get_tree().get_first_node_in_group("player")
		else:
			navigation_agent.ClearTarget()
		
# Handle gravity
func handle_gravity(delta):
	gravity += 25 * delta
	if gravity > 0 and is_on_floor():
		gravity = 0
		
func initialise_state_machine() -> void:
	
	hsm.add_transition(hsm.ANYSTATE, chase_state, "chase")
	hsm.add_transition(chase_state, attack_state, "attack")
	
	hsm.add_transition(hsm.ANYSTATE, attack_state, "attack")
	hsm.add_transition(attack_state, chase_state, "chase")
	
	#hsm.initial_state = patrol_state
	hsm.initialize(self)
	hsm.set_active(true)

func attack() -> void: 
	playback.travel("attack")
	
func start_chase() -> void: 
	hsm.dispatch("chase")
	
func death() -> void:
	if can_spawn_minion:
		spawn_minions()
	
	if has_loot:
		spawn_loot()
	
	enemy_death.emit(self)
	if death_sfx:
		for sfx in death_sfx:
			AudioManager.play_sound(sfx)
	
	if death_particles:
		
		model_mesh.visible = false
		hsm.set_active(false)
		navigation_agent.ClearTarget()
		health.set_deferred("monitoring", false)
		health.set_deferred("monitorable", false)
		set_collision_layer_value(1, false)
		set_collision_layer_value(4, false)
		velocity = Vector3.ZERO
		
		death_particles.emitting = true
		await  death_particles.finished
		

		
	queue_free()

func spawn_minions() -> void:
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


func spawn_loot() -> void:
	if loot:
		var num_spawn: int = randi_range(min_spawn_loot, max_spawn_loot)
		
		for i in range(num_spawn):
			var spawn = loot.pick_random().instantiate()
			
			var valid_spawn_position = false
			var spawn_position_loot: Vector3
			
			while not valid_spawn_position:
				# Generate a random point within the spawn radius
				var random_offset = Vector3(
					randf_range(-spawn_radius_loot, spawn_radius_loot),  # X offset
					0,                                        # Y remains the same, no vertical change
					randf_range(-spawn_radius_loot, spawn_radius_loot)   # Z offset
				)
				
				# Calculate tentative spawn position relative to the current position
				var tentative_position = global_position + random_offset

				# Use NavigationServer3D to get the closest point on the navigation mesh
				spawn_position_loot = NavigationServer3D.map_get_closest_point(nav_region.get_navigation_map(), tentative_position)
				
				# Check if the spawn_position is valid (on the navigation mesh)
				if spawn_position_loot != Vector3.ZERO:
					valid_spawn_position = true  # Exit the loop when a valid position is found

			# Spawn the minion at the valid position
			get_parent().add_child(spawn)
			spawn.global_position = spawn_position_loot
		
func _on_follow_target_3d_reached_target(_target: Node3D) -> void:
	hsm.dispatch("attack")
