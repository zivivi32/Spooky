extends GPUParticles3D

func _ready() -> void:
	emitting = true
	connect("finished", queue_free)
