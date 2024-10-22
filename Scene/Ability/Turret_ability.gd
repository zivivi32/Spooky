extends Special_Abilities

@export var turret_scene: PackedScene
var turret: Turret

var duration_time: float
var cooldown_time: float

func process_ability(): 
	var mouse_pos = player.update_player_aim()
	
	turret = turret_scene.instantiate()
	cooldown_time = turret.turret_cooldown
	
	get_tree().root.add_child(turret)
	mouse_pos.y = 0
	turret.global_position = mouse_pos
	duration_timer.start(turret.turret_lifetime)
	
	
func process_cooldown():
	cool_down_timer.start(cooldown_time)
	on_cool_down.emit()
	turret.die()
