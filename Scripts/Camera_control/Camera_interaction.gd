extends Node3D

@export var area_pcam: PhantomCamera3D
@export var interaction_area: InteractionArea
var initial_camera_position: Vector3
var initial_camera_rotation: Vector3

var tween: Tween
var tween_duration: float = 0.9


func _ready() -> void:
	interaction_area.interact = Callable(self, "_entered_area")

func _entered_area() -> void:
	area_pcam.set_priority(20)
	await get_tree().create_timer(3).timeout
	area_pcam.set_priority(0)
	
func _exited_area(body) -> void:
	if body is Player:
		area_pcam.set_priority(0)
		body.interaction(true)
