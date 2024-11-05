# res://addons/cutscene_system/resources/steps/camera_step.gd
extends CutsceneStep
class_name CameraStep

@export var camera_name: StringName  # Instead of NodePath, we'll use the camera's name
@export var priority: int = 10
@export var resets: bool = true

var _previous_priority: int
var _camera: Node
var moving_camera_done: bool = false

func execute() -> void:
	# Find the camera by name in the scene
	var cameras = scene_tree.get_nodes_in_group("phantom_camera")  # Assuming PhantomCamera3D nodes are in this group
	if cameras:
		print_debug(cameras)
		for camera in cameras:
			if camera.name == camera_name:
				_camera = camera
				break
		
		if _camera:
			_previous_priority = _camera.priority
			_camera.set_priority(priority)
			await _camera.tween_completed
			moving_camera_done = true
	else:
		print_debug("No cameras found")

func _is_complete() -> bool:
	return moving_camera_done

func reset() -> void:
	if resets:
		if _camera:
			_camera.set_priority(_previous_priority)
