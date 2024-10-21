extends LimboState

@export var death_particles: GPUParticles3D

@export_subgroup("Loot configurations")
@export var nav_region: NavigationRegion3D
@export var has_loot: bool = true
@export var loot: Array[PackedScene]
@export var min_spawn_loot: int = 2
@export var max_spawn_loot: int = 5
@export var spawn_radius_loot: float = 3

func _enter() -> void:
	if has_loot:
		agent.spawn_loot()
	if death_particles:
		
		agent.model_mesh.visible = false
		agent.hsm.set_active(false)
		agent.navigation_agent.ClearTarget()
		agent.health.set_deferred("monitoring", false)
		agent.health.set_deferred("monitorable", false)
		agent.set_collision_layer_value(1, false)
		agent.set_collision_layer_value(4, false)
		agent.velocity = Vector3.ZERO
		
		death_particles.emitting = true
		await  death_particles.finished
		
	agent.queue_free()
