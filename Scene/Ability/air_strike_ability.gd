extends Special_Abilities

@export var duration: float = 1
@export var cool_down: float = 10
@export var spawnable: PackedScene

func process_ability(): 
	duration_timer.start(duration)
	var spawns = spawnable.instantiate()
	get_tree().root.add_child(spawns)
	spawns.global_position = Vector3.ZERO
	

func process_cooldown():
	cool_down_timer.start(cool_down)
	cool_down_wait = cool_down
	on_cool_down.emit()
