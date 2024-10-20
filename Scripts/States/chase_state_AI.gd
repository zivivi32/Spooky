extends LimboState
@export_subgroup("State Properties")
@export var followtarget: FollowTarget3D
@export var chase_speed: float = 3

func _enter() -> void:
	followtarget.ClearTarget()
	agent.player = get_tree().get_first_node_in_group("player")
	followtarget.SetTarget(agent.player)
	followtarget.Speed = chase_speed
	agent.playback.travel("Movement")
func _exit() -> void:
	pass
