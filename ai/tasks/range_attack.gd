extends BTAction

@export var bullet_count: int = 10

func _enter() -> void:
	agent.weapon.bullet_count = bullet_count
	agent.range_attack()
	agent.navigation_agent.ClearTarget()
	agent.velocity = Vector3.ZERO
	agent.navigation_agent.Speed = 0
	
func _tick(_delta: float) -> Status:
	return SUCCESS

func _exit() -> void:
	agent.weapon.bullet_count = agent.bullet_count
