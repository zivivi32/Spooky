extends Area3D
class_name Coin

@export var model: Node3D
@export var vfx: GPUParticles3D
@export var amount: int = 1
@export var life_time: float = 5
@export var timer: Timer
@export var movement_speed: float = 5.0
@export var collect_sfx: Array[AudioStream]

var is_moving: bool = false
var target_player: Player

func _ready() -> void:
	timer.connect("timeout", disappear)
	timer.start(life_time)

func disappear() -> void:
	set_collision_layer_value(6, false)
	set_collision_mask_value(2, false)
	model.visible = false	
	if vfx:
		vfx.emitting = true
		await vfx.finished
	queue_free()

func collected(player: Player) -> void: 
	player.coins += amount
	if collect_sfx:
		for sfx in collect_sfx:
			AudioManager.play_sound(sfx, -5.0)
	disappear()

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		collected(body)

##### COIN MAGNET FUNCTIONS ########

# Start moving the coin towards the player
func start_moving_towards_player(player: Player) -> void:
	is_moving = true
	target_player = player

# Stop moving the coin
func stop_moving() -> void:
	is_moving = false
	target_player = null

# Called every frame to update the coin's position
func _process(delta: float) -> void:
	if is_moving and target_player:
		move_towards_player(delta)

# Move the coin towards the player
func move_towards_player(delta: float) -> void:
	var direction: Vector3 = global_transform.origin.direction_to(target_player.global_transform.origin)
	global_transform.origin += direction * movement_speed * delta
	
	# If the coin is close enough to the player, collect it
	var distance: float = global_transform.origin.distance_to(target_player.global_transform.origin)
	if distance < 1.0:
		collected(target_player)
