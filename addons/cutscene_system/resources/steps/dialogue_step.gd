# res://addons/cutscene_system/resources/steps/dialogue_step.gd
extends CutsceneStep
class_name DialogueStep

@export var dialogue_resource: DialogueResource
@export var dialogue_title: String
var _balloon: Node

func execute() -> void:
	var balloon_scene = load("res://Dialogues/balloon.tscn")
	_balloon = balloon_scene.instantiate()
	scene_tree.current_scene.add_child(_balloon)
	_balloon.start(dialogue_resource, dialogue_title)

func _is_complete() -> bool:
	return not is_instance_valid(_balloon)
