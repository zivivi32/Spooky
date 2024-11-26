extends Node3D

@export var wave_spawner: Node3D
@export var wave_move_speed: float = 2
@export var wave_move_timer: Timer
@export var wave_move_wait: float = 2
@export var wave_stop_timer: Timer
@export var wave_stop_wait: float = 2

var can_move: bool = false

func _ready():
	wave_spawner.wave_completed.connect(_on_wave_completed)
	wave_move_timer.connect("timeout", start_movement)
	wave_stop_timer.connect("timeout", stop_movement)
	wave_move_timer.start(wave_move_wait)
	
func start_movement(): 
	can_move = false
	wave_stop_timer.start(wave_stop_wait)
	
func stop_movement(): 
	can_move = true
	wave_move_timer.start(wave_move_wait)

func _on_wave_completed():
	# wave_spawner.increase_difficulty()
	wave_spawner.start_next_wave()

func _process(delta: float) -> void:
	if can_move:
		wave_spawner.global_position.x += wave_move_speed * delta
