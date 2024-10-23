extends BTAction
@export var soundFX: Array[AudioStream]

func _enter() -> void:
	for sfx in soundFX:
		AudioManager.play_sound(sfx)

func _tick(_delta: float) -> Status:
	return SUCCESS
