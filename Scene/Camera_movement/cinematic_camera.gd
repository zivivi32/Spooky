extends Node3D
@export var phantom_camera: PhantomCamera3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		phantom_camera.set_priority(5)
		body.camera_angle = phantom_camera.rotation_degrees.y


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		phantom_camera.set_priority(0)
		body.camera_angle = GlobalVariables.default_camera_angle
