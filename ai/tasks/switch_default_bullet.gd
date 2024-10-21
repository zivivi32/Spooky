extends BTAction

func _enter() -> void:
	agent.switch_default_bullet()

func _tick(_delta: float) -> Status:
	return SUCCESS
