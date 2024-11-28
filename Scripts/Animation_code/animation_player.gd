extends Node


@export var animation_player: AnimationPlayer

func _ready() -> void:
	animation_player.connect("animation_finished", die)

func die(animation):
	queue_free()
