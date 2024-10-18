extends Node3D
class_name Turret
@export_subgroup("Turret Configurations")
@export var model: Node3D
@export var gun: Gun_Weapon
@export var detection: Area3D
@export var turret_lifetime: float = 15
@export var timer: Timer

@export_subgroup("VFX")
@export var spawn_particles: GPUParticles3D
@export var death_particles: GPUParticles3D

var target: Enemy

func _ready() -> void:
	timer.start(turret_lifetime)
	timer.connect("timeout", die)
	
	if spawn_particles:
		spawn_particles.emitting = true

func die(): 
	model.visible = false
	gun.attack_timer.stop()
	if death_particles:
		death_particles.emitting = true
		await  death_particles.finished
	queue_free()

func _physics_process(_delta: float) -> void:
	var targets = detection.get_overlapping_bodies()
	if targets.size() > 0: 
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
	gun.look_at(target_position, Vector3.UP, true)
	gun.rotation.x = 0
	gun.rotation.z = 0
