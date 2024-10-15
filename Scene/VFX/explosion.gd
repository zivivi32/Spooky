extends Node3D
@export var animation: AnimationPlayer

signal explosion_done

func _ready() -> void:
	animation.play("explosion")
	
func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	explosion_done.emit()
