extends BTAction
func _enter() -> void:
	agent.stop_attack()
	
func _tick(_delta: float) -> Status:
	return SUCCESS
