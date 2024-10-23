extends Node3D
@export var wave_music: AudioStreamPlayer
@export var boss_music: AudioStreamPlayer
@export var end_scene: String

func _ready() -> void:
	if end_scene:
		Events.end_game.connect(load_end_screen)

func load_end_screen():
	SceneLoader.load_scene(end_scene)

func start_wave_music(): 
	stop_boss_music()
	if !wave_music.playing:
		wave_music.play()

func start_boss_music(): 
	stop_wave_music()
	if !boss_music.playing:
		boss_music.play()

func stop_wave_music(): 
	if wave_music.playing:
		wave_music.stop()
		
func stop_boss_music(): 
	if boss_music.playing:
		boss_music.stop()


func _on_enemy_spawn_boss_spawn() -> void:
	start_boss_music()


func _on_enemy_spawn_wave_started() -> void:
	start_wave_music()
