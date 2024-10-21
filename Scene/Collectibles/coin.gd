extends Area3D
@export var model: Node3D
@export var vfx: GPUParticles3D
@export var amount : int = 1
@export var life_time: float = 5
@export var timer: Timer

func _ready() -> void:
	timer.connect("timeout", disappear)
	timer.start(life_time)

func disappear():
	set_collision_mask_value(2, false)
	model.visible = false	
	if vfx:
		vfx.emitting = true
		await vfx.finished
	queue_free()


func collected(player): 
	player.coins += amount
	disappear()
func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		collected(body)
