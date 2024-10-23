extends Area3D
@export_subgroup("Projectile properties")
@export var damage: int = 50
@export var speed: float = 25
@export var max_pierced: int = 1
@export var life_time: float = 3
@export var life_timer: Timer

@export_subgroup("Explosive projectile properties")
@export var is_explosive: bool = false
@export var explosion_scene: PackedScene
@export var vfx: Array[PackedScene]
@export var visuals: Array[GPUParticles3D]

var bodies_pierced: int = 0
var direction := Vector3.FORWARD
var rotated_direction
var is_spread: bool = false
var rotate_on_y: float

func _ready():
	life_timer.start(life_time)
	life_timer.connect("timeout", queue_free)
	if visuals:
		for fx in visuals:
			fx.emitting = true
	if direction.length() > 0.01:
		look_at(global_position + direction, Vector3.UP, true)  # Rotate to face the direction of movement
	
func _physics_process(delta):
	global_position += direction * (delta * speed)
	#if direction.length() > 0.01:
		#look_at(global_position + direction, Vector3.UP, true)  # Rotate to face the direction of movement
	#


func _on_body_entered(body):
	if body is Health_System:
		body.damage(damage)
		bodies_pierced += 1
	if bodies_pierced >= max_pierced:
		if is_explosive: 
			var explosion = explosion_scene.instantiate()
			get_tree().root.add_child(explosion)
			explosion.global_position = global_position
		queue_free()
