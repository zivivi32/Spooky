extends Area3D
@export var health: Health_System
@export var model_mesh: Node3D
@export var death_sfx: Array[AudioStream]
@export var death_particles: GPUParticles3D
@export var damage_on_contact: int = 30

signal destroyed
func _ready() -> void:
	health.connect("death", death)

func death() -> void:
	destroyed.emit()
	if death_sfx:
		for sfx in death_sfx:
			AudioManager.play_sound(sfx)
	
	if death_particles:
		
		model_mesh.visible = false
		health.set_deferred("monitoring", false)
		health.set_deferred("monitorable", false)
		set_collision_layer_value(1, false)
		set_collision_layer_value(4, false)
		
		death_particles.emitting = true
		await  death_particles.finished

	queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.health.damage(damage_on_contact)
