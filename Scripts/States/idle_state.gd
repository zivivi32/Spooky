extends LimboState
#Idle_State
@export_subgroup("State Properties")
@export var followtarget: FollowTarget3D

func _enter() -> void:
	followtarget.ClearTarget()
	followtarget.Speed = 0

func _update(_delta: float) -> void:
	if agent.velocity != Vector3.ZERO:
		get_root().dispatch(EVENT_FINISHED)

	
