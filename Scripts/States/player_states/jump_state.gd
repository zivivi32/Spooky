extends LimboState
@export var jump_strength: float = 8


func _enter() -> void:
	jump()
	get_root().dispatch(EVENT_FINISHED)

func jump() -> void: 
	if agent.jump_single or agent.jump_double:
		pass
		#Audio.play("sounds/jump_a.ogg, sounds/jump_b.ogg, sounds/jump_c.ogg")
	
	if agent.jump_double:
		agent.gravity = -jump_strength
		agent.jump_double = false
		
	if(agent.jump_single): agent.action_jump(jump_strength)
