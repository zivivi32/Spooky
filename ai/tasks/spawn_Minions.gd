extends BTAction

func _enter() -> void:
	#agent.spawn_minions()
	agent.navigation_agent.ClearTarget()
	agent.velocity = Vector3.ZERO
	agent.navigation_agent.Speed = 0
	
func _tick(_delta: float) -> Status:
	return SUCCESS

func _exit() -> void:
	pass
