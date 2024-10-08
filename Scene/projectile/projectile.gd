extends Area3D

var direction := Vector3.FORWARD
var rotated_direction
var is_spread: bool = false
var rotate_on_y: float
@export var damage: int = 50
@export var speed: float = 25
@export var max_pierced: int = 1
@export var life_time: float = 3
@export var life_timer: Timer
var bodies_pierced: int = 0

func _ready():
	life_timer.start(life_time)
	life_timer.connect("timeout", queue_free)

func _physics_process(delta):
	global_position += direction * (delta * speed)
	
func _on_body_entered(body):
	if body is Health_System:
		body.damage(damage)
		bodies_pierced += 1
	if bodies_pierced >= max_pierced:
		queue_free()
