extends CanvasLayer
@export var level_scene: String
@export var level_music: AudioStreamPlayer

func _ready() -> void:
	level_music.play()

func _on_button_pressed() -> void:
	SceneManager.change_scene(level_scene, {"pattern_enter": "squares", "pattern_leave" : "squares"})
	level_music.stop()
	
