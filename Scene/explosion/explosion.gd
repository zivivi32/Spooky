extends Area3D
@export var damage: int = 100
@export var gpu_particle: GPUParticles3D
@export var time_life: float = 0.5
@export var timer: Timer
@export var explosion_visual: PackedScene

func _ready() -> void:
	
	if timer: 
		timer.connect("timeout", no_monitoring)
		timer.start(time_life)

	if gpu_particle: 
		gpu_particle.connect("finished", queue_free)
		gpu_particle.emitting = true
		
	Events.emit_signal("fx_screen_shake", 0.1, 1)

func no_monitoring():
	monitoring = false

func _on_body_entered(body):
	if body is Health_System:
		body.damage(damage)


func _on_vfx_explosion_explosion_done() -> void:
	queue_free()
