extends BTAction
func _enter() -> void:
	agent.start_attack()
	
func _tick(_delta: float) -> Status:
	return SUCCESS
