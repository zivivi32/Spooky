extends BTAction

func _enter() -> void:
	agent.spawn_minions()
	agent.navigation_agent.ClearTarget()
	agent.velocity = Vector3.ZERO
	agent.navigation_agent.Speed = 0
	
func _tick(delta: float) -> Status:
	return SUCCESS
