extends CharacterBody3D
class_name Enemy

@export_subgroup("Character properties")
@export var model: Node3D
@export var speed: int = 5
@export var health: Health_System
@export var animation_tree: AnimationTree
@export var navigation_agent: FollowTarget3D

@export_subgroup("Minion spawner")
@export var can_spawn_minion: bool = false
@export var spawn_radius: float = 3
@export var minions: Array[PackedScene]
@export var min_spawn: int = 3
@export var max_spawn: int = 5
@export var spawn_position: PathFollow3D

@export_subgroup("State Machine")
@export var hsm: LimboHSM
@export var chase_state: LimboState
@export var attack_state: LimboState

var rotation_direction = 0
var player: Player
var playback 
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
signal enemy_death

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	health.connect("death", death)
	
	set_as_top_level(true)
	
	playback = animation_tree["parameters/playback"]
	initialise_state_machine()

func handle_rotation(delta) -> void : 
	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
		
	model.rotation.y = lerp_angle(model.rotation.y, rotation_direction, delta * 10)

func handle_animation() -> void: 
	var animation_velocity = Vector2(velocity.x,velocity.z)
	animation_tree.set("parameters/Movement/blend_position", animation_velocity)

func _physics_process(delta: float) -> void:
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
	
	enemy_death.emit(self)
	queue_free()

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
		var spawn_position = global_position + random_offset
		# Defer adding the minion to the scene
		get_parent().add_child(spawn)
		# Set the calculated spawn position
		spawn.global_position = spawn_position
		

func _on_follow_target_3d_reached_target(target: Node3D) -> void:
	hsm.dispatch("attack")
