extends LimboState
@export_subgroup("State Properties")
@export var random_target_point: RandomTarget3D
@export var followtarget: FollowTarget3D

func _ready() -> void:
	pass
	#followtarget.navigation_finished.connect(choose_next_point)

func choose_next_point() -> void:
	if !agent.player:
		agent.last_position = Vector3.ZERO
		randomize()
		followtarget.SetFixedTarget(random_target_point.GetNextPoint())
	

func _enter() -> void:
	if !agent.last_position:
		choose_next_point()
	else: 
		followtarget.SetFixedTarget(agent.last_position)
