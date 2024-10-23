extends CanvasLayer
@export var level_scene: String

func _on_button_pressed() -> void:
	SceneLoader.load_scene(level_scene)
