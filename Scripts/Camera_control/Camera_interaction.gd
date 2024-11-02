extends Node3D

@export var area_pcam: PhantomCamera3D
@export var interaction_area: InteractionArea
@export var hub_shop: CanvasLayer
var initial_camera_position: Vector3
var initial_camera_rotation: Vector3

var tween: Tween
var tween_duration: float = 0.9


func _ready() -> void:
	interaction_area.interact = Callable(self, "_entered_area")
	Events.connect("shop_done", shop_end)

func _entered_area() -> void:
	area_pcam.set_priority(20)
	#await get_tree().create_timer(2).timeout
	await area_pcam.tween_completed
	Events.shop_open.emit()
	hub_shop.show()
	
	#area_pcam.set_priority(0)
	
func shop_end():
	area_pcam.set_priority(0)
