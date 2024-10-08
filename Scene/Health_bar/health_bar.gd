extends ProgressBar

class_name HealthBar
@export var timer:Timer
@export var damagebar : ProgressBar

var health = 0 : set = _set_health


func _set_health(new_health):
	var prev_health = health
	health = min(max_value, new_health)
	value = health
	
	if health < prev_health:
		timer.start()
	else: 
		damagebar.value = health
	

func init_health(_health):
	health = _health
	max_value = _health
	value = _health
	damagebar.max_value = _health
	damagebar.value = _health 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_timer_timeout():
	damagebar.value = health
