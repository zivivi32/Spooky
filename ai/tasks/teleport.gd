extends BTAction
@export var teleport_back: bool = true

func _enter() -> void:
	agent.teleport(teleport_back)
	agent.navigation_agent.ClearTarget()
	agent.velocity = Vector3.ZERO
	agent.navigation_agent.Speed = 0
	
func _tick(_delta: float) -> Status:
	return SUCCESS

func _exit() -> void:
	pass
