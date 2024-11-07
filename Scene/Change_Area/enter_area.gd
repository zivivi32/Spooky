extends Node3D

@export var interaction_area: InteractionArea
@export var level_change: String
@export var level_name: String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if level_name:
		interaction_area.action_name = level_name
	interaction_area.interact = Callable(self, "change_area")

func change_area(): 
	SceneManager.change_scene(level_change, {"pattern_enter": "squares", "pattern_leave" : "squares"})
