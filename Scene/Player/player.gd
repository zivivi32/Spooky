extends CharacterBody3D
class_name Player
@export_subgroup("Properties")
@export var movement_speed = 10
@export var camera : Camera3D
@export var model: Node3D
@export var animation_tree: AnimationTree
@export_subgroup("VFX")
@export var walking_particles: GPUParticles3D

@export_subgroup("Health")
@export var health: Health_System
@export var damage_rate: int = 2

@export_subgroup("Abilities")
@export var dash: Dash_Ability

@export_subgroup("Weapon properties")
@export var default_bullet: PackedScene
@export var gun: Gun_Weapon
@export var weapon1: Special_Abilities
@export var weapon2: Special_Abilities
@export var weapon3: Special_Abilities

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var rotation_direction: float
var movement_velocity: Vector3
var plane = Plane(Vector3(0, 1, 0), 0)  # A plane at y = 0 (assuming the ground is at y = 0)

@onready var world_node = get_tree().get_first_node_in_group("world")

func _ready() -> void:
	health.connect("death", death)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon1"):
		weapon1.launch_ability()

	if event.is_action_pressed("weapon2"): 
		weapon2.launch_ability()
		
	if event.is_action_pressed("weapon3"): 
		weapon3.launch_ability()
	
	if event.is_action_pressed("dash"):
		dash.launch_ability()

func death(): 
	queue_free()
	
func to_isometric(motion_3d):
	# Rotate the input vector to match the camera's orientation
	motion_3d = motion_3d.rotated(Vector3(0, 1, 0), deg_to_rad(45.0))
	return motion_3d
	
func damage_on_contact(delta):
		#Process damage: 
	var contact_bodies = health.get_overlapping_bodies()
	if contact_bodies.size() > 0:
		health.health -= (damage_rate * contact_bodies.size() * delta)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	handle_controls(delta)
	handle_gravity(delta)
	velocity = movement_velocity.normalized() * movement_speed 
	velocity.y = -gravity
	
	move_and_slide()
	
	## Manage Contact Damage
	#damage_on_contact(delta)

	# Rotate the player model based on movement
	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
	model.rotation.y = lerp_angle(model.rotation.y, rotation_direction, delta * 10)

	# Update the gun's rotation based on the mouse position
	update_gun_aim(update_player_aim())
	#update_player_rotate(update_player_aim())
	
##### AIMING WITH MOUSE
func update_player_aim():
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_ray_normal(mouse_pos)

	var to = from + ray_direction * 1000  # Adjust 1000 as needed
	
	# Creating ray_cast from and to a point with collision mask of 5. Meaning will only collide with objects on layer 5
	var ray_query = PhysicsRayQueryParameters3D.create(from, to, pow(2, 20-1))

	# Ray cast will only collide with areas and not bodies (static or character bodies)
	ray_query.collide_with_areas = true
	ray_query.collide_with_bodies = false

	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(ray_query)

	if result:
		return result.position
	else:
		return Vector3.ZERO


########### Rotate the gun towards the mouse position
func update_gun_aim(target_position : Vector3):
	if target_position == Vector3.ZERO:
		return  # Don't rotate if no valid target

	target_position.y = 0
	gun.look_at(target_position, Vector3.UP, true)
	gun.rotation.x = 0
	gun.rotation.z = 0

func handle_animation(movement_vector: Vector3) -> void: 
	var animation_velocity = Vector2(movement_vector.x,movement_vector.z)
	animation_tree.set("parameters/Movement/blend_position", animation_velocity)

	if walking_particles:
		walking_particles.emitting = (animation_velocity != Vector2.ZERO)

func update_player_rotate(target_position : Vector3):
	if target_position == Vector3.ZERO:
		return  # Don't rotate if no valid target

	# Calculate the direction from the gun to the mouse target
	var direction_to_mouse = (target_position - model.global_position).normalized()

	# Compute the rotation angles
	var gun_rotation_angle = atan2(direction_to_mouse.x, direction_to_mouse.z)

	# Adjust only the gun's rotation to face the target
	model.rotation.y = gun_rotation_angle

	# Optional: Lock gun rotation on x and z axes if necessary
	model.rotation.x = 0
	model.rotation.z = 0

# Handle gravity
func handle_gravity(delta):
	gravity += 25 * delta
	if gravity > 0 and is_on_floor():
		gravity = 0

# Handle movement input
func handle_controls(_delta):
	# Movement
	var input := Vector3.ZERO
	input = input.rotated(Vector3.UP, world_node.rotation.y).normalized()
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")

	if input.length() > 1:
		input = input.normalized()
	
	handle_animation(input)

	movement_velocity = to_isometric(input) 
	
func set_default_bullet(): 
	gun.change_bullet(default_bullet)

func call_abilities(weapon_bullet) -> void: 
	gun.change_bullet(weapon_bullet)
