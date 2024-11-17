extends PathFollow3D

@export var speed = 0.1
@export var easy_wave_configurations: WaveData
@export var medium_wave_configurations: WaveData
@export var hard_wave_configurations: WaveData
signal restart

var is_wave_comlete : bool = false
func _process(delta):
	progress_ratio += (speed/2) * delta
	if progress_ratio >= 0.9:
		restart.emit()
		progress_ratio = 0.0
		

func _on_invaders_spawner_wave_completed() -> void:
	is_wave_comlete = true
	


func _on_invaders_spawner_all_waves_completed() -> void:
	#$Invaders_Spawner.current_wave = 0
	is_wave_comlete = true


func _on_restart() -> void:
	if is_wave_comlete:
		$Invaders_Spawner.current_wave = 0
		$Invaders_Spawner.start_next_wave()
		is_wave_comlete = false
		


func _on_enemy_spawn_easy_wave_signal() -> void:
	##Easy Mode
	$Invaders_Spawner.waves.clear()
	$Invaders_Spawner.waves.append(easy_wave_configurations)

func _on_enemy_spawn_hard_wave_signal() -> void:
	$Invaders_Spawner.waves.clear()
	$Invaders_Spawner.waves.append(easy_wave_configurations)


func _on_enemy_spawn_medium_wave_signal() -> void:
	$Invaders_Spawner.waves.clear()
	$Invaders_Spawner.waves.append(easy_wave_configurations)