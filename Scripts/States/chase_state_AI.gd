extends LimboState
@export_subgroup("State Properties")
@export var followtarget: FollowTarget3D

func _enter() -> void:
	followtarget.SetTarget(agent.player)
	agent.playback.travel("Movement")
func _exit() -> void:
	pass
