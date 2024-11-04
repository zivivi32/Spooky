# res://addons/cutscene_system/resources/steps/cutscene_step.gd
extends Resource
class_name CutsceneStep

@export var step_name: String
@export var wait_for_completion: bool = true

var scene_tree: SceneTree

func setup(tree: SceneTree) -> void:
	scene_tree = tree

func execute() -> void:
	pass

func _is_complete() -> bool:
	return true
