extends Node3D


@export var bg_music: AudioStreamPlayer

func _ready() -> void:
	bg_music.call_deferred("play")
