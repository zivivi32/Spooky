# res://addons/cutscene_system/autoload/cutscene_manager.gd
extends Node

signal cutscene_started(cutscene_name: String)
signal cutscene_finished(cutscene_name: String)
signal step_started(step_name: String)
signal step_finished(step_name: String)

var current_cutscene: Cutscene
var current_step_index: int = -1
var is_playing := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	if is_playing and current_step_index >= 0:
		var step = current_cutscene.steps[current_step_index]
		if step._is_complete():
			_advance_to_next_step()

func play_cutscene(cutscene: Cutscene) -> void:
	if is_playing:
		return
		
	current_cutscene = cutscene
	is_playing = true
	current_step_index = -1
	emit_signal("cutscene_started", cutscene.cutscene_name)
	_advance_to_next_step()

func _advance_to_next_step() -> void:
	if current_step_index >= 0:
		emit_signal("step_finished", current_cutscene.steps[current_step_index].step_name)
	
	current_step_index += 1
	
	if current_step_index >= current_cutscene.steps.size():
		_end_cutscene()
		return
		
	var step = current_cutscene.steps[current_step_index]
	step.setup(get_tree())  # Pass the scene tree to the step
	emit_signal("step_started", step.step_name)
	step.execute()

func _end_cutscene() -> void:
	# Reset any necessary steps (like camera priorities)
	for step in current_cutscene.steps:
		if step is CameraStep:
			step.reset()
	
	var cutscene_name = current_cutscene.cutscene_name
	current_cutscene = null
	current_step_index = -1
	is_playing = false
	emit_signal("cutscene_finished", cutscene_name)
