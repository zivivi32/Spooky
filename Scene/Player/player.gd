extends CharacterBody3D
class_name Player
@export_subgroup("Properties")
@export var is_testing: bool = false
@export var start_shoot: bool = true
@export var movement_speed = 10
@export var camera : Camera3D
@export var model: Node3D
@export var animation_tree: AnimationTree
var current_aim_direction := Vector3.ZERO
var aim_smoothing := 15.0  # Adjust this value to change smoothing speed
var using_controller := false

@export_subgroup("VFX")
@export var walking_particles: GPUParticles3D

@export_subgroup("Health")
@export var health: Health_System
@export var damage_rate: int = 2
@export var death_animation_time: float = 1
@export var death_particle: GPUParticles3D

@export_subgroup("Coins")
@export var coin_label: Label
@export var base_text: String
var coins: int :
	set(new_coins):
		coins = new_coins
		coin_label.text = base_text + " : " +str(coins)
	get:
		return coins
@export var coin_magnet: CoinMagnet

@export_subgroup("Abilities")
@export var dash: Dash_Ability

@export_subgroup("Weapon properties")
@export var default_bullet: PackedScene
@export var gun: Gun_Weapon
@export var ability_manager: Ability_Manager

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var rotation_direction: float
var movement_velocity: Vector3
var plane = Plane(Vector3(0, 1, 0), 0)  # A plane at y = 0 (assuming the ground is at y = 0)

signal player_death

@onready var world_node = get_tree().get_first_node_in_group("world")


@export var test_abilities: Array[PackedScene]

@export_subgroup("UI HUD")
@export var HUD: CanvasLayer
@export var shop: CanvasLayer
@export var lose_screen: CanvasLayer

var input: Vector3
var can_control: bool = true
var custom_cursor = preload("res://Assets/Cursor/target_round_big.png")

var camera_angle : float = 45

func _ready() -> void:
	## Capture and hide the mouse pointer
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	#
	## Set the scaled custom cursor icon
	#Input.set_custom_mouse_cursor(custom_cursor)
	
	Events.connect("in_interaction", player_cannot_control)
	Events.connect("out_interaction", player_can_control)
	
	if start_shoot: 
		gun.attack_timer.start()
	else: 
		gun.attack_timer.stop()
	can_control = true
	#coins = 350
	health.connect("death", death)
	
	if is_testing: 
		health.max_health = 10000
		health.health = 10000
		coins = 1000
		add_ability(load("res://Scene/Ability/Abilities_scenes/Explosive_gun.tscn"))
		#add_ability(load("res://Scene/Ability/Abilities_scenes/turret_ability.tscn"))
		
	#refresh_abilities()
	
	HUD.show()
	shop.hide()
	lose_screen.hide()
	

func player_can_control():
	can_control = true
	HUD.show()

func player_cannot_control():
	can_control = false
	HUD.hide()
	velocity = Vector3.ZERO

func _input(event: InputEvent) -> void:
	if can_control:
		if event.is_action_pressed("weapon1"):
			ability_manager.launch_ability(0)
			#refresh_abilities()

		if event.is_action_pressed("weapon2"): 
			ability_manager.launch_ability(1)
			
		#if event.is_action_pressed("weapon3"): 
			#ability_manager.launch_ability(2)
		
		if event.is_action_pressed("dash"):
			dash.launch_ability()

func death(): 
	model.visible = false
	can_control = false
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, false)
	gun.attack_timer.stop()
	
	death_particle.emitting = true
	
	await get_tree().create_timer(death_animation_time).timeout
	velocity = Vector3.ZERO
	player_death.emit()
	
	HUD.hide()
	shop.hide()
	lose_screen.show()
	
	
func damage_on_contact(delta):
		#Process damage: 
	var contact_bodies = health.get_overlapping_bodies()
	if contact_bodies.size() > 0:
		health.health -= (damage_rate * contact_bodies.size() * delta)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	if can_control:
		handle_controls(delta)
		handle_gravity(delta)
		
		#velocity = movement_velocity.normalized() * movement_speed 
		#velocity.y = -gravity
		var applied_velocity = velocity.lerp(movement_velocity, delta * 10)
		applied_velocity.y = -gravity
		
		if applied_velocity.length() < 0.1:
			applied_velocity = Vector3.ZERO
			
		velocity = applied_velocity

		move_and_slide()
		
		## Manage Contact Damage
		#damage_on_contact(delta)

		# Rotate the player model based on movement
		if Vector2(velocity.z, velocity.x).length() > 0:
			rotation_direction = Vector2(velocity.z, velocity.x).angle()
		model.rotation.y = lerp_angle(model.rotation.y, rotation_direction, delta * 10)

		# Update the gun's rotation based on the mouse position
		#update_gun_aim(update_player_aim())
		update_player_rotate(update_player_aim())
	
	handle_animation(velocity)
	
func interaction(control: bool):
	can_control = control
	velocity = Vector3.ZERO
	
func to_isometric(motion_3d):
	# Rotate the input vector to match the camera's orientation
	motion_3d = motion_3d.rotated(Vector3(0, 1, 0), deg_to_rad(camera_angle))
	return motion_3d

# Keep your original movement code unchanged
func handle_controls(_delta):
	if can_control:
		# Movement
		input = Vector3.ZERO
		input = input.rotated(Vector3.UP, world_node.rotation.y).normalized()
		input.x = Input.get_axis("move_left", "move_right")
		input.z = Input.get_axis("move_forward", "move_back")
		if input.length() > 1:
			input = input.normalized()
		movement_velocity = to_isometric(input) * movement_speed
		
func update_player_aim() -> Vector3:
	# If using mouse, use original mouse aim logic
	if Input.get_last_mouse_velocity() != Vector2.ZERO:
		return get_mouse_aim_position()  # Ensure this returns a Vector3 for consistency

	# If using controller stick, use stick aim logic
	var right_stick_x = Input.get_axis("right_stick_left", "right_stick_right")
	var right_stick_y = Input.get_axis("right_stick_up", "right_stick_down")
	
	# Apply deadzone
	var deadzone = 0.001
	if abs(right_stick_x) < deadzone and abs(right_stick_y) < deadzone:
		return Vector3.ZERO  # Indicate no input with Vector3.ZERO

	# Create aim direction vector based on stick input
	var aim_direction = Vector3(right_stick_x, 0, right_stick_y)

	# Adjust for isometric camera angle
	aim_direction = to_isometric(aim_direction).normalized()

	# Set an arbitrary distance for the target position in front of the player
	var aim_distance = 10.0
	var target_position = global_position + (aim_direction * aim_distance)

	return target_position

# Original mouse aim helper function
func get_mouse_aim_position() -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_ray_normal(mouse_pos)
	var to = from + ray_direction * 1000
	
	var ray_query = PhysicsRayQueryParameters3D.create(from, to, pow(2, 20-1))
	ray_query.collide_with_areas = true
	ray_query.collide_with_bodies = false
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(ray_query)
	if result:
		return result.position
	else:
		return Vector3.ZERO

# Keep your original rotation code
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

# Keep your original gun aim code
func update_gun_aim(target_position : Vector3):
	if target_position == Vector3.ZERO:
		return  # Don't rotate if no valid target
	target_position.y = 0
	gun.look_at(target_position, Vector3.UP, true)
	gun.rotation.x = 0
	gun.rotation.z = 0
		
func handle_animation(movement_vector: Vector3) -> void: 
	var animation_velocity = Vector2(movement_vector.x,movement_vector.z)
	#animation_tree.set("parameters/Movement/blend_position", animation_velocity)
	animation_tree.set("parameters/Movement/Movement/blend_position", animation_velocity)
	
	var is_moving = animation_velocity != Vector2.ZERO
	
	if walking_particles:
		walking_particles.emitting = is_moving
	
	if is_moving:
		gun.model.rotation.x = 0
	else: 
		gun.model.rotation_degrees.x = -30


# Handle gravity
func handle_gravity(delta):
	gravity += 25 * delta
	if gravity > 0 and is_on_floor():
		gravity = 0

	
func set_default_bullet(): 
	gun.change_bullet(default_bullet)

func change_gun_bullet(weapon_bullet) -> void: 
	gun.change_bullet(weapon_bullet)

func add_ability(new_ability: PackedScene):
	ability_manager.add_ability(new_ability)
	
##### Shop Controls functions #####

## Coin Magnet Functions
func increase_magnet_radius(amount): 
	coin_magnet.increase_radius(amount)

func activate_magnet():
	coin_magnet.magnet_enabled = true


## Player Health Functions
func heal_player(amount: int):
	health.health += amount

func increase_health(amount: int): 
	health.max_health += amount
	health.health = health.max_health
