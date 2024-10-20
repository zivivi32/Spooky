extends BTAction
@export var target_var: StringName = &"target"

func _enter() -> void:
	agent.patrol()
	#agent.hsm.dispatch("patrol")
	
func _tick(_delta: float) -> Status:
	return SUCCESS
