extends Node3D
class_name Turret
@export_subgroup("Turret Configurations")
@export var model: Node3D
@export var gun: Gun_Weapon
@export var detection: Area3D
@export var turret_lifetime: float = 15
@export var turret_cooldown: float = 30
@export var timer: Timer

@export_subgroup("VFX")
@export var move_vfx_particles: Array[GPUParticles3D]
@export var spawn_particles: GPUParticles3D
@export var death_particles: GPUParticles3D

var target: Enemy

func _ready() -> void:
	#timer.start(turret_lifetime)
	#timer.connect("timeout", die)
	model.scale = Vector3(1.2 ,1.7 ,1.2)
	play_move_vfx()
	if spawn_particles:
		spawn_particles.emitting = true

func die(): 
	model.visible = false
	gun.attack_timer.stop()
	if death_particles:
		death_particles.emitting = true
		await  death_particles.finished
	queue_free()

func _process(delta: float) -> void:
	model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 10)


func play_move_vfx(): 
	if move_vfx_particles: 
		for particles in move_vfx_particles:
			particles.restart()
			particles.emitting = true

func _physics_process(_delta: float) -> void:
	var targets = detection.get_overlapping_bodies()
	if targets.size() > 0: 
		if target != targets.front():
			model.scale = Vector3(1.0 ,1.75,1.0)
			play_move_vfx()
		target = targets.front()
		if gun.attack_timer.is_stopped():
			gun.attack_timer.start()
		update_gun_aim(target.global_position)
	else:
		gun.attack_timer.stop()

func update_gun_aim(target_position : Vector3):
	if target_position == Vector3.ZERO:
		return  # Don't rotate if no valid target

	target_position.y = 0
	model.look_at(target_position, Vector3.UP, true)
	model.rotation.x = 0
	model.rotation.z = 0
