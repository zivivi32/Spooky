extends Node3D

@export_subgroup("Gun Properties")
@export var bullet_scene: PackedScene
@export var bullet_count: int = 1
@export var bullet_speed: float = 25
@export var spawn_pos: Marker3D
@export_range(0, 360) var arc: float = 60
@export var timer_count: float = 0.5
@export var is_ai: bool = false
var rotation_direction: float
var can_shoot: bool = true

@export var attack_timer: Timer


func _ready() -> void:
	attack_timer.wait_time = timer_count
	if !is_ai:
		attack_timer.connect("timeout", shoot)

func _process(delta: float) -> void:
	scale = scale.lerp(Vector3(1, 1, 1), delta * 10)

func shoot() -> void: 
	if can_shoot:
		can_shoot = false
		scale = Vector3(1.2 ,1.2 ,1.2)
		
		var arc_rad = deg_to_rad(arc)
		var increment = arc_rad / max(1, bullet_count - 1)

		for i in bullet_count:
			var bullet = bullet_scene.instantiate()
			bullet.speed = bullet_speed

			# Calculate the spread angle for this bullet
			var angle_offset = (increment * i) - (arc_rad / 2)

			if bullet_count == 1:
				bullet.direction = global_transform.basis.z
				bullet.rotation = spawn_pos.global_rotation
			else:
				# Apply rotation to the direction vector to create the spread
				var spread_direction = global_transform.basis.z.rotated(Vector3.UP, angle_offset)
				bullet.direction = spread_direction.normalized()

			# Add the bullet to the scene
			get_tree().root.add_child(bullet)
			bullet.global_position = spawn_pos.global_position

			#Events.emit_signal("fx_screen_shake")

		#await get_tree().create_timer(1/fire_rate).timeout
		can_shoot = true
