extends Node3D
@export var wave_spawner: WaveSpawner

func _ready():
	wave_spawner.wave_completed.connect(_on_wave_completed)
	#wave_spawner.all_waves_completed.connect(_on_game_won)
	#wave_spawner.enemy_destroyed.connect(_on_enemy_killed)

func _on_wave_completed():
	#wave_spawner.increase_difficulty()
	wave_spawner.start_next_wave()


func _on_timer_timeout() -> void:
	wave_spawner.global_position.x += 1
