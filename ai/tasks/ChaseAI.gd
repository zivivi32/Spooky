extends BTAction
@export var chase_speed: float = 3

func _enter() -> void:
	agent.navigation_agent.ClearTarget()
	agent.get_player()
	agent.navigation_agent.SetTarget(agent.player)
	agent.navigation_agent.Speed = chase_speed
	
func _tick(delta: float) -> Status:
	agent.range_attack()
	return SUCCESS
