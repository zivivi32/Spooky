# res://addons/cutscene_system/plugin.gd
@tool
extends EditorPlugin

func _enter_tree() -> void:
	# Register custom resources
	add_custom_type("CutsceneStep", "Resource", preload("res://addons/cutscene_system/resources/steps/cutscene_step.gd"), null)
	add_custom_type("DialogueStep", "Resource", preload("res://addons/cutscene_system/resources/steps/dialogue_step.gd"), null)
	add_custom_type("CameraStep", "Resource", preload("res://addons/cutscene_system/resources/steps/camera_step.gd"), null)
	add_custom_type("AnimationStep", "Resource", preload("res://addons/cutscene_system/resources/steps/animation_step.gd"), null)
	add_custom_type("Cutscene", "Resource", preload("res://addons/cutscene_system/resources/cutscene.gd"), null)
	
	# Add autoload singleton
	add_autoload_singleton("CutsceneManager", "res://addons/cutscene_system/autoload/cutscene_manager.gd")

func _exit_tree() -> void:
	# Clean up custom resources
	remove_custom_type("CutsceneStep")
	remove_custom_type("DialogueStep")
	remove_custom_type("CameraStep")
	remove_custom_type("AnimationStep")
	remove_custom_type("Cutscene")
	
	# Remove autoload singleton
	remove_autoload_singleton("CutsceneManager")
