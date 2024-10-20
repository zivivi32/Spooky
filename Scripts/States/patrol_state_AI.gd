extends LimboState
@export_subgroup("State Properties")
@export var random_target_point: RandomTarget3D
@export var followtarget: FollowTarget3D

func _ready() -> void:
	pass
	#followtarget.navigation_finished.connect(choose_next_point)

func choose_next_point() -> void:
	print_debug("Patrol State")
	randomize()
	followtarget.SetFixedTarget(random_target_point.GetNextPoint())
	

func _enter() -> void:
	#choose_next_point()
	followtarget.ClearTarget()
	#followtarget.can_move = true
	followtarget.Speed = agent.speed
	randomize()
	followtarget.SetFixedTarget(random_target_point.GetNextPoint())
