extends LimboState

@export_subgroup("State Properties")
@export var followtarget: FollowTarget3D
@export var attack_range: float = 5.0
var player :Node3D 

func _enter() -> void:
	#followtarget.ClearTarget()
	#agent.velocity = Vector3.ZERO
	player = agent.player
	
func _update(delta: float) -> void:
	if is_instance_valid(player):
		if player.global_position.distance_to(agent.global_position) <= attack_range:
			agent.look_at(player.global_position)
			agent.attack()
		else:
			agent.start_chase()

func _exit() -> void:
	agent.playback.travel("Movement")
