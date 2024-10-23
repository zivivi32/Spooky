extends Node3D
@export var animation: AnimationPlayer
@export_subgroup("SFX")
@export var impact_sound: AudioStream
signal explosion_done

func _ready() -> void:
	animation.play("explosion")
	
	if impact_sound:
		AudioManager.play_sound(impact_sound)
func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	explosion_done.emit()
