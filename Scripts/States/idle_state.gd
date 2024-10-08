extends LimboState
#Idle_State
var state_name = "idle"
@export_subgroup("State Properties")
@export var movement_speed: float = 5.0
var movement_velocity: Vector3

@export_subgroup("Animations properties")
@export var animation_amp: float = 0.1
@export var animation_freq: float = 5.0

func _enter() -> void:
	agent.animations_amp = animation_amp
	agent.animation_freq = animation_freq

func _update(_delta: float) -> void:
	if agent.movement_velocity != Vector3.ZERO:
		get_root().dispatch(EVENT_FINISHED)

	
