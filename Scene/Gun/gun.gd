extends Node3D

class_name Gun_Weapon

@export_subgroup("Gun Properties")
@export var bullet_scene: PackedScene
@export var model: Node3D
@export var bullet_count: int = 1
@export var max_spread: int = 3
@export var bullet_speed: float = 25
@export var spawn_pos: Marker3D
@export_range(0, 360) var arc: float = 60
@export var timer_count: float = 0.5
@export var is_ai: bool = false
var rotation_direction: float
var can_shoot: bool = true
var extra_damage: int = 0
@export var attack_timer: Timer


@export_subgroup("VFX")
@export var muzzle_flash : PackedScene
@export var flash_particles: Array[GPUParticles3D]

@export_subgroup("SFX")
@export var sfx: Array[AudioStream]
@export var volume: float = 0.0

func _ready() -> void:
	attack_timer.wait_time = timer_count
	
	if !is_ai:
		attack_timer.connect("timeout", shoot)

func _process(delta: float) -> void:
	model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 10)

func increase_bullet_count(new_count): 
	bullet_count += new_count
	if bullet_count >= max_spread:
		bullet_count = max_spread

func shoot() -> void: 
	if can_shoot:
		can_shoot = false
		model.scale = Vector3(1.2 ,1.2 ,1.2)
		
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
				
			bullet.damage += extra_damage
			# Add the bullet to the scene
			get_tree().root.add_child(bullet)
			bullet.global_position = spawn_pos.global_position
			
			if muzzle_flash: 
				var vfx = muzzle_flash.instantiate()
				get_tree().root.add_child(vfx)
				vfx.global_position = spawn_pos.global_position
				
			if flash_particles: 
				for vfx in flash_particles:
					vfx.emitting = true
			#Events.emit_signal("fx_screen_shake")
		if sfx:
			for sound in sfx: 
				AudioManager.play_sound(sound, volume)

		#await get_tree().create_timer(1/fire_rate).timeout
		can_shoot = true

func change_bullet(new_bullet: PackedScene) -> void:
	bullet_scene = new_bullet
