extends Node3D

#@onready var fire_amber = %FireAmber
@export var fire_amber: GPUParticles3D
func _ready():
	fire_amber.emitting = true
	var queue_timer = get_tree().create_timer(1.0)
	queue_timer.connect("timeout", queue_free)
