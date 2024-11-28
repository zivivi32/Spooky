extends BTAction
@export var use_agent_function: bool = false
func _enter() -> void:
	if use_agent_function:
		agent.spawn_minions()
	agent.navigation_agent.ClearTarget()
	agent.velocity = Vector3.ZERO
	agent.navigation_agent.Speed = 0
	
func _tick(_delta: float) -> Status:
	return SUCCESS

func _exit() -> void:
	pass
