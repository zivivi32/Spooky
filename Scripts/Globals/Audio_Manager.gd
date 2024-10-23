extends Node
class_name Global_Audio_Manager

func play_sound(stream: AudioStream, volume: float = 0.0): 
	var instance = AudioStreamPlayer.new()
	instance.bus = "SFX"
	instance.stream = stream
	instance.volume_db = volume
	instance.finished.connect(remove_node.bind(instance))
	add_child(instance)
	instance.play()
	
func remove_node(instance: AudioStreamPlayer):
	instance.queue_free()
