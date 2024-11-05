# res://addons/cutscene_system/resources/steps/animation_step.gd
extends CutsceneStep
class_name AnimationStep

@export var animation_player_name: String
@export var animation_name: String
@export var return_to_animation: bool = false
@export var return_animation_name: String
var _animation_player: AnimationPlayer

func execute() -> void:
	
	var animation_players = scene_tree.get_nodes_in_group("animation_player")
	for animation_player in animation_players:
			if animation_player.name == animation_player_name:
				_animation_player = animation_player
				break

	if _animation_player:
		_animation_player.play(animation_name)
		await _animation_player.animation_finished
		if return_to_animation:
			_animation_player.play(return_animation_name)

func _is_complete() -> bool:
	if not wait_for_completion:
		return true
	return not _animation_player or not _animation_player.is_playing()
