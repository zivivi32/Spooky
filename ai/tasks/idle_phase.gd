extends BTAction

func _enter() -> void:
	agent.navigation_agent.ClearTarget()
	agent.navigation_agent.Speed = 0
	agent.velocity = Vector3.ZERO

func _tick(_delta: float) -> Status:
	agent.reached_target()

	return SUCCESS

func _exit() -> void:
	agent.navigation_agent.can_move = true
