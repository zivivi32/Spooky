extends CharacterBody3D

class_name Boss

@export_subgroup("Character properties")
@export var model: Node3D
@export var model_mesh: Node3D
@export var speed: int = 5
@export var health: Health_System
@export var animation_tree: AnimationTree
@export var is_spawned: bool = false
@export var navigation_agent: FollowTarget3D
@export var random_target_point : RandomTarget3D

@export_subgroup("VFX")
@export var spawn_particles: GPUParticles3D
@export var walking_particles: GPUParticles3D
@export var death_particles: GPUParticles3D

@export_subgroup("Weapons")
@export var weapon: Gun_Weapon
@export var melee_bullet: PackedScene
@export var range_bullet: PackedScene

@export_subgroup("Minion spawner")
@export var can_spawn_minion: bool = false
@export var spawn_radius: float = 3
@export var minions: Array[PackedScene]
@export var min_spawn: int = 3
@export var max_spawn: int = 5
@export var spawn_position: Vector3

var rotation_direction = 0
var player: Player
var playback 
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
signal enemy_death

func _ready() -> void:
	playback = animation_tree["parameters/playback"]
	health.connect("death", death)


################### BOSS FUNCTIONS ##########################

func get_player(): 
	player = get_tree().get_first_node_in_group("player")

func chase_player():
	navigation_agent.SetTarget(player)

func patrol(): 
	navigation_agent.ClearTarget()
	randomize()
	navigation_agent.SetFixedTarget(random_target_point.GetNextPoint())

func reached_target(): 
	velocity = Vector3.ZERO

func melee_attack(): 
	switch_bullet(melee_bullet)
	weapon.shoot()

func range_attack():
	switch_bullet(range_bullet)
	weapon.shoot()

func switch_bullet(new_bullet: PackedScene):
	weapon.bullet_scene = new_bullet
	
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
		spawn_position = global_position + random_offset
		spawn.is_spawned = true
		# Defer adding the minion to the scene
		get_parent().add_child(spawn)
		# Set the calculated spawn position
		spawn.global_position = spawn_position

###############################################################


func _physics_process(delta: float) -> void:
	handle_animation()
	pass

func handle_animation() -> void: 
	var animation_velocity = Vector2(velocity.x,velocity.z)
	animation_tree.set("parameters/Movement/blend_position", animation_velocity)
	
	if walking_particles:
		walking_particles.emitting = (animation_velocity != Vector2.ZERO)

func death() -> void:
	if can_spawn_minion:
		spawn_minions()
	
	enemy_death.emit(self)
	
	if death_particles:
		
		model_mesh.visible = false
		navigation_agent.ClearTarget()
		health.set_deferred("monitoring", false)
		health.set_deferred("monitorable", false)
		set_collision_layer_value(1, false)
		set_collision_layer_value(4, false)
		velocity = Vector3.ZERO
		
		death_particles.emitting = true
		await  death_particles.finished
		
	queue_free()
