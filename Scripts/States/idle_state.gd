extends LimboState
#Idle_State
@export_subgroup("State Properties")
@export var followtarget: FollowTarget3D

func _enter() -> void:
	followtarget.ClearTarget()
	agent.movement_velocity = Vector3.ZERO

func _update(_delta: float) -> void:
	if agent.movement_velocity != Vector3.ZERO:
		get_root().dispatch(EVENT_FINISHED)

	
